import 'package:flutter/material.dart';

import '../../../../models/tv_device.dart';
import '../../../../models/tv_protocol.dart';

/// Fallback for when SSDP discovery doesn't find a TV: lets the user enter
/// an IP address and protocol directly. Returns the constructed [TvDevice]
/// via [Navigator.pop], or null if cancelled.
class ManualEntryDialog extends StatefulWidget {
  const ManualEntryDialog({super.key});

  @override
  State<ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<ManualEntryDialog> {
  final _ipController = TextEditingController();
  TvProtocol _protocol = TvProtocol.roku;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add device manually'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TvProtocol>(
            initialValue: _protocol,
            decoration: const InputDecoration(labelText: 'TV type'),
            items: TvProtocol.values
                .map((protocol) => DropdownMenuItem(
                      value: protocol,
                      child: Text(protocol.label),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _protocol = value);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: 'IP address',
              hintText: '192.168.1.50',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final ip = _ipController.text.trim();
            if (ip.isEmpty) return;
            Navigator.of(context).pop(
              TvDevice(
                id: '${_protocol.name}:$ip',
                name: '${_protocol.label} TV',
                ipAddress: ip,
                protocol: _protocol,
              ),
            );
          },
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
