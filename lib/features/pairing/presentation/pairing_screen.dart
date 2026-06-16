import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/tv/tv_controller_providers.dart';
import '../../../models/tv_connection_state.dart';
import '../../../models/tv_device.dart';

/// Transient screen shown while connecting to a TV that needs pairing.
///
/// webOS/Tizen show an on-screen "allow this app?" prompt the user accepts on
/// the TV. Vizio instead displays a PIN that the user types here
/// ([TvConnectionState.awaitingPairingCode]).
class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key, required this.device});

  final TvDevice device;

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _pinController = TextEditingController();
  bool _submitting = false;
  String? _pinError;

  TvDevice get device => widget.device;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    final code = _pinController.text.trim();
    if (code.isEmpty) {
      setState(() => _pinError = 'Enter the code shown on your TV.');
      return;
    }
    setState(() {
      _submitting = true;
      _pinError = null;
    });
    final controller = ref.read(tvControllerInstanceProvider(device));
    final result = await controller.submitPairingCode(code);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _pinError = result.success ? null : (result.errorMessage ?? 'Pairing failed.');
    });
  }

  @override
  Widget build(BuildContext context) {
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
    final isAwaitingCode = state == TvConnectionState.awaitingPairingCode;
    final hasError = connection.hasError || state == TvConnectionState.error;

    return Scaffold(
      appBar: AppBar(title: Text('Pair with ${device.name}')),
      body: Center(
        child: SingleChildScrollView(
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
              if (hasError)
                ..._errorContent(context, connection.error)
              else if (isAwaitingCode)
                ..._pinContent(context)
              else if (isAwaitingPrompt)
                ..._promptContent(context)
              else
                ..._connectingContent(context),
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

  List<Widget> _errorContent(BuildContext context, Object? error) {
    return [
      Text(
        "Couldn't connect to ${device.name}.",
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        '$error',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => ref.invalidate(tvControllerInstanceProvider(device)),
        child: const Text('Retry'),
      ),
    ];
  }

  List<Widget> _pinContent(BuildContext context) {
    return [
      Text(
        'Enter the code on your TV',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        '${device.name} is showing a pairing code. Type it below to finish '
        'pairing.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 24),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: TextField(
          controller: _pinController,
          autofocus: true,
          enabled: !_submitting,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: Theme.of(context).textTheme.headlineSmall,
          decoration: InputDecoration(
            hintText: '1234',
            errorText: _pinError,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _submitPin(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _submitting ? null : _submitPin,
        child: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Pair'),
      ),
    ];
  }

  List<Widget> _promptContent(BuildContext context) {
    return [
      Text(
        'Check your TV screen',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      const Text(
        'Accept the connection request shown on your TV to finish pairing.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      const CircularProgressIndicator(),
    ];
  }

  List<Widget> _connectingContent(BuildContext context) {
    return [
      Text(
        'Connecting to ${device.name}...',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 24),
      const CircularProgressIndicator(),
    ];
  }
}
