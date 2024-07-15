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
      debugPrint(matches[0].matchId);
      return matches;
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<void> vote(String matchId, String team, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/match/$matchId/vote'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'team': team}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to vote');
    }
  }

  Future<void> addUserToWaitList(String matchId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/match/$matchId/wait'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add user to wait list');
    }
  }
}