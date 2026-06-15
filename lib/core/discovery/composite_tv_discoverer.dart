import 'dart:async';

import '../../models/tv_device.dart';
import 'roku_discoverer.dart';
import 'tizen_discoverer.dart';
import 'tv_discoverer.dart';
import 'webos_discoverer.dart';

/// Runs all [TvDiscoverer]s concurrently and merges their results into a
/// single stream, de-duplicating devices that respond more than once.
class CompositeTvDiscoverer {
  CompositeTvDiscoverer({List<TvDiscoverer>? discoverers})
      : _discoverers = discoverers ??
            [
              RokuSsdpDiscoverer(),
              WebOsSsdpDiscoverer(),
              TizenSsdpDiscoverer(),
            ];

  final List<TvDiscoverer> _discoverers;

  /// Emits each uniquely-discovered [TvDevice]. The stream closes once
  /// every discoverer's scan has finished.
  Stream<TvDevice> discoverAll({Duration timeout = const Duration(seconds: 4)}) {
    final controller = StreamController<TvDevice>();
    final seen = <String>{};
    var remaining = _discoverers.length;

    for (final discoverer in _discoverers) {
      discoverer.discover(timeout: timeout).listen(
        (device) {
          if (seen.add('${device.protocol}:${device.ipAddress}')) {
            controller.add(device);
          }
        },
        onError: controller.addError,
        onDone: () {
          remaining--;
          if (remaining == 0) controller.close();
        },
      );
    }

    return controller.stream;
  }
}
