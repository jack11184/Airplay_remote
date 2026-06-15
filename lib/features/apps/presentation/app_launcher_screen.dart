import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/tv/tv_controller.dart';
import '../../../core/tv/tv_controller_providers.dart';
import '../../../models/tv_app.dart';
import '../../../models/tv_device.dart';
import '../application/app_list_provider.dart';

class AppLauncherScreen extends ConsumerWidget {
  const AppLauncherScreen({super.key, required this.device});

  final TvDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(appListProvider(device));
    final connection = ref.watch(tvConnectProvider(device));

    return Scaffold(
      appBar: AppBar(title: Text('${device.name} Apps')),
      body: apps.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(child: Text('No apps found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _AppTile(
                app: app,
                onTap: connection.hasValue
                    ? () => _launch(context, connection.requireValue, app)
                    : null,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load apps: $error')),
      ),
    );
  }

  Future<void> _launch(
    BuildContext context,
    TvController controller,
    TvApp app,
  ) async {
    HapticFeedback.lightImpact();
    final result = await controller.launchApp(app);
    if (!result.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to launch ${app.name}'),
        ),
      );
    }
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app, this.onTap});

  final TvApp app;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: app.iconUrl != null
                  ? Image.network(
                      app.iconUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.tv, size: 32),
                    )
                  : const Icon(Icons.tv, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            app.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
