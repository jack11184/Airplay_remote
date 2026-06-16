import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../network/network_info.dart';

/// A parsed SSDP M-SEARCH response (an HTTP-over-UDP "200 OK" message).
class SsdpResponse {
  SsdpResponse(this.headers, {this.remoteAddress});

  final Map<String, String> headers;

  /// The IP the datagram actually came from. Used as a fallback when a
  /// device omits or mis-reports its `LOCATION` host.
  final String? remoteAddress;

  String? get location => headers['location'];
  String? get searchTarget => headers['st'];
  String? get usn => headers['usn'];
  String? get server => headers['server'];

  /// Best available IP for the responding device: the `LOCATION` host when
  /// present and parseable, otherwise the datagram's source address.
  String? get host {
    final fromLocation = Uri.tryParse(location ?? '')?.host;
    if (fromLocation != null && fromLocation.isNotEmpty) return fromLocation;
    return remoteAddress;
  }
}

/// Minimal SSDP (Simple Service Discovery Protocol) client.
///
/// Sends UDP multicast M-SEARCH requests to 239.255.255.250:1900 and emits
/// each device's response. No mature, maintained Dart SSDP package exists,
/// so this is a small hand-rolled client - the same approach used by SSDP
/// discovery implementations in other languages.
///
/// Crucially, it binds and transmits on *every* active IPv4 interface rather
/// than a single `0.0.0.0` socket. On multi-homed hosts (a Mac with Wi-Fi +
/// Ethernet + VPN/bridge interfaces, for example) a `0.0.0.0` multicast send
/// egresses on only one OS-chosen interface, which is frequently not the one
/// the TV is on - the classic "discovery works on my phone but not my
/// laptop" failure. Fanning out across interfaces makes discovery reliable
/// regardless of how the network is wired.
class SsdpClient {
  SsdpClient({NetworkInfoService? networkInfo})
      : _networkInfo = networkInfo ?? NetworkInfoService();

  final NetworkInfoService _networkInfo;

  static final _multicastAddress = InternetAddress('239.255.255.250');
  static const _multicastPort = 1900;

  /// Sends an M-SEARCH for each of [searchTargets] from every active IPv4
  /// interface and emits every response received within [timeout]. The
  /// returned stream closes itself once [timeout] elapses.
  Stream<SsdpResponse> search({
    required List<String> searchTargets,
    Duration timeout = const Duration(seconds: 4),
    int mx = 2,
  }) {
    final controller = StreamController<SsdpResponse>();
    final sockets = <RawDatagramSocket>[];
    var closed = false;

    Future<void> closeAll() async {
      if (closed) return;
      closed = true;
      for (final socket in sockets) {
        socket.close();
      }
      if (!controller.isClosed) await controller.close();
    }

    () async {
      List<InternetAddress> bindAddresses;
      try {
        final interfaces = await _networkInfo.activeIpv4Interfaces();
        bindAddresses = [
          for (final iface in interfaces)
            for (final addr in iface.addresses)
              if (addr.type == InternetAddressType.IPv4) addr,
        ];
      } catch (_) {
        bindAddresses = const [];
      }
      // Always include the wildcard address so we still work if interface
      // enumeration comes back empty (e.g. restricted sandbox).
      if (bindAddresses.isEmpty) {
        bindAddresses = [InternetAddress.anyIPv4];
      }

      for (final bindAddress in bindAddresses) {
        try {
          final socket = await RawDatagramSocket.bind(bindAddress, 0);
          socket
            ..broadcastEnabled = true
            ..multicastHops = 4;
          socket.listen((event) {
            if (event != RawSocketEvent.read) return;
            final datagram = socket.receive();
            if (datagram == null) return;
            final response = _parse(
              utf8.decode(datagram.data, allowMalformed: true),
              datagram.address.address,
            );
            if (response != null && !controller.isClosed) {
              controller.add(response);
            }
          });
          sockets.add(socket);

          for (final st in searchTargets) {
            final message = 'M-SEARCH * HTTP/1.1\r\n'
                'HOST: ${_multicastAddress.address}:$_multicastPort\r\n'
                'MAN: "ssdp:discover"\r\n'
                'MX: $mx\r\n'
                'ST: $st\r\n'
                '\r\n';
            socket.send(
              utf8.encode(message),
              _multicastAddress,
              _multicastPort,
            );
          }
        } catch (_) {
          // A single interface failing to bind/send (e.g. a down VPN adapter)
          // must not abort discovery on the others.
        }
      }

      if (sockets.isEmpty) {
        await closeAll();
        return;
      }

      Timer(timeout, closeAll);
    }();

    controller.onCancel = closeAll;
    return controller.stream;
  }

  SsdpResponse? _parse(String message, String remoteAddress) {
    final lines = message.split('\r\n');
    if (lines.isEmpty || !lines.first.startsWith('HTTP/1.1 200')) return null;

    final headers = <String, String>{};
    for (final line in lines.skip(1)) {
      final separator = line.indexOf(':');
      if (separator == -1) continue;
      final key = line.substring(0, separator).trim().toLowerCase();
      final value = line.substring(separator + 1).trim();
      headers[key] = value;
    }
    return SsdpResponse(headers, remoteAddress: remoteAddress);
  }
}
