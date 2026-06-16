import 'dart:async';

import '../../models/tv_device.dart';
import 'ssdp_client.dart';
import 'tv_discoverer.dart';
import 'upnp_description.dart';

/// Shared SSDP-based [TvDiscoverer] machinery.
///
/// Subclasses declare which search target(s) identify their brand; this base
/// handles the common work: de-duplicating responders by IP, optionally
/// fetching each device's UPnP description to recover a real friendly name
/// and model, and constructing the [TvDevice].
abstract class SsdpTvDiscoverer implements TvDiscoverer {
  SsdpTvDiscoverer({
    SsdpClient? client,
    UpnpDescriptionClient? descriptionClient,
  })  : client = client ?? SsdpClient(),
        descriptionClient = descriptionClient ?? UpnpDescriptionClient();

  final SsdpClient client;
  final UpnpDescriptionClient descriptionClient;

  /// The SSDP `ST` value(s) to M-SEARCH for.
  List<String> get searchTargets;

  /// Display name used when the device's description exposes no friendly name.
  String get defaultName;

  /// Whether to fetch the UPnP description document for friendly-name/model
  /// enrichment. Subclasses that need the description to *identify* the
  /// device (e.g. Vizio over generic DIAL) must keep this on.
  bool get enrich => true;

  /// Whether a response (optionally with its fetched [description]) is a
  /// device this discoverer should claim. Defaults to accepting everything,
  /// since per-brand search targets are already specific.
  bool accepts(SsdpResponse response, UpnpDescription? description) => true;

  @override
  Stream<TvDevice> discover({Duration timeout = const Duration(seconds: 4)}) {
    final seenHosts = <String>{};
    return client
        .search(searchTargets: searchTargets, timeout: timeout)
        .asyncMap((response) async {
          final ip = response.host;
          if (ip == null || !seenHosts.add(ip)) return null;

          UpnpDescription? description;
          final location = response.location;
          if (enrich && location != null && location.isNotEmpty) {
            description = await descriptionClient.fetch(location);
          }

          if (!accepts(response, description)) return null;

          final friendly = description?.friendlyName?.trim();
          return TvDevice(
            id: response.usn ?? '${protocol.name}:$ip',
            name: (friendly != null && friendly.isNotEmpty)
                ? friendly
                : defaultName,
            ipAddress: ip,
            protocol: protocol,
            modelName: description?.modelName,
          );
        })
        .where((device) => device != null)
        .cast<TvDevice>();
  }
}
