import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composite_tv_discoverer.dart';

final compositeTvDiscovererProvider = Provider<CompositeTvDiscoverer>((ref) {
  return CompositeTvDiscoverer();
});
