import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../server/model/Meetings.dart';
import 'meeting_view_model.dart';

class MeetingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final meetingViewModel = Provider.of<MeetingViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Meetings'),
      ),
      body: FutureBuilder(
        future: meetingViewModel.fetchUserMeetings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load meetings'));
          } else {
            return ListView.builder(
              itemCount: meetingViewModel.meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetingViewModel.meetings[index];
                return Card(
                  child: ListTile(
                    title: Text(meeting.title),
                    subtitle: Text('Date: ${meeting.date}\nTime: ${meeting.time}'),
                    trailing: meeting.isClosed
                        ? Text('Closed', style: TextStyle(color: Colors.red))
                        : ElevatedButton(
                            onPressed: () => meetingViewModel.joinMeeting(meeting.id),
                            child: Text('Join'),
                          ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetingDetailPage(meeting: meeting),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MeetingDetailPage extends StatelessWidget {
  final Meeting meeting;

  MeetingDetailPage({required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meeting.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${meeting.title}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Date: ${meeting.date}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Time: ${meeting.time}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Participants: ${meeting.currentParticipants}/${meeting.maxParticipants}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Pub Address: ${meeting.pubAddress}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Support Team: ${meeting.supportTeam}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Status: ${meeting.isClosed ? 'Closed' : 'Open'}', style: TextStyle(fontSize: 18, color: meeting.isClosed ? Colors.red : Colors.green)),
          ],
        ),
      ),
    );
  }
}