import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:soccer_app/schedule/schedule_model.dart';
import 'package:soccer_app/server/service/base_url.dart';

class MatchService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<List<Match>> getMatchesByDate(String date) async {
    debugPrint("get matches for date $date");
    final response = await http.get(Uri.parse('$baseUrl/match/by-date?date=$date'));

    debugPrint('getMatches Response status: ${response.statusCode}');
    debugPrint('getMatches Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      final matches = data.map((match) => Match.fromJson(match)).toList();
      return matches;
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<void> vote(String matchId, String team, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/match/vote/$matchId/$team/$userId'),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to vote');
    }
  }

  Future<void> addUserToWaitList(String matchId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/match/wait/$matchId/$userId'),
    );

    debugPrint('addUserToWaitList Response status: ${response.statusCode}');
    debugPrint('addUserToWaitList Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to add user to wait list');
    }
  }
}