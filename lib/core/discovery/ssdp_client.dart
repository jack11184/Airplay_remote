import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A parsed SSDP M-SEARCH response (an HTTP-over-UDP "200 OK" message).
class SsdpResponse {
  SsdpResponse(this.headers);

  final Map<String, String> headers;

  String? get location => headers['location'];
  String? get searchTarget => headers['st'];
  String? get usn => headers['usn'];
  String? get server => headers['server'];
}

/// Minimal SSDP (Simple Service Discovery Protocol) client.
///
/// Sends UDP multicast M-SEARCH requests to 239.255.255.250:1900 and emits
/// each device's response. No mature, maintained Dart SSDP package exists,
/// so this is a small hand-rolled client - the same approach used by SSDP
/// discovery implementations in other languages.
class SsdpClient {
  static final _multicastAddress = InternetAddress('239.255.255.250');
  static const _multicastPort = 1900;

  /// Sends an M-SEARCH for each of [searchTargets] and emits every response
  /// received within [timeout]. The returned stream closes itself once
  /// [timeout] elapses.
  Stream<SsdpResponse> search({
    required List<String> searchTargets,
    Duration timeout = const Duration(seconds: 4),
    int mx = 2,
  }) {
    final controller = StreamController<SsdpResponse>();

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
      socket.broadcastEnabled = true;

      socket.listen((event) {
        if (event != RawSocketEvent.read) return;
        final datagram = socket.receive();
        if (datagram == null) return;
        final response =
            _parse(utf8.decode(datagram.data, allowMalformed: true));
        if (response != null && !controller.isClosed) {
          controller.add(response);
        }
      });

      for (final st in searchTargets) {
        final message = 'M-SEARCH * HTTP/1.1\r\n'
            'HOST: $_multicastAddress:$_multicastPort\r\n'
            'MAN: "ssdp:discover"\r\n'
            'MX: $mx\r\n'
            'ST: $st\r\n'
            '\r\n';
        socket.send(utf8.encode(message), _multicastAddress, _multicastPort);
      }

      Timer(timeout, () {
        socket.close();
        if (!controller.isClosed) controller.close();
      });
    }).catchError((Object error, StackTrace stackTrace) {
      controller.addError(error, stackTrace);
      controller.close();
    });

    return controller.stream;
  }

  SsdpResponse? _parse(String message) {
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
    return SsdpResponse(headers);
  }
}
