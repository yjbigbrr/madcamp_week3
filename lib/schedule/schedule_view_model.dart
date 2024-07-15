import 'package:flutter/material.dart';
import '../server/service/match_service.dart';
import 'schedule_model.dart';

class ScheduleViewModel extends ChangeNotifier {
  List<Match> _matches = [];
  DateTime _selectedDate = DateTime.now();
  final MatchService _matchService;
  bool isLoading = false;
  final String userId;

  ScheduleViewModel(this._matchService, this.userId);

  List<Match> get matches => _matches;
  DateTime get selectedDate => _selectedDate;

  List<Match> get matchesForSelectedDate => _matches
      .where((match) =>
  match.startTime.year == _selectedDate.year &&
      match.startTime.month == _selectedDate.month &&
      match.startTime.day == _selectedDate.day)
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
      // '2024-07-14' 형식으로 날짜를 포맷팅
      String formattedDate = date.toIso8601String().substring(0, 10);
      _matches = await _matchService.getMatchesByDate(formattedDate);
    } catch (e) {
      print("Error fetching matches: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> vote(String matchId, String team) async {
    try {
      await _matchService.vote(matchId, team, userId);
      // 서버에서 새로운 데이터 가져와서 업데이트
      await _fetchMatchesForDate(_selectedDate);
    } catch (e) {
      throw e;
    }
  }

  Future<void> addUserToWaitList(String matchId) async {
    debugPrint("hello $userId! add to wait list of $matchId");
    try {
      await _matchService.addUserToWaitList(matchId, userId);
      // 서버에서 새로운 데이터 가져와서 업데이트
      await _fetchMatchesForDate(_selectedDate);
    } catch (e) {
      throw e;
    }
  }
}