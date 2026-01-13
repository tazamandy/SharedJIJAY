import 'api_service.dart';

/// Service for event-related API calls
class EventService {
  /// Get all events
  static Future<EventListResponse> getEvents({
    String? status,
    String? type,
    int? page,
    int? limit,
  }) async {
    String endpoint = '/events';
    List<String> params = [];

    if (status != null) params.add('status=$status');
    if (type != null) params.add('type=$type');
    if (page != null) params.add('page=$page');
    if (limit != null) params.add('limit=$limit');

    if (params.isNotEmpty) {
      endpoint += '?' + params.join('&');
    }

    final response = await ApiService.get(endpoint);
    return EventListResponse.fromJson(response);
  }

  /// Get event by ID
  static Future<EventResponse> getEvent({required String eventId}) async {
    final response = await ApiService.get('/events/$eventId');
    // Backend returns event wrapped in "event" key
    return EventResponse.fromJson(response);
  }

  /// Create new event
  static Future<EventResponse> createEvent({
    required String name,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    String? course,
    String? section,
    String? yearLevel,
    String? department,
    String? college,
    List<String>? taggedCourses,
    Map<String, dynamic>? metadata,
  }) async {
    print('📡 Creating event: $name');
    print('   Start: $startDate');
    print('   End: $endDate');

    // Format date as YYYY-MM-DD for event_date field
    final eventDateStr =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    final body = {
      'title': name,
      'description': description,
      'event_date': eventDateStr,
      'start_time': startDate.toIso8601String(),
      'end_time': endDate.toIso8601String(),
      'location': location,
      if (course != null && course.isNotEmpty) 'course': course,
      if (section != null && section.isNotEmpty) 'section': section,
      if (yearLevel != null && yearLevel.isNotEmpty) 'year_level': yearLevel,
      if (department != null && department.isNotEmpty) 'department': department,
      if (college != null && college.isNotEmpty) 'college': college,
      if (taggedCourses != null && taggedCourses.isNotEmpty)
        'tagged_courses': taggedCourses,
    };

    print('📤 Request body: $body');

    try {
      final response = await ApiService.post('/events', body: body);
      print('✅ Event created successfully: $response');
      return EventResponse.fromJson(response);
    } catch (e) {
      print('❌ Error creating event: $e');
      rethrow;
    }
  }

  /// Update event
  static Future<EventResponse> updateEvent({
    required String eventId,
    String? name,
    String? description,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? status,
    String? remarks,
  }) async {
    final body = <String, dynamic>{};

    if (name != null) body['title'] = name; // Backend expects 'title'
    if (description != null) body['description'] = description;
    if (type != null) body['type'] = type;
    if (startDate != null) {
      body['start_time'] = startDate.toIso8601String();
      // Also set event_date as YYYY-MM-DD
      body['event_date'] = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) body['end_time'] = endDate.toIso8601String();
    if (location != null) body['location'] = location;
    if (status != null) body['status'] = status;
    if (remarks != null) body['remarks'] = remarks;

    final response = await ApiService.put('/events/$eventId', body: body);

    return EventResponse.fromJson(response);
  }

  /// Delete event
  static Future<void> deleteEvent({required String eventId}) async {
    await ApiService.delete('/events/$eventId');
  }

  /// Get event attendees
  static Future<EventAttendeeListResponse> getEventAttendees({
    required String eventId,
  }) async {
    final response = await ApiService.get('/events/$eventId/attendees');
    return EventAttendeeListResponse.fromJson(response);
  }

  /// Generate QR code for event
  static Future<QRCodeResponse> generateQRCode({
    required String eventId,
  }) async {
    final response = await ApiService.get('/events/$eventId/qr-code');
    return QRCodeResponse.fromJson(response);
  }

  /// Get event statistics
  static Future<EventStatsResponse> getEventStats({
    required String eventId,
  }) async {
    final response = await ApiService.get('/events/$eventId/stats');
    return EventStatsResponse.fromJson(response);
  }
}

// Response Models
class EventResponse {
  final String id;
  final String name;
  final String description;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String status;
  final String remarks;
  final String message;

  EventResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.status,
    required this.remarks,
    required this.message,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns event wrapped in "event" key for create/update
    final eventData = json['event'] ?? json;
    
    return EventResponse(
      id: eventData['id']?.toString() ?? '',
      name: eventData['title'] ?? eventData['name'] ?? '',
      description: eventData['description'] ?? '',
      type: eventData['type'] ?? 'class',
      startDate: DateTime.tryParse(eventData['start_time'] ?? eventData['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(eventData['end_time'] ?? eventData['end_date'] ?? '') ?? DateTime.now(),
      location: eventData['location'] ?? '',
      status: eventData['status'] ?? 'scheduled',
      remarks: eventData['remarks'] ?? '',
      message: json['message'] ?? 'Success',
    );
  }
}

class EventListResponse {
  final List<EventRecord> events;
  final int count;
  final String message;

  EventListResponse({
    required this.events,
    this.count = 0,
    this.message = 'Success',
  });

  factory EventListResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns 'events' array, not 'data'
    final data = json['events'] ?? [];
    List<EventRecord> events = [];

    print('📥 Parsing events response: $json');

    if (data is List) {
      events = data
          .map((item) => EventRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    print('✅ Parsed ${events.length} events from response');

    return EventListResponse(
      events: events,
      count: json['count'] ?? events.length,
      message: json['message'] ?? 'Success',
    );
  }
}

class EventRecord {
  final String id;
  final String title;
  final String name;
  final String description;
  final String location;
  final String status;
  final DateTime eventDate;
  final DateTime startTime;
  final DateTime endTime;
  final String? course;
  final String? section;
  final String? yearLevel;
  final String? department;
  final List<String> taggedCourses;
  final int attendeeCount;

  EventRecord({
    required this.id,
    required this.title,
    required this.name,
    required this.description,
    required this.location,
    required this.status,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.course,
    this.section,
    this.yearLevel,
    this.department,
    this.taggedCourses = const [],
    this.attendeeCount = 0,
  });

  factory EventRecord.fromJson(Map<String, dynamic> json) {
    // Parse tagged courses if available
    List<String> taggedCourses = [];
    if (json['tagged_courses'] is List) {
      taggedCourses = List<String>.from(json['tagged_courses'] as List);
    }

    return EventRecord(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'scheduled',
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now(),
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
      course: json['course'],
      section: json['section'],
      yearLevel: json['year_level'],
      department: json['department'],
      taggedCourses: taggedCourses,
      attendeeCount: json['attendee_count'] ?? 0,
    );
  }

  // Get display map for event listing
  Map<String, dynamic> toDisplayMap() {
    return {
      'title': title,
      'name': name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'status': status,
    };
  }
}

class EventAttendeeListResponse {
  final String eventId;
  final List<AttendeeRecord> attendees;
  final int totalAttendees;
  final String message;

  EventAttendeeListResponse({
    required this.eventId,
    required this.attendees,
    required this.totalAttendees,
    required this.message,
  });

  factory EventAttendeeListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['attendees'] ?? [];
    List<AttendeeRecord> attendees = [];

    if (data is List) {
      attendees = data
          .map((item) => AttendeeRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return EventAttendeeListResponse(
      eventId: json['event_id'] ?? '',
      attendees: attendees,
      totalAttendees: json['total_attendees'] ?? 0,
      message: json['message'] ?? 'Success',
    );
  }
}

class AttendeeRecord {
  final String userId;
  final String studentId;
  final String name;
  final String email;
  final String status;
  final DateTime? attendanceTime;

  AttendeeRecord({
    required this.userId,
    required this.studentId,
    required this.name,
    required this.email,
    required this.status,
    this.attendanceTime,
  });

  factory AttendeeRecord.fromJson(Map<String, dynamic> json) {
    return AttendeeRecord(
      userId: json['user_id'] ?? '',
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'absent',
      attendanceTime: json['attendance_time'] != null
          ? DateTime.tryParse(json['attendance_time'])
          : null,
    );
  }
}

class QRCodeResponse {
  final String eventId;
  final String qrCode;
  final String qrUrl;
  final String message;

  QRCodeResponse({
    required this.eventId,
    required this.qrCode,
    required this.qrUrl,
    required this.message,
  });

  factory QRCodeResponse.fromJson(Map<String, dynamic> json) {
    return QRCodeResponse(
      eventId: json['event_id'] ?? '',
      qrCode: json['qr_code'] ?? '',
      qrUrl: json['qr_url'] ?? '',
      message: json['message'] ?? 'Success',
    );
  }
}

class EventStatsResponse {
  final String eventId;
  final int totalExpected;
  final int totalPresent;
  final int totalAbsent;
  final double attendancePercentage;
  final String message;

  EventStatsResponse({
    required this.eventId,
    required this.totalExpected,
    required this.totalPresent,
    required this.totalAbsent,
    required this.attendancePercentage,
    required this.message,
  });

  factory EventStatsResponse.fromJson(Map<String, dynamic> json) {
    return EventStatsResponse(
      eventId: json['event_id'] ?? '',
      totalExpected: json['total_expected'] ?? 0,
      totalPresent: json['total_present'] ?? 0,
      totalAbsent: json['total_absent'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] ?? 0).toDouble(),
      message: json['message'] ?? 'Success',
    );
  }
}
