import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:attendance_systems/services/attendance_service.dart';

class AdminQRScannerScreen extends StatefulWidget {
  final int eventId;
  final VoidCallback? onSuccess;

  const AdminQRScannerScreen({
    super.key,
    required this.eventId,
    this.onSuccess,
  });

  @override
  State<AdminQRScannerScreen> createState() => _AdminQRScannerScreenState();
}

class _AdminQRScannerScreenState extends State<AdminQRScannerScreen> {
  late MobileScannerController controller;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String qrCode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    setState(() => _errorMessage = null);

    try {
      // Parse QR code format: "student:STUDENT123" or "event:X:student:STUDENT123"
      String? studentId;
      
      if (qrCode.startsWith('student:')) {
        // Format: student:STUDENT123
        final parts = qrCode.split(':');
        if (parts.length >= 2) {
          studentId = parts.sublist(1).join(':'); // Handle student IDs with colons
        }
      } else if (qrCode.startsWith('event:')) {
        // Format: event:X:student:STUDENT123
        final parts = qrCode.split(':');
        if (parts.length >= 4 && parts[2] == 'student') {
          studentId = parts.sublist(3).join(':'); // Handle student IDs with colons
        }
      } else if (qrCode.contains(':')) {
        // Legacy format: STUDENT123:time_in or STUDENT123:time_out
        final parts = qrCode.split(':');
        if (parts.length == 2 && (parts[1] == 'time_in' || parts[1] == 'time_out')) {
          studentId = parts[0];
          final actionToken = parts[1];
          final markAction = actionToken == 'time_in' ? 'check_in' : 'check_out';
          await _markAttendance(studentId, markAction);
          return;
        }
      }

      if (studentId == null || studentId.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid QR format. Could not extract student ID.';
          _isProcessing = false;
        });
        return;
      }

      // Check current attendance status to determine action
      try {
        final attendance = await AttendanceService.getAttendance(
          eventId: widget.eventId,
          studentId: studentId,
        );
        
        // Determine action based on check-in/check-out status
        String action;
        if (attendance == null || attendance.checkInTime == null) {
          // Not checked in yet → check in
          action = 'check_in';
        } else if (attendance.checkOutTime == null) {
          // Checked in but not checked out → check out
          action = 'check_out';
        } else {
          // Already checked out → show message
          setState(() {
            _errorMessage = 'Student already checked in and out for this event.';
            _isProcessing = false;
          });
          return;
        }
        
        await _markAttendance(studentId, action);
      } catch (e) {
        // If attendance not found, default to check_in
        if (e.toString().contains('not found') || e.toString().contains('404')) {
          await _markAttendance(studentId, 'check_in');
        } else {
          rethrow;
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        _isProcessing = false;
      });
    }
  }

  Future<void> _markAttendance(String studentId, String action) async {
    final response = await AttendanceService.markAttendance(
      eventId: widget.eventId,
      studentId: studentId,
      action: action,
      method: 'qr_code',
    );

    setState(() => _isProcessing = false);
    if (!mounted) return;

    final eventCount = response['attendance']?['event_attendance_count'] ?? 0;
    final totalCount = response['attendance']?['total_attendance_count'] ?? 0;
    final studentFirstName =
        response['attendance']?['student']?['first_name'] ?? 'Student';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          action == 'check_in'
              ? '✓ Time In Recorded'
              : '✓ Time Out Recorded',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Student: $studentFirstName ($studentId)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              '${action == 'check_in' ? 'Time In' : 'Time Out'} has been marked successfully!',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Event Attendance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$eventCount',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'students na nag-attend',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Student\'s Total: $totalCount',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _errorMessage = null;
              });
            },
            child: const Text('Scan Another'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onSuccess?.call();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          if (_errorMessage != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.shade300, width: 2),
                ),
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(15),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2, color: Colors.white, size: 32),
                  SizedBox(height: 10),
                  Text(
                    'Scan Student QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Point camera at the student\'s QR code',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
