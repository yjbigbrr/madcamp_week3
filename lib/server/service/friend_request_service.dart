// friend_request_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:soccer_app/drawer/friend/friend_model.dart';
import '../model/FriendRequest.dart';
import 'base_url.dart';
import 'package:soccer_app/server/model/User.dart';

class FriendRequestService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<List<Friend>> getFriends(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/friends'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      final friends = jsonResponse.map((json) => Friend.fromJson(json)).toList();
      return friends;
    } else {
      throw Exception('Failed to load friends');
    }
  }

  Future<bool> sendFriendRequest(String senderId, String receiverId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/friend-request/$senderId/$receiverId'),
    );

    debugPrint('sendFriendRequest Response status: ${response.statusCode}');
    debugPrint('sendFriendRequest Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String userId, String senderId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/accept-friend-request/$senderId'),
    );

    debugPrint('acceptFriendRequest Response status: ${response.statusCode}');
    debugPrint('acceptFriendRequest Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> rejectFriendRequest(String userId, String senderId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/reject-friend-request/$senderId'),
    );

    debugPrint('rejectFriendRequest Response status: ${response.statusCode}');
    debugPrint('rejectFriendRequest Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<FriendRequest>> getPendingRequests(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/pending-friend-requests'),
    );

    debugPrint('getPendingRequests Response status: ${response.statusCode}');
    debugPrint('getPendingRequests Response body: ${response.body}');

    if (response.statusCode == 200) {
      Iterable jsonResponse = jsonDecode(response.body);
      return List<FriendRequest>.from(
          jsonResponse.map((model) => FriendRequest.fromJson(model)));
    } else {
      throw Exception('Failed to load pending requests');
    }
  }
}
