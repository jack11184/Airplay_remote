import 'dart:async';

import '../../../models/command_result.dart';
import '../../../models/tv_app.dart';
import '../../../models/tv_connection_state.dart';
import '../../../models/tv_device.dart';
import '../../../models/tv_device_info.dart';
import '../../../models/tv_input.dart';
import '../tv_controller.dart';
import 'tizen_rest_client.dart';
import 'tizen_ws_client.dart';

/// [TvController] for Samsung Tizen TVs over the remote-control WebSocket
/// API.
///
/// The first connection requires the user to accept an on-screen prompt;
/// the resulting session token is emitted via [pairingKeyUpdates] so it can
/// be persisted and reused for silent reconnects.
class TizenController implements TvController {
  TizenController(
    this.device, {
    TizenWsClient? client,
    TizenRestClient? restClient,
  })  : _client = client ?? TizenWsClient(device.ipAddress),
        _restClient = restClient ?? TizenRestClient(device.ipAddress);

  @override
  final TvDevice device;

  final TizenWsClient _client;
  final TizenRestClient _restClient;

  StreamSubscription<TizenPairingState>? _pairingSub;

  final _connectionStateController =
      StreamController<TvConnectionState>.broadcast();
  final _pairingKeyController = StreamController<String>.broadcast();

  @override
  Stream<TvConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<String> get pairingKeyUpdates => _pairingKeyController.stream;

  @override
  Future<void> connect() async {
    _connectionStateController.add(TvConnectionState.connecting);

    _pairingSub = _client.pairingUpdates.listen((state) {
      if (state == TizenPairingState.awaitingPrompt) {
        _connectionStateController
            .add(TvConnectionState.awaitingPairingConfirmation);
      }
    });

    try {
      final token = await _client.connect(device.pairingKey);
      if (token != null && token != device.pairingKey) {
        _pairingKeyController.add(token);
      }
      _connectionStateController.add(TvConnectionState.connected);
    } catch (e) {
      _connectionStateController.add(TvConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<CommandResult> submitPairingCode(String code) async =>
      CommandResult.failure(
        'Samsung pairs via the on-screen prompt, not a code.',
      );

  @override
  Future<void> disconnect() async {
    await _pairingSub?.cancel();
    await _client.close();
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(TvConnectionState.disconnected);
      await _connectionStateController.close();
    }
    if (!_pairingKeyController.isClosed) {
      await _pairingKeyController.close();
    }
  }

  CommandResult _sendKey(String keyCode) {
    try {
      _client.sendKey(keyCode);
      return CommandResult.ok();
    } catch (e) {
      return CommandResult.failure('$e');
    }
  }

  @override
  Future<CommandResult> sendPower() => Future.value(_sendKey('KEY_POWER'));

  @override
  Future<CommandResult> sendVolumeUp() => Future.value(_sendKey('KEY_VOLUP'));

  @override
  Future<CommandResult> sendVolumeDown() =>
      Future.value(_sendKey('KEY_VOLDOWN'));

  @override
  Future<CommandResult> sendMute() => Future.value(_sendKey('KEY_MUTE'));

  @override
  Future<CommandResult> sendDirection(DPadDirection direction) {
    final key = switch (direction) {
      DPadDirection.up => 'KEY_UP',
      DPadDirection.down => 'KEY_DOWN',
      DPadDirection.left => 'KEY_LEFT',
      DPadDirection.right => 'KEY_RIGHT',
    };
    return Future.value(_sendKey(key));
  }

  @override
  Future<CommandResult> sendSelect() => Future.value(_sendKey('KEY_ENTER'));

  @override
  Future<CommandResult> sendHome() => Future.value(_sendKey('KEY_HOME'));

  @override
  Future<CommandResult> sendBack() => Future.value(_sendKey('KEY_RETURN'));

  @override
  Future<CommandResult> sendNumber(int digit) =>
      Future.value(_sendKey('KEY_$digit'));

  @override
  Future<CommandResult> sendPlayPause() => Future.value(_sendKey('KEY_PLAY'));

  @override
  Future<CommandResult> sendRewind() => Future.value(_sendKey('KEY_REWIND'));

  @override
  Future<CommandResult> sendFastForward() => Future.value(_sendKey('KEY_FF'));

  @override
  Future<List<TvApp>?> listApps() async => null;

  @override
  Future<CommandResult> launchApp(TvApp app) async {
    try {
      _client.launchApp(app.id);
      return CommandResult.ok();
    } catch (e) {
      return CommandResult.failure('$e');
    }
  }

  @override
  Future<List<TvInput>?> listInputs() async => null;

  @override
  Future<CommandResult> selectInput(TvInput input) =>
      Future.value(_sendKey(input.id));

  @override
  Future<CommandResult> sendInput() => Future.value(_sendKey('KEY_SOURCE'));

  @override
  bool get supportsKeyboard => true;

  @override
  bool get keyboardIsIncremental => false;

  @override
  Future<CommandResult> sendText(String text) async {
    try {
      _client.sendInputString(text);
      return CommandResult.ok();
    } catch (e) {
      return CommandResult.failure('$e');
    }
  }

  @override
  Future<CommandResult> sendKeyboardBackspace() =>
      Future.value(_sendKey('KEY_DELETE'));

  @override
  Future<CommandResult> sendKeyboardEnter() =>
      Future.value(_sendKey('KEY_ENTER'));

  @override
  Future<TvDeviceInfo> getDeviceInfo() => _restClient.getDeviceInfo();
}
