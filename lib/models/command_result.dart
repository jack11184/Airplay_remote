import 'package:freezed_annotation/freezed_annotation.dart';

part 'command_result.freezed.dart';

/// Outcome of sending a single remote-control command to a [TvDevice].
@freezed
abstract class CommandResult with _$CommandResult {
  const factory CommandResult({
    required bool success,
    String? errorMessage,
  }) = _CommandResult;

  factory CommandResult.ok() => const CommandResult(success: true);

  factory CommandResult.failure(String message) =>
      CommandResult(success: false, errorMessage: message);
}
