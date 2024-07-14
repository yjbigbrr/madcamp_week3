import 'package:flutter/material.dart';
import 'schedule_model.dart';

class ScheduleViewModel extends ChangeNotifier {
  List<Match> _matches = [
    Match(
      date: DateTime(2024, 7, 14),
      league: 'Premier League',
      homeTeam: 'Team A',
      awayTeam: 'Team B',
      startTime: DateTime(2024, 7, 14, 16, 0),
      score: '0-0',
      homeTeamPoints: 10,
      awayTeamPoints: 15,
    ),
    Match(
      date: DateTime(2024, 7, 14),
      league: 'La Liga',
      homeTeam: 'Team C',
      awayTeam: 'Team D',
      startTime: DateTime(2024, 7, 14, 18, 0),
      score: '1-1',
      homeTeamPoints: 12,
      awayTeamPoints: 14,
    ),
    Match(
      date: DateTime(2024, 7, 15),
      league: 'Bundesliga',
      homeTeam: 'Team E',
      awayTeam: 'Team F',
      startTime: DateTime(2024, 7, 15, 20, 0),
      score: '2-2',
      homeTeamPoints: 8,
      awayTeamPoints: 9,
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