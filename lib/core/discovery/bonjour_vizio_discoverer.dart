import 'dart:async';

import 'package:bonsoir/bonsoir.dart';

import '../../models/tv_device.dart';
import '../../models/tv_protocol.dart';
import 'tv_discoverer.dart';

/// Discovers Vizio SmartCast TVs over Bonjour/mDNS using the platform-native
/// Bonjour stack (via the `bonsoir` plugin).
///
/// SmartCast TVs advertise the `_viziocast._tcp` service and are silent on
/// SSDP. Crucially, going through the OS Bonjour resolver (rather than raw
/// multicast sockets, as a hand-rolled mDNS client would) means discovery
/// works on iOS too: iOS blocks app-level multicast without a special
/// entitlement, but the system resolver is exempt as long as the service type
/// is declared in `NSBonjourServices` (see ios/Runner/Info.plist).
class BonjourVizioDiscoverer implements TvDiscoverer {
  static const _serviceType = '_viziocast._tcp';

  @override
  TvProtocol get protocol => TvProtocol.vizio;

  @override
  Stream<TvDevice> discover({Duration timeout = const Duration(seconds: 4)}) {
    final controller = StreamController<TvDevice>();
    final seen = <String>{};
    BonsoirDiscovery? discovery;
    StreamSubscription<BonsoirDiscoveryEvent>? sub;
    Timer? timer;
    var cleaning = false;

    Future<void> cleanup() async {
      if (cleaning) return;
      cleaning = true;
      timer?.cancel();
      await sub?.cancel();
      try {
        await discovery?.stop();
      } catch (_) {}
      if (!controller.isClosed) await controller.close();
    }

    Future<void> run() async {
      try {
        final disc = discovery = BonsoirDiscovery(type: _serviceType);
        await disc.initialize();
        sub = disc.eventStream!.listen((event) {
          if (event is BonsoirDiscoveryServiceFoundEvent) {
            // Found a service name; ask the OS to resolve its address/port.
            disc.serviceResolver.resolveService(event.service);
          } else if (event is BonsoirDiscoveryServiceResolvedEvent) {
            _emit(event.service, controller, seen);
          }
        });
        await disc.start();
        timer = Timer(timeout, cleanup);
      } catch (_) {
        // Bonjour unavailable (e.g. permission denied); degrade quietly so the
        // SSDP discoverers still run.
        await cleanup();
      }
    }

    controller.onCancel = cleanup;
    run();
    return controller.stream;
  }

  void _emit(
    BonsoirService service,
    StreamController<TvDevice> controller,
    Set<String> seen,
  ) {
    final ip = _ipv4Of(service);
    if (ip == null || !seen.add(ip)) return;
    final name = service.name.trim();
    if (!controller.isClosed) {
      controller.add(TvDevice(
        id: 'vizio:$ip',
        name: name.isEmpty ? 'Vizio SmartCast TV' : name,
        ipAddress: ip,
        protocol: TvProtocol.vizio,
      ));
    }
  }

  /// Prefers an IPv4 address (Vizio's SmartCast API is reached over IPv4),
  /// falling back to whatever address was resolved.
  String? _ipv4Of(BonsoirService service) {
    final addresses = service.hostAddresses;
    for (final address in addresses) {
      if (!address.contains(':')) return address;
    }
    return addresses.isEmpty ? null : addresses.first;
  }
}
