import 'package:flutter/material.dart';
import 'package:attendance_systems/widgets/custom_top_navbar.dart';
import 'package:attendance_systems/widgets/custom_bottom_navbar.dart';
import 'package:attendance_systems/services/user_session.dart';
import 'package:attendance_systems/services/user_service.dart';
import 'package:attendance_systems/services/navigation_service.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  int _currentIndex = 2;
  String _selectedRole = 'All';
  List<UserRecord> allUsers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await UserService.getAllUsers();
      setState(() {
        allUsers = response.users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<UserRecord> get filteredUsers {
    if (_selectedRole == 'All') {
      return allUsers;
    }
    return allUsers
        .where((user) => user.role.toLowerCase() == _selectedRole.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopNavbar(
        title: 'Manage Users',
        subtitle: 'View and manage system users',
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade600, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ['All', 'Student', 'Admin', 'Superadmin', 'Teacher']
                            .map(
                              (role) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRole = role;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedRole == role
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _selectedRole == role
                                          ? Colors.transparent
                                          : Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == role
                                          ? Colors.blue.shade600
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),

              // Users List or Loading/Error
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Loading users...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade300,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading users',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              errorMessage ?? 'Unknown error',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Colors.white.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No users found',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${user.firstName} ${user.lastName}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user.email,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ID: ${user.studentId}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          user.emailVerified
                                              ? 'Verified'
                                              : 'Pending',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: user.emailVerified
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          user.role,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${user.course}${user.department != null && user.department!.isNotEmpty ? ' - ${user.department}' : ''}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _showEditUserDialog(user);
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: const Text('Edit'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade600,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (UserSession.isSuperadmin() &&
                                          user.role != 'superadmin')
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _showPromoteDialog(user);
                                            },
                                            icon: const Icon(
                                              Icons.admin_panel_settings,
                                              size: 16,
                                            ),
                                            label: const Text('Promote'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orange.shade600,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            // Dashboard
            NavigationService.navigateToDashboard(context);
          } else if (index == 1) {
            // Events
            NavigationService.navigateToEvents(context);
          } else if (index == 3) {
            // Logout
            NavigationService.handleLogout(context);
          }
          // index == 2 is Users, already on this screen
        },
        items: [
          BottomNavbarItem(icon: Icons.dashboard, label: 'Dashboard'),
          BottomNavbarItem(icon: Icons.event_note, label: 'Events'),
          BottomNavbarItem(icon: Icons.group, label: 'Users'),
          BottomNavbarItem(icon: Icons.logout, label: 'Logout'),
        ],
      ),
    );
  }

  void _showEditUserDialog(UserRecord user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${user.email}'),
              const SizedBox(height: 8),
              Text('Student ID: ${user.studentId}'),
              const SizedBox(height: 8),
              Text('Course: ${user.course}'),
              const SizedBox(height: 8),
              Text('Department: ${user.department ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Year Level: ${user.yearLevel}'),
              if (user.section != null && user.section!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Section: ${user.section}'),
              ],
              if (user.middleName != null && user.middleName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Middle Name: ${user.middleName}'),
              ],
              if (user.college != null && user.college!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('College: ${user.college}'),
              ],
              if (user.contactNumber != null &&
                  user.contactNumber!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Contact: ${user.contactNumber}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPromoteDialog(UserRecord user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Role: ${user.role}'),
            const SizedBox(height: 16),
            const Text('Promote to:'),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Admin'),
              onTap: () {
                Navigator.pop(context);
                _promoteUser(user.id, 'admin');
              },
            ),
            ListTile(
              title: const Text('Superadmin'),
              onTap: () {
                Navigator.pop(context);
                _promoteUser(user.id, 'superadmin');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _promoteUser(String userId, String newRole) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Promoting user...')));

      await UserService.promoteUser(userId: userId, newRole: newRole);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User promoted successfully!')),
      );

      _loadUsers(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
