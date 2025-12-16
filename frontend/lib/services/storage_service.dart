import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'user_data';

  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  Future<User?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;

    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      final user = User.fromJson(userData);

      // Check if token is expired
      if (user.isExpired) {
        await clearUser();
        return null;
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}
