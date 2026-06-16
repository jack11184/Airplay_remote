import 'dart:async';

import '../../../models/command_result.dart';
import '../../../models/tv_app.dart';
import '../../../models/tv_connection_state.dart';
import '../../../models/tv_device.dart';
import '../../../models/tv_device_info.dart';
import '../../../models/tv_input.dart';
import '../tv_controller.dart';
import 'vizio_app_catalog.dart';
import 'vizio_key_codes.dart';
import 'vizio_smartcast_client.dart';

/// [TvController] for Vizio SmartCast TVs over the SmartCast HTTPS API.
///
/// First-time pairing is PIN-based: the TV shows a code that the user types
/// into the app via [submitPairingCode]. The resulting AUTH token is emitted
/// through [pairingKeyUpdates] for persistence and silent reconnection.
class VizioController implements TvController {
  VizioController(this.device, {VizioSmartCastClient? client})
      : _client = client ??
            VizioSmartCastClient(device.ipAddress, authToken: device.pairingKey);

  @override
  final TvDevice device;

  final VizioSmartCastClient _client;

  final _connectionStateController =
      StreamController<TvConnectionState>.broadcast();
  final _pairingKeyController = StreamController<String>.broadcast();

  VizioPairingChallenge? _challenge;
  Completer<void>? _paired;

  @override
  Stream<TvConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<String> get pairingKeyUpdates => _pairingKeyController.stream;

  void _emit(TvConnectionState state) {
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(state);
    }
  }

  @override
  Future<void> connect() async {
    _emit(TvConnectionState.connecting);
    try {
      // Try a silent reconnect with a saved token first.
      if (device.pairingKey != null) {
        _client.authToken = device.pairingKey;
        try {
          await _client.isPoweredOn();
          _emit(TvConnectionState.connected);
          return;
        } on VizioException {
          // Token is stale/rejected; fall through to re-pair.
          _client.authToken = null;
        }
      }

      _challenge = await _client.startPairing(deviceName: 'TV Remote');
      _emit(TvConnectionState.awaitingPairingCode);

      final paired = _paired = Completer<void>();
      await paired.future; // Completed by submitPairingCode on success.

      _emit(TvConnectionState.connected);
    } catch (e) {
      _emit(TvConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<CommandResult> submitPairingCode(String code) async {
    final challenge = _challenge;
    final paired = _paired;
    if (challenge == null || paired == null || paired.isCompleted) {
      return CommandResult.failure('Not waiting for a pairing code.');
    }
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return CommandResult.failure('Enter the code shown on your TV.');
    }
    try {
      final token =
          await _client.finishPairing(challenge: challenge, pin: trimmed);
      _pairingKeyController.add(token);
      paired.complete();
      return CommandResult.ok();
    } on VizioException catch (e) {
      // Stay in the awaiting-code state so the user can retry the PIN.
      return CommandResult.failure(e.message);
    }
  }

  @override
  Future<void> disconnect() async {
    // Unblock a connect() still waiting on a PIN so it doesn't hang.
    if (_paired != null && !_paired!.isCompleted) {
      _paired!.completeError(StateError('disconnected'));
      await _client.cancelPairing();
    }
    if (!_connectionStateController.isClosed) {
      _emit(TvConnectionState.disconnected);
      await _connectionStateController.close();
    }
    if (!_pairingKeyController.isClosed) {
      await _pairingKeyController.close();
    }
  }

  Future<CommandResult> _key(VizioKey key) async {
    try {
      await _client.sendKey(key);
      return CommandResult.ok();
    } on VizioException catch (e) {
      return CommandResult.failure(e.message);
    }
  }

  @override
  Future<CommandResult> sendPower() => _key(VizioKey.powerToggle);

  @override
  Future<CommandResult> sendVolumeUp() => _key(VizioKey.volumeUp);

  @override
  Future<CommandResult> sendVolumeDown() => _key(VizioKey.volumeDown);

  @override
  Future<CommandResult> sendMute() => _key(VizioKey.muteToggle);

  @override
  Future<CommandResult> sendDirection(DPadDirection direction) {
    final key = switch (direction) {
      DPadDirection.up => VizioKey.up,
      DPadDirection.down => VizioKey.down,
      DPadDirection.left => VizioKey.left,
      DPadDirection.right => VizioKey.right,
    };
    return _key(key);
  }

  @override
  Future<CommandResult> sendSelect() => _key(VizioKey.ok);

  @override
  Future<CommandResult> sendHome() => _key(VizioKey.home);

  @override
  Future<CommandResult> sendBack() => _key(VizioKey.back);

  @override
  Future<CommandResult> sendNumber(int digit) async =>
      CommandResult.failure('SmartCast has no number pad.');

  @override
  Future<CommandResult> sendPlayPause() => _key(VizioKey.play);

  @override
  Future<CommandResult> sendRewind() => _key(VizioKey.seekBack);

  @override
  Future<CommandResult> sendFastForward() => _key(VizioKey.seekForward);

  @override
  Future<List<TvApp>?> listApps() async => null;

  @override
  Future<CommandResult> launchApp(TvApp app) async {
    final payload = VizioAppCatalog.decodeLaunch(app.id);
    if (payload == null) {
      return CommandResult.failure('Cannot launch ${app.name} on this TV.');
    }
    try {
      await _client.launchApp(
        nameSpace: payload['NAME_SPACE'] as int,
        appId: payload['APP_ID'].toString(),
        message: payload['MESSAGE'],
      );
      return CommandResult.ok();
    } on VizioException catch (e) {
      return CommandResult.failure(e.message);
    }
  }

  @override
  Future<List<TvInput>?> listInputs() async => null;

  @override
  Future<CommandResult> selectInput(TvInput input) => _key(VizioKey.inputNext);

  @override
  Future<CommandResult> sendInput() => _key(VizioKey.inputNext);

  @override
  bool get supportsKeyboard => false;

  @override
  bool get keyboardIsIncremental => false;

  @override
  Future<CommandResult> sendText(String text) async =>
      CommandResult.failure('SmartCast has no text-input API.');

  @override
  Future<CommandResult> sendKeyboardBackspace() async =>
      CommandResult.failure('SmartCast has no text-input API.');

  @override
  Future<CommandResult> sendKeyboardEnter() async =>
      CommandResult.failure('SmartCast has no text-input API.');

  @override
  Future<TvDeviceInfo> getDeviceInfo() =>
      _client.getDeviceInfo(fallbackName: device.name);
}
