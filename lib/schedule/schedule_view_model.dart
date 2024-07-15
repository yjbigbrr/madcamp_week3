import 'package:flutter/material.dart';
import 'schedule_model.dart';

class ScheduleViewModel extends ChangeNotifier {
  List<Match> _matches = [
    Match(
      matchId: "1",
      date: DateTime(2024, 7, 14),
      league: 'Premier League',
      homeTeam: 'Team A',
      awayTeam: 'Team B',
      startTime: DateTime(2024, 7, 14, 16, 00),
      homeTeamScore: 0,
      awayTeamScore: 0,
      homeTeamVotes: 10,
      awayTeamVotes: 15,
    ),
    Match(
      matchId: "2",
      date: DateTime(2024, 7, 14),
      league: 'La Liga',
      homeTeam: 'Team C',
      awayTeam: 'Team D',
      startTime: DateTime(2024, 7, 14, 18, 00),
      homeTeamScore: 0,
      awayTeamScore: 0,
      homeTeamVotes: 12,
      awayTeamVotes: 14,
    ),
    Match(
      matchId: "3",
      date: DateTime(2024, 7, 15),
      league: 'Bundesliga',
      homeTeam: 'Team E',
      awayTeam: 'Team F',
      startTime: DateTime(2024, 7, 15, 20, 0),
      homeTeamScore: 0,
      awayTeamScore: 0,
      homeTeamVotes: 8,
      awayTeamVotes: 9,
    ),
  ];

  DateTime _selectedDate = DateTime.now();

  List<Match> get matches => _matches;
  DateTime get selectedDate => _selectedDate;

  List<Match> get matchesForSelectedDate => _matches
      .where((match) =>
  match.date.year == _selectedDate.year &&
      match.date.month == _selectedDate.month &&
      match.date.day == _selectedDate.day)
      .toList();

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
}