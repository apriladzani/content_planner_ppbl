import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static late SharedPreferences _prefs;
  static const String keyIsLogin = 'isLogin';
  static const String keyUserId = 'userId';
  static const String keyRole = 'role';
  static const String keyCategory = 'category';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isLogin => _prefs.getBool(keyIsLogin) ?? false;

  static String? get userId => _prefs.getString(keyUserId);

  static String? get role => _prefs.getString(keyRole);

  static String? get category => _prefs.getString(keyCategory);

  static Future<void> saveLogin(String userId, String role) async {
    await _prefs.setBool(keyIsLogin, true);
    await _prefs.setString(keyUserId, userId);
    await _prefs.setString(keyRole, role);
  }

  static Future<void> setCategory(String? category) async {
    if (category == null) {
      await _prefs.remove(keyCategory);
    } else {
      await _prefs.setString(keyCategory, category);
    }
  }

  static Future<void> logout() async {
    await _prefs.setBool(keyIsLogin, false);
    await _prefs.remove(keyUserId);
    await _prefs.remove(keyRole);
    await _prefs.remove(keyCategory);
  }
}
