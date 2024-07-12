import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soccer_app/server/model/UpdateStatsDto.dart';
import 'base_url.dart';

class MyPlayerService {
  final String baseUrl = BaseUrl.baseUrl;

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