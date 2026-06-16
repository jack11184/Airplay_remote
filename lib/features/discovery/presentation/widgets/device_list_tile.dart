import 'package:flutter/material.dart';

import '../../../../models/tv_device.dart';
import '../../../../models/tv_protocol.dart';

class DeviceListTile extends StatelessWidget {
  const DeviceListTile({
    super.key,
    required this.device,
    required this.onTap,
  });

  final TvDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(_iconFor(device.protocol))),
      title: Text(device.name),
      subtitle: Text(device.modelName ?? device.ipAddress),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  IconData _iconFor(TvProtocol protocol) {
    switch (protocol) {
      case TvProtocol.roku:
        return Icons.tv;
      case TvProtocol.webOs:
        return Icons.live_tv;
      case TvProtocol.tizen:
        return Icons.smart_display;
      case TvProtocol.vizio:
        return Icons.cast_connected;
    }
  }
}
