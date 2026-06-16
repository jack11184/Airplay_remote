import 'dart:async';

import 'package:dio/dio.dart';

import '../../../models/command_result.dart';
import '../../../models/tv_app.dart';
import '../../../models/tv_connection_state.dart';
import '../../../models/tv_device.dart';
import '../../../models/tv_device_info.dart';
import '../../../models/tv_input.dart';
import '../tv_controller.dart';
import 'roku_ecp_client.dart';

/// [TvController] for Roku devices over the External Control Protocol
/// (ECP). Roku requires no pairing - any reachable IP on port 8060 can be
/// controlled immediately.
class RokuController implements TvController {
  RokuController(this.device, {RokuEcpClient? client})
      : _client = client ?? RokuEcpClient(device.ipAddress);

  @override
  final TvDevice device;

  final RokuEcpClient _client;

  final _connectionStateController =
      StreamController<TvConnectionState>.broadcast();

  @override
  Stream<TvConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<String> get pairingKeyUpdates => const Stream.empty();

  @override
  Future<void> connect() async {
    _connectionStateController.add(TvConnectionState.connecting);
    try {
      await _client.getDeviceInfo();
      _connectionStateController.add(TvConnectionState.connected);
    } catch (_) {
      _connectionStateController.add(TvConnectionState.error);
      rethrow;
    }
  }

  @override
  Future<CommandResult> submitPairingCode(String code) async =>
      CommandResult.failure('Roku does not require a pairing code.');

  @override
  Future<void> disconnect() async {
    _connectionStateController.add(TvConnectionState.disconnected);
    await _connectionStateController.close();
  }

  Future<CommandResult> _keypress(String key) async {
    try {
      await _client.keypress(key);
      return CommandResult.ok();
    } on DioException catch (e) {
      return CommandResult.failure(e.message ?? 'Failed to send "$key"');
    }
  }

  @override
  Future<CommandResult> sendPower() => _keypress('Power');

  @override
  Future<CommandResult> sendVolumeUp() => _keypress('VolumeUp');

  @override
  Future<CommandResult> sendVolumeDown() => _keypress('VolumeDown');

  @override
  Future<CommandResult> sendMute() => _keypress('VolumeMute');

  @override
  Future<CommandResult> sendDirection(DPadDirection direction) {
    switch (direction) {
      case DPadDirection.up:
        return _keypress('Up');
      case DPadDirection.down:
        return _keypress('Down');
      case DPadDirection.left:
        return _keypress('Left');
      case DPadDirection.right:
        return _keypress('Right');
    }
  }

  @override
  Future<CommandResult> sendSelect() => _keypress('Select');

  @override
  Future<CommandResult> sendHome() => _keypress('Home');

  @override
  Future<CommandResult> sendBack() => _keypress('Back');

  @override
  Future<CommandResult> sendNumber(int digit) => _keypress('Lit_$digit');

  @override
  Future<CommandResult> sendPlayPause() => _keypress('Play');

  @override
  Future<CommandResult> sendRewind() => _keypress('Rev');

  @override
  Future<CommandResult> sendFastForward() => _keypress('Fwd');

  @override
  Future<List<TvApp>?> listApps() => _client.getApps();

  @override
  Future<CommandResult> launchApp(TvApp app) async {
    try {
      await _client.launchApp(app.id);
      return CommandResult.ok();
    } on DioException catch (e) {
      return CommandResult.failure(
        e.message ?? 'Failed to launch ${app.name}',
      );
    }
  }

  @override
  Future<List<TvInput>?> listInputs() async => const [
        TvInput(id: 'InputTuner', name: 'Antenna'),
        TvInput(id: 'InputHDMI1', name: 'HDMI 1'),
        TvInput(id: 'InputHDMI2', name: 'HDMI 2'),
        TvInput(id: 'InputHDMI3', name: 'HDMI 3'),
        TvInput(id: 'InputHDMI4', name: 'HDMI 4'),
        TvInput(id: 'InputAV1', name: 'AV'),
      ];

  @override
  Future<CommandResult> selectInput(TvInput input) => _keypress(input.id);

  @override
  Future<CommandResult> sendInput() => _keypress('InputHDMI1');

  @override
  bool get supportsKeyboard => true;

  @override
  bool get keyboardIsIncremental => true;

  @override
  Future<CommandResult> sendText(String text) async {
    try {
      for (final rune in text.runes) {
        await _client.keypressLiteral(String.fromCharCode(rune));
      }
      return CommandResult.ok();
    } on DioException catch (e) {
      return CommandResult.failure(e.message ?? 'Failed to type');
    }
  }

  @override
  Future<CommandResult> sendKeyboardBackspace() => _keypress('Backspace');

  @override
  Future<CommandResult> sendKeyboardEnter() => _keypress('Enter');

  @override
  Future<TvDeviceInfo> getDeviceInfo() => _client.getDeviceInfo();
}
