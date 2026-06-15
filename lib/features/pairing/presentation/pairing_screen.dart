import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/tv/tv_controller_providers.dart';
import '../../../models/tv_connection_state.dart';
import '../../../models/tv_device.dart';

/// Transient screen shown while connecting to a webOS/Tizen TV for the
/// first time: the TV shows an on-screen "allow this app?" prompt that the
/// user must accept before pairing completes.
class PairingScreen extends ConsumerWidget {
  const PairingScreen({super.key, required this.device});

  final TvDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(tvConnectionStateProvider(device));
    final connection = ref.watch(tvConnectProvider(device));

    ref.listen(tvConnectProvider(device), (previous, next) {
      if (next.hasValue && !next.isLoading) {
        context.pushReplacement('/remote', extra: device);
      }
    });

    final state = connectionState.value;
    final isAwaitingPrompt =
        state == TvConnectionState.awaitingPairingConfirmation;
    final hasError =
        connection.hasError || state == TvConnectionState.error;

    return Scaffold(
      appBar: AppBar(title: Text('Pair with ${device.name}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasError ? Icons.error_outline : Icons.live_tv,
                size: 64,
                color: hasError ? Theme.of(context).colorScheme.error : null,
              ),
              const SizedBox(height: 24),
              if (hasError) ...[
                Text(
                  "Couldn't connect to ${device.name}.",
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${connection.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(tvControllerInstanceProvider(device)),
                  child: const Text('Retry'),
                ),
              ] else if (isAwaitingPrompt) ...[
                Text(
                  'Check your TV screen',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accept the connection request shown on your TV to finish '
                  'pairing.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ] else ...[
                Text(
                  'Connecting to ${device.name}...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
