import 'package:flutter/material.dart';

import '../../../../core/tv/tv_controller.dart';
import '../../../../shared/widgets/remote_button.dart';

/// Bottom sheet with a 0-9 number pad for channel entry.
class NumberPadSheet extends StatelessWidget {
  const NumberPadSheet({super.key, required this.controller});

  final TvController controller;

  static Future<void> show(BuildContext context, TvController controller) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => NumberPadSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: List.generate(10, (digit) => digit).map((digit) {
            return RemoteButton(
              label: '$digit',
              size: 64,
              onPressed: () => controller.sendNumber(digit),
            );
          }).toList(),
        ),
      ),
    );
  }
}
