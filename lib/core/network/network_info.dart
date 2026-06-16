import 'dart:io';

/// A summary of the device's current local-network attachment, derived from
/// the active (non-loopback) IPv4 network interfaces.
class NetworkStatus {
  const NetworkStatus({
    required this.interfaceName,
    required this.ipAddress,
  });

  /// The OS interface name carrying the primary IPv4 address (e.g. `en0`).
  final String interfaceName;

  /// The device's own IPv4 address on that interface.
  final String ipAddress;

  /// The `/24` network prefix the device sits on, e.g. `192.168.1`. Used as a
  /// short, human-recognisable label for "the network you're on".
  String get subnetLabel {
    final parts = ipAddress.split('.');
    if (parts.length != 4) return ipAddress;
    return '${parts[0]}.${parts[1]}.${parts[2]}.x';
  }
}

/// Reads the host's local-network attachment using `dart:io` only (no
/// plugins, no permissions). This is what lets discovery target the actual
/// Wi-Fi/LAN interface(s) rather than whatever interface the OS happens to
/// pick by default for a `0.0.0.0` bind.
class NetworkInfoService {
  /// All active IPv4 interfaces, excluding loopback and link-local
  /// (`169.254.x.x`) addresses. These are the interfaces SSDP/discovery
  /// should bind to and send from.
  Future<List<NetworkInterface>> activeIpv4Interfaces() async {
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );
    return interfaces
        .where((iface) => iface.addresses.any(_isUsable))
        .toList();
  }

  /// The best-guess primary network the device is attached to, or `null` if
  /// the device has no usable IPv4 interface (e.g. offline).
  Future<NetworkStatus?> currentNetwork() async {
    final interfaces = await activeIpv4Interfaces();
    if (interfaces.isEmpty) return null;

    // Prefer a private-range address (the LAN the TV is on) on the
    // lowest-numbered interface, which on macOS/iOS is typically Wi-Fi/en0.
    interfaces.sort((a, b) => a.name.compareTo(b.name));
    for (final iface in interfaces) {
      for (final addr in iface.addresses) {
        if (_isUsable(addr) && _isPrivate(addr)) {
          return NetworkStatus(
            interfaceName: iface.name,
            ipAddress: addr.address,
          );
        }
      }
    }

    final fallback = interfaces.first;
    final addr = fallback.addresses.firstWhere(_isUsable);
    return NetworkStatus(
      interfaceName: fallback.name,
      ipAddress: addr.address,
    );
  }

  static bool _isUsable(InternetAddress addr) =>
      addr.type == InternetAddressType.IPv4 &&
      !addr.isLoopback &&
      !addr.address.startsWith('169.254.');

  static bool _isPrivate(InternetAddress addr) {
    final ip = addr.address;
    if (ip.startsWith('192.168.') || ip.startsWith('10.')) return true;
    // 172.16.0.0 – 172.31.255.255
    if (ip.startsWith('172.')) {
      final second = int.tryParse(ip.split('.')[1]) ?? 0;
      return second >= 16 && second <= 31;
    }
    return false;
  }
}
