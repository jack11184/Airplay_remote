import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

import '../../../models/tv_app.dart';
import '../../../models/tv_device_info.dart';

/// Thin client for Roku's External Control Protocol (ECP).
///
/// ECP is plain HTTP on port 8060 with no authentication or pairing.
class RokuEcpClient {
  RokuEcpClient(this.ipAddress, {Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://$ipAddress:8060',
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ));

  final String ipAddress;
  final Dio _dio;

  Future<void> keypress(String key) async {
    await _dio.post('/keypress/$key');
  }

  /// Types a single literal character into a focused field via the ECP
  /// `Lit_<char>` key. The character is percent-encoded so spaces and
  /// punctuation are transmitted safely.
  Future<void> keypressLiteral(String char) async {
    await _dio.post('/keypress/Lit_${Uri.encodeComponent(char)}');
  }

  Future<void> launchApp(String appId) async {
    await _dio.post('/launch/$appId');
  }

  Future<TvDeviceInfo> getDeviceInfo() async {
    final response = await _dio.get<String>('/query/device-info');
    final root = XmlDocument.parse(response.data ?? '').rootElement;
    return TvDeviceInfo(
      modelName: _text(root, 'model-name') ??
          _text(root, 'friendly-device-name') ??
          'Roku',
      serialNumber: _text(root, 'serial-number'),
      softwareVersion: _text(root, 'software-version'),
    );
  }

  Future<List<TvApp>> getApps() async {
    final response = await _dio.get<String>('/query/apps');
    final root = XmlDocument.parse(response.data ?? '').rootElement;
    return root.findElements('app').map((app) {
      final id = app.getAttribute('id') ?? '';
      return TvApp(
        id: id,
        name: app.innerText.trim(),
        iconUrl: 'http://$ipAddress:8060/query/icon/$id',
      );
    }).toList();
  }

  String? _text(XmlElement root, String name) {
    final elements = root.findElements(name);
    return elements.isEmpty ? null : elements.first.innerText;
  }
}
