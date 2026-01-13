import 'package:flutter/material.dart';
// QR generator removed per request
import 'package:attendance_systems/screens/attendance_history_screen.dart';
import 'package:attendance_systems/screens/schedule_screen.dart';
import 'package:attendance_systems/services/daily_attendance_tracker.dart';
import 'package:attendance_systems/services/user_session.dart';
import 'package:attendance_systems/services/user_service.dart';
import 'package:attendance_systems/services/navigation_service.dart';
import 'package:attendance_systems/widgets/qr_modal.dart';
import 'package:attendance_systems/theme/app_theme.dart';

class StudentHomeScreen extends StatefulWidget {
  final String studentId;
  const StudentHomeScreen({super.key, required this.studentId});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with WidgetsBindingObserver {
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  String? _checkInTime;
  String? _checkOutTime;
  String? _studentName;
  bool _isLoading = true;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Sync with backend and refresh attendance status when app comes back to foreground
      _syncAndRefresh();
    }
  }

  Future<void> _syncAndRefresh() async {
    try {
      await DailyAttendanceTracker.syncWithBackend();
      await _loadAttendanceStatus();

      // Show success message
      if (mounted) {
        print('✅ Sync completed and status updated');
      }
    } catch (e) {
      print('❌ Sync failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserInfo() async {
    final name = await UserSession.getUserName();
    await _loadAttendanceStatus();

    setState(() {
      _studentName = name;
      _isLoading = false;
    });
  }

  Future<void> _loadAttendanceStatus() async {
    final checkedIn = await DailyAttendanceTracker.isCheckedInToday();
    final checkedOut = await DailyAttendanceTracker.isCheckedOutToday();
    final checkInTime = await DailyAttendanceTracker.getCheckinTime();
    final checkOutTime = await DailyAttendanceTracker.getCheckoutTime();

    setState(() {
      _isCheckedIn = checkedIn;
      _isCheckedOut = checkedOut;
      _checkInTime = checkInTime != null
          ? DailyAttendanceTracker.formatTime(checkInTime)
          : null;
      _checkOutTime = checkOutTime != null
          ? DailyAttendanceTracker.formatTime(checkOutTime)
          : null;
    });
  }

  Future<void> _showMyQR() async {
    // Fetch QR payload from backend and show modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String payload;
    try {
      payload = await UserService.getMyQRCode();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to generate QR: $e')));
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // remove loader

    await showDialog(
      context: context,
      builder: (context) => QRModal(payload: payload, title: 'My QR Code'),
    );

    // After modal is dismissed, sync status
    await _syncAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.studentGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _studentName ?? 'Student',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Syncing...')),
                          );
                          // Sync with backend
                          await _syncAndRefresh();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Synced successfully!'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _showMyQR,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.qr_code,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Daily Attendance Status Card
                      _buildDailyAttendanceCard(),
                      const SizedBox(height: 20),
                      // Attendance Overview Card
                      _buildInfoCard(
                        title: 'Attendance Overview',
                        icon: Icons.calendar_today,
                        children: [
                          _buildStatRow('Present', '15', Colors.green),
                          _buildStatRow('Absent', '2', Colors.red),
                          _buildStatRow('Late', '1', Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.qr_code_2,
                              label: 'My QR',
                              onTap: _showMyQR,
                              enabled: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.history,
                              label: 'Attendance',
                              onTap: () {
                                NavigationService.push(
                                  context,
                                  const AttendanceHistoryScreen(),
                                );
                              },
                              enabled: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.schedule,
                              label: 'Schedule',
                              onTap: () {
                                NavigationService.push(
                                  context,
                                  const ScheduleScreen(),
                                );
                              },
                              enabled: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.logout,
                              label: 'Logout',
                              onTap: () {
                                _showLogoutDialog();
                              },
                              enabled: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });

          switch (index) {
            case 0:
              // Home - already here
              break;
            case 1:
              // History
              NavigationService.push(
                context,
                const AttendanceHistoryScreen(),
              );
              break;
            case 2:
              // Schedule
              NavigationService.push(
                context,
                const ScheduleScreen(),
              );
              break;
            case 3:
              // Logout
              _showLogoutDialog();
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  void _showLogoutDialog() {
    NavigationService.handleLogout(context);
  }

  Widget _buildDailyAttendanceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.today,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Attendance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Time In Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.login,
                    color: _isCheckedIn ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time In',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _checkInTime ?? 'Not marked',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isCheckedIn ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: _isCheckedIn
                      ? Colors.green.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  _isCheckedIn ? '✓ Marked' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isCheckedIn ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time Out Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: _isCheckedOut ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time Out',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _checkOutTime ?? 'Not marked',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isCheckedOut ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: _isCheckedOut
                      ? Colors.red.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  _isCheckedOut
                      ? '✓ Marked'
                      : (_isCheckedIn ? 'Pending' : 'Locked'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isCheckedOut
                        ? Colors.red
                        : (_isCheckedIn ? Colors.orange : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: Colors.blue.shade600, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
    String status = 'pending',
  }) {
    Color statusColor = Colors.grey;
    if (status == 'completed') {
      statusColor = Colors.green;
    } else if (status == 'active') {
      statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(enabled ? 0.95 : 0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: statusColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
