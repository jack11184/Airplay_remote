/// Lifecycle state of a [TvController]'s connection to a TV.
enum TvConnectionState {
  disconnected,
  connecting,

  /// webOS/Tizen only: waiting for the user to accept the on-screen
  /// pairing prompt.
  awaitingPairingConfirmation,
  connected,
  error,
}
