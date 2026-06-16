import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../../models/tv_device_info.dart';
import 'vizio_key_codes.dart';

/// Raised when the SmartCast API returns a non-success status or can't be
/// reached. [message] is suitable for showing to the user.
class VizioException implements Exception {
  VizioException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The outcome of a pairing-start request: the TV is now showing a PIN, and
/// these tokens must be echoed back with that PIN to finish pairing.
class VizioPairingChallenge {
  const VizioPairingChallenge({
    required this.pairingToken,
    required this.challengeType,
  });

  final int pairingToken;
  final int challengeType;
}

/// Thin client for the Vizio SmartCast HTTPS API.
///
/// SmartCast is served over TLS with a self-signed certificate (so cert
/// verification is disabled) on port 7345 on newer sets and 9000 on older
/// ones; the working port is probed on first use. All control endpoints
/// except pairing require the `AUTH` token obtained from the pairing flow.
class VizioSmartCastClient {
  VizioSmartCastClient(
    this.ipAddress, {
    String? authToken,
    Dio? dio,
    List<int>? candidatePorts,
  })  : _candidatePorts = candidatePorts ?? const [7345, 9000],
        _dio = dio ?? _buildDio() {
    _authToken = authToken;
  }

  final String ipAddress;
  final Dio _dio;
  final List<int> _candidatePorts;

  String? _authToken;
  int? _port;

  set authToken(String? token) => _authToken = token;

  /// A stable identifier for this app instance, echoed during pairing so the
  /// TV can associate the issued token with this client.
  static const _deviceId = 'flutter-tv-remote';

  static Dio _buildDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      // SmartCast returns JSON; let us inspect non-2xx bodies for error detail.
      validateStatus: (status) => status != null && status < 500,
    ));
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // SmartCast TVs present a self-signed certificate.
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
    return dio;
  }

  /// Probes [_candidatePorts] for an open TLS SmartCast endpoint and caches
  /// the first that accepts a connection.
  Future<int> _resolvePort() async {
    if (_port != null) return _port!;
    for (final port in _candidatePorts) {
      try {
        final socket = await SecureSocket.connect(
          ipAddress,
          port,
          onBadCertificate: (_) => true,
          timeout: const Duration(seconds: 3),
        );
        socket.destroy();
        return _port = port;
      } catch (_) {
        // Try the next candidate port.
      }
    }
    throw VizioException(
      'No SmartCast service reachable at $ipAddress on ports '
      '${_candidatePorts.join(' / ')}.',
    );
  }

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    Object? body,
  }) async {
    final port = await _resolvePort();
    final Response<Object?> response;
    try {
      response = await _dio.request<Object?>(
        'https://$ipAddress:$port$path',
        data: body,
        options: Options(
          method: method,
          headers: {
            'Content-Type': 'application/json',
            if (_authToken != null) 'AUTH': _authToken,
          },
        ),
      );
    } on DioException catch (e) {
      throw VizioException(e.message ?? 'Request to $ipAddress failed.');
    }

    final data = response.data;
    if (data is! Map<String, Object?>) {
      throw VizioException('Unexpected response from $ipAddress.');
    }
    return data;
  }

  String _resultOf(Map<String, Object?> response) {
    final status = response['STATUS'];
    if (status is Map) {
      return (status['RESULT'] ?? status['result'])?.toString() ?? 'UNKNOWN';
    }
    return 'UNKNOWN';
  }

  String? _detailOf(Map<String, Object?> response) {
    final status = response['STATUS'];
    if (status is Map) {
      return (status['DETAIL'] ?? status['detail'])?.toString();
    }
    return null;
  }

  void _ensureSuccess(Map<String, Object?> response, String action) {
    final result = _resultOf(response).toUpperCase();
    if (result != 'SUCCESS') {
      throw VizioException(_detailOf(response) ?? '$action failed ($result).');
    }
  }

  Map<String, Object?> _itemOf(Map<String, Object?> response) {
    final item = response['ITEM'] ?? response['item'];
    return item is Map<String, Object?> ? item : const {};
  }

  // --- Pairing ---

  /// Begins pairing. The TV displays a PIN; returns the tokens needed to
  /// complete pairing with [finishPairing].
  Future<VizioPairingChallenge> startPairing({String deviceName = 'TV Remote'}) async {
    final response = await _send(
      'PUT',
      '/pairing/start',
      body: {'DEVICE_ID': _deviceId, 'DEVICE_NAME': deviceName},
    );
    _ensureSuccess(response, 'Pairing');
    final item = _itemOf(response);
    final token = item['PAIRING_REQ_TOKEN'] ?? item['pairing_req_token'];
    final challenge = item['CHALLENGE_TYPE'] ?? item['challenge_type'];
    if (token is! int || challenge is! int) {
      throw VizioException('Pairing did not return a challenge token.');
    }
    return VizioPairingChallenge(pairingToken: token, challengeType: challenge);
  }

  /// Completes pairing with the [pin] shown on the TV; returns the AUTH token
  /// to persist and reuse for future connections.
  Future<String> finishPairing({
    required VizioPairingChallenge challenge,
    required String pin,
  }) async {
    final response = await _send(
      'PUT',
      '/pairing/pair',
      body: {
        'DEVICE_ID': _deviceId,
        'CHALLENGE_TYPE': challenge.challengeType,
        'RESPONSE_VALUE': pin,
        'PAIRING_REQ_TOKEN': challenge.pairingToken,
      },
    );
    _ensureSuccess(response, 'Pairing');
    final token = _itemOf(response)['AUTH_TOKEN'] ?? _itemOf(response)['auth_token'];
    if (token is! String || token.isEmpty) {
      throw VizioException('Pairing succeeded but no token was returned.');
    }
    _authToken = token;
    return token;
  }

  Future<void> cancelPairing() async {
    try {
      await _send(
        'PUT',
        '/pairing/cancel',
        body: {'DEVICE_ID': _deviceId},
      );
    } catch (_) {
      // Cancellation is best-effort.
    }
  }

  // --- Control ---

  /// Verifies the current [authToken] works by reading the power state.
  /// Throws [VizioException] if the token is missing/expired.
  Future<bool> isPoweredOn() async {
    final response = await _send('GET', '/state/device/power_mode');
    _ensureSuccess(response, 'Power state');
    final items = response['ITEMS'];
    if (items is List && items.isNotEmpty && items.first is Map) {
      final value = (items.first as Map)['VALUE'];
      return value == 1 || value == '1';
    }
    return false;
  }

  Future<void> sendKey(VizioKey key) async {
    final response = await _send(
      'PUT',
      '/key_command/',
      body: {
        'KEYLIST': [
          {'CODESET': key.codeset, 'CODE': key.code, 'ACTION': 'KEYPRESS'},
        ],
      },
    );
    _ensureSuccess(response, 'Key command');
  }

  Future<void> launchApp({
    required int nameSpace,
    required String appId,
    Object? message,
  }) async {
    final response = await _send(
      'PUT',
      '/app/launch',
      body: {
        'VALUE': {
          'MESSAGE': message,
          'NAME_SPACE': nameSpace,
          'APP_ID': appId,
        },
      },
    );
    _ensureSuccess(response, 'Launch app');
  }

  Future<TvDeviceInfo> getDeviceInfo({String fallbackName = 'Vizio SmartCast TV'}) async {
    try {
      final response = await _send('GET', '/state/device/deviceinfo');
      final items = response['ITEMS'];
      String? model;
      String? version;
      if (items is List) {
        for (final entry in items) {
          if (entry is! Map) continue;
          final name = (entry['CNAME'] ?? entry['NAME'])?.toString().toLowerCase();
          final value = entry['VALUE']?.toString();
          if (name == null || value == null) continue;
          if (name.contains('model')) model = value;
          if (name.contains('version')) version = value;
        }
      }
      return TvDeviceInfo(
        modelName: model ?? fallbackName,
        softwareVersion: version,
      );
    } catch (_) {
      return TvDeviceInfo(modelName: fallbackName);
    }
  }
}
