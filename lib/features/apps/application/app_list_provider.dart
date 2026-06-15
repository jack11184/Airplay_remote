import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tv/tizen/tizen_app_catalog.dart';
import '../../../core/tv/tv_controller_providers.dart';
import '../../../models/tv_app.dart';
import '../../../models/tv_device.dart';
import '../../../models/tv_protocol.dart';

/// Apps available to launch on [device]: live results from the TV where
/// supported (Roku/webOS), or the curated [tizenAppCatalog] for Samsung.
final appListProvider =
    FutureProvider.autoDispose.family<List<TvApp>, TvDevice>(
        (ref, device) async {
  final controller = await ref.watch(tvConnectProvider(device).future);
  final apps = await controller.listApps();
  if (apps != null) return apps;
  return device.protocol == TvProtocol.tizen ? tizenAppCatalog : const [];
});
