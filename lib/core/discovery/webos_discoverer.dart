import '../../models/tv_device.dart';
import '../../models/tv_protocol.dart';
import 'ssdp_client.dart';
import 'tv_discoverer.dart';

/// Discovers LG webOS TVs via SSDP (search target
/// `urn:lge-com:service:webos-second-screen:1`).
class WebOsSsdpDiscoverer implements TvDiscoverer {
  WebOsSsdpDiscoverer({SsdpClient? client})
      : _client = client ?? SsdpClient();

  final SsdpClient _client;

  @override
  TvProtocol get protocol => TvProtocol.webOs;

  @override
  Stream<TvDevice> discover({Duration timeout = const Duration(seconds: 4)}) {
    return _client
        .search(
      searchTargets: const ['urn:lge-com:service:webos-second-screen:1'],
      timeout: timeout,
    )
        .map((response) {
      final ip = Uri.tryParse(response.location ?? '')?.host;
      if (ip == null) return null;
      return TvDevice(
        id: response.usn ?? 'webos:$ip',
        name: 'LG TV',
        ipAddress: ip,
        protocol: TvProtocol.webOs,
      );
    }).where((device) => device != null).cast<TvDevice>();
  }
}
