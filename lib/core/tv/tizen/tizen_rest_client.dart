import 'package:dio/dio.dart';

import '../../../models/tv_device_info.dart';

/// Thin client for Samsung Tizen's plain-HTTP device info endpoint.
///
/// Unlike the remote-control API, `/api/v1/` requires no pairing and is
/// served over plain HTTP on port 8001.
class TizenRestClient {
  TizenRestClient(this.ipAddress, {Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://$ipAddress:8001',
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ));

  final String ipAddress;
  final Dio _dio;

  Future<TvDeviceInfo> getDeviceInfo() async {
    final response = await _dio.get<Map<String, Object?>>('/api/v1/');
    final device =
        (response.data?['device'] as Map<String, Object?>?) ?? const {};
    return TvDeviceInfo(
      modelName: device['modelName'] as String? ?? 'Samsung TV',
      softwareVersion: device['firmwareVersion'] as String?,
    );
  }
}
