import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tv/tizen/tizen_app_catalog.dart';
import '../../../core/tv/tv_controller_providers.dart';
import '../../../core/tv/vizio/vizio_app_catalog.dart';
import '../../../models/tv_app.dart';
import '../../../models/tv_device.dart';
import '../../../models/tv_protocol.dart';

/// Apps available to launch on [device]: live results from the TV where
/// supported (Roku/webOS), or a curated/published catalog otherwise
/// (Samsung's static list, Vizio's self-updating published catalog).
final appListProvider =
    FutureProvider.autoDispose.family<List<TvApp>, TvDevice>(
        (ref, device) async {
  final controller = await ref.watch(tvConnectProvider(device).future);
  final apps = await controller.listApps();
  if (apps != null) return apps;

  switch (device.protocol) {
    case TvProtocol.tizen:
      return tizenAppCatalog;
    case TvProtocol.vizio:
      return ref.watch(vizioAppCatalogProvider).fetch();
    default:
      return const [];
  }
});
