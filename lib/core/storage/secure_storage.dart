import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccessTokenKey = 'kalasetu_access_token';
const _kUserIdKey = 'kalasetu_user_id';
const _kUserRoleKey = 'kalasetu_user_role';

final secureStorageProvider = Provider<SecureStorageService>(
  (_) => SecureStorageService(),
);

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessTokenKey, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: _kAccessTokenKey);

  Future<void> saveUserId(String id) =>
      _storage.write(key: _kUserIdKey, value: id);

  Future<String?> getUserId() =>
      _storage.read(key: _kUserIdKey);

  Future<void> saveUserRole(String role) =>
      _storage.write(key: _kUserRoleKey, value: role);

  Future<String?> getUserRole() =>
      _storage.read(key: _kUserRoleKey);

  Future<void> clearAll() async {
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kUserIdKey);
    await _storage.delete(key: _kUserRoleKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
