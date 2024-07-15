class Meeting {
  final String id; // 모임의 고유 ID
  final String title; // 모임의 제목
  final int maxParticipants; // 최대 참여자 수
  int currentParticipants; // 현재 참여자 수
  final List<String> participants; // 참여자들의 ID 리스트
  final String pubAddress; // 펍의 주소
  final String supportTeam; // 응원하는 팀 이름
  final String date; // 축구 관람 날짜 ('YYYY-MM-DD' 형식)
  final String time; // 축구 관람 시간 ('HH:mm~HH:mm' 형식)
  final bool isClosed; // 모집 상태 (true: 마감, false: 모집 중)
  final double longitude; // 경도
  final double latitude; // 위도
  final String creatorId; // 모임 생성자의 ID

  Meeting({
    required this.id,
    required this.title,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.participants = const [],
    required this.pubAddress,
    required this.supportTeam,
    required this.date,
    required this.time,
    this.isClosed = false,
    required this.longitude,
    required this.latitude,
    required this.creatorId,
  });

  // JSON으로부터 Meeting 객체를 생성하는 팩토리 생성자
  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['_id'],
      title: json['title'],
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'],
      participants: List<String>.from(json['participants']),
      pubAddress: json['pubAddress'],
      supportTeam: json['supportTeam'],
      date: json['date'],
      time: json['time'],
      isClosed: json['isClosed'],
      longitude: json['longitude'],
      latitude: json['latitude'],
      creatorId: json['creatorId'],
    );
  }

  // Meeting 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Note the underscore, which is necessary for MongoDB
      'title': title,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'participants': participants,
      'pubAddress': pubAddress,
      'supportTeam': supportTeam,
      'date': date,
      'time': time,
      'isClosed': isClosed,
      'longitude': longitude,
      'latitude': latitude,
      'creatorId': creatorId,
    };
  }
}