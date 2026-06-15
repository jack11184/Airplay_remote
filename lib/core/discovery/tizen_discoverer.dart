import '../../models/tv_device.dart';
import '../../models/tv_protocol.dart';
import 'ssdp_client.dart';
import 'tv_discoverer.dart';

/// Discovers Samsung Tizen TVs via SSDP. Most models respond to
/// `urn:samsung.com:device:RemoteControlReceiver:1`; some older models only
/// respond to `urn:samsung.com:service:MainTVAgent2:1`, so both are queried.
class TizenSsdpDiscoverer implements TvDiscoverer {
  TizenSsdpDiscoverer({SsdpClient? client})
      : _client = client ?? SsdpClient();

  final SsdpClient _client;

  @override
  TvProtocol get protocol => TvProtocol.tizen;

  @override
  Stream<TvDevice> discover({Duration timeout = const Duration(seconds: 4)}) {
    return _client
        .search(
      searchTargets: const [
        'urn:samsung.com:device:RemoteControlReceiver:1',
        'urn:samsung.com:service:MainTVAgent2:1',
      ],
      timeout: timeout,
    )
        .map((response) {
      final ip = Uri.tryParse(response.location ?? '')?.host;
      if (ip == null) return null;
      return TvDevice(
        id: response.usn ?? 'tizen:$ip',
        name: 'Samsung TV',
        ipAddress: ip,
        protocol: TvProtocol.tizen,
      );
    }).where((device) => device != null).cast<TvDevice>();
  }
}
