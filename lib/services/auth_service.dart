import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersPrefix = 'user_';
  static const String _sessionKey = 'session_username';

  Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_usersPrefix$username';
    if (prefs.containsKey(key)) {
      return false; // Username sudah ada
    }
    await prefs.setString(key, password);
    return true;
  }

  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_usersPrefix$username';
    final stored = prefs.getString(key);
    if (stored == password) {
      await prefs.setString(_sessionKey, username);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<bool> isLoggedIn() async {
    final user = await getLoggedInUser();
    return user != null;
  }
}
