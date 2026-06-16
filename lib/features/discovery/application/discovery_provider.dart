import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/discovery/discovery_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../models/tv_device.dart';

/// Scans the local network for TVs and accumulates results as they arrive.
///
/// [isScanning] is true while the underlying SSDP scan is in flight; it (and
/// [state]) update together so widgets watching this provider re-render
/// when scanning finishes.
class DiscoveryNotifier extends AsyncNotifier<List<TvDevice>> {
  StreamSubscription<TvDevice>? _subscription;
  bool isScanning = false;

  @override
  FutureOr<List<TvDevice>> build() {
    ref.onDispose(() => _subscription?.cancel());
    _scan();
    return const [];
  }

  void rescan() => _scan();

  void _scan() {
    _subscription?.cancel();
    final results = <TvDevice>[];
    isScanning = true;
    state = const AsyncData([]);

    final discoverer = ref.read(compositeTvDiscovererProvider);
    _subscription = discoverer
        .discoverAll(timeout: const Duration(seconds: 6))
        .listen(
      (device) {
        results.add(device);
        state = AsyncData(List.unmodifiable(results));
      },
      onDone: () {
        isScanning = false;
        state = AsyncData(List.unmodifiable(results));
      },
      onError: (Object error, StackTrace stackTrace) {
        isScanning = false;
        state = AsyncError(error, stackTrace);
      },
    );
  }
}

final discoveryProvider =
    AsyncNotifierProvider<DiscoveryNotifier, List<TvDevice>>(
  DiscoveryNotifier.new,
);

/// Previously paired/known devices, loaded from secure storage.
final pairedDevicesProvider = FutureProvider<List<TvDevice>>((ref) async {
  try {
    final repo = ref.watch(deviceRepositoryProvider);
    return repo.loadDevices();
  } catch (e) {
    return [];
  }
});
