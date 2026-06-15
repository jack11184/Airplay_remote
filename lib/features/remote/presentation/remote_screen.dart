import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/tv/tv_controller.dart';
import '../../../core/tv/tv_controller_providers.dart';
import '../../../models/command_result.dart';
import '../../../models/tv_connection_state.dart';
import '../../../models/tv_device.dart';
import '../../../shared/widgets/remote_button.dart';
import 'widgets/dpad_widget.dart';
import 'widgets/number_pad_sheet.dart';

class RemoteScreen extends ConsumerWidget {
  const RemoteScreen({super.key, required this.device});

  final TvDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(tvConnectionStateProvider(device));
    final connection = ref.watch(tvConnectProvider(device));

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          _ConnectionIndicator(state: connectionState.value),
          IconButton(
            icon: const Icon(Icons.apps),
            tooltip: 'Apps',
            onPressed: connection.hasValue
                ? () => context.push('/remote/apps', extra: device)
                : null,
          ),
        ],
      ),
      body: connection.when(
        data: (controller) => _RemoteControls(controller: controller),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Could not connect to ${device.name}'),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(tvControllerInstanceProvider(device)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator({required this.state});

  final TvConnectionState? state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      TvConnectionState.connected => Colors.green,
      TvConnectionState.error => Theme.of(context).colorScheme.error,
      _ => Colors.grey,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.circle, size: 12, color: color),
    );
  }
}

class _RemoteControls extends StatelessWidget {
  const _RemoteControls({required this.controller});

  final TvController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: RemoteButton(
                icon: Icons.power_settings_new,
                tooltip: 'Power',
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onErrorContainer,
                onPressed: controller.sendPower,
              ),
            ),
            const Spacer(),
            DPadWidget(controller: controller),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RemoteButton(
                  icon: Icons.home,
                  tooltip: 'Home',
                  onPressed: controller.sendHome,
                ),
                RemoteButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Back',
                  onPressed: controller.sendBack,
                ),
                RemoteButton(
                  icon: Icons.dialpad,
                  tooltip: 'Number pad',
                  onPressed: () async {
                    await NumberPadSheet.show(context, controller);
                    return CommandResult.ok();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RemoteButton(
                  icon: Icons.fast_rewind,
                  tooltip: 'Rewind',
                  onPressed: controller.sendRewind,
                ),
                RemoteButton(
                  icon: Icons.play_arrow,
                  tooltip: 'Play/Pause',
                  onPressed: controller.sendPlayPause,
                ),
                RemoteButton(
                  icon: Icons.fast_forward,
                  tooltip: 'Fast forward',
                  onPressed: controller.sendFastForward,
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RemoteButton(
                  icon: Icons.volume_down,
                  tooltip: 'Volume down',
                  onPressed: controller.sendVolumeDown,
                ),
                const SizedBox(width: 16),
                RemoteButton(
                  icon: Icons.volume_off,
                  tooltip: 'Mute',
                  onPressed: controller.sendMute,
                ),
                const SizedBox(width: 16),
                RemoteButton(
                  icon: Icons.volume_up,
                  tooltip: 'Volume up',
                  onPressed: controller.sendVolumeUp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
