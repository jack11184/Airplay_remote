import '../../models/tv_protocol.dart';
import 'ssdp_tv_discoverer.dart';

/// Discovers Roku devices via SSDP (search target `roku:ecp`). Roku's ECP
/// is always served on port 8060 and requires no pairing.
class RokuSsdpDiscoverer extends SsdpTvDiscoverer {
  RokuSsdpDiscoverer({super.client, super.descriptionClient});

  @override
  TvProtocol get protocol => TvProtocol.roku;

  @override
  List<String> get searchTargets => const ['roku:ecp'];

  @override
  String get defaultName => 'Roku TV';
}
