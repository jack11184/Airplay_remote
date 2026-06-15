import 'package:freezed_annotation/freezed_annotation.dart';

import 'tv_protocol.dart';

part 'tv_device.freezed.dart';
part 'tv_device.g.dart';

/// A discovered or paired smart TV.
///
/// [pairingKey] holds the webOS client-key or Samsung Tizen token once a
/// pairing handshake has completed; it is null for Roku (no pairing) and
/// for devices that have not yet been paired.
@freezed
abstract class TvDevice with _$TvDevice {
  const factory TvDevice({
    required String id,
    required String name,
    required String ipAddress,
    required TvProtocol protocol,
    String? modelName,
    String? pairingKey,
  }) = _TvDevice;

  factory TvDevice.fromJson(Map<String, Object?> json) =>
      _$TvDeviceFromJson(json);
}
