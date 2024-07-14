import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  final List<Map<String, String>> schedules = [
    {'name': 'Match 1', 'date': '2024-07-15'},
    {'name': 'Match 2', 'date': '2024-07-20'},
    {'name': 'Match 3', 'date': '2024-07-25'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return ListTile(
            title: Text(schedule['name']!),
            subtitle: Text(schedule['date']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleDetailPage(schedule: schedule),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ScheduleDetailPage extends StatelessWidget {
  final Map<String, String> schedule;

  ScheduleDetailPage({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(schedule['name']!),
      ),
      body: Center(
        child: Text('Details for ${schedule['name']} on ${schedule['date']}'),
      ),
    );
  }
}