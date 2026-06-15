import '../../models/command_result.dart';
import '../../models/tv_app.dart';
import '../../models/tv_connection_state.dart';
import '../../models/tv_device.dart';
import '../../models/tv_device_info.dart';

/// A direction sent to a TV's directional pad.
enum DPadDirection { up, down, left, right }

/// Protocol-agnostic remote control for a single [TvDevice].
///
/// Each TV brand (Roku, LG webOS, Samsung Tizen, ...) provides its own
/// implementation so the UI layer can drive any supported TV through this
/// single interface.
abstract class TvController {
  /// The device this controller talks to.
  TvDevice get device;

  /// Emits the connection lifecycle as [connect] proceeds.
  Stream<TvConnectionState> get connectionState;

  /// Emits a new pairing credential (webOS client-key / Tizen token)
  /// whenever one is received during [connect], so callers can persist it
  /// via the device repository.
  Stream<String> get pairingKeyUpdates;

  /// Opens the connection, performing a pairing handshake if needed.
  ///
  /// For webOS/Tizen this may emit [TvConnectionState.awaitingPairingConfirmation]
  /// while an on-screen prompt is shown, before settling on
  /// [TvConnectionState.connected] or [TvConnectionState.error].
  Future<void> connect();

  /// Closes the connection and releases any sockets.
  Future<void> disconnect();

  // --- Remote control commands ---

  Future<CommandResult> sendPower();
  Future<CommandResult> sendVolumeUp();
  Future<CommandResult> sendVolumeDown();
  Future<CommandResult> sendMute();
  Future<CommandResult> sendDirection(DPadDirection direction);
  Future<CommandResult> sendSelect();
  Future<CommandResult> sendHome();
  Future<CommandResult> sendBack();
  Future<CommandResult> sendNumber(int digit);
  Future<CommandResult> sendPlayPause();
  Future<CommandResult> sendRewind();
  Future<CommandResult> sendFastForward();

  // --- Apps ---

  /// Returns the apps installed on the TV, or `null` if this protocol/
  /// firmware doesn't support live app listing (callers should fall back
  /// to a curated static list, as is done for Samsung Tizen).
  Future<List<TvApp>?> listApps();

  Future<CommandResult> launchApp(TvApp app);

  // --- Device info ---

  Future<TvDeviceInfo> getDeviceInfo();
}
