import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<Map<String, String>?> getSavedUser();
  Future<void> saveUser({
    required String id,
    required String displayName,
    required String token,
  });
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _idKey = 'auth.user.id';
  static const _nameKey = 'auth.user.name';
  static const _tokenKey = 'auth.user.token';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Map<String, String>?> getSavedUser() async {
    final id = sharedPreferences.getString(_idKey);
    final name = sharedPreferences.getString(_nameKey);
    final token = sharedPreferences.getString(_tokenKey);
    if (id == null || name == null || token == null) return null;
    return {'id': id, 'displayName': name, 'token': token};
  }

  @override
  Future<void> saveUser({
    required String id,
    required String displayName,
    required String token,
  }) async {
    await sharedPreferences.setString(_idKey, id);
    await sharedPreferences.setString(_nameKey, displayName);
    await sharedPreferences.setString(_tokenKey, token);
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(_idKey);
    await sharedPreferences.remove(_nameKey);
    await sharedPreferences.remove(_tokenKey);
  }
}
