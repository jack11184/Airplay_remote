import 'package:go_router/go_router.dart';

import '../features/apps/presentation/app_launcher_screen.dart';
import '../features/discovery/presentation/discovery_screen.dart';
import '../features/pairing/presentation/pairing_screen.dart';
import '../features/remote/presentation/remote_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../models/tv_device.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DiscoveryScreen(),
    ),
    GoRoute(
      path: '/pairing',
      builder: (context, state) =>
          PairingScreen(device: state.extra as TvDevice),
    ),
    GoRoute(
      path: '/remote',
      builder: (context, state) =>
          RemoteScreen(device: state.extra as TvDevice),
    ),
    GoRoute(
      path: '/remote/apps',
      builder: (context, state) =>
          AppLauncherScreen(device: state.extra as TvDevice),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
