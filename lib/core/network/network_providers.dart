import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_info.dart';

final networkInfoServiceProvider = Provider<NetworkInfoService>((ref) {
  return NetworkInfoService();
});

/// The current local network the device is attached to, or `null` if offline.
/// Surfaced in the discovery UI so the user can confirm the app is scanning
/// the same network their TV is on.
final currentNetworkProvider = FutureProvider<NetworkStatus?>((ref) {
  return ref.watch(networkInfoServiceProvider).currentNetwork();
});
