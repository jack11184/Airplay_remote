import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/tv/tv_controller.dart';
import '../../../../models/command_result.dart';

/// Popup keyboard for typing into the TV's focused text field (search boxes,
/// logins, ...).
///
/// For incremental keyboards (Roku, webOS) keystrokes are mirrored to the TV
/// live as you type, including backspaces. For replace-style keyboards
/// (Samsung) the full text is sent when you press Send. TVs without any text
/// API (Vizio SmartCast) get an explanatory message instead.
class KeyboardSheet extends StatefulWidget {
  const KeyboardSheet({super.key, required this.controller});

  final TvController controller;

  static Future<void> show(BuildContext context, TvController controller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        // Lift the sheet above the on-screen keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: KeyboardSheet(controller: controller),
      ),
    );
  }

  @override
  State<KeyboardSheet> createState() => _KeyboardSheetState();
}

class _KeyboardSheetState extends State<KeyboardSheet> {
  final _textController = TextEditingController();

  /// What we believe is currently in the TV's field (incremental mode).
  String _mirror = '';

  /// Serialises sends so fast typing can't interleave network calls.
  Future<void> _queue = Future.value();

  TvController get controller => widget.controller;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (!controller.keyboardIsIncremental) return;
    _queue = _queue.then((_) => _mirrorTo(value));
  }

  Future<void> _mirrorTo(String value) async {
    var prefix = 0;
    final max = math.min(_mirror.length, value.length);
    while (prefix < max && _mirror.codeUnitAt(prefix) == value.codeUnitAt(prefix)) {
      prefix++;
    }
    final deletions = _mirror.length - prefix;
    for (var i = 0; i < deletions; i++) {
      await controller.sendKeyboardBackspace();
    }
    final additions = value.substring(prefix);
    if (additions.isNotEmpty) {
      await controller.sendText(additions);
    }
    _mirror = value;
  }

  Future<void> _notify(CommandResult result) async {
    if (!result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Failed to type')),
      );
    }
  }

  Future<void> _sendWhole() async {
    await _notify(await controller.sendText(_textController.text));
  }

  Future<void> _enter() async {
    if (controller.keyboardIsIncremental) {
      await _queue;
    }
    await _notify(await controller.sendKeyboardEnter());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.supportsKeyboard) {
      return _unsupported(context);
    }

    final incremental = controller.keyboardIsIncremental;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Keyboard', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (_) => _enter(),
              decoration: InputDecoration(
                hintText: incremental
                    ? 'Type here — appears on your TV live'
                    : 'Type, then Send to your TV',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.keyboard),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!incremental)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sendWhole,
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ),
                if (!incremental) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _enter,
                    icon: const Icon(Icons.keyboard_return),
                    label: const Text('Enter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _unsupported(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.keyboard_hide, size: 40),
            const SizedBox(height: 12),
            Text(
              'Typing not supported',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${controller.device.name} has no text-input API. Use the D-pad '
              'to navigate the on-screen keyboard on your TV.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
