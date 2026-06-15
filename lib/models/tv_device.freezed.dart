// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TvDevice {

 String get id; String get name; String get ipAddress; TvProtocol get protocol; String? get modelName; String? get pairingKey;
/// Create a copy of TvDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TvDeviceCopyWith<TvDevice> get copyWith => _$TvDeviceCopyWithImpl<TvDevice>(this as TvDevice, _$identity);

  /// Serializes this TvDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TvDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.pairingKey, pairingKey) || other.pairingKey == pairingKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ipAddress,protocol,modelName,pairingKey);

@override
String toString() {
  return 'TvDevice(id: $id, name: $name, ipAddress: $ipAddress, protocol: $protocol, modelName: $modelName, pairingKey: $pairingKey)';
}


}

/// @nodoc
abstract mixin class $TvDeviceCopyWith<$Res>  {
  factory $TvDeviceCopyWith(TvDevice value, $Res Function(TvDevice) _then) = _$TvDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ipAddress, TvProtocol protocol, String? modelName, String? pairingKey
});




}
/// @nodoc
class _$TvDeviceCopyWithImpl<$Res>
    implements $TvDeviceCopyWith<$Res> {
  _$TvDeviceCopyWithImpl(this._self, this._then);

  final TvDevice _self;
  final $Res Function(TvDevice) _then;

/// Create a copy of TvDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ipAddress = null,Object? protocol = null,Object? modelName = freezed,Object? pairingKey = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as TvProtocol,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,pairingKey: freezed == pairingKey ? _self.pairingKey : pairingKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TvDevice].
extension TvDevicePatterns on TvDevice {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TvDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TvDevice() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TvDevice value)  $default,){
final _that = this;
switch (_that) {
case _TvDevice():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TvDevice value)?  $default,){
final _that = this;
switch (_that) {
case _TvDevice() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ipAddress,  TvProtocol protocol,  String? modelName,  String? pairingKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TvDevice() when $default != null:
return $default(_that.id,_that.name,_that.ipAddress,_that.protocol,_that.modelName,_that.pairingKey);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ipAddress,  TvProtocol protocol,  String? modelName,  String? pairingKey)  $default,) {final _that = this;
switch (_that) {
case _TvDevice():
return $default(_that.id,_that.name,_that.ipAddress,_that.protocol,_that.modelName,_that.pairingKey);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ipAddress,  TvProtocol protocol,  String? modelName,  String? pairingKey)?  $default,) {final _that = this;
switch (_that) {
case _TvDevice() when $default != null:
return $default(_that.id,_that.name,_that.ipAddress,_that.protocol,_that.modelName,_that.pairingKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TvDevice implements TvDevice {
  const _TvDevice({required this.id, required this.name, required this.ipAddress, required this.protocol, this.modelName, this.pairingKey});
  factory _TvDevice.fromJson(Map<String, dynamic> json) => _$TvDeviceFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ipAddress;
@override final  TvProtocol protocol;
@override final  String? modelName;
@override final  String? pairingKey;

/// Create a copy of TvDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TvDeviceCopyWith<_TvDevice> get copyWith => __$TvDeviceCopyWithImpl<_TvDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TvDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TvDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.pairingKey, pairingKey) || other.pairingKey == pairingKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ipAddress,protocol,modelName,pairingKey);

@override
String toString() {
  return 'TvDevice(id: $id, name: $name, ipAddress: $ipAddress, protocol: $protocol, modelName: $modelName, pairingKey: $pairingKey)';
}


}

/// @nodoc
abstract mixin class _$TvDeviceCopyWith<$Res> implements $TvDeviceCopyWith<$Res> {
  factory _$TvDeviceCopyWith(_TvDevice value, $Res Function(_TvDevice) _then) = __$TvDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ipAddress, TvProtocol protocol, String? modelName, String? pairingKey
});




}
/// @nodoc
class __$TvDeviceCopyWithImpl<$Res>
    implements _$TvDeviceCopyWith<$Res> {
  __$TvDeviceCopyWithImpl(this._self, this._then);

  final _TvDevice _self;
  final $Res Function(_TvDevice) _then;

/// Create a copy of TvDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ipAddress = null,Object? protocol = null,Object? modelName = freezed,Object? pairingKey = freezed,}) {
  return _then(_TvDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,protocol: null == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as TvProtocol,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,pairingKey: freezed == pairingKey ? _self.pairingKey : pairingKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
