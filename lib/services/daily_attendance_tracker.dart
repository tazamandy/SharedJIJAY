import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_service.dart';
import 'user_session.dart';

/// Tracks daily check-in and check-out status
class DailyAttendanceTracker {
  static const String _prefix = 'attendance_';

  /// Check if already checked in today
  static Future<bool> isCheckedInToday() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey('check_in');
    return prefs.getBool(key) ?? false;
  }

  /// Check if already checked out today
  static Future<bool> isCheckedOutToday() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey('check_out');
    return prefs.getBool(key) ?? false;
  }

  /// Get today's check-in time
  static Future<DateTime?> getCheckinTime() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey('check_in_time');
    final timeStr = prefs.getString(key);
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  /// Get today's check-out time
  static Future<DateTime?> getCheckoutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey('check_out_time');
    final timeStr = prefs.getString(key);
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  /// Mark check-in
  static Future<void> markCheckedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey('check_in');
    final timeKey = _getTodayKey('check_in_time');

    await prefs.setBool(key, true);
    await prefs.setString(timeKey, DateTime.now().toIso8601String());
  }

  /// Mark check-out
  static Future<void> markCheckedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTodayKey('check_out');
    final timeKey = _getTodayKey('check_out_time');

    await prefs.setBool(key, true);
    await prefs.setString(timeKey, DateTime.now().toIso8601String());
  }

  /// Reset daily attendance (call at midnight)
  static Future<void> resetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getToday();

    // Get all keys and remove today's keys
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.contains(_prefix + today)) {
        await prefs.remove(key);
      }
    }
  }

  /// Get count of scans done today (0, 1, or 2)
  static Future<int> getScansCount() async {
    int count = 0;
    if (await isCheckedInToday()) count++;
    if (await isCheckedOutToday()) count++;
    return count;
  }

  /// Get remaining scans (0, 1, or 2)
  static Future<int> getRemainingScans() async {
    final scans = await getScansCount();
    return 2 - scans; // Maximum 2 scans per day
  }

  /// Format time nicely with date and time (e.g., "Jan 13 • 10:15 AM")
  static String formatTime(DateTime? time) {
    if (time == null) return 'Not yet';

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final monthStr = months[time.month - 1];
    final dayStr = time.day;

    // Convert to 12-hour format
    final hour12 = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    final timeStr =
        '${hour12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $ampm';

    return '$monthStr $dayStr • $timeStr';
  }

  /// Get today's date as string (YYYY-MM-DD)
  static String _getToday() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get prefixed key for today
  static String _getTodayKey(String suffix) {
    return '$_prefix${_getToday()}_$suffix';
  }

  /// Sync with backend and update local storage
  static Future<void> syncWithBackend() async {
    try {
      final studentId = await UserSession.getStudentId();
      if (studentId == null) {
        print('❌ No student ID found');
        return;
      }

      print('🔄 Syncing attendance for student: $studentId');

      // Fetch attendance records from backend
      final response = await AttendanceService.getMyAttendance();

      print('📋 Got ${response.records.length} records from backend');

      if (response.records.isEmpty) {
        print('❌ No records found on backend');
        return;
      }

      // Get today's date
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      print('📅 Today range: $todayStart to $tomorrowStart');

      // Update local storage with backend data
      final prefs = await SharedPreferences.getInstance();

      // Track what we've found
      bool foundCheckIn = false;
      bool foundCheckOut = false;
      DateTime? checkInTime;
      DateTime? checkOutTime;

      // Filter today's records
      final todayRecords = response.records.where((record) {
        return record.markedAt.isAfter(todayStart) &&
            record.markedAt.isBefore(tomorrowStart);
      }).toList();

      print('📌 Filtered to ${todayRecords.length} today records');

      // First pass: look through records to find check-in and check-out
      for (final record in todayRecords) {
        final markedAt = record.markedAt;
        final checkInTime_record = record.checkInTime;
        final checkOutTime_record = record.checkOutTime;
        final status = record.status.toLowerCase();

        print(
          '   Record: ${record.id} | status: "$status" | checkIn: $checkInTime_record | checkOut: $checkOutTime_record | time: $markedAt',
        );

        // If check_in_time exists, we have a check-in
        if (checkInTime_record != null && !foundCheckIn) {
          foundCheckIn = true;
          checkInTime = DateTime.tryParse(checkInTime_record) ?? markedAt;
          print('✅ Found check_in at $checkInTime');
        }

        // If check_out_time exists, we have a check-out
        if (checkOutTime_record != null && !foundCheckOut) {
          foundCheckOut = true;
          checkOutTime = DateTime.tryParse(checkOutTime_record) ?? markedAt;
          print('✅ Found check_out at $checkOutTime');
        }
      }

      // If we only have one record with just check-in, assume it's check-in
      if (todayRecords.length == 1 &&
          !foundCheckIn &&
          todayRecords[0].checkInTime != null) {
        print(
          '📍 Single record found with check_in_time, treating as check_in',
        );
        foundCheckIn = true;
        checkInTime =
            DateTime.tryParse(todayRecords[0].checkInTime!) ??
            todayRecords[0].markedAt;
      }

      // Update local storage with found data
      if (foundCheckIn && checkInTime != null) {
        await prefs.setBool(_getTodayKey('check_in'), true);
        await prefs.setString(
          _getTodayKey('check_in_time'),
          checkInTime.toIso8601String(),
        );
        print('💾 Saved check_in to local storage at $checkInTime');
      }

      if (foundCheckOut && checkOutTime != null) {
        await prefs.setBool(_getTodayKey('check_out'), true);
        await prefs.setString(
          _getTodayKey('check_out_time'),
          checkOutTime.toIso8601String(),
        );
        print('💾 Saved check_out to local storage at $checkOutTime');
      }

      print(
        '✨ Sync complete - Check-in: $foundCheckIn, Check-out: $foundCheckOut',
      );
    } catch (e) {
      print('❌ Sync error: $e');
      rethrow; // Let the caller know there was an error
    }
  }
}
