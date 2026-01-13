import 'api_service.dart';

/// Service for attendance-related API calls
class AttendanceService {
  /// Get user's attendance records (current student)
  static Future<AttendanceListResponse> getMyAttendance({
    String? userId,
    String? eventId,
  }) async {
    // Backend endpoint: GET /attendance/my-attendance (always uses authenticated user)
    // userId parameter is ignored - the backend always returns current user's attendance
    String endpoint = '/attendance/my-attendance';

    if (eventId != null) {
      endpoint += '?event_id=$eventId';
    }

    print('📡 Calling attendance endpoint: $endpoint');
    final response = await ApiService.get(endpoint);
    print('📡 Raw attendance response: $response');

    final parsed = AttendanceListResponse.fromJson(response);
    print('✅ Parsed ${parsed.records.length} attendance records from backend');
    return parsed;
  }

  /// Mark attendance for an event (check-in or check-out)
  static Future<Map<String, dynamic>> markAttendance({
    required int eventId,
    required String studentId,
    required String action, // 'check_in' or 'check_out'
    String method = 'qr_code',
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final response = await ApiService.post(
      '/attendance/mark',
      body: {
        'event_id': eventId,
        'student_id': studentId,
        'action': action, // 'check_in' or 'check_out'
        'method': method,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
      },
    );

    return response;
  }

  /// Get attendance for a specific student and event (admin only)
  /// Returns null if attendance not found
  static Future<AttendanceRecord?> getAttendance({
    required int eventId,
    required String studentId,
  }) async {
    try {
      // Try to get attendance by event - this endpoint returns all attendances for the event
      final response = await ApiService.get('/events/$eventId/attendance');
      
      if (response['attendances'] != null) {
        final attendances = response['attendances'] as List;
        for (final attJson in attendances) {
          final att = AttendanceRecord.fromJson(attJson);
          if (att.userId == studentId && att.eventId == eventId) {
            return att;
          }
        }
      }
      
      return null;
    } catch (e) {
      // If not found or error, return null (will default to check_in)
      return null;
    }
  }

  /// Get attendance statistics
  static Future<AttendanceStatsResponse> getAttendanceStats({
    String? userId,
    String? eventId,
  }) async {
    String endpoint = '/attendance/stats';

    if (userId != null || eventId != null) {
      endpoint += '?';
      if (userId != null) endpoint += 'user_id=$userId&';
      if (eventId != null) endpoint += 'event_id=$eventId';
      endpoint = endpoint.replaceAll(RegExp(r'&$'), '');
    }

    final response = await ApiService.get(endpoint);
    return AttendanceStatsResponse.fromJson(response);
  }
}

// Response Models
class AttendanceResponse {
  final String id;
  final String userId;
  final String eventId;
  final DateTime timestamp;
  final String status;
  final String message;

  AttendanceResponse({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.timestamp,
    required this.status,
    required this.message,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'present',
      message: json['message'] ?? 'Attendance marked',
    );
  }
}

class AttendanceListResponse {
  final List<AttendanceRecord> records;
  final String message;
  final int count;

  AttendanceListResponse({
    required this.records,
    required this.message,
    this.count = 0,
  });

  factory AttendanceListResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns 'attendances' not 'data'
    final data = json['attendances'] ?? [];
    List<AttendanceRecord> records = [];

    if (data is List) {
      records = data
          .map(
            (item) => AttendanceRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return AttendanceListResponse(
      records: records,
      message: json['message'] ?? 'Success',
      count: json['count'] ?? records.length,
    );
  }
}

class AttendanceRecord {
  final String id;
  final String userId;
  final int eventId;
  final DateTime markedAt;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? action; // 'check_in' or 'check_out' - derived from times

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.markedAt,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.action,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Determine action based on which timestamps are present
    String? action;
    if (json['check_in_time'] != null && json['check_out_time'] == null) {
      action = 'check_in';
    } else if (json['check_in_time'] != null &&
        json['check_out_time'] != null) {
      action = 'check_out';
    }

    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      userId: json['student_id'] ?? '',
      eventId: json['event_id'] is int
          ? json['event_id']
          : int.tryParse(json['event_id']?.toString() ?? '') ?? 0,
      markedAt: DateTime.tryParse(json['marked_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'present',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      action: action,
    );
  }
}

class AttendanceStatsResponse {
  final int totalEvents;
  final int attendedEvents;
  final double attendancePercentage;
  final String message;

  AttendanceStatsResponse({
    required this.totalEvents,
    required this.attendedEvents,
    required this.attendancePercentage,
    required this.message,
  });

  factory AttendanceStatsResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsResponse(
      totalEvents: json['total_events'] ?? 0,
      attendedEvents: json['attended_events'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] ?? 0).toDouble(),
      message: json['message'] ?? 'Success',
    );
  }
}
