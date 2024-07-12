import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/User.dart';

class UserService {
  final String baseUrl = "http://143.248.229.87:3000";

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
  Future<User?> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/users?id=$id'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return User.fromJson(jsonResponse[0]);
    } else {
      throw Exception('Failed to load user');
    }
  }

  // 사용자 존재 여부 확인
  Future<bool> isUserExists(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/exists?id=$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check user existence');
    }
  }

  // 사용자 닉네임 업데이트
  Future<User?> updateUserNickname(String id, String newNickname) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/nickname?id=$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'nickname': newNickname}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user nickname');
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

  // 로그인
  Future<bool> login(String id, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'id': id, 'password': password}),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to login');
    }
  }
}