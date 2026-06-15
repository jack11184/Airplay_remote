import 'dart:convert';

import '../../models/tv_device.dart';
import 'secure_storage_service.dart';

/// Persists the list of TVs the user has discovered/paired with, including
/// webOS client-keys / Samsung Tizen tokens stored on each [TvDevice].
class DeviceRepository {
  DeviceRepository(this._storage);

  static const _key = 'paired_devices';

  final SecureStorageService _storage;

  Future<List<TvDevice>> loadDevices() async {
    final raw = await _storage.read(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<Object?>;
    return list
        .map((e) => TvDevice.fromJson(e as Map<String, Object?>))
        .toList();
  }

  Future<void> saveDevices(List<TvDevice> devices) async {
    final raw = jsonEncode(devices.map((d) => d.toJson()).toList());
    await _storage.write(_key, raw);
  }

  /// Inserts or updates a device by [TvDevice.id].
  Future<void> upsertDevice(TvDevice device) async {
    final devices = await loadDevices();
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
    await saveDevices(devices);
  }

  Future<void> removeDevice(String id) async {
    final devices = await loadDevices();
    devices.removeWhere((d) => d.id == id);
    await saveDevices(devices);
  }
}
