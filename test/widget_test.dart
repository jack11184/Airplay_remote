import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tv_remote/app.dart';
import 'package:tv_remote/core/discovery/composite_tv_discoverer.dart';
import 'package:tv_remote/core/discovery/discovery_providers.dart';

void main() {
  testWidgets('Discovery screen is shown on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Avoid real SSDP/UDP socket use (and its timers) in tests.
          compositeTvDiscovererProvider.overrideWithValue(
            CompositeTvDiscoverer(discoverers: const []),
          ),
        ],
        child: const TvRemoteApp(),
      ),
    );

    expect(find.text('TV Remote'), findsOneWidget);
  });
}
