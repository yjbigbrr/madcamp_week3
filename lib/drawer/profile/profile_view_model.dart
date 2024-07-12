import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_model.dart';
import 'dart:convert';

class ProfileViewModel extends ChangeNotifier {
  static const String _profileKey = 'profile';

  MyProfile? _profile;

  MyProfile? get profile => _profile;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);

    if (profileJson != null) {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      _profile = MyProfile.fromJson(profileMap);
      notifyListeners();
    }
  }

  Future<void> saveProfile(MyProfile profile) async {
    debugPrint("save profile info");
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? nickname,
    List<String>? favoriteLeagues,
    List<String>? favoriteTeams,
    List<String>? favoritePlayers,
    String? city,
    bool? isKakaoLinked,
  }) async {
    if (_profile == null) return;

    final updatedProfile = MyProfile(
      nickname: nickname ?? _profile!.nickname,
      id: _profile!.id,
      favoriteLeagues: favoriteLeagues ?? _profile!.favoriteLeagues,
      favoriteTeams: favoriteTeams ?? _profile!.favoriteTeams,
      favoritePlayers: favoritePlayers ?? _profile!.favoritePlayers,
      city: city ?? _profile!.city,
      isKakaoLinked: isKakaoLinked ?? _profile!.isKakaoLinked,
    );

    await saveProfile(updatedProfile);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    _profile = null;
    notifyListeners();
  }
}