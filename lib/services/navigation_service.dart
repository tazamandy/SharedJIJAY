import 'package:flutter/material.dart';
import 'package:attendance_systems/screens/login_screen.dart';
import 'package:attendance_systems/screens/student_home_screen.dart';
import 'package:attendance_systems/screens/admin_dashboard_screen.dart';
import 'package:attendance_systems/screens/superadmin_dashboard_screen.dart';
import 'package:attendance_systems/screens/view_event_screen.dart';
import 'package:attendance_systems/screens/manage_user_screen.dart';
import 'package:attendance_systems/screens/manage_attendance_screen.dart';
import 'package:attendance_systems/services/user_session.dart';

/// Centralized navigation service for consistent navigation throughout the app
class NavigationService {
  // Smooth page transition
  static PageRoute<T> _smoothRoute<T extends Object?>(
    Widget page, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Navigate to a new screen (allows back navigation)
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return Navigator.of(
      context,
    ).push<T>(_smoothRoute<T>(page, settings: settings));
  }

  /// Navigate and replace current screen (no back navigation)
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return Navigator.of(
      context,
    ).pushReplacement<T, TO>(_smoothRoute<T>(page, settings: settings));
  }

  /// Navigate and remove all previous routes (for login/logout)
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _smoothRoute<T>(page, settings: settings),
      (route) => false,
    );
  }

  /// Navigate to dashboard based on user role
  static Future<void> navigateToDashboard(BuildContext context) async {
    final isSuperadmin = UserSession.isSuperadmin();
    final isAdmin = UserSession.isAdmin();

    Widget dashboard;
    if (isSuperadmin) {
      dashboard = const SuperadminDashboardScreen();
    } else if (isAdmin) {
      dashboard = const AdminDashboardScreen();
    } else {
      // Get student ID from session
      final studentId = await UserSession.getStudentId();
      dashboard = StudentHomeScreen(studentId: studentId ?? '');
    }

    await pushAndRemoveUntil(context, dashboard);
  }

  /// Navigate to login screen (clears navigation stack)
  static Future<void> navigateToLogin(BuildContext context) {
    return pushAndRemoveUntil(context, const LoginScreen());
  }

  /// Navigate to events screen
  static Future<void> navigateToEvents(BuildContext context) {
    return push(context, const ViewEventScreen());
  }

  /// Navigate to manage users screen
  static Future<void> navigateToManageUsers(BuildContext context) {
    return push(context, const ManageUserScreen());
  }

  /// Navigate to manage attendance screen (admin/superadmin only)
  static Future<void> navigateToManageAttendance(
    BuildContext context, {
    required int eventId,
    String? eventTitle,
  }) {
    return push(
      context,
      ManageAttendanceScreen(
        eventId: eventId,
        eventTitle: eventTitle,
      ),
    );
  }

  /// Pop current screen
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.of(context).popUntil(predicate);
  }

  /// Show logout confirmation dialog
  static Future<bool> showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Handle logout flow
  static Future<void> handleLogout(BuildContext context) async {
    final confirmed = await showLogoutDialog(context);
    if (confirmed && context.mounted) {
      // Clear session
      await UserSession.reset();
      // Navigate to login
      if (context.mounted) {
        navigateToLogin(context);
      }
    }
  }
}
