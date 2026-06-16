import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/command_result.dart';

/// A circular remote-control button: gives haptic feedback on tap, sends
/// [onPressed], and surfaces a snackbar if the command fails.
class RemoteButton extends StatelessWidget {
  const RemoteButton({
    super.key,
    this.icon,
    this.label,
    required this.onPressed,
    this.size = 56,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  }) : assert(icon != null || label != null);

  final IconData? icon;
  final String? label;
  final Future<CommandResult> Function() onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  Future<void> _handleTap(BuildContext context) async {
    HapticFeedback.lightImpact();
    CommandResult result = await onPressed();
    if (!result.success) {
      await Future.delayed(const Duration(milliseconds: 500));
      result = await onPressed();
    }
    if (!result.success) {
      await Future.delayed(const Duration(milliseconds: 500));
      result = await onPressed();
    }
    if (!result.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Command failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = icon != null
        ? Icon(icon, color: foregroundColor)
        : Text(
            label!,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          );

    final button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _handleTap(context),
          child: Center(child: child),
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: button) : button;
  }
}
