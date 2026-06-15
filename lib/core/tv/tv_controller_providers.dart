import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/discovery/application/discovery_provider.dart';
import '../../models/tv_connection_state.dart';
import '../../models/tv_device.dart';
import '../storage/storage_providers.dart';
import 'tv_controller.dart';
import 'tv_controller_factory.dart';

final tvControllerFactoryProvider = Provider<TvControllerFactory>((ref) {
  return TvControllerFactory(ref.watch(secureStorageServiceProvider));
});

/// Creates (but does not connect) the [TvController] for [device]. Kept
/// alive for as long as anything watches it, and disconnected on dispose.
final tvControllerInstanceProvider =
    Provider.autoDispose.family<TvController, TvDevice>((ref, device) {
  final factory = ref.watch(tvControllerFactoryProvider);
  final controller = factory.create(device);
  ref.onDispose(() {
    controller.disconnect();
  });
  return controller;
});

/// Live connection-state updates for [device], including
/// [TvConnectionState.awaitingPairingConfirmation] while a webOS/Tizen
/// on-screen pairing prompt is pending.
final tvConnectionStateProvider =
    StreamProvider.autoDispose.family<TvConnectionState, TvDevice>(
        (ref, device) {
  final controller = ref.watch(tvControllerInstanceProvider(device));
  return controller.connectionState;
});

/// Connects to [device] and resolves to the ready [TvController]. Persists
/// any new pairing credential (webOS client-key / Tizen token) emitted
/// during connection.
final tvConnectProvider =
    FutureProvider.autoDispose.family<TvController, TvDevice>(
        (ref, device) async {
  final controller = ref.watch(tvControllerInstanceProvider(device));
  final repo = ref.watch(deviceRepositoryProvider);

  final pairingSub = controller.pairingKeyUpdates.listen((key) {
    repo.upsertDevice(device.copyWith(pairingKey: key));
    ref.invalidate(pairedDevicesProvider);
  });
  ref.onDispose(pairingSub.cancel);

  await controller.connect();
  await repo.upsertDevice(device);
  ref.invalidate(pairedDevicesProvider);
  return controller;
});
