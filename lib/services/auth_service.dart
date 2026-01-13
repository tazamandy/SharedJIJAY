// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_session.dart';

// Response model for password reset
class PasswordResetResponse {
  final String verificationToken;
  final String message;

  PasswordResetResponse({
    required this.verificationToken,
    required this.message,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      verificationToken:
          json['verification_token'] ?? json['verificationToken'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

// Response model for registration
class RegisterResponse {
  final String email;
  final String verificationToken;

  RegisterResponse({required this.email, required this.verificationToken});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns: { "message": "...", "student_id": "...", "token": "...", "status": "success" }
    // Extract email from request or use a placeholder - backend doesn't return email in response
    return RegisterResponse(
      email: json['email'] ?? '', // Will be set from registration request
      verificationToken: json['token'] ?? json['verification_token'] ?? json['verificationToken'] ?? '',
    );
  }
}

class AuthService with ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/login',
        // Backend expects student_id but also accepts email in this field
        body: {'student_id': identifier, 'password': password},
        requireAuth: false,
      );

      final accessToken =
          response['access_token'] ?? response['token'] ?? response['jwt'];

      if (accessToken == null || (accessToken is String && accessToken.isEmpty)) {
        _errorMessage = response['error'] ?? response['message'] ?? 'Login failed';
        return false;
      }

      // Save tokens
      await UserSession.setToken(accessToken.toString());

      // Persist user info for routing and profile
      await UserSession.setUserInfo(
        userId: response['student_id'] ?? response['email'] ?? '',
        role: (response['role'] ?? 'student').toString(),
        email: response['email'] ?? '',
        studentId: response['student_id'] ?? '',
        userName: [
          response['first_name'],
          response['last_name'],
        ].whereType<String>().where((e) => e.isNotEmpty).join(' ').trim(),
      );

      _isLoggedIn = true;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    try {
      // Call logout API
      // Logout is handled client-side by clearing tokens
      // No backend endpoint needed

      // Clear local session
      await UserSession.reset();

      _isLoggedIn = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Still clear local session even if API fails
      await UserSession.reset();
      _isLoggedIn = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> checkAuth() async {
    final token = await UserSession.getToken();
    _isLoggedIn = token != null && token.isNotEmpty;
    notifyListeners();
    return _isLoggedIn;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  static Future<RegisterResponse> register({
    required String studentId,
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    required String middleName,
    required String course,
    required String yearLevel,
    required String section,
    required String department,
    required String college,
    required String contactNumber,
    required String address,
  }) async {
    try {
      final response = await ApiService.post(
        '/register',
        body: {
          'student_id': studentId.isEmpty ? null : studentId,
          'email': email,
          'password': password,
          'username': username,
          'first_name': firstName,
          'last_name': lastName,
          'middle_name': middleName.isEmpty ? null : middleName,
          'course': course,
          'year_level': yearLevel,
          'section': section.isEmpty ? null : section,
          'department': department.isEmpty ? null : department,
          'college': college.isEmpty ? null : college,
          'contact_number': contactNumber.isEmpty ? null : contactNumber,
          'address': address.isEmpty ? null : address,
        },
        requireAuth: false,
      );

      return RegisterResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<PasswordResetResponse> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await ApiService.post(
        '/forgot-password',
        body: {'email': email},
        requireAuth: false,
      );

      return PasswordResetResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> verifyEmail({
    required String token,
    required String code,
  }) async {
    try {
      // Use the token from registration in Authorization header
      final response = await ApiService.post(
        '/reg/verify',
        body: {'code': code},
        requireAuth: false,
        customToken: token, // Pass token directly
      );

      return response['success'] == true || response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}
