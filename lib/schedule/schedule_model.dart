class Match {
  final String matchId;
  final DateTime date;
  final String league;
  final String homeTeam;
  final String awayTeam;
  final DateTime startTime;
  int homeTeamScore;
  int awayTeamScore;
  int homeTeamVotes;
  int awayTeamVotes;

  Match({
    required this.matchId,
    required this.date,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    this.homeTeamScore = 0,
    this.awayTeamScore = 0,
    this.homeTeamVotes = 0,
    this.awayTeamVotes = 0,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['_id'],
      date: DateTime.parse(json['date']),
      league: json['league'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      startTime: DateTime.parse(json['startTime']),
      homeTeamScore: json['homeTeamScore'],
      awayTeamScore: json['awayTeamScore'],
      homeTeamVotes: json['homeTeamVotes'],
      awayTeamVotes: json['awayTeamVotes'],
    );
  }
}