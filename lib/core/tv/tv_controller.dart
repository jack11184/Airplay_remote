import '../../models/command_result.dart';
import '../../models/tv_app.dart';
import '../../models/tv_connection_state.dart';
import '../../models/tv_device.dart';
import '../../models/tv_device_info.dart';
import '../../models/tv_input.dart';

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

  /// Submits the pairing PIN shown on the TV while [connect] is blocked in
  /// [TvConnectionState.awaitingPairingCode] (Vizio). Other protocols, which
  /// pair via an on-screen accept prompt rather than a typed code, return a
  /// failure result.
  Future<CommandResult> submitPairingCode(String code);

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

  // --- Inputs ---

  /// Lists the TV's external inputs (HDMI/AV/tuner), or `null` if this
  /// protocol can't enumerate them (in which case callers fall back to
  /// [sendInput] to open the TV's own chooser or cycle inputs).
  Future<List<TvInput>?> listInputs();

  /// Switches to [input], which must come from [listInputs].
  Future<CommandResult> selectInput(TvInput input);

  /// Opens the TV's input/source selector or advances to the next input, for
  /// protocols that don't enumerate inputs.
  Future<CommandResult> sendInput();

  // --- Keyboard / text entry ---

  /// Whether this TV can receive typed text from the remote (search boxes,
  /// login fields, ...). Vizio SmartCast, for example, exposes no text API.
  bool get supportsKeyboard;

  /// Whether [sendText] appends to the focused field (so live, character-by-
  /// character typing with [sendKeyboardBackspace] works), versus replacing
  /// the field's entire contents on each call. Roku/webOS are incremental;
  /// Samsung replaces.
  bool get keyboardIsIncremental;

  /// Types [text] into the TV's focused field. For incremental keyboards
  /// [text] is the fragment to append; otherwise it replaces the field.
  Future<CommandResult> sendText(String text);

  /// Deletes one character from the focused field (incremental keyboards).
  Future<CommandResult> sendKeyboardBackspace();

  /// Submits/confirms the focused field (enter / search).
  Future<CommandResult> sendKeyboardEnter();

  // --- Device info ---

  Future<TvDeviceInfo> getDeviceInfo();
}
