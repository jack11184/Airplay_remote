import 'package:freezed_annotation/freezed_annotation.dart';

part 'tv_app.freezed.dart';
part 'tv_app.g.dart';

/// An app installed on (or launchable from) a TV.
@freezed
abstract class TvApp with _$TvApp {
  const factory TvApp({
    required String id,
    required String name,
    String? iconUrl,
  }) = _TvApp;

  factory TvApp.fromJson(Map<String, Object?> json) => _$TvAppFromJson(json);
}
