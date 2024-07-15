class Match {
  final DateTime date;
  final String league;
  final String homeTeam;
  final String awayTeam;
  final DateTime startTime;
  final int homeTeamScore;
  final int awayTeamScore;
  final int homeTeamPoints;
  final int awayTeamPoints;

  Match({
    required this.date,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    required this.homeTeamScore,
    required this.awayTeamScore,
    required this.homeTeamPoints,
    required this.awayTeamPoints,
  });
}