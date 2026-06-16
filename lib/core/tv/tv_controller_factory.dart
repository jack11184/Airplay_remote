import '../../models/tv_device.dart';
import '../../models/tv_protocol.dart';
import '../storage/secure_storage_service.dart';
import 'roku/roku_controller.dart';
import 'tizen/tizen_controller.dart';
import 'tv_controller.dart';
import 'vizio/vizio_controller.dart';
import 'webos/webos_controller.dart';

/// Builds the right [TvController] implementation for a [TvDevice] based on
/// its [TvProtocol].
class TvControllerFactory {
  TvControllerFactory(this._secureStorage);

  // ignore: unused_field
  final SecureStorageService _secureStorage;

  TvController create(TvDevice device) {
    switch (device.protocol) {
      case TvProtocol.roku:
        return RokuController(device);
      case TvProtocol.webOs:
        return WebOsController(device);
      case TvProtocol.tizen:
        return TizenController(device);
      case TvProtocol.vizio:
        return VizioController(device);
    }
  }
}
