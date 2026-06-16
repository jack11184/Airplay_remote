import '../../models/tv_protocol.dart';
import 'ssdp_client.dart';
import 'ssdp_tv_discoverer.dart';
import 'upnp_description.dart';

/// Discovers Vizio SmartCast TVs.
///
/// Vizio displays answer the brand-specific SSDP search target
/// `urn:schemas-kinoma-com:device:shell:1`. Many also answer the generic
/// DIAL target `urn:dial-multiscreen-org:service:dial:1` (as do Roku, Android
/// TV, etc.), so DIAL responders are only claimed once their UPnP
/// description confirms the manufacturer is Vizio. Querying both targets
/// makes detection robust across SmartCast firmware generations.
class VizioSsdpDiscoverer extends SsdpTvDiscoverer {
  VizioSsdpDiscoverer({super.client, super.descriptionClient});

  static const _kinomaTarget = 'urn:schemas-kinoma-com:device:shell:1';
  static const _dialTarget = 'urn:dial-multiscreen-org:service:dial:1';

  @override
  TvProtocol get protocol => TvProtocol.vizio;

  @override
  List<String> get searchTargets => const [_kinomaTarget, _dialTarget];

  @override
  String get defaultName => 'Vizio SmartCast TV';

  @override
  bool accepts(SsdpResponse response, UpnpDescription? description) {
    // The kinoma target is Vizio-specific - trust it even if the description
    // couldn't be fetched. Generic DIAL responders must prove they're Vizio.
    final st = response.searchTarget?.toLowerCase() ?? '';
    if (st.contains('kinoma')) return true;
    return description?.isVizio ?? false;
  }
}
