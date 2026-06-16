import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/tv_app.dart';

/// Shared [VizioAppCatalog]. Provider-scoped so the fetched catalog (and its
/// HTTP client) is reused across the app.
final vizioAppCatalogProvider = Provider<VizioAppCatalog>((ref) {
  return VizioAppCatalog();
});

/// Builds the list of launchable apps for Vizio SmartCast TVs.
///
/// SmartCast has no reliable "list installed apps" endpoint, so instead we
/// use Vizio's own published catalog: `vizio_apps_prod.json` maps app ids to
/// names/icons, and `app_availability_prod.json` maps the same ids to the
/// `{NAME_SPACE, APP_ID, MESSAGE}` launch payload. Joining them yields an
/// always-current, self-updating catalog. The launch payload is encoded into
/// [TvApp.id] as JSON so the controller can replay it to `/app/launch`.
///
/// If the network fetch fails, a small built-in [_fallback] of the most
/// common apps is returned so app launching still works offline-of-Vizio.
class VizioAppCatalog {
  VizioAppCatalog({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 6),
            ));

  final Dio _dio;

  static const _appsUrl = 'https://scfs.vizio.com/appservice/vizio_apps_prod.json';
  static const _availabilityUrl =
      'https://scfs.vizio.com/appservice/app_availability_prod.json';

  /// Encodes a launch payload into a [TvApp.id] string.
  static String encodeLaunch({
    required int nameSpace,
    required String appId,
    Object? message,
  }) =>
      jsonEncode({'NAME_SPACE': nameSpace, 'APP_ID': appId, 'MESSAGE': message});

  /// Decodes a launch payload previously encoded into a [TvApp.id]. Returns
  /// null if the id isn't a Vizio launch payload.
  static Map<String, Object?>? decodeLaunch(String id) {
    try {
      final decoded = jsonDecode(id);
      if (decoded is Map<String, Object?> && decoded.containsKey('APP_ID')) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  Future<List<TvApp>> fetch() async {
    try {
      final results = await Future.wait([
        _dio.get<Object?>(_appsUrl),
        _dio.get<Object?>(_availabilityUrl),
      ]);
      final apps = _asList(results[0].data);
      final availability = _asList(results[1].data);

      // id -> launch payload (preferring the wildcard "*" chipset entry).
      final payloadById = <String, Map<String, Object?>>{};
      for (final entry in availability) {
        if (entry is! Map) continue;
        final id = entry['id']?.toString();
        if (id == null) continue;
        final chipsets = entry['chipsets'];
        if (chipsets is! Map) continue;
        final variants = chipsets['*'] ?? chipsets.values.first;
        if (variants is! List || variants.isEmpty) continue;
        final first = variants.first;
        if (first is! Map) continue;
        final payloadRaw = first['app_type_payload'];
        if (payloadRaw is! String) continue;
        final payload = jsonDecode(payloadRaw);
        if (payload is Map<String, Object?>) payloadById[id] = payload;
      }

      final catalog = <({TvApp app, int sort})>[];
      for (final entry in apps) {
        if (entry is! Map) continue;
        final id = entry['id']?.toString();
        final name = entry['name']?.toString();
        if (id == null || name == null) continue;
        final payload = payloadById[id];
        if (payload == null) continue;

        final nameSpace = payload['NAME_SPACE'];
        final appId = payload['APP_ID']?.toString();
        if (nameSpace is! int || appId == null) continue;

        final info = entry['mobileAppInfo'];
        final iconUrl =
            info is Map ? info['app_icon_image_url']?.toString() : null;
        final sort = info is Map ? info['featured_sort'] : null;

        catalog.add((
          app: TvApp(
            id: encodeLaunch(
              nameSpace: nameSpace,
              appId: appId,
              message: payload['MESSAGE'],
            ),
            name: name,
            iconUrl: (iconUrl != null && iconUrl.startsWith('http'))
                ? iconUrl
                : null,
          ),
          sort: sort is int ? sort : 1 << 30,
        ));
      }

      if (catalog.isEmpty) return _fallback;

      catalog.sort((a, b) => a.sort.compareTo(b.sort));
      // De-dup by display name, keep a sensible cap for the grid.
      final seen = <String>{};
      final result = <TvApp>[];
      for (final item in catalog) {
        if (seen.add(item.app.name.toLowerCase())) result.add(item.app);
        if (result.length >= 40) break;
      }
      return result;
    } catch (_) {
      return _fallback;
    }
  }

  static List<Object?> _asList(Object? data) {
    if (data is List) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is List) return decoded;
    }
    return const [];
  }

  /// Most-common apps with widely-confirmed launch parameters, used when the
  /// live catalog can't be fetched.
  static final List<TvApp> _fallback = [
    TvApp(id: encodeLaunch(nameSpace: 3, appId: '1'), name: 'Netflix'),
    TvApp(id: encodeLaunch(nameSpace: 2, appId: '3'), name: 'Hulu'),
    TvApp(id: encodeLaunch(nameSpace: 3, appId: '4'), name: 'Prime Video'),
    TvApp(
      id: encodeLaunch(
        nameSpace: 2,
        appId: '31',
        message: 'https://my.vudu.com/castReceiver/index.html?launch-source=app-icon',
      ),
      name: 'Vudu',
    ),
  ];
}
