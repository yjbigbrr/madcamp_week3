class MyPlayer {
  final String id;
  final String name;
  final String position;
  final String preferredFoot;
  final int overAll;

  // 공격능력치
  final int? dribbling;
  final int? shooting;
  final int? offTheBall;

  //패스능력치
  final int? passing;
  final int? firstTouch;
  final int? crossing;
  final int? vision;

  // 수비능력치
  final int? tackling;
  final int? marking;
  final int? defensivePositioning;
  final int? concentration;

  // 신체능력치
  final int strength;
  final int pace;
  final int stamina;
  final int agility;
  final int jumping;
  final int injuryProneness;

  // 골키퍼 능력치
  final int? reflexes;
  final int? aeriel;
  final int? handling;
  final int? communication;
  final int? commandOfArea;
  final int? goalKicks;
  final int? throwing;

  MyPlayer({
    required this.id,
    required this.name,
    required this.position,
    required this.preferredFoot,
    required this.overAll,
    this.dribbling,
    this.shooting,
    this.passing,
    this.vision,
    this.firstTouch,
    this.crossing,
    this.offTheBall,
    this.tackling,
    this.marking,
    this.defensivePositioning,
    this.concentration,
    required this.strength,
    required this.pace,
    required this.stamina,
    required this.agility,
    required this.jumping,
    required this.injuryProneness,
    this.reflexes,
    this.aeriel,
    this.handling,
    this.communication,
    this.commandOfArea,
    this.goalKicks,
    this.throwing,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'preferredFoot': preferredFoot,
    'overAll': overAll,
    'dribbling': dribbling,
    'shooting': shooting,
    'offTheBall': offTheBall,
    'passing': passing,
    'firstTouch': firstTouch,
    'crossing': crossing,
    'vision': vision,
    'tackling': tackling,
    'marking': marking,
    'defensivePositioning': defensivePositioning,
    'concentration': concentration,
    'strength': strength,
    'pace': pace,
    'stamina': stamina,
    'agility': agility,
    'jumping': jumping,
    'injuryProneness': injuryProneness,
    'reflexes': reflexes,
    'aeriel': aeriel,
    'handling': handling,
    'communication': communication,
    'commandOfArea': commandOfArea,
    'goalKicks': goalKicks,
    'throwing': throwing,
  };

  // JSON 역직렬화
  factory MyPlayer.fromJson(Map<String, dynamic> json) {
    return MyPlayer(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      preferredFoot: json['preferredFoot'],
      overAll: json['overAll'],
      dribbling: json['dribbling'],
      shooting: json['shooting'],
      passing: json['passing'],
      vision: json['vision'],
      firstTouch: json['firstTouch'],
      crossing: json['crossing'],
      offTheBall: json['offTheBall'],
      tackling: json['tackling'],
      marking: json['marking'],
      defensivePositioning: json['defensivePositioning'],
      concentration: json['concentration'],
      strength: json['strength'],
      pace: json['pace'],
      stamina: json['stamina'],
      agility: json['agility'],
      jumping: json['jumping'],
      injuryProneness: json['injuryProneness'],
      reflexes: json['reflexes'],
      aeriel: json['aeriel'],
      handling: json['handling'],
      communication: json['communication'],
      commandOfArea: json['commandOfArea'],
      goalKicks: json['goalKicks'],
      throwing: json['throwing'],
    );
  }
}