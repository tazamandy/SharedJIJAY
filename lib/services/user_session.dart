import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Global user session management with JWT token handling
class UserSession {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _emailKey = 'user_email';
  static const String _studentIdKey = 'student_id';
  static const String _userNameKey = 'user_name';

  static const _secureStorage = FlutterSecureStorage();

  static String _userRole = 'superadmin'; // Default role for testing
  static String? _token;
  static String? _userId;
  static String? _email;
  static String? _studentId;
  static String? _userName;

  /// Initialize user session (call on app startup)
  static Future<void> initialize() async {
    _token = await _secureStorage.read(key: _tokenKey);
    _userId = await _secureStorage.read(key: _userIdKey);
    _userRole = (await _secureStorage.read(key: _userRoleKey)) ?? 'superadmin';
    _email = await _secureStorage.read(key: _emailKey);
    _studentId = await _secureStorage.read(key: _studentIdKey);
    _userName = await _secureStorage.read(key: _userNameKey);
  }

  /// Set JWT token and user info (call after login)
  static Future<void> setToken(String token) async {
    _token = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get JWT token
  static Future<String?> getToken() async {
    return _token ?? await _secureStorage.read(key: _tokenKey);
  }

  /// Set current user info
  static Future<void> setUserInfo({
    required String userId,
    required String role,
    required String email,
    required String studentId,
    String? userName,
  }) async {
    _userId = userId;
    _userRole = role.toLowerCase();
    _email = email;
    _studentId = studentId;
    _userName = userName;

    await Future.wait([
      _secureStorage.write(key: _userIdKey, value: userId),
      _secureStorage.write(key: _userRoleKey, value: role.toLowerCase()),
      _secureStorage.write(key: _emailKey, value: email),
      _secureStorage.write(key: _studentIdKey, value: studentId),
      if (userName != null)
        _secureStorage.write(key: _userNameKey, value: userName),
    ]);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    return _userId ?? await _secureStorage.read(key: _userIdKey);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    return _email ?? await _secureStorage.read(key: _emailKey);
  }

  /// Get student ID
  static Future<String?> getStudentId() async {
    return _studentId ?? await _secureStorage.read(key: _studentIdKey);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    return _userName ?? await _secureStorage.read(key: _userNameKey);
  }

  /// Set the current user's role
  static void setUserRole(String role) {
    _userRole = role.toLowerCase();
    _secureStorage.write(key: _userRoleKey, value: role.toLowerCase());
  }

  /// Get the current user's role
  static String getUserRole() {
    return _userRole;
  }

  /// Check if user is superadmin
  static bool isSuperadmin() {
    return _userRole == 'superadmin';
  }

  /// Check if user is admin
  static bool isAdmin() {
    return _userRole == 'admin';
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Reset session (for logout)
  static Future<void> reset() async {
    _userRole = 'superadmin';
    _token = null;
    _userId = null;
    _email = null;
    _studentId = null;
    _userName = null;

    await Future.wait([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _userRoleKey),
      _secureStorage.delete(key: _emailKey),
      _secureStorage.delete(key: _studentIdKey),
      _secureStorage.delete(key: _userNameKey),
    ]);
  }
}
