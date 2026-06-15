import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../../../models/tv_device.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/section_header.dart';
import '../../discovery/application/discovery_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paired = ref.watch(pairedDevicesProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SectionHeader('Appearance'),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (mode) =>
                ref.read(themeModeProvider.notifier).state = mode!,
            child: const Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('System'),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Light'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Dark'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(),
          const SectionHeader('Paired devices'),
          paired.when(
            data: (devices) => devices.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('No paired devices yet.'),
                  )
                : Column(
                    children: devices
                        .map((d) => _PairedDeviceTile(device: d))
                        .toList(),
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) =>
                Padding(padding: const EdgeInsets.all(16), child: Text('Error: $error')),
          ),
          const Divider(),
          const SectionHeader('Coming soon'),
          const ListTile(
            leading: Icon(Icons.android),
            title: Text('Android TV'),
          ),
          const ListTile(
            leading: Icon(Icons.cast),
            title: Text('Chromecast'),
          ),
          const ListTile(
            leading: Icon(Icons.airplay),
            title: Text('AirPlay (Apple TV)'),
          ),
        ],
      ),
    );
  }
}

class _PairedDeviceTile extends ConsumerWidget {
  const _PairedDeviceTile({required this.device});

  final TvDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(device.name),
      subtitle: Text(device.modelName ?? device.ipAddress),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Forget device',
        onPressed: () async {
          await ref.read(deviceRepositoryProvider).removeDevice(device.id);
          ref.invalidate(pairedDevicesProvider);
        },
      ),
    );
  }
}
