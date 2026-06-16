/// The smart-TV remote-control protocol a [TvDevice] speaks.
enum TvProtocol {
  roku,
  webOs,
  tizen,
  vizio,
}

/// Human-readable brand label for a [TvProtocol], used across the UI and for
/// naming freshly-discovered devices.
extension TvProtocolLabel on TvProtocol {
  String get label {
    switch (this) {
      case TvProtocol.roku:
        return 'Roku';
      case TvProtocol.webOs:
        return 'LG webOS';
      case TvProtocol.tizen:
        return 'Samsung Tizen';
      case TvProtocol.vizio:
        return 'Vizio SmartCast';
    }
  }

  /// Whether this protocol requires a pairing handshake before it can be
  /// controlled. Roku's ECP is open; the others need a key/token/PIN.
  bool get requiresPairing => this != TvProtocol.roku;
}
