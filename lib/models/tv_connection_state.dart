/// Lifecycle state of a [TvController]'s connection to a TV.
enum TvConnectionState {
  disconnected,
  connecting,

  /// webOS/Tizen only: waiting for the user to accept the on-screen
  /// pairing prompt.
  awaitingPairingConfirmation,

  /// Vizio only: the TV is displaying a PIN that the user must type into the
  /// app to finish pairing (see [TvController.submitPairingCode]).
  awaitingPairingCode,
  connected,
  error,
}
