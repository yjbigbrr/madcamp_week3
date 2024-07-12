class UpdateStatsDto {
  final int? dribbling;
  final int? shooting;
  final int? passing;
  final int? firstTouch;
  final int? crossing;
  final int? offTheBall;
  final int? tackling;
  final int? marking;
  final int? defensivePositioning;
  final int? concentration;
  final int? strength;
  final int? pace;
  final int? stamina;
  final int? jumping;
  final int? injuryProneness;
  final int? reflexes;
  final int? handling;
  final int? communication;
  final int? commandOfArea;
  final int? goalKicks;
  final int? throwing;

  UpdateStatsDto({
    this.dribbling,
    this.shooting,
    this.passing,
    this.firstTouch,
    this.crossing,
    this.offTheBall,
    this.tackling,
    this.marking,
    this.defensivePositioning,
    this.concentration,
    this.strength,
    this.pace,
    this.stamina,
    this.jumping,
    this.injuryProneness,
    this.reflexes,
    this.handling,
    this.communication,
    this.commandOfArea,
    this.goalKicks,
    this.throwing,
  });

  Map<String, int?> toJson() {
    return {
      'dribbling': dribbling,
      'shooting': shooting,
      'passing': passing,
      'firstTouch': firstTouch,
      'crossing': crossing,
      'offTheBall': offTheBall,
      'tackling': tackling,
      'marking': marking,
      'defensivePositioning': defensivePositioning,
      'concentration': concentration,
      'strength': strength,
      'pace': pace,
      'stamina': stamina,
      'jumping': jumping,
      'injuryProneness': injuryProneness,
      'reflexes': reflexes,
      'handling': handling,
      'communication': communication,
      'commandOfArea': commandOfArea,
      'goalKicks': goalKicks,
      'throwing': throwing,
    }..removeWhere((key, value) => value == null); // null 값을 제거합니다.
  }
}