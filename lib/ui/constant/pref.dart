import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  //sets
  static Future<bool> setLoggedIn(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setToken(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setFullName(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setEmailID(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setID(String key, String value) async =>
      await _prefs.setString(key, value);

  //getsuserName
  static bool? getLoggedIn(String key) => _prefs.getBool(key);

  static String? getToken(String key) => _prefs.getString(key);

  static String? getFullName(String key) => _prefs.getString(key);

  static String? getID(String key) => _prefs.getString(key);

  static String? getEmailId(String key) => _prefs.getString(key);

  //deletes..
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();

  // 🔹 Profile image methods
  static Future<bool> setProfileImage(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, path);
  }

  static Future<String?> getProfileImage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> removeProfileImage([String key = 'profileImage']) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
