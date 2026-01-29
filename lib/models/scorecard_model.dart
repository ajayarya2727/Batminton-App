// =============================================================================
// SCORECARD MODEL - Player Performance and Statistics
// =============================================================================

class BadmintonPlayerStats {
  final String playerId;
  final String playerName;
  final int totalPointsScored;
  final int roundsWon;
  final int roundsLost;
  final Map<int, int> pointsPerRound; // Round number -> Points scored in that round
  final int servesWon;
  final int servesLost;
  final double winPercentage;

  const BadmintonPlayerStats({
    required this.playerId,
    required this.playerName,
    this.totalPointsScored = 0,
    this.roundsWon = 0,
    this.roundsLost = 0,
    this.pointsPerRound = const {},
    this.servesWon = 0,
    this.servesLost = 0,
    double? winPercentage,
  }) : winPercentage = winPercentage ?? 0.0;

  // Computed properties
  int get totalRoundsPlayed => roundsWon + roundsLost;
  double get averagePointsPerRound => totalRoundsPlayed > 0 ? totalPointsScored / totalRoundsPlayed : 0.0;
  bool get hasPlayedRounds => totalRoundsPlayed > 0;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'totalPointsScored': totalPointsScored,
      'roundsWon': roundsWon,
      'roundsLost': roundsLost,
      'pointsPerRound': pointsPerRound,
      'servesWon': servesWon,
      'servesLost': servesLost,
      'winPercentage': winPercentage,
    };
  }

  // JSON deserialization
  factory BadmintonPlayerStats.fromJson(Map<String, dynamic> json) {
    return BadmintonPlayerStats(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      totalPointsScored: json['totalPointsScored'] as int? ?? 0,
      roundsWon: json['roundsWon'] as int? ?? 0,
      roundsLost: json['roundsLost'] as int? ?? 0,
      pointsPerRound: Map<int, int>.from(json['pointsPerRound'] as Map? ?? {}),
      servesWon: json['servesWon'] as int? ?? 0,
      servesLost: json['servesLost'] as int? ?? 0,
      winPercentage: (json['winPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Copy with method
  BadmintonPlayerStats copyWith({
    String? playerId,
    String? playerName,
    int? totalPointsScored,
    int? roundsWon,
    int? roundsLost,
    Map<int, int>? pointsPerRound,
    int? servesWon,
    int? servesLost,
    double? winPercentage,
  }) {
    return BadmintonPlayerStats(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      totalPointsScored: totalPointsScored ?? this.totalPointsScored,
      roundsWon: roundsWon ?? this.roundsWon,
      roundsLost: roundsLost ?? this.roundsLost,
      pointsPerRound: pointsPerRound ?? this.pointsPerRound,
      servesWon: servesWon ?? this.servesWon,
      servesLost: servesLost ?? this.servesLost,
      winPercentage: winPercentage ?? this.winPercentage,
    );
  }

  @override
  String toString() => 'BadmintonPlayerStats(player: $playerName, points: $totalPointsScored, rounds: $roundsWon-$roundsLost)';
}

class BadmintonTeamStats {
  final String teamId;
  final String teamName;
  final String teamLogo;
  final List<BadmintonPlayerStats> playerStats;
  final int totalTeamPoints;
  final int roundsWon;
  final int roundsLost;
  final double teamWinPercentage;

  const BadmintonTeamStats({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.playerStats,
    int? totalTeamPoints,
    this.roundsWon = 0,
    this.roundsLost = 0,
    double? teamWinPercentage,
  }) : totalTeamPoints = totalTeamPoints ?? 0,
       teamWinPercentage = teamWinPercentage ?? 0.0;

  // Computed properties
  int get totalRoundsPlayed => roundsWon + roundsLost;
  double get averagePointsPerRound => totalRoundsPlayed > 0 ? totalTeamPoints / totalRoundsPlayed : 0.0;
  bool get hasWonMatch => roundsWon >= 2;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamLogo': teamLogo,
      'playerStats': playerStats.map((p) => p.toJson()).toList(),
      'totalTeamPoints': totalTeamPoints,
      'roundsWon': roundsWon,
      'roundsLost': roundsLost,
      'teamWinPercentage': teamWinPercentage,
    };
  }

  // JSON deserialization
  factory BadmintonTeamStats.fromJson(Map<String, dynamic> json) {
    return BadmintonTeamStats(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      teamLogo: json['teamLogo'] as String,
      playerStats: (json['playerStats'] as List<dynamic>)
          .map((p) => BadmintonPlayerStats.fromJson(p as Map<String, dynamic>))
          .toList(),
      totalTeamPoints: json['totalTeamPoints'] as int?,
      roundsWon: json['roundsWon'] as int? ?? 0,
      roundsLost: json['roundsLost'] as int? ?? 0,
      teamWinPercentage: (json['teamWinPercentage'] as num?)?.toDouble(),
    );
  }

  @override
  String toString() => 'BadmintonTeamStats(team: $teamName, points: $totalTeamPoints, rounds: $roundsWon-$roundsLost)';
}

class BadmintonMatchScorecard {
  final String matchId;
  final BadmintonTeamStats team1Stats;
  final BadmintonTeamStats team2Stats;
  final DateTime matchDate;
  final String matchType;
  final String matchStatus;
  final String? matchWinner;
  final int totalRounds;
  final Map<int, Map<String, int>> roundScores; // Round -> {team1: score, team2: score}

  const BadmintonMatchScorecard({
    required this.matchId,
    required this.team1Stats,
    required this.team2Stats,
    required this.matchDate,
    required this.matchType,
    required this.matchStatus,
    this.matchWinner,
    this.totalRounds = 3,
    this.roundScores = const {},
  });

  // Computed properties
  bool get isMatchCompleted => matchStatus == 'completed';
  int get completedRounds => roundScores.length;
  String get finalScore => '${team1Stats.roundsWon} - ${team2Stats.roundsWon}';

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'team1Stats': team1Stats.toJson(),
      'team2Stats': team2Stats.toJson(),
      'matchDate': matchDate.toIso8601String(),
      'matchType': matchType,
      'matchStatus': matchStatus,
      'matchWinner': matchWinner,
      'totalRounds': totalRounds,
      'roundScores': roundScores,
    };
  }

  // JSON deserialization
  factory BadmintonMatchScorecard.fromJson(Map<String, dynamic> json) {
    return BadmintonMatchScorecard(
      matchId: json['matchId'] as String,
      team1Stats: BadmintonTeamStats.fromJson(json['team1Stats'] as Map<String, dynamic>),
      team2Stats: BadmintonTeamStats.fromJson(json['team2Stats'] as Map<String, dynamic>),
      matchDate: DateTime.parse(json['matchDate'] as String),
      matchType: json['matchType'] as String,
      matchStatus: json['matchStatus'] as String,
      matchWinner: json['matchWinner'] as String?,
      totalRounds: json['totalRounds'] as int? ?? 3,
      roundScores: Map<int, Map<String, int>>.from(
        (json['roundScores'] as Map? ?? {}).map(
          (key, value) => MapEntry(
            int.parse(key.toString()),
            Map<String, int>.from(value as Map),
          ),
        ),
      ),
    );
  }

  @override
  String toString() => 'BadmintonMatchScorecard(match: $matchId, score: $finalScore, status: $matchStatus)';
}