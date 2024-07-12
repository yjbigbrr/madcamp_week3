class MyProfile {
  final String nickname;
  final String id;
  final List<String> favoriteLeagues;
  final List<String> favoriteTeams;
  final List<String> favoritePlayers;
  final String city;
  final bool isKakaoLinked;

  MyProfile({
    required this.nickname,
    required this.id,
    required this.favoriteLeagues,
    required this.favoriteTeams,
    required this.favoritePlayers,
    required this.city,
    required this.isKakaoLinked,
  });

  // Profile 객체를 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'id': id,
      'favoriteLeagues': favoriteLeagues,
      'favoriteTeams': favoriteTeams,
      'favoritePlayers': favoritePlayers,
      'city': city,
      'isKakaoLinked': isKakaoLinked,
    };
  }

  // JSON 형식의 데이터를 Profile 객체로 변환
  factory MyProfile.fromJson(Map<String, dynamic> json) {
    return MyProfile(
      nickname: json['nickname'],
      id: json['id'],
      favoriteLeagues: json['favoriteLeagues'] != null
          ? List<String>.from(json['favoriteLeagues'])
          : [],
      favoriteTeams: json['favoriteTeams'] != null
          ? List<String>.from(json['favoriteTeams'])
          : [],
      favoritePlayers: json['favoritePlayers'] != null
          ? List<String>.from(json['favoritePlayers'])
          : [],
      city: json['city'] ?? '',
      isKakaoLinked: json['isKakaoLinked'] ?? false,
    );
  }
}