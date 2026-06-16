/// Vizio SmartCast remote key codes as (CODESET, CODE) pairs, sent to
/// `/key_command/` with `ACTION: "KEYPRESS"`.
///
/// Values are taken from the documented SmartCast key map (see the exiva and
/// pyvizio API references). Each codeset groups related keys; the code
/// selects the specific key within that group.
class VizioKey {
  const VizioKey(this.codeset, this.code);

  final int codeset;
  final int code;

  // Media transport (codeset 2)
  static const seekForward = VizioKey(2, 0);
  static const seekBack = VizioKey(2, 1);
  static const pause = VizioKey(2, 2);
  static const play = VizioKey(2, 3);

  // Navigation / D-pad (codeset 3)
  static const down = VizioKey(3, 0);
  static const left = VizioKey(3, 1);
  static const ok = VizioKey(3, 2);
  static const right = VizioKey(3, 7);
  static const up = VizioKey(3, 8);

  // Menus (codeset 4)
  static const back = VizioKey(4, 0);
  static const menu = VizioKey(4, 8);
  static const home = VizioKey(4, 15);

  // Exit (codeset 9)
  static const exit = VizioKey(9, 0);

  // Audio (codeset 5)
  static const volumeDown = VizioKey(5, 0);
  static const volumeUp = VizioKey(5, 1);
  static const muteOff = VizioKey(5, 2);
  static const muteOn = VizioKey(5, 3);
  static const muteToggle = VizioKey(5, 4);

  // Input / source (codeset 7)
  static const inputNext = VizioKey(7, 1);

  // Channels (codeset 8)
  static const channelDown = VizioKey(8, 0);
  static const channelUp = VizioKey(8, 1);

  // Power (codeset 11)
  static const powerOff = VizioKey(11, 0);
  static const powerOn = VizioKey(11, 1);
  static const powerToggle = VizioKey(11, 2);
}
