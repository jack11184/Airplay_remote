import 'package:flutter/material.dart';

import '../../../../core/tv/tv_controller.dart';
import '../../../../shared/widgets/remote_button.dart';

/// A directional pad with a center select/OK button.
class DPadWidget extends StatelessWidget {
  const DPadWidget({super.key, required this.controller});

  final TvController controller;

  @override
  Widget build(BuildContext context) {
    const buttonSize = 56.0;
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_up,
              size: buttonSize,
              tooltip: 'Up',
              onPressed: () => controller.sendDirection(DPadDirection.up),
            ),
          ),
          Positioned(
            bottom: 0,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_down,
              size: buttonSize,
              tooltip: 'Down',
              onPressed: () => controller.sendDirection(DPadDirection.down),
            ),
          ),
          Positioned(
            left: 0,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_left,
              size: buttonSize,
              tooltip: 'Left',
              onPressed: () => controller.sendDirection(DPadDirection.left),
            ),
          ),
          Positioned(
            right: 0,
            child: RemoteButton(
              icon: Icons.keyboard_arrow_right,
              size: buttonSize,
              tooltip: 'Right',
              onPressed: () => controller.sendDirection(DPadDirection.right),
            ),
          ),
          RemoteButton(
            label: 'OK',
            size: 76,
            tooltip: 'Select',
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: controller.sendSelect,
          ),
        ],
      ),
    );
  }
}
