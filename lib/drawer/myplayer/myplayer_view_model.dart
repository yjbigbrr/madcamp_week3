import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:soccer_app/server/model/MyPlayer.dart';
import 'package:soccer_app/server/model/MyPlayer.dart';
import 'package:soccer_app/server/service/myplayer_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MyPlayerViewModel extends ChangeNotifier {
  MyPlayer? myPlayer;
  bool isLoading = false;

  MyPlayerViewModel() {
    _loadMyPlayer();
  }

  Future<void> _loadMyPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    final playerData = prefs.getString('myPlayer');
    if (playerData != null) {
      final jsonData = jsonDecode(playerData) as Map<String, dynamic>;
      myPlayer = MyPlayer.fromJson(jsonData);
      notifyListeners();
    }
  }

  Future<void> _saveMyPlayer() async {
    if (myPlayer != null) {
      final prefs = await SharedPreferences.getInstance();
      final playerData = jsonEncode(myPlayer!.toJson());
      await prefs.setString('myPlayer', playerData);
    }
  }

  Future<void> fetchMyPlayer(String myPlayerId) async {
    isLoading = true;
    notifyListeners();

    try {
      final fetchedMyPlayer = await MyPlayerService().getMyPlayer(myPlayerId);
      myPlayer = fetchedMyPlayer;
      await _saveMyPlayer();
    } catch (e) {
      myPlayer = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> createMyPlayer(String? userId, MyPlayer myPlayerData) async {
    if (userId == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final createdMyPlayer = await MyPlayerService().createMyPlayer(userId, myPlayerData);
      myPlayer = createdMyPlayer;
      await _saveMyPlayer(); // Save newly created player
    } catch (e) {
      // Error handling
    }

    isLoading = false;
    notifyListeners();
  }
}