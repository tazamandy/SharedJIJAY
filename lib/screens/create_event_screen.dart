import 'package:flutter/material.dart';
import 'package:attendance_systems/widgets/custom_top_navbar.dart';
import 'package:attendance_systems/widgets/custom_bottom_navbar.dart';
import 'package:attendance_systems/screens/admin_qr_scanner_screen.dart';
import 'package:attendance_systems/screens/superadmin_qr_scanner_screen.dart';
import 'package:attendance_systems/services/user_session.dart';
import 'package:attendance_systems/services/event_service.dart';
import 'package:attendance_systems/services/navigation_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _eventDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _locationController;

  bool _isLoading = false;
  int _currentIndex = 0;

  // Dropdown options
  final List<String> courseOptions = [
    'Bachelor of Science in Information Technology',
    'Bachelor of Science in Computer Science',
    'Bachelor of Science in Mathematics',
    'Bachelor of Science in Physics',
    'Bachelor of Science in Chemistry',
    'Bachelor of Science in Biology',
    'Bachelor of Science in Psychology',
    'Bachelor of Science in Sociology',
    'Bachelor of Science in Economics',
    'Bachelor of Science in Political Science',
    'Bachelor of Science in English',
    'Bachelor of Science in History',
    'Bachelor of Science in Philosophy',
    'Bachelor of Science in Religious Studies',
    'Bachelor of Science in Music',
    'Bachelor of Science in Art',
    'Bachelor of Science in Architecture',
    'Bachelor of Science in Industrial Design',
    'Bachelor of Science in Mechanical Engineering',
    'Bachelor of Science in Electrical Engineering',
    'Bachelor of Science in Civil Engineering',
    'Bachelor of Science in Chemical Engineering',
    'Bachelor of Science in Agricultural Engineering',
    'Bachelor of Science in Industrial Engineering',
    'Bachelor of Science in Environmental Engineering',
    'Bachelor of Science in Mining Engineering',
    'Bachelor of Science in Petroleum Engineering',
    'Bachelor of Science in Naval Architecture and Ocean Engineering',
    'Bachelor of Science in Aerospace Engineering',
    'Bachelor of Science in Biomedical Engineering',
    'Bachelor of Science in Computer Engineering',
    'Bachelor of Science in Industrial Design',
    'Bachelor of Science in Mechanical Engineering',
    'Bachelor of Science in Electrical Engineering',
    'Bachelor of Science in Civil Engineering',
    'Bachelor of Science in Chemical Engineering',
    'Bachelor of Science in Agricultural Engineering',
    'Bachelor of Science in Industrial Engineering',
    'Bachelor of Science in Environmental Engineering',
    'Bachelor of Science in Mining Engineering',
    'Bachelor of Science in Petroleum Engineering',
    'Bachelor of Science in Naval Architecture and Ocean Engineering',
    'Bachelor of Science in Aerospace Engineering',
    'Bachelor of Science in Biomedical Engineering',
    'Bachelor of Science in Computer Engineering',
    'Bachelor of Science in Industrial Design',
    'Bachelor of Science in Mechanical Engineering',
    'Bachelor of Science in Electrical Engineering',
    'Bachelor of Science in Civil Engineering',
    'Bachelor of Science in Chemical Engineering',
  ];
  final List<String> sectionOptions = ['A', 'B', 'C', 'D', 'E'];
  final List<String> yearLevelOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];
  final List<String> departmentOptions = [
    'Computer Science',
    'Information Technology',
    'Engineering',
    'Business',
  ];

  // Selected values
  List<String> selectedCourses = [];
  List<String> selectedSections = [];
  List<String> selectedYearLevels = [];
  List<String> selectedDepartments = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _eventDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _eventDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _createEvent() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCourses.isEmpty ||
          selectedSections.isEmpty ||
          selectedYearLevels.isEmpty ||
          selectedDepartments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one item from all dropdowns'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Parse dates and times
        final eventDate = DateTime.parse(_eventDateController.text);
        final startTimeStr = _startTimeController.text;
        final endTimeStr = _endTimeController.text;

        final startHour = int.parse(startTimeStr.split(':')[0]);
        final startMinute = int.parse(startTimeStr.split(':')[1]);
        final endHour = int.parse(endTimeStr.split(':')[0]);
        final endMinute = int.parse(endTimeStr.split(':')[1]);

        final startDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          startHour,
          startMinute,
        );

        final endDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          endHour,
          endMinute,
        );

        print('🚀 Creating event with parameters:');
        print('   Title: ${_titleController.text}');
        print('   Description: ${_descriptionController.text}');
        print('   Location: ${_locationController.text}');
        print('   Start: $startDateTime');
        print('   End: $endDateTime');
        print('   Courses: $selectedCourses');
        print('   Sections: $selectedSections');
        print('   Year Levels: $selectedYearLevels');
        print('   Departments: $selectedDepartments');

        // Create event on backend
        final created = await EventService.createEvent(
          name: _titleController.text,
          description: _descriptionController.text,
          type: 'class',
          startDate: startDateTime,
          endDate: endDateTime,
          location: _locationController.text,
          course: selectedCourses.isNotEmpty ? selectedCourses[0] : null,
          section: selectedSections.isNotEmpty ? selectedSections[0] : null,
          yearLevel: selectedYearLevels.isNotEmpty
              ? selectedYearLevels[0]
              : null,
          department: selectedDepartments.isNotEmpty
              ? selectedDepartments[0]
              : null,
          taggedCourses: selectedCourses,
        );
        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Event created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Open scanner immediately for the created event
          int eventId = 0;
          try {
            eventId = int.tryParse(created.id.toString()) ?? 0;
          } catch (_) {
            eventId = 0;
          }

          if (eventId > 0) {
            final isSuperadmin = UserSession.isSuperadmin();
            NavigationService.push(
              context,
              isSuperadmin
                  ? SuperadminQRScannerScreen(eventId: eventId)
                  : AdminQRScannerScreen(eventId: eventId),
            );
          } else {
            // fallback: just pop back
            NavigationService.pop(context, true);
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error creating event: $e'),
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
        title: 'Create Event',
        subtitle: '',
        onLeadingPressed: () {
          NavigationService.navigateToDashboard(context);
        },
        leading: null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Description
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title',
                      hint: 'Enter event title',
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter event description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),

                    // Date and Location
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            controller: _eventDateController,
                            label: 'Event Date',
                            onTap: () => _selectDate(_eventDateController),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _locationController,
                            label: 'Location',
                            hint: 'Enter location',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Start Time and End Time
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            controller: _startTimeController,
                            label: 'Start Time',
                            onTap: () => _selectTime(_startTimeController),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeField(
                            controller: _endTimeController,
                            label: 'End Time',
                            onTap: () => _selectTime(_endTimeController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Courses Multi-Select
                    _buildMultiSelectDropdown(
                      label: 'Courses (Select Multiple)',
                      selectedItems: selectedCourses,
                      allItems: courseOptions,
                      onChanged: (selected) {
                        setState(() {
                          selectedCourses = selected;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Sections Multi-Select
                    _buildMultiSelectDropdown(
                      label: 'Sections (Select Multiple)',
                      selectedItems: selectedSections,
                      allItems: sectionOptions,
                      onChanged: (selected) {
                        setState(() {
                          selectedSections = selected;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Year Level Multi-Select
                    _buildMultiSelectDropdown(
                      label: 'Year Level (Select Multiple)',
                      selectedItems: selectedYearLevels,
                      allItems: yearLevelOptions,
                      onChanged: (selected) {
                        setState(() {
                          selectedYearLevels = selected;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Department Multi-Select
                    _buildMultiSelectDropdown(
                      label: 'Department (Select Multiple)',
                      selectedItems: selectedDepartments,
                      allItems: departmentOptions,
                      onChanged: (selected) {
                        setState(() {
                          selectedDepartments = selected;
                        });
                      },
                    ),
                    const SizedBox(height: 30),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Create Event',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text.isEmpty ? 'Select date' : controller.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.text.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.blue.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text.isEmpty ? 'Select time' : controller.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.text.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
                Icon(Icons.access_time, size: 18, color: Colors.blue.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdown({
    required String label,
    required List<String> selectedItems,
    required List<String> allItems,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.blue.shade50),
            child: MultiSelectDropdown(
              items: allItems,
              selectedItems: selectedItems,
              onChanged: onChanged,
            ),
          ),
        ),
        if (selectedItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedItems.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class MultiSelectDropdown extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onChanged;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isOpen ? Colors.blue.shade600 : Colors.blue.shade200,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isOpen ? Colors.blue.shade100 : Colors.transparent,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.selectedItems.isEmpty
                        ? 'Select options'
                        : '${widget.selectedItems.length} selected',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.selectedItems.isEmpty
                          ? Colors.grey.shade400
                          : Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isOpen ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue.shade200, width: 2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Select All Option
                GestureDetector(
                  onTap: () {
                    if (widget.selectedItems.length == widget.items.length) {
                      // Deselect all
                      widget.onChanged([]);
                    } else {
                      // Select all
                      widget.onChanged(List.from(widget.items));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: widget.selectedItems.length == widget.items.length
                          ? Colors.blue.shade50
                          : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue.shade100,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue.shade600,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            color:
                                widget.selectedItems.length ==
                                    widget.items.length
                                ? Colors.blue.shade600
                                : Colors.transparent,
                          ),
                          child:
                              widget.selectedItems.length == widget.items.length
                              ? const Icon(
                                  Icons.check,
                                  size: 15,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Select All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Individual Items
                ...widget.items.map((item) {
                  final isSelected = widget.selectedItems.contains(item);
                  return GestureDetector(
                    onTap: () {
                      List<String> updated = List.from(widget.selectedItems);
                      if (isSelected) {
                        updated.remove(item);
                      } else {
                        updated.add(item);
                      }
                      widget.onChanged(updated);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue.shade600
                                    : Colors.blue.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              color: isSelected
                                  ? Colors.blue.shade600
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 15,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }
}
