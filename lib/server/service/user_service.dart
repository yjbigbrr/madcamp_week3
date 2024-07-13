import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/User.dart';
import 'base_url.dart';

class UserService {
  final String baseUrl = BaseUrl.baseUrl;

  // 사용자 생성
  Future<bool> createUser(User user) async {
    debugPrint("create user");
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 201) {
      debugPrint("status code is 201");
      return jsonDecode(response.body);
    } else {
      debugPrint("status code isn't 201");
      return false;
    }
  }

  // 모든 사용자 조회
  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));

    if (response.statusCode == 200) {
      Iterable jsonResponse = jsonDecode(response.body);
      return List<User>.from(jsonResponse.map((model) => User.fromJson(model)));
    } else {
      throw Exception('Failed to load users');
    }
  }

  // 특정 사용자 조회
  Future<User?> getUserByKakaoId(String kakaoId) async {
    final response = await http.get(Uri.parse('$baseUrl/users?kakaoId=$kakaoId'));

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return User.fromJson(jsonResponse[0]);
    } else {
      throw Exception('Failed to load user');
    }
  }

  // 사용자 존재 여부 확인
  Future<bool> isUserExists(String kakaoId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/exists?kakaoId=$kakaoId'));

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check user existence');
    }
  }

  // 사용자 업데이트
  Future<User?> updateUser(String id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users?id=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  // 사용자 삭제
  Future<User?> removeUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users?id=$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete user');
    }
  }

  Future<List<String>> getMyPlayerIds(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/myplayers');
    final response = await http.get(url);

    debugPrint('getMyPlayerIds Response status: ${response.statusCode}');
    debugPrint('getMyPlayerIds Response body: ${response.body}');

    if (response.statusCode == 200) {
      // 응답 본문이 ID 리스트라면
      debugPrint('return with status 200! getMyPlayer');
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return List<String>.from(jsonResponse);
      } else {
        debugPrint('Unexpected response format!!!!');
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to fetch MyPlayer IDs');
    }
  }

  // 로그인
  Future<User> login(String id, String password) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/login?id=$id&password=$password'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return User.fromJson(jsonResponse); // Parse and return User
    } else {
      throw Exception('Failed to login');
    }
  }
}