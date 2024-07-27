import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static bool isLoggedIn = false;
  static String? userId;
  static String? userType; // Add user type field

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    userId = prefs.getString('userId');
    userType = prefs.getString('userType'); // Initialize user type from SharedPreferences
  }

  static Future<void> login(String userId, String userType) async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = true;
    SessionManager.userId = userId;
    SessionManager.userType = userType; // Set user type
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('userType', userType); // Store user type
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = false;
    userId = null;
    userType = null; // Clear user type on logout
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userType'); // Remove user type from SharedPreferences
  }
}
