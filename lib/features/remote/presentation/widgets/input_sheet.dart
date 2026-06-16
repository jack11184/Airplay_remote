import 'package:flutter/material.dart';

import '../../../../core/tv/tv_controller.dart';
import '../../../../models/command_result.dart';
import '../../../../models/tv_input.dart';

/// Bottom sheet for switching the TV's input/source.
///
/// For protocols that can enumerate inputs (Roku's fixed HDMI/AV/tuner set,
/// LG's live external-input list) it shows them as a pick list. For protocols
/// that can't (Samsung, Vizio) it offers a single action that opens the TV's
/// own input chooser or advances to the next source.
class InputSheet extends StatefulWidget {
  const InputSheet({super.key, required this.controller});

  final TvController controller;

  static Future<void> show(BuildContext context, TvController controller) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => InputSheet(controller: controller),
    );
  }

  @override
  State<InputSheet> createState() => _InputSheetState();
}

class _InputSheetState extends State<InputSheet> {
  late final Future<List<TvInput>?> _inputs = widget.controller.listInputs();

  Future<void> _run(Future<CommandResult> Function() action) async {
    final result = await action();
    if (!mounted) return;
    Navigator.of(context).pop();
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to change input'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<TvInput>?>(
        future: _inputs,
        builder: (context, snapshot) {
          final loading =
              snapshot.connectionState != ConnectionState.done;
          final inputs = snapshot.data;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Input',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (inputs != null && inputs.isNotEmpty)
                ...inputs.map(
                  (input) => ListTile(
                    leading: const Icon(Icons.input),
                    title: Text(input.name),
                    onTap: () => _run(() => widget.controller.selectInput(input)),
                  ),
                )
              else
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: const Text('Switch input'),
                  subtitle: const Text(
                    'Opens the input menu on your TV or moves to the next '
                    'source',
                  ),
                  onTap: () => _run(widget.controller.sendInput),
                ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
