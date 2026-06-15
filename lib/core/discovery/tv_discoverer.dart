import '../../models/tv_device.dart';
import '../../models/tv_protocol.dart';

/// Discovers TVs of a single [protocol] on the local network.
abstract class TvDiscoverer {
  TvProtocol get protocol;

  /// Emits a [TvDevice] for each device found. The stream closes itself
  /// once [timeout] elapses.
  Stream<TvDevice> discover({Duration timeout = const Duration(seconds: 4)});
}
