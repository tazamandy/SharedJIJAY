import 'api_service.dart';

/// Service for user management and profile operations
class UserService {
  /// Get user profile
  static Future<UserProfileResponse> getUserProfile({String? userId}) async {
    final endpoint = userId != null ? '/users/$userId' : '/users/me';
    final response = await ApiService.get(endpoint);
    return UserProfileResponse.fromJson(response);
  }

  /// Update user profile
  static Future<UserProfileResponse> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? contactNumber,
    String? address,
    String? course,
    String? yearLevel,
    String? section,
  }) async {
    final body = <String, dynamic>{};

    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (middleName != null) body['middle_name'] = middleName;
    if (contactNumber != null) body['contact_number'] = contactNumber;
    if (address != null) body['address'] = address;
    if (course != null) body['course'] = course;
    if (yearLevel != null) body['year_level'] = yearLevel;
    if (section != null) body['section'] = section;

    final response = await ApiService.put('/users/me', body: body);

    return UserProfileResponse.fromJson(response);
  }

  /// Get all users (admin only)
  static Future<UserListResponse> getAllUsers({
    String? role,
    String? department,
    int? page,
    int? limit,
  }) async {
    String endpoint = '/admin/users';
    List<String> params = [];

    if (role != null) params.add('role=$role');
    if (department != null) params.add('department=$department');
    if (page != null) params.add('page=$page');
    if (limit != null) params.add('limit=$limit');

    if (params.isNotEmpty) {
      endpoint += '?' + params.join('&');
    }

    final response = await ApiService.get(endpoint);
    return UserListResponse.fromJson(response);
  }

  /// Promote user to admin/superadmin (admin only)
  static Future<PromoteUserResponse> promoteUser({
    required String userId,
    required String newRole,
  }) async {
    final response = await ApiService.post(
      '/admin/promote',
      body: {'student_id': userId, 'role': newRole},
    );

    return PromoteUserResponse.fromJson(response);
  }

  /// Change password
  static Future<ChangePasswordResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiService.post(
      '/change-password',
      body: {'current_password': currentPassword, 'new_password': newPassword},
    );

    return ChangePasswordResponse.fromJson(response);
  }

  /// Delete user account
  static Future<void> deleteAccount({required String password}) async {
    await ApiService.post('/users/me/delete', body: {'password': password});
  }

  /// Fetch the current user's QR payload from the backend
  /// Returns the raw payload string used to generate the QR code.
  static Future<String> getMyQRCode() async {
    final triedBases = <String>[];

    Future<Map<String, dynamic>> tryGet() async {
      return await ApiService.get('/users/me/qrcode');
    }

    late Map<String, dynamic> response;
    try {
      response = await tryGet();
    } catch (e) {
      // If the default attempt failed, try common emulator host fallbacks.
      // This helps when running on Android emulator where `localhost` is different.
      final fallbacks = ['http://10.0.2.2:3000', 'http://127.0.0.1:3000', 'http://localhost:3000'];
      bool succeeded = false;
      Object? lastError;
      for (final base in fallbacks) {
        try {
          triedBases.add(base);
          ApiService.setBaseUrl(base);
          response = await tryGet();
          succeeded = true;
          break;
        } catch (err) {
          lastError = err;
        }
      }

      if (!succeeded) {
        // Re-throw the last error with some context
        throw Exception('GET request failed: $lastError. Tried bases: ${triedBases.join(', ')}');
      }
    }

    // Try common response shapes to extract the QR payload
    if (response.containsKey('qr')) return response['qr'].toString();
    if (response.containsKey('qr_code')) return response['qr_code'].toString();
    if (response.containsKey('payload')) return response['payload'].toString();
    if (response.containsKey('data')) {
      final d = response['data'];
      if (d is String) return d;
      if (d is Map && d.containsKey('qr')) return d['qr'].toString();
    }

    // Fallback: return the entire encoded response as a string
    return response.toString();
  }
}

// Response Models
class UserProfileResponse {
  final String id;
  final String studentId;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String course;
  final String yearLevel;
  final String section;
  final String department;
  final String college;
  final String contactNumber;
  final String address;
  final String role;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String message;

  UserProfileResponse({
    required this.id,
    required this.studentId,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.course,
    required this.yearLevel,
    required this.section,
    required this.department,
    required this.college,
    required this.contactNumber,
    required this.address,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.message,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      course: json['course'] ?? '',
      yearLevel: json['year_level'] ?? '',
      section: json['section'] ?? '',
      department: json['department'] ?? '',
      college: json['college'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'student',
      emailVerified: json['email_verified'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      message: json['message'] ?? 'Success',
    );
  }
}

class UserListResponse {
  final List<UserRecord> users;
  final int total;
  final int page;
  final int limit;
  final String message;

  UserListResponse({
    required this.users,
    required this.total,
    required this.page,
    required this.limit,
    required this.message,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? [];
    List<UserRecord> users = [];

    if (data is List) {
      users = data
          .map((item) => UserRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return UserListResponse(
      users: users,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      message: json['message'] ?? 'Success',
    );
  }
}

class UserRecord {
  final String id;
  final String studentId;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String course;
  final String yearLevel;
  final String? section;
  final String? department;
  final String? college;
  final String? contactNumber;
  final String? address;
  final String role;
  final bool emailVerified;

  UserRecord({
    required this.id,
    required this.studentId,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.course,
    required this.yearLevel,
    this.section,
    this.department,
    this.college,
    this.contactNumber,
    this.address,
    required this.role,
    required this.emailVerified,
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      middleName: json['middle_name'],
      course: json['course'] ?? '',
      yearLevel: json['year_level'] ?? '',
      section: json['section'],
      department: json['department'],
      college: json['college'],
      contactNumber: json['contact_number'],
      address: json['address'],
      role: json['role'] ?? 'student',
      emailVerified: json['is_verified'] ?? json['email_verified'] ?? false,
    );
  }
}

class PromoteUserResponse {
  final String userId;
  final String newRole;
  final String message;
  final String status;

  PromoteUserResponse({
    required this.userId,
    required this.newRole,
    required this.message,
    required this.status,
  });

  factory PromoteUserResponse.fromJson(Map<String, dynamic> json) {
    return PromoteUserResponse(
      userId: json['user_id'] ?? '',
      newRole: json['new_role'] ?? '',
      message: json['message'] ?? 'User promoted',
      status: json['status'] ?? 'success',
    );
  }
}

class ChangePasswordResponse {
  final String message;
  final String status;

  ChangePasswordResponse({required this.message, required this.status});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      message: json['message'] ?? 'Password changed',
      status: json['status'] ?? 'success',
    );
  }
}
