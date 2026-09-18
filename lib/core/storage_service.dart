import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class StorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Token ────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<String?> getToken() =>
      _storage.read(key: AppConstants.tokenKey);

  Future<void> deleteToken() =>
      _storage.delete(key: AppConstants.tokenKey);

  // ── User ─────────────────────────────────────────────────────────────
  Future<void> saveUser(Map<String, dynamic> userJson) =>
      _storage.write(key: AppConstants.userKey, value: jsonEncode(userJson));

  Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> deleteUser() =>
      _storage.delete(key: AppConstants.userKey);

  // ── Support Tracking ─────────────────────────────────────────────────
  Future<void> saveLastSupportViewTime(DateTime time) =>
      _storage.write(key: 'last_support_view', value: time.toIso8601String());

  Future<DateTime?> getLastSupportViewTime() async {
    final raw = await _storage.read(key: 'last_support_view');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  // ── Utils ─────────────────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();
}
