import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] for persisting small secrets
/// (webOS client-keys, Samsung Tizen tokens, Vizio auth tokens) and the
/// paired-device list.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          // Use the legacy file-based keychain rather than the data-protection
          // keychain. The data-protection keychain requires a
          // `keychain-access-groups` entitlement that locally-signed macOS
          // dev builds don't have, which otherwise fails every read/write
          // with errSecMissingEntitlement (-34018).
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        );

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);
}
