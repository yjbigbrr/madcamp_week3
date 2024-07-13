import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer_app/drawer/profile/profile_view_model.dart';
import 'package:soccer_app/server/model/MyPlayer.dart';
import 'package:soccer_app/server/service/myplayer_service.dart';
import 'package:soccer_app/server/service/user_service.dart';


class MyPlayerViewModel extends ChangeNotifier {
  final ProfileViewModel profileViewModel;
  List<String>? myPlayerIds;
  MyPlayer? currentMyPlayer;
  bool isLoading = false;

  MyPlayerViewModel({required this.profileViewModel}) {
    _fetchPlayerIdsAndData();
    debugPrint("my player view model init: list of player ids - $myPlayerIds");
  }

  Future<void> _fetchPlayerIdsAndData() async {
    final profile = profileViewModel.profile;

    if (profile == null) return;

    isLoading = true;
    notifyListeners();

    try {
      debugPrint("ready to get my player ids. my user id: ${profile.id}");
      myPlayerIds = await UserService().getMyPlayerIds(profile.id);
      debugPrint("my player ids prepared!!!! $myPlayerIds");
      if (myPlayerIds != null && myPlayerIds!.isNotEmpty) {
        await _fetchMyPlayer(myPlayerIds![0]); // 기본으로 첫 번째 플레이어 로드
      }
    } catch (e) {
      debugPrint("exception occurred getting player ids");
      myPlayerIds = null;
      currentMyPlayer = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchMyPlayer(String playerId) async {
    isLoading = true;
    notifyListeners();

    try {
      currentMyPlayer = await MyPlayerService().getMyPlayer(playerId);
    } catch (e) {
      currentMyPlayer = null;
    }

    isLoading = false;
    notifyListeners();
  }

  void changePlayer(String playerId) async {
    await _fetchMyPlayer(playerId);
    notifyListeners();
  }

  Future<void> createMyPlayer(String? userId, MyPlayer myPlayerData) async {
    if (userId == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final createdMyPlayer = await MyPlayerService().createMyPlayer(userId, myPlayerData);
      currentMyPlayer = createdMyPlayer;
    } catch (e) {
      // Error handling
    }

    isLoading = false;
    notifyListeners();
  }
}