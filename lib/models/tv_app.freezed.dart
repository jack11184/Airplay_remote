// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_app.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TvApp {

 String get id; String get name; String? get iconUrl;
/// Create a copy of TvApp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TvAppCopyWith<TvApp> get copyWith => _$TvAppCopyWithImpl<TvApp>(this as TvApp, _$identity);

  /// Serializes this TvApp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TvApp&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl);

@override
String toString() {
  return 'TvApp(id: $id, name: $name, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class $TvAppCopyWith<$Res>  {
  factory $TvAppCopyWith(TvApp value, $Res Function(TvApp) _then) = _$TvAppCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? iconUrl
});




}
/// @nodoc
class _$TvAppCopyWithImpl<$Res>
    implements $TvAppCopyWith<$Res> {
  _$TvAppCopyWithImpl(this._self, this._then);

  final TvApp _self;
  final $Res Function(TvApp) _then;

/// Create a copy of TvApp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TvApp].
extension TvAppPatterns on TvApp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TvApp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TvApp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TvApp value)  $default,){
final _that = this;
switch (_that) {
case _TvApp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TvApp value)?  $default,){
final _that = this;
switch (_that) {
case _TvApp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? iconUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TvApp() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? iconUrl)  $default,) {final _that = this;
switch (_that) {
case _TvApp():
return $default(_that.id,_that.name,_that.iconUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? iconUrl)?  $default,) {final _that = this;
switch (_that) {
case _TvApp() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TvApp implements TvApp {
  const _TvApp({required this.id, required this.name, this.iconUrl});
  factory _TvApp.fromJson(Map<String, dynamic> json) => _$TvAppFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? iconUrl;

/// Create a copy of TvApp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TvAppCopyWith<_TvApp> get copyWith => __$TvAppCopyWithImpl<_TvApp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TvAppToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TvApp&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl);

@override
String toString() {
  return 'TvApp(id: $id, name: $name, iconUrl: $iconUrl)';
}


}

/// @nodoc
abstract mixin class _$TvAppCopyWith<$Res> implements $TvAppCopyWith<$Res> {
  factory _$TvAppCopyWith(_TvApp value, $Res Function(_TvApp) _then) = __$TvAppCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? iconUrl
});




}
/// @nodoc
class __$TvAppCopyWithImpl<$Res>
    implements _$TvAppCopyWith<$Res> {
  __$TvAppCopyWithImpl(this._self, this._then);

  final _TvApp _self;
  final $Res Function(_TvApp) _then;

/// Create a copy of TvApp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,}) {
  return _then(_TvApp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
