/// Service to calculate accurate system statistics based on actual data
class StatisticsService {
  /// Sample events data
  static final Map<String, List<Map<String, String>>> events = {
    '2025-01-12': [
      {
        'title': 'CS101 - Introduction to Computer Science',
        'time': '09:00 AM - 11:00 AM',
        'location': 'Room 101',
        'attendees': '45/50',
      },
      {
        'title': 'IT201 - Mobile Development',
        'time': '01:00 PM - 03:00 PM',
        'location': 'Lab 05',
        'attendees': '30/35',
      },
    ],
    '2025-01-15': [
      {
        'title': 'MATH101 - Discrete Mathematics',
        'time': '10:00 AM - 12:00 PM',
        'location': 'Room 205',
        'attendees': '55/60',
      },
    ],
    '2025-01-20': [
      {
        'title': 'CS201 - Algorithms and Complexity',
        'time': '02:00 PM - 04:00 PM',
        'location': 'Auditorium A',
        'attendees': '80/100',
      },
    ],
  };

  /// Sample users data
  static final List<Map<String, String>> allUsers = [
    {
      'name': 'John Smith',
      'email': 'john.smith@school.edu',
      'role': 'Student',
      'department': 'Computer Science',
      'status': 'Active',
    },
    {
      'name': 'Maria Garcia',
      'email': 'maria.garcia@school.edu',
      'role': 'Teacher',
      'department': 'Computer Science',
      'status': 'Active',
    },
    {
      'name': 'Robert Johnson',
      'email': 'robert.johnson@school.edu',
      'role': 'Student',
      'department': 'Information Technology',
      'status': 'Active',
    },
    {
      'name': 'Sarah Williams',
      'email': 'sarah.williams@school.edu',
      'role': 'Admin',
      'department': 'Administration',
      'status': 'Active',
    },
    {
      'name': 'Michael Chen',
      'email': 'michael.chen@school.edu',
      'role': 'Teacher',
      'department': 'Mathematics',
      'status': 'Inactive',
    },
    {
      'name': 'Emma Davis',
      'email': 'emma.davis@school.edu',
      'role': 'Student',
      'department': 'Engineering',
      'status': 'Active',
    },
    {
      'name': 'David Martinez',
      'email': 'david.martinez@school.edu',
      'role': 'Student',
      'department': 'Business',
      'status': 'Active',
    },
    {
      'name': 'Lisa Anderson',
      'email': 'lisa.anderson@school.edu',
      'role': 'Teacher',
      'department': 'English',
      'status': 'Active',
    },
  ];

  /// Get total number of users
  static int getTotalUsers() {
    return allUsers.length;
  }

  /// Get total number of events
  static int getTotalEvents() {
    return events.values.fold(0, (sum, eventList) => sum + eventList.length);
  }

  /// Get total number of students
  static int getTotalStudents() {
    return allUsers.where((user) => user['role'] == 'Student').length;
  }

  /// Get total number of teachers
  static int getTotalTeachers() {
    return allUsers.where((user) => user['role'] == 'Teacher').length;
  }

  /// Get total number of active users
  static int getTotalActiveUsers() {
    return allUsers.where((user) => user['status'] == 'Active').length;
  }

  /// Get total number of inactive users
  static int getTotalInactiveUsers() {
    return allUsers.where((user) => user['status'] == 'Inactive').length;
  }

  /// Get total attendees present (sum of present from all events)
  static int getTotalAttendeesPresentToday() {
    int total = 0;
    for (var eventList in events.values) {
      for (var event in eventList) {
        final attendees = event['attendees'] ?? '0/0';
        final parts = attendees.split('/');
        if (parts.isNotEmpty) {
          try {
            total += int.parse(parts[0].trim());
          } catch (e) {
            // Ignore parsing errors
          }
        }
      }
    }
    return total;
  }

  /// Get total attendees capacity (sum of total capacity from all events)
  static int getTotalAttendeeCapacityToday() {
    int total = 0;
    for (var eventList in events.values) {
      for (var event in eventList) {
        final attendees = event['attendees'] ?? '0/0';
        final parts = attendees.split('/');
        if (parts.length > 1) {
          try {
            total += int.parse(parts[1].trim());
          } catch (e) {
            // Ignore parsing errors
          }
        }
      }
    }
    return total;
  }

  /// Get total absent (total capacity - present)
  static int getTotalAbsentToday() {
    return getTotalAttendeeCapacityToday() - getTotalAttendeesPresentToday();
  }

  /// Get number of departments/courses
  static int getTotalDepartments() {
    final departments = <String>{};
    for (var user in allUsers) {
      departments.add(user['department'] ?? '');
    }
    return departments.length;
  }
}
