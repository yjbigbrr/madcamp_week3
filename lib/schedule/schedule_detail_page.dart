import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_app/schedule/schedule_view_model.dart';
import 'package:soccer_app/schedule/schedule_model.dart';
import '../drawer/profile/profile_view_model.dart';

class MatchDetailPage extends StatefulWidget {
  final Match match;

  MatchDetailPage({required this.match});

  @override
  _MatchDetailPageState createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  @override
  Widget build(BuildContext context) {
    final scheduleViewModel = Provider.of<ScheduleViewModel>(context, listen: false);
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final userId = profileViewModel.profile?.id ?? '';

    final bool hasVotedForHome = widget.match.homeTeamVoters?.contains(userId) ?? false;
    final bool hasVotedForAway = widget.match.awayTeamVoters?.contains(userId) ?? false;
    final bool hasVoted = hasVotedForHome || hasVotedForAway;

    final int totalVotes = widget.match.homeTeamVotes + widget.match.awayTeamVotes;
    final double homeTeamVotePercentage = totalVotes == 0 ? 0 : (widget.match.homeTeamVotes / totalVotes) * 100;
    final double awayTeamVotePercentage = totalVotes == 0 ? 0 : (widget.match.awayTeamVotes / totalVotes) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('Match Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.match.homeTeam} vs ${widget.match.awayTeam}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'League: ${widget.match.league}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Date: ${widget.match.startTime.year}-${widget.match.startTime.month}-${widget.match.startTime.day}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Time: ${widget.match.startTime.hour}:${widget.match.startTime.minute}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: homeTeamVotePercentage / 100,
                    backgroundColor: Colors.grey,
                    color: Colors.blue,
                    minHeight: 20,
                  ),
                  Text('Home Team: ${homeTeamVotePercentage.toStringAsFixed(1)}%'),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: awayTeamVotePercentage / 100,
                    backgroundColor: Colors.grey,
                    color: Colors.red,
                    minHeight: 20,
                  ),
                  Text('Away Team: ${awayTeamVotePercentage.toStringAsFixed(1)}%'),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: hasVoted
                        ? null
                        : () async {
                      try {
                        await scheduleViewModel.vote(widget.match.matchId, 'home');
                        setState(() {
                          widget.match.homeTeamVotes++;
                          widget.match.homeTeamVoters?.add(userId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voted for ${widget.match.homeTeam}')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to vote')));
                      }
                    },
                    child: Text('Vote for ${widget.match.homeTeam}'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: hasVoted
                        ? null
                        : () async {
                      try {
                        await scheduleViewModel.vote(widget.match.matchId, 'away');
                        setState(() {
                          widget.match.awayTeamVotes++;
                          widget.match.awayTeamVoters?.add(userId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voted for ${widget.match.awayTeam}')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to vote')));
                      }
                    },
                    child: Text('Vote for ${widget.match.awayTeam}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}