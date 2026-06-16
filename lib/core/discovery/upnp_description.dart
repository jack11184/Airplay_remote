import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

/// The interesting fields from a UPnP/SSDP device description document
/// (the XML served at an SSDP response's `LOCATION` URL).
class UpnpDescription {
  const UpnpDescription({
    this.friendlyName,
    this.manufacturer,
    this.modelName,
    this.deviceType,
  });

  final String? friendlyName;
  final String? manufacturer;
  final String? modelName;
  final String? deviceType;

  bool get isVizio {
    final haystack =
        '${manufacturer ?? ''} ${friendlyName ?? ''} ${modelName ?? ''}'
            .toLowerCase();
    return haystack.contains('vizio') || haystack.contains('smartcast');
  }
}

/// Fetches and parses a device's UPnP description document. SSDP responses
/// only carry an IP and a `LOCATION` URL; the description adds the real
/// friendly name, model and manufacturer - which lets the UI show "Living
/// Room TV" instead of a generic "Vizio TV", and lets a generic DIAL
/// response be positively identified as a particular brand.
class UpnpDescriptionClient {
  UpnpDescriptionClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ));

  final Dio _dio;

  Future<UpnpDescription?> fetch(String location) async {
    try {
      final response = await _dio.get<String>(location);
      final body = response.data;
      if (body == null || body.isEmpty) return null;
      final doc = XmlDocument.parse(body);

      // `device` may be nested under `root`; search anywhere for robustness
      // across the many slightly-different vendor description layouts.
      String? first(String tag) {
        final elements = doc.findAllElements(tag);
        if (elements.isEmpty) return null;
        final text = elements.first.innerText.trim();
        return text.isEmpty ? null : text;
      }

      return UpnpDescription(
        friendlyName: first('friendlyName'),
        manufacturer: first('manufacturer'),
        modelName: first('modelName'),
        deviceType: first('deviceType'),
      );
    } catch (_) {
      // Description fetch is best-effort enrichment; never fatal to discovery.
      return null;
    }
  }
}
