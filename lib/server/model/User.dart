class User {
  final String id;
  final String password;
  final String nickname;
  final List<String> favoriteLeagues;
  final List<String> favoriteTeams;
  final List<String> favoritePlayers;
  final int points;

  User({
    required this.id,
    required this.password,
    required this.nickname,
    required this.favoriteLeagues,
    required this.favoriteTeams,
    required this.favoritePlayers,
    required this.points,
  });

  // JSON으로부터 User 객체를 생성하는 팩토리 생성자
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      password: json['password'],
      nickname: json['nickname'],
      favoriteLeagues: List<String>.from(json['favoriteLeagues']),
      favoriteTeams: List<String>.from(json['favoriteTeams']),
      favoritePlayers: List<String>.from(json['favoritePlayers']),
      points: json['points'],
    );
  }

  // User 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'nickname': nickname,
      'favoriteLeagues': favoriteLeagues,
      'favoriteTeams': favoriteTeams,
      'favoritePlayers': favoritePlayers,
      'points': points,
    };
  }
}