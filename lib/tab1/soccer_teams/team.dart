import 'dart:convert';
import 'package:flutter/services.dart';

class Team {
  final String name;
  final String imagePath;
  final String starting11ImagePath;
  final String playerStatsImagePath;
  final String clubInfoPath;

  Team({
    required this.name,
    required this.imagePath,
    required this.starting11ImagePath,
    required this.playerStatsImagePath,
    required this.clubInfoPath,
  });

  Future<String> getClubInfo() async {
    try {

      return await rootBundle.loadString(clubInfoPath);
    } catch (e) {
      print("Error loading club info: $e");
      return 'Club information not available';
    }

  }
}
