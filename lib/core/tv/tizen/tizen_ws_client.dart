import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Pairing-related events emitted while [TizenWsClient.connect] runs.
enum TizenPairingState {
  /// The TV is showing an on-screen "Allow [app] to connect?" prompt.
  awaitingPrompt,

  /// The connection was approved (or silently accepted via a stored token).
  connected,

  /// The connection was explicitly rejected on the TV.
  unauthorized,
}

/// Low-level client for Samsung Tizen's remote-control WebSocket API.
///
/// Connects to `wss://<ip>:8002/api/v2/channel/samsung.remote.control`
/// (falling back to `ws://<ip>:8001` on older TVs), waits for the TV to
/// accept the connection (which may require an on-screen prompt the first
/// time), and lets callers send remote-key presses and app-launch requests.
class TizenWsClient {
  TizenWsClient(this.ipAddress, {this.appName = 'TV Remote'});

  final String ipAddress;
  final String appName;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  final _pairingController = StreamController<TizenPairingState>.broadcast();

  /// Emits pairing-handshake progress; see [TizenPairingState].
  Stream<TizenPairingState> get pairingUpdates => _pairingController.stream;

  /// Connects and waits for the TV to accept the connection.
  ///
  /// Returns the session token to persist (unchanged from [token] if no new
  /// token was issued). Throws if the connection is rejected or times out
  /// waiting for the on-screen prompt to be accepted.
  Future<String?> connect(String? token) async {
    final name = base64Url.encode(utf8.encode(appName));
    final tokenParam = token != null ? '&token=$token' : '';
    final path =
        '/api/v2/channel/samsung.remote.control?name=$name$tokenParam';

    _channel = await _openSocket(path);

    final completer = Completer<String?>();
    final promptTimer = Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        _pairingController.add(TizenPairingState.awaitingPrompt);
      }
    });

    _subscription = _channel!.stream.listen(
      (raw) {
        final message = jsonDecode(raw as String) as Map<String, Object?>;
        final event = message['event'] as String?;
        switch (event) {
          case 'ms.channel.connect':
            final data = message['data'] as Map<String, Object?>?;
            final newToken = data?['token'] as String?;
            _pairingController.add(TizenPairingState.connected);
            if (!completer.isCompleted) completer.complete(newToken ?? token);
          case 'ms.channel.unauthorized' || 'ms.channel.timeOut':
            _pairingController.add(TizenPairingState.unauthorized);
            if (!completer.isCompleted) {
              completer.completeError(StateError('Connection rejected by TV'));
            }
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(const SocketException('Connection closed'));
        }
      },
      onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 60));
    } finally {
      promptTimer.cancel();
    }
  }

  Future<WebSocketChannel> _openSocket(String path) async {
    final secureClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    final secure = IOWebSocketChannel.connect(
      'wss://$ipAddress:8002$path',
      customClient: secureClient,
      connectTimeout: const Duration(seconds: 5),
    );
    try {
      await secure.ready;
      return secure;
    } catch (_) {
      // Older Tizen TVs only serve the unencrypted endpoint.
    }

    final plain = IOWebSocketChannel.connect(
      'ws://$ipAddress:8001$path',
      connectTimeout: const Duration(seconds: 5),
    );
    await plain.ready;
    return plain;
  }

  /// Sends a single remote-control key press, e.g. `KEY_POWER`, `KEY_HOME`.
  void sendKey(String keyCode) {
    _send({
      'method': 'ms.remote.control',
      'params': {
        'Cmd': 'Click',
        'DataOfCmd': keyCode,
        'Option': 'false',
        'TypeOfRemote': 'SendRemoteKey',
      },
    });
  }

  /// Types [text] into the TV's focused text field, replacing its current
  /// contents. Samsung accepts the whole string base64-encoded via the
  /// `SendInputString` remote command.
  void sendInputString(String text) {
    _send({
      'method': 'ms.remote.control',
      'params': {
        'Cmd': base64.encode(utf8.encode(text)),
        'DataOfCmd': 'base64',
        'TypeOfRemote': 'SendInputString',
      },
    });
  }

  /// Requests that the TV launch the app identified by [appId].
  void launchApp(String appId) {
    _send({
      'method': 'ms.channel.emit',
      'params': {
        'event': 'ed.apps.launch',
        'to': 'host',
        'data': {'appId': appId, 'action_type': 'DEEP_LINK'},
      },
    });
  }

  void _send(Map<String, Object?> message) {
    final channel = _channel;
    if (channel == null) throw StateError('Not connected');
    channel.sink.add(jsonEncode(message));
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
  }
}
