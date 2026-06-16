import '../../models/tv_protocol.dart';
import 'ssdp_tv_discoverer.dart';

/// Discovers LG webOS TVs via SSDP (search target
/// `urn:lge-com:service:webos-second-screen:1`).
class WebOsSsdpDiscoverer extends SsdpTvDiscoverer {
  WebOsSsdpDiscoverer({super.client, super.descriptionClient});

  @override
  TvProtocol get protocol => TvProtocol.webOs;

  @override
  List<String> get searchTargets =>
      const ['urn:lge-com:service:webos-second-screen:1'];

  @override
  String get defaultName => 'LG TV';
}
