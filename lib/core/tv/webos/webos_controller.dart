import 'dart:async';

import '../../../models/command_result.dart';
import '../../../models/tv_app.dart';
import '../../../models/tv_connection_state.dart';
import '../../../models/tv_device.dart';
import '../../../models/tv_device_info.dart';
import '../tv_controller.dart';
import 'webos_pointer_client.dart';
import 'webos_ssap_client.dart';

/// [TvController] for LG webOS TVs over SSAP (Second Screen App Protocol).
///
/// The first connection requires the user to accept an on-screen prompt;
/// the resulting `client-key` is emitted via [pairingKeyUpdates] so it can
/// be persisted and reused for silent reconnects.
class WebOsController implements TvController {
  WebOsController(this.device, {WebOsSsapClient? client})
      : _client = client ?? WebOsSsapClient(device.ipAddress);

  @override
  final TvDevice device;

  final WebOsSsapClient _client;
  WebOsPointerClient? _pointer;

  StreamSubscription<WebOsPairingState>? _pairingSub;

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
      if (state == WebOsPairingState.awaitingPrompt) {
        _connectionStateController
            .add(TvConnectionState.awaitingPairingConfirmation);
      }
    });

    try {
      await _client.connect();
      final clientKey = await _client.register(device.pairingKey);
      if (clientKey != device.pairingKey) {
        _pairingKeyController.add(clientKey);
      }
      await _openPointerSocket();
      _connectionStateController.add(TvConnectionState.connected);
    } catch (e) {
      _connectionStateController.add(TvConnectionState.error);
      rethrow;
    }
  }

  Future<void> _openPointerSocket() async {
    try {
      final response = await _client
          .request('ssap://com.webos.service.networkinput/getPointerInputSocket');
      final socketPath = response['socketPath'] as String?;
      if (socketPath != null) {
        _pointer = await WebOsPointerClient.connect(socketPath);
      }
    } catch (_) {
      // D-pad/number input degrades gracefully if the pointer socket can't
      // be opened; other commands are unaffected.
    }
  }

  @override
  Future<void> disconnect() async {
    await _pairingSub?.cancel();
    await _pointer?.close();
    await _client.close();
    if (!_connectionStateController.isClosed) {
      _connectionStateController.add(TvConnectionState.disconnected);
      await _connectionStateController.close();
    }
    if (!_pairingKeyController.isClosed) {
      await _pairingKeyController.close();
    }
  }

  Future<CommandResult> _request(
    String uri, [
    Map<String, Object?>? payload,
  ]) async {
    try {
      await _client.request(uri, payload);
      return CommandResult.ok();
    } catch (e) {
      return CommandResult.failure('$e');
    }
  }

  CommandResult _button(String name) {
    final pointer = _pointer;
    if (pointer == null) {
      return CommandResult.failure('Not connected to ${device.name}');
    }
    pointer.button(name);
    return CommandResult.ok();
  }

  @override
  Future<CommandResult> sendPower() => _request('ssap://system/turnOff');

  @override
  Future<CommandResult> sendVolumeUp() => _request('ssap://audio/volumeUp');

  @override
  Future<CommandResult> sendVolumeDown() =>
      _request('ssap://audio/volumeDown');

  @override
  Future<CommandResult> sendMute() async {
    try {
      final status = await _client.request('ssap://audio/getStatus');
      final muted = status['mute'] as bool? ?? false;
      await _client.request('ssap://audio/setMute', {'mute': !muted});
      return CommandResult.ok();
    } catch (e) {
      return CommandResult.failure('$e');
    }
  }

  @override
  Future<CommandResult> sendDirection(DPadDirection direction) {
    final name = switch (direction) {
      DPadDirection.up => 'UP',
      DPadDirection.down => 'DOWN',
      DPadDirection.left => 'LEFT',
      DPadDirection.right => 'RIGHT',
    };
    return Future.value(_button(name));
  }

  @override
  Future<CommandResult> sendSelect() => Future.value(_button('ENTER'));

  @override
  Future<CommandResult> sendHome() => Future.value(_button('HOME'));

  @override
  Future<CommandResult> sendBack() => Future.value(_button('BACK'));

  @override
  Future<CommandResult> sendNumber(int digit) =>
      Future.value(_button('$digit'));

  @override
  Future<CommandResult> sendPlayPause() =>
      _request('ssap://media.controls/play');

  @override
  Future<CommandResult> sendRewind() =>
      _request('ssap://media.controls/rewind');

  @override
  Future<CommandResult> sendFastForward() =>
      _request('ssap://media.controls/fastForward');

  @override
  Future<List<TvApp>?> listApps() async {
    try {
      final response =
          await _client.request('ssap://com.webos.applicationManager/listLaunchPoints');
      final launchPoints = response['launchPoints'] as List<Object?>? ?? [];
      return launchPoints.map((entry) {
        final point = entry as Map<String, Object?>;
        return TvApp(
          id: point['id'] as String,
          name: point['title'] as String,
          iconUrl: point['icon'] as String?,
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CommandResult> launchApp(TvApp app) =>
      _request('ssap://system.launcher/launch', {'id': app.id});

  @override
  Future<TvDeviceInfo> getDeviceInfo() async {
    final info = await _client.request('ssap://system/getSystemInfo');
    String? softwareVersion;
    try {
      final swInfo =
          await _client.request('ssap://com.webos.service.update/getCurrentSWInformation');
      softwareVersion = swInfo['product_name'] as String?;
    } catch (_) {
      // Not all firmware versions expose this endpoint.
    }
    return TvDeviceInfo(
      modelName: info['modelName'] as String? ?? device.name,
      softwareVersion: softwareVersion,
    );
  }
}
