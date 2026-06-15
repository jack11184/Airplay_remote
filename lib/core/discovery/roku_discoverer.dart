import '../../models/tv_device.dart';
import '../../models/tv_protocol.dart';
import 'ssdp_client.dart';
import 'tv_discoverer.dart';

/// Discovers Roku devices via SSDP (search target `roku:ecp`). Roku's ECP
/// is always served on port 8060 and requires no pairing.
class RokuSsdpDiscoverer implements TvDiscoverer {
  RokuSsdpDiscoverer({SsdpClient? client}) : _client = client ?? SsdpClient();

  final SsdpClient _client;

  @override
  TvProtocol get protocol => TvProtocol.roku;

  @override
  Stream<TvDevice> discover({Duration timeout = const Duration(seconds: 4)}) {
    return _client
        .search(searchTargets: const ['roku:ecp'], timeout: timeout)
        .map((response) {
      final ip = Uri.tryParse(response.location ?? '')?.host;
      if (ip == null) return null;
      return TvDevice(
        id: response.usn ?? 'roku:$ip',
        name: 'Roku TV',
        ipAddress: ip,
        protocol: TvProtocol.roku,
      );
    }).where((device) => device != null).cast<TvDevice>();
  }
}
