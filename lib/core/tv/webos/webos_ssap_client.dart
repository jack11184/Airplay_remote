import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'webos_manifest.dart';

/// Pairing-related events emitted while [WebOsSsapClient.register] runs.
enum WebOsPairingState {
  /// The TV is showing an on-screen "Allow this device to connect?" prompt.
  awaitingPrompt,

  /// Registration succeeded; a `client-key` has been issued.
  registered,
}

/// Low-level client for LG webOS's SSAP (Second Screen App Protocol).
///
/// Connects over WebSocket (`wss://<ip>:3001`, falling back to
/// `ws://<ip>:3000` on older TVs), performs the registration handshake, and
/// lets callers send `ssap://` requests and await their JSON responses.
class WebOsSsapClient {
  WebOsSsapClient(this.ipAddress);

  final String ipAddress;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  int _nextId = 0;
  final _pending = <String, Completer<Map<String, Object?>>>{};

  final _pairingController =
      StreamController<WebOsPairingState>.broadcast();

  /// Emits pairing-handshake progress; see [WebOsPairingState].
  Stream<WebOsPairingState> get pairingUpdates => _pairingController.stream;

  String? _registerRequestId;
  Completer<String>? _registrationCompleter;

  /// Opens the WebSocket connection to the TV.
  Future<void> connect() async {
    _channel = await _openSocket();
    _subscription = _channel!.stream.listen(
      _handleMessage,
      onDone: _handleDone,
      onError: (_) => _handleDone(),
    );
  }

  Future<WebSocketChannel> _openSocket() async {
    final secureClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    final secure = IOWebSocketChannel.connect(
      'wss://$ipAddress:3001',
      customClient: secureClient,
      connectTimeout: const Duration(seconds: 5),
    );
    try {
      await secure.ready;
      return secure;
    } catch (_) {
      // Older webOS TVs only serve the unencrypted endpoint.
    }

    final plain = IOWebSocketChannel.connect(
      'ws://$ipAddress:3000',
      connectTimeout: const Duration(seconds: 5),
    );
    await plain.ready;
    return plain;
  }

  /// Runs the registration handshake, reusing [clientKey] if it was issued
  /// on a previous connection. Returns the client-key to persist (unchanged
  /// if [clientKey] was accepted as-is).
  ///
  /// While the TV shows its on-screen pairing prompt, [pairingUpdates]
  /// emits [WebOsPairingState.awaitingPrompt].
  Future<String> register(String? clientKey) {
    final id = _newId();
    _registerRequestId = id;
    final completer = Completer<String>();
    _registrationCompleter = completer;

    _send({
      'type': 'register',
      'id': id,
      'payload': {
        'forcePairing': false,
        'pairingType': 'PROMPT',
        'manifest': webOsManifest,
        'client-key': ?clientKey,
      },
    });

    return completer.future.timeout(const Duration(seconds: 60));
  }

  /// Sends `ssap://[uri]` with [payload] and returns the response payload.
  Future<Map<String, Object?>> request(
    String uri, [
    Map<String, Object?>? payload,
  ]) {
    final id = _newId();
    final completer = Completer<Map<String, Object?>>();
    _pending[id] = completer;

    _send({
      'type': 'request',
      'id': id,
      'uri': uri,
      'payload': payload ?? const {},
    });

    return completer.future.timeout(const Duration(seconds: 10));
  }

  void _send(Map<String, Object?> message) {
    final channel = _channel;
    if (channel == null) throw StateError('Not connected');
    channel.sink.add(jsonEncode(message));
  }

  void _handleMessage(dynamic raw) {
    final message = jsonDecode(raw as String) as Map<String, Object?>;
    final id = message['id'] as String?;
    final type = message['type'] as String?;
    final payload =
        (message['payload'] as Map<String, Object?>?) ?? const {};

    if (id == _registerRequestId) {
      _handleRegistrationMessage(type, payload);
      return;
    }

    final pending = _pending.remove(id);
    if (pending == null) return;
    if (type == 'error') {
      pending.completeError(StateError(
        message['error'] as String? ?? 'Request failed',
      ));
    } else {
      pending.complete(payload);
    }
  }

  void _handleRegistrationMessage(
    String? type,
    Map<String, Object?> payload,
  ) {
    switch (type) {
      case 'response':
        if (payload['pairingType'] == 'PROMPT') {
          _pairingController.add(WebOsPairingState.awaitingPrompt);
        }
      case 'registered':
        final key = payload['client-key'] as String;
        _registerRequestId = null;
        _pairingController.add(WebOsPairingState.registered);
        _registrationCompleter?.complete(key);
        _registrationCompleter = null;
      case 'error':
        _registerRequestId = null;
        _registrationCompleter?.completeError(
          StateError('Registration failed'),
        );
        _registrationCompleter = null;
    }
  }

  void _handleDone() {
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(const SocketException('Connection closed'));
      }
    }
    _pending.clear();

    final registration = _registrationCompleter;
    if (registration != null && !registration.isCompleted) {
      registration.completeError(const SocketException('Connection closed'));
    }
    _registrationCompleter = null;
  }

  String _newId() => 'req_${_nextId++}';

  Future<void> close() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
  }
}
