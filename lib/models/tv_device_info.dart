import 'package:freezed_annotation/freezed_annotation.dart';

part 'tv_device_info.freezed.dart';

/// Basic identifying information reported by a connected TV.
@freezed
abstract class TvDeviceInfo with _$TvDeviceInfo {
  const factory TvDeviceInfo({
    required String modelName,
    String? serialNumber,
    String? softwareVersion,
  }) = _TvDeviceInfo;
}
