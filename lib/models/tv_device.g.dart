// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TvDevice _$TvDeviceFromJson(Map<String, dynamic> json) => _TvDevice(
  id: json['id'] as String,
  name: json['name'] as String,
  ipAddress: json['ipAddress'] as String,
  protocol: $enumDecode(_$TvProtocolEnumMap, json['protocol']),
  modelName: json['modelName'] as String?,
  pairingKey: json['pairingKey'] as String?,
);

Map<String, dynamic> _$TvDeviceToJson(_TvDevice instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'ipAddress': instance.ipAddress,
  'protocol': _$TvProtocolEnumMap[instance.protocol]!,
  'modelName': instance.modelName,
  'pairingKey': instance.pairingKey,
};

const _$TvProtocolEnumMap = {
  TvProtocol.roku: 'roku',
  TvProtocol.webOs: 'webOs',
  TvProtocol.tizen: 'tizen',
  TvProtocol.vizio: 'vizio',
};
