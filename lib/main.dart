import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Prevent unhandled async errors from killing the isolate on standalone
  // launch (without a debugger attached they would crash the app instead of
  // surfacing as a red-screen like in debug mode with flutter run).
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true;
  };
  runApp(const ProviderScope(child: TvRemoteApp()));
}
