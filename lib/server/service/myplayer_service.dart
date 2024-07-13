import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soccer_app/server/model/UpdateStatsDto.dart';
import 'base_url.dart';
import 'package:soccer_app/server/model/MyPlayer.dart';

class MyPlayerService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<MyPlayer> getMyPlayer(String playerId) async {
    final response = await http.get(Uri.parse('$baseUrl/myplayers/$playerId'));

    debugPrint('getMyPlayer Response status: ${response.statusCode}');
    debugPrint('getMyPlayer Response body: ${response.body}');

    if (response.statusCode == 200) {
      return MyPlayer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch MyPlayer');
    }
  }

  Future<MyPlayer> createMyPlayer(String userId, MyPlayer myPlayerData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/create-myplayer'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(myPlayerData.toJson()),
    );

    debugPrint('createMyPlayer Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return MyPlayer.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create MyPlayer');
    }
  }

  Future<bool> updateStats(String id, UpdateStatsDto statsDto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/myplayer/$id/stats'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(statsDto.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update stats');
    }
  }
}