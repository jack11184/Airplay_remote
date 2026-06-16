import '../../models/tv_protocol.dart';
import 'ssdp_tv_discoverer.dart';

/// Discovers Samsung Tizen TVs via SSDP. Most models respond to
/// `urn:samsung.com:device:RemoteControlReceiver:1`; some older models only
/// respond to `urn:samsung.com:service:MainTVAgent2:1`, so both are queried.
class TizenSsdpDiscoverer extends SsdpTvDiscoverer {
  TizenSsdpDiscoverer({super.client, super.descriptionClient});

  @override
  TvProtocol get protocol => TvProtocol.tizen;

  @override
  List<String> get searchTargets => const [
        'urn:samsung.com:device:RemoteControlReceiver:1',
        'urn:samsung.com:service:MainTVAgent2:1',
      ];

  @override
  String get defaultName => 'Samsung TV';
}
