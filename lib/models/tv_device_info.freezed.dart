// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_device_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TvDeviceInfo {

 String get modelName; String? get serialNumber; String? get softwareVersion;
/// Create a copy of TvDeviceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TvDeviceInfoCopyWith<TvDeviceInfo> get copyWith => _$TvDeviceInfoCopyWithImpl<TvDeviceInfo>(this as TvDeviceInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TvDeviceInfo&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.softwareVersion, softwareVersion) || other.softwareVersion == softwareVersion));
}


@override
int get hashCode => Object.hash(runtimeType,modelName,serialNumber,softwareVersion);

@override
String toString() {
  return 'TvDeviceInfo(modelName: $modelName, serialNumber: $serialNumber, softwareVersion: $softwareVersion)';
}


}

/// @nodoc
abstract mixin class $TvDeviceInfoCopyWith<$Res>  {
  factory $TvDeviceInfoCopyWith(TvDeviceInfo value, $Res Function(TvDeviceInfo) _then) = _$TvDeviceInfoCopyWithImpl;
@useResult
$Res call({
 String modelName, String? serialNumber, String? softwareVersion
});




}
/// @nodoc
class _$TvDeviceInfoCopyWithImpl<$Res>
    implements $TvDeviceInfoCopyWith<$Res> {
  _$TvDeviceInfoCopyWithImpl(this._self, this._then);

  final TvDeviceInfo _self;
  final $Res Function(TvDeviceInfo) _then;

/// Create a copy of TvDeviceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? modelName = null,Object? serialNumber = freezed,Object? softwareVersion = freezed,}) {
  return _then(_self.copyWith(
modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,softwareVersion: freezed == softwareVersion ? _self.softwareVersion : softwareVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TvDeviceInfo].
extension TvDeviceInfoPatterns on TvDeviceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TvDeviceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TvDeviceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TvDeviceInfo value)  $default,){
final _that = this;
switch (_that) {
case _TvDeviceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TvDeviceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TvDeviceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String modelName,  String? serialNumber,  String? softwareVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TvDeviceInfo() when $default != null:
return $default(_that.modelName,_that.serialNumber,_that.softwareVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String modelName,  String? serialNumber,  String? softwareVersion)  $default,) {final _that = this;
switch (_that) {
case _TvDeviceInfo():
return $default(_that.modelName,_that.serialNumber,_that.softwareVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String modelName,  String? serialNumber,  String? softwareVersion)?  $default,) {final _that = this;
switch (_that) {
case _TvDeviceInfo() when $default != null:
return $default(_that.modelName,_that.serialNumber,_that.softwareVersion);case _:
  return null;

}
}

}

/// @nodoc


class _TvDeviceInfo implements TvDeviceInfo {
  const _TvDeviceInfo({required this.modelName, this.serialNumber, this.softwareVersion});
  

@override final  String modelName;
@override final  String? serialNumber;
@override final  String? softwareVersion;

/// Create a copy of TvDeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TvDeviceInfoCopyWith<_TvDeviceInfo> get copyWith => __$TvDeviceInfoCopyWithImpl<_TvDeviceInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TvDeviceInfo&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.softwareVersion, softwareVersion) || other.softwareVersion == softwareVersion));
}


@override
int get hashCode => Object.hash(runtimeType,modelName,serialNumber,softwareVersion);

@override
String toString() {
  return 'TvDeviceInfo(modelName: $modelName, serialNumber: $serialNumber, softwareVersion: $softwareVersion)';
}


}

/// @nodoc
abstract mixin class _$TvDeviceInfoCopyWith<$Res> implements $TvDeviceInfoCopyWith<$Res> {
  factory _$TvDeviceInfoCopyWith(_TvDeviceInfo value, $Res Function(_TvDeviceInfo) _then) = __$TvDeviceInfoCopyWithImpl;
@override @useResult
$Res call({
 String modelName, String? serialNumber, String? softwareVersion
});




}
/// @nodoc
class __$TvDeviceInfoCopyWithImpl<$Res>
    implements _$TvDeviceInfoCopyWith<$Res> {
  __$TvDeviceInfoCopyWithImpl(this._self, this._then);

  final _TvDeviceInfo _self;
  final $Res Function(_TvDeviceInfo) _then;

/// Create a copy of TvDeviceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? modelName = null,Object? serialNumber = freezed,Object? softwareVersion = freezed,}) {
  return _then(_TvDeviceInfo(
modelName: null == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,softwareVersion: freezed == softwareVersion ? _self.softwareVersion : softwareVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
