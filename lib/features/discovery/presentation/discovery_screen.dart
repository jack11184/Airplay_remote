import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/tv_device.dart';
import '../../../models/tv_protocol.dart';
import '../../../shared/widgets/section_header.dart';
import '../application/discovery_provider.dart';
import 'widgets/device_list_tile.dart';
import 'widgets/manual_entry_dialog.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discovered = ref.watch(discoveryProvider);
    final paired = ref.watch(pairedDevicesProvider);
    final isScanning = ref.watch(discoveryProvider.notifier).isScanning;
    final pairedIds = paired.value?.map((d) => d.id).toSet() ?? <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('TV Remote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(discoveryProvider.notifier).rescan(),
        child: ListView(
          children: [
            if (isScanning)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Scanning for TVs on your network...'),
                  ],
                ),
              ),
            ...paired.when(
              data: (devices) => devices.isEmpty
                  ? const <Widget>[]
                  : [
                      const SectionHeader('Paired devices'),
                      ...devices.map(
                        (d) => DeviceListTile(
                          device: d,
                          onTap: () => _connect(context, d),
                        ),
                      ),
                    ],
              loading: () => const <Widget>[],
              error: (_, _) => const <Widget>[],
            ),
            ...discovered.when(
              data: (devices) {
                final newDevices =
                    devices.where((d) => !pairedIds.contains(d.id)).toList();
                if (newDevices.isNotEmpty) {
                  return [
                    const SectionHeader('Discovered'),
                    ...newDevices.map(
                      (d) => DeviceListTile(
                        device: d,
                        onTap: () => _connect(context, d),
                      ),
                    ),
                  ];
                }
                if (!isScanning && pairedIds.isEmpty) {
                  return const [
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No TVs found.\nMake sure your TV and phone are on '
                          'the same Wi-Fi, or add one manually below.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ];
                }
                return const <Widget>[];
              },
              loading: () => const <Widget>[],
              error: (error, _) => [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Discovery error: $error'),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final device = await showDialog<TvDevice>(
            context: context,
            builder: (_) => const ManualEntryDialog(),
          );
          if (device != null && context.mounted) _connect(context, device);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add manually'),
      ),
    );
  }

  void _connect(BuildContext context, TvDevice device) {
    final needsPairing =
        device.protocol != TvProtocol.roku && device.pairingKey == null;
    if (needsPairing) {
      context.push('/pairing', extra: device);
    } else {
      context.push('/remote', extra: device);
    }
  }
}
