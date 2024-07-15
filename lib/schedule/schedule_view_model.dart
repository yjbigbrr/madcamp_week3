import 'package:flutter/material.dart';
import '../server/service/match_service.dart';
import 'schedule_model.dart';

class ScheduleViewModel extends ChangeNotifier {
  List<Match> _matches = [];
  DateTime _selectedDate = DateTime.now();
  final MatchService _matchService;
  bool isLoading = false;

  ScheduleViewModel(this._matchService);

  List<Match> get matches => _matches;
  DateTime get selectedDate => _selectedDate;

  List<Match> get matchesForSelectedDate => _matches
      .where((match) =>
  match.date.year == _selectedDate.year &&
      match.date.month == _selectedDate.month &&
      match.date.day == _selectedDate.day)
      .toList();

  void selectDate(DateTime date) async {
    _selectedDate = date;
    await _fetchMatchesForDate(date);
    notifyListeners();
  }

  Future<void> _fetchMatchesForDate(DateTime date) async {
    isLoading = true;
    notifyListeners();

    try {
      _matches = await _matchService.getMatchesByDate(date.toIso8601String().substring(0, 10));
    } catch (e) {
      print("Error fetching matches: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}