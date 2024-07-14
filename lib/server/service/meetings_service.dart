import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/Meetings.dart';

class MeetingService {
  final String baseUrl = "http://143.248.229.87:3000";
  // 현재 유저의 모임 불러오기
  Future<List<Meeting>> getMeetings(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/meetings'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final meetings = jsonResponse.map((json) => Meeting.fromJson(json)).toList();
      return meetings;
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  // 새로운 모임 생성
  Future<bool> createMeeting(Meeting meeting) async {
    debugPrint("create meeting");
    final response = await http.post(
      Uri.parse('$baseUrl/meetings'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(meeting.toJson()),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 201) {
      debugPrint("status code is 201");
      return true;
    } else {
      debugPrint("status code isn't 201");
      return false;
    }
  }

  // 모든 모임 조회
  Future<List<Meeting>> getAllMeetings() async {
    final response = await http.get(Uri.parse('$baseUrl/meetings'));

    if (response.statusCode == 200) {
      Iterable jsonResponse = jsonDecode(response.body);
      return List<Meeting>.from(jsonResponse.map((model) => Meeting.fromJson(model)));
    } else {
      throw Exception('Failed to load meetings');
    }
  }

  // 특정 모임 조회
  Future<Meeting?> getMeetingById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/meetings/$id'));

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Meeting.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load meeting');
    }
  }

  // 모임에 참가
  Future<bool> joinMeeting(String meetingId, String userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/meetings/join/$meetingId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'userId': userId}),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to join meeting');
    }
  }
}