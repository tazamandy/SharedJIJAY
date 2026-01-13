import 'package:flutter/material.dart';
import 'package:attendance_systems/widgets/custom_bottom_navbar.dart';
import 'package:attendance_systems/widgets/custom_top_navbar.dart';
import 'package:attendance_systems/services/statistics_service.dart';
import 'package:attendance_systems/services/navigation_service.dart';
import 'package:attendance_systems/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: CustomTopNavbar(
        title: 'Admin Dashboard',
        subtitle: 'Manage classes & attendance',
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.notifications, color: Colors.purple.shade600),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.purpleGradient,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Main Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Overview
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Students',
                              value: StatisticsService.getTotalStudents()
                                  .toString(),
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Classes',
                              value: StatisticsService.getTotalEvents()
                                  .toString(),
                              icon: Icons.school,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Present Today',
                              value:
                                  StatisticsService.getTotalAttendeesPresentToday()
                                      .toString(),
                              icon: Icons.check_circle,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Absent Today',
                              value: StatisticsService.getTotalAbsentToday()
                                  .toString(),
                              icon: Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Management Options
                      const Text(
                        'Management Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildManagementCard(
                        icon: Icons.group,
                        title: 'Manage Students',
                        subtitle: 'Add, edit, or remove students',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildManagementCard(
                        icon: Icons.class_,
                        title: 'Manage Classes',
                        subtitle: 'Create and manage class sections',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildManagementCard(
                        icon: Icons.calendar_month,
                        title: 'Attendance Reports',
                        subtitle: 'View and export attendance data',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildManagementCard(
                        icon: Icons.schedule,
                        title: 'Class Schedule',
                        subtitle: 'Manage class timetables',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildManagementCard(
                        icon: Icons.assessment,
                        title: 'Generate Reports',
                        subtitle: 'Create detailed attendance reports',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildManagementCard(
                        icon: Icons.settings,
                        title: 'Settings',
                        subtitle: 'Configure system settings',
                        onTap: () {},
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
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          if (index == 1) {
            // Students tab
            NavigationService.navigateToManageUsers(context);
          } else if (index == 2) {
            // Events tab
            NavigationService.navigateToEvents(context);
          } else if (index == 3) {
            // Logout tab
            NavigationService.handleLogout(context);
          }
        },
        items: [
          BottomNavbarItem(icon: Icons.dashboard, label: 'Dashboard'),
          BottomNavbarItem(icon: Icons.group, label: 'Users'),
          BottomNavbarItem(icon: Icons.event_note, label: 'Events'),
          BottomNavbarItem(icon: Icons.logout, label: 'Logout'),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.purple.shade600, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.purple.shade600,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

}
