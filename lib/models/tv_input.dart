/// An external input/source on a TV (HDMI, AV, tuner, ...).
class TvInput {
  const TvInput({required this.id, required this.name});

  /// Protocol-specific identifier used to select this input (e.g. the Roku
  /// ECP keypress `InputHDMI1`, or the webOS `inputId` `HDMI_1`).
  final String id;

  /// Human-readable label shown in the input picker (e.g. "HDMI 1").
  final String name;
}
