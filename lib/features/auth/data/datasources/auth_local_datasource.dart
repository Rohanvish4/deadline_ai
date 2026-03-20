import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<Map<String, String>?> getSavedUser();
  Future<void> saveUser({required String id, required String displayName});
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _idKey = 'auth.user.id';
  static const _nameKey = 'auth.user.name';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Map<String, String>?> getSavedUser() async {
    final id = sharedPreferences.getString(_idKey);
    final name = sharedPreferences.getString(_nameKey);
    if (id == null || name == null) return null;
    return {'id': id, 'displayName': name};
  }

  @override
  Future<void> saveUser({required String id, required String displayName}) async {
    await sharedPreferences.setString(_idKey, id);
    await sharedPreferences.setString(_nameKey, displayName);
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(_idKey);
    await sharedPreferences.remove(_nameKey);
  }
}
