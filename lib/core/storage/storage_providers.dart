import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device_repository.dart';
import 'secure_storage_service.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(ref.watch(secureStorageServiceProvider));
});
