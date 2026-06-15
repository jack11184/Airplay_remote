import 'dart:io';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Sends button presses to a webOS TV's "pointer input" socket.
///
/// The socket address is obtained by calling
/// `ssap://com.webos.service.networkinput/getPointerInputSocket` on the main
/// [WebOsSsapClient] connection. Unlike the main connection, this socket
/// speaks a simple newline-delimited `key:value` format rather than JSON.
class WebOsPointerClient {
  WebOsPointerClient._(this._channel);

  final WebSocketChannel _channel;

  static Future<WebOsPointerClient> connect(String socketPath) async {
    final uri = Uri.parse(socketPath);
    final channel = uri.scheme == 'wss'
        ? IOWebSocketChannel.connect(
            socketPath,
            customClient: HttpClient()
              ..badCertificateCallback = (cert, host, port) => true,
            connectTimeout: const Duration(seconds: 5),
          )
        : IOWebSocketChannel.connect(
            socketPath,
            connectTimeout: const Duration(seconds: 5),
          );
    await channel.ready;
    return WebOsPointerClient._(channel);
  }

  /// Presses and releases the named button (e.g. `UP`, `HOME`, `ENTER`, or a
  /// digit `0`-`9`).
  void button(String name) {
    _channel.sink.add('type:button\nname:$name\n\n');
  }

  Future<void> close() => _channel.sink.close();
}
