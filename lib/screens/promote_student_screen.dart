import 'package:flutter/material.dart';
import 'package:attendance_systems/widgets/custom_top_navbar.dart';
import 'package:attendance_systems/widgets/custom_bottom_navbar.dart';
import 'package:attendance_systems/services/navigation_service.dart';
import 'package:attendance_systems/services/user_service.dart';

class PromoteStudentScreen extends StatefulWidget {
  const PromoteStudentScreen({super.key});

  @override
  State<PromoteStudentScreen> createState() => _PromoteStudentScreenState();
}

class _PromoteStudentScreenState extends State<PromoteStudentScreen> {
  int _currentIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  String _selectedRole = 'student';

  final List<String> _roles = [
    'student',
    'faculty',
    'admin',
  ];

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final id = _idController.text.trim();
      final role = _selectedRole;
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        await UserService.promoteUser(
          userId: id,
          newRole: role.toLowerCase(),
        );
        
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Successfully promoted user $id to $role'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form
          _idController.clear();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to promote user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopNavbar(
        title: 'Promote Student',
        subtitle: '',
        onLeadingPressed: () => NavigationService.pop(context),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.notifications, color: Colors.blue.shade600),
            ),
          ),
        ],
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Promote a student by Student ID',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _idController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Student ID',
                              prefixIcon: const Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter Student ID';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRole,
                                isExpanded: true,
                                items: _roles
                                    .map(
                                      (r) => DropdownMenuItem(
                                        value: r,
                                        child: Text(r),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedRole = v);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _submit,
                            child: const Text(
                              'Promote',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
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
          
          if (index == 0) {
            // Dashboard
            NavigationService.navigateToDashboard(context);
          } else if (index == 1) {
            // Events
            NavigationService.navigateToEvents(context);
          } else if (index == 2) {
            // Users
            NavigationService.navigateToManageUsers(context);
          } else if (index == 3) {
            // Logout
            NavigationService.handleLogout(context);
          }
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
}
