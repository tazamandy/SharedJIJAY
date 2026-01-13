import 'package:flutter/material.dart';
import 'package:attendance_systems/widgets/custom_top_navbar.dart';
import 'package:attendance_systems/widgets/custom_bottom_navbar.dart';
import 'package:attendance_systems/screens/event_details_screen.dart';
import 'package:attendance_systems/services/event_service.dart';
import 'package:attendance_systems/services/navigation_service.dart';

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key});

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  int _currentIndex = 1;
  late AnimationController _animationController;
  bool _isLoading = false;

  // Events data from backend
  final Map<String, List<Map<String, dynamic>>> events = {};
  List<dynamic> _allEvents = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      print('📡 Loading events from backend...');
      final response = await EventService.getEvents();
      print('✅ Got ${response.events.length} events from backend');

      if (mounted) {
        setState(() {
          _allEvents = response.events;
          _buildEventMap();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading events: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading events: $e')));
      }
    }
  }

  void _buildEventMap() {
    // Clear existing events
    events.clear();

    // Parse events and organize by date
    for (final event in _allEvents) {
      // EventRecord is an object, access properties directly
      final title = event.title ?? event.name ?? 'Event';
      final startTime = event.startTime;

      if (startTime != null) {
        try {
          final dateKey =
              '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';

          if (!events.containsKey(dateKey)) {
            events[dateKey] = [];
          }

          final eventList = events[dateKey] ?? [];
          eventList.add({
            'title': title,
            'time': startTime.toString(),
            'id': event.id,
            'description': event.description,
            'location': event.location,
            'status': event.status,
            'attendee_count': event.attendeeCount,
            'eventDate': event.eventDate,
            'startTime': event.startTime,
            'endTime': event.endTime,
            'course': event.course,
            'section': event.section,
            'yearLevel': event.yearLevel,
            'department': event.department,
            'taggedCourses': event.taggedCourses,
          });
          events[dateKey] = eventList;

          print(
            '📌 Added event: $title on $dateKey with ${event.attendeeCount} attendees',
          );
        } catch (e) {
          print('⚠️ Could not parse event date: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshEvents() async {
    print('🔄 Refreshing events...');
    await _loadEvents();
  }

  void _changeMonth(int monthOffset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthOffset,
        1,
      );
      // Reset selected date to first day of new month
      _selectedDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
      _animationController.reset();
      _animationController.forward();
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _changeMonth(-1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _changeMonth(1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Weekday Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (day) => SizedBox(
                      width: 45,
                      height: 32,
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Calendar Grid
          ..._buildCalendarGrid(firstWeekday, daysInMonth),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarGrid(int firstWeekday, int daysInMonth) {
    final days = <Widget>[];

    // Empty cells before month starts (Sunday = 7, so we use % 7)
    for (int i = 0; i < firstWeekday % 7; i++) {
      days.add(const SizedBox(width: 45, height: 50));
    }

    // Calendar days
    for (int day = 1; day <= daysInMonth; day++) {
      final dateKey =
          '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      final hasEvent = events.containsKey(dateKey);
      final isSelected =
          _selectedDate.day == day &&
          _selectedDate.month == _currentMonth.month &&
          _selectedDate.year == _currentMonth.year;
      final isToday =
          DateTime.now().day == day &&
          DateTime.now().month == _currentMonth.month &&
          DateTime.now().year == _currentMonth.year;

      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );
              _animationController.reset();
              _animationController.forward();
            });
          },
          child: Container(
            width: 45,
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Date number
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade700,
                            ],
                          )
                        : null,
                    color: !isSelected && hasEvent
                        ? Colors.blue.shade50
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday && !isSelected
                          ? Colors.blue.shade500
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isToday
                            ? Colors.blue.shade700
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Event indicator dot
                if (hasEvent)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade400
                            : Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Arrange days in rows
    final rows = <Widget>[];
    for (int i = 0; i < days.length; i += 7) {
      final weekDays = days.sublist(
        i,
        i + 7 > days.length ? days.length : i + 7,
      );
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays,
          ),
        ),
      );
    }

    return rows;
  }

  List<Map<String, dynamic>> _getEventsForSelectedDate() {
    final dateKey =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    return events[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _allEvents.isEmpty) {
      return Scaffold(
        appBar: CustomTopNavbar(title: 'Events', subtitle: ''),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final selectedEvents = _getEventsForSelectedDate();

    return Scaffold(
      appBar: CustomTopNavbar(title: 'Events', subtitle: ''),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshEvents,
            color: Colors.blue.shade600,
            backgroundColor: Colors.white,
            strokeWidth: 3,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  _buildCalendar(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Events on ${_selectedDate.day} ${_getMonthName(_selectedDate.month).substring(0, 3)} ${_selectedDate.year}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (selectedEvents.isEmpty)
                          FadeTransition(
                            opacity: _animationController,
                            child: Container(
                              padding: const EdgeInsets.all(48),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade50,
                                            Colors.blue.shade100,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.event_busy_rounded,
                                        size: 64,
                                        color: Colors.blue.shade400,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'No events scheduled',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Select a different date\nto view events',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...selectedEvents.asMap().entries.map((entry) {
                            final event = entry.value;
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) {
                                setState(() {
                                  // Could set a hover state here if needed
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        NavigationService.push(
                                          context,
                                          EventDetailsScreen(
                                            event: event,
                                            eventDate:
                                                '${_selectedDate.day} ${_getMonthName(_selectedDate.month).substring(0, 3)} ${_selectedDate.year}',
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade600,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    event['title'] ??
                                                        'No Title',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          Colors.blue.shade700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (event['attendee_count'] !=
                                                      null)
                                                    Text(
                                                      '${event['attendee_count']} attendees',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: Colors.blue.shade600,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
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
          } else if (index == 2) {
            // Users
            NavigationService.navigateToManageUsers(context);
          } else if (index == 3) {
            // Logout
            NavigationService.handleLogout(context);
          }
          // index == 1 is Events, already on this screen
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
