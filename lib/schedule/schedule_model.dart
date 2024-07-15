class Match {
  final String matchId;
  final String league;
  final String homeTeam;
  final String awayTeam;
  final DateTime startTime;
  int homeTeamScore;
  int awayTeamScore;
  int homeTeamVotes;
  int awayTeamVotes;
  final List<String>? homeTeamVoters;
  final List<String>? awayTeamVoters;

  Match({
    required this.matchId,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    this.homeTeamScore = 0,
    this.awayTeamScore = 0,
    this.homeTeamVotes = 0,
    this.awayTeamVotes = 0,
    this.homeTeamVoters,
    this.awayTeamVoters,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['_id'],
      league: json['league'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      startTime: DateTime.parse(json['startTime']),
      homeTeamScore: json['homeTeamScore'],
      awayTeamScore: json['awayTeamScore'],
      homeTeamVotes: json['homeTeamVotes'],
      awayTeamVotes: json['awayTeamVotes'],
      homeTeamVoters: List<String>.from(json['homeTeamVoters'] ?? []),
      awayTeamVoters: List<String>.from(json['awayTeamVoters'] ?? []),
    );
  }
}