import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Sample schedule data - In a real app, this would come from the backend
  final List<Map<String, dynamic>> _schedule = [
    {
      'subject': 'BS Computer Science',
      'professor': 'Prof. John Doe',
      'room': 'Room 101',
      'time': '8:00 AM - 9:30 AM',
      'day': 'Monday',
      'status': 'upcoming',
    },
    {
      'subject': 'Data Structures',
      'professor': 'Prof. Jane Smith',
      'room': 'Room 205',
      'time': '10:00 AM - 11:30 AM',
      'day': 'Monday',
      'status': 'completed',
    },
    {
      'subject': 'Web Development',
      'professor': 'Prof. Mike Johnson',
      'room': 'Lab 3',
      'time': '1:00 PM - 3:00 PM',
      'day': 'Monday',
      'status': 'upcoming',
    },
    {
      'subject': 'Database Management',
      'professor': 'Prof. Sarah Williams',
      'room': 'Room 301',
      'time': '8:00 AM - 9:30 AM',
      'day': 'Tuesday',
      'status': 'upcoming',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This Week Header
              Text(
                'This Week\'s Schedule',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              // Schedule List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _schedule.length,
                itemBuilder: (context, index) {
                  return _buildScheduleCard(_schedule[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final subject = schedule['subject'];
    final professor = schedule['professor'];
    final room = schedule['room'];
    final time = schedule['time'];
    final day = schedule['day'];
    final status = schedule['status'];

    final isCompleted = status == 'completed';
    final bgColor = isCompleted ? Colors.grey.shade100 : Colors.blue.shade50;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? Colors.grey.shade300 : Colors.blue.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject and Day
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.grey.shade600
                                : Colors.blue.shade900,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.grey.shade400
                          : Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : 'Upcoming',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Details Grid
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.person_outline,
                      label: 'Professor',
                      value: professor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.location_on_outlined,
                      label: 'Room',
                      value: room,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Time
              _buildDetailItem(
                icon: Icons.access_time_outlined,
                label: 'Time',
                value: time,
              ),
              if (!isCompleted) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Use Check In button to mark attendance for this class',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
