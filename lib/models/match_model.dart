class MatchModel {
  final String id;
  final String matchType; // "1v1" or "2v2"
  final List<String> team1Players;
  final List<String> team2Players;
  final int team1Score;
  final int team2Score;
  final DateTime createdAt;
  final bool isCompleted;
  final int currentRound; // Current round (1, 2, or 3)
  final List<int> team1RoundWins; // Rounds won by team 1
  final List<int> team2RoundWins; // Rounds won by team 2
  final List<Map<String, int>> roundScores; // Score history for each round
  final String? winner; // Overall match winner
  final bool milestone21Reached; // Track if 21 milestone was already reached

  MatchModel({
    required this.id,
    required this.matchType,
    required this.team1Players,
    required this.team2Players,
    this.team1Score = 0,
    this.team2Score = 0,
    required this.createdAt,
    this.isCompleted = false,
    this.currentRound = 1,
    this.team1RoundWins = const [],
    this.team2RoundWins = const [],
    this.roundScores = const [],
    this.winner,
    this.milestone21Reached = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchType': matchType,
      'team1Players': team1Players,
      'team2Players': team2Players,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'currentRound': currentRound,
      'team1RoundWins': team1RoundWins,
      'team2RoundWins': team2RoundWins,
      'roundScores': roundScores,
      'winner': winner,
      'milestone21Reached': milestone21Reached,
    };
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      matchType: json['matchType'],
      team1Players: List<String>.from(json['team1Players']),
      team2Players: List<String>.from(json['team2Players']),
      team1Score: json['team1Score'] ?? 0,
      team2Score: json['team2Score'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      currentRound: json['currentRound'] ?? 1,
      team1RoundWins: json['team1RoundWins'] != null 
          ? List<int>.from(json['team1RoundWins']) 
          : [],
      team2RoundWins: json['team2RoundWins'] != null 
          ? List<int>.from(json['team2RoundWins']) 
          : [],
      roundScores: json['roundScores'] != null 
          ? List<Map<String, int>>.from(
              json['roundScores'].map((x) => Map<String, int>.from(x))
            )
          : [],
      winner: json['winner'],
      milestone21Reached: json['milestone21Reached'] ?? false,
    );
  }

  MatchModel copyWith({
    String? id,
    String? matchType,
    List<String>? team1Players,
    List<String>? team2Players,
    int? team1Score,
    int? team2Score,
    DateTime? createdAt,
    bool? isCompleted,
    int? currentRound,
    List<int>? team1RoundWins,
    List<int>? team2RoundWins,
    List<Map<String, int>>? roundScores,
    String? winner,
    bool? milestone21Reached,
  }) {
    return MatchModel(
      id: id ?? this.id,
      matchType: matchType ?? this.matchType,
      team1Players: team1Players ?? this.team1Players,
      team2Players: team2Players ?? this.team2Players,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      currentRound: currentRound ?? this.currentRound,
      team1RoundWins: team1RoundWins ?? this.team1RoundWins,
      team2RoundWins: team2RoundWins ?? this.team2RoundWins,
      roundScores: roundScores ?? this.roundScores,
      winner: winner ?? this.winner,
      milestone21Reached: milestone21Reached ?? this.milestone21Reached,
    );
  }

  // Helper methods for badminton rules
  bool get isRoundComplete {
    return team1Score >= 21 || team2Score >= 21;
  }

  bool get isMatchComplete {
    return team1RoundWins.length >= 2 || team2RoundWins.length >= 2;
  }

  String get currentRoundWinner {
    if (team1Score >= 21 && team1Score - team2Score >= 2) {
      return 'team1';
    } else if (team2Score >= 21 && team2Score - team1Score >= 2) {
      return 'team2';
    }
    return '';
  }

  int get team1RoundsWon => team1RoundWins.length;
  int get team2RoundsWon => team2RoundWins.length;

  // New computed properties for multi-round support
  String get matchWinner {
    if (team1RoundsWon >= 2) return 'team1';
    if (team2RoundsWon >= 2) return 'team2';
    return '';
  }

  Map<String, int> get currentRoundScore => {
    'team1': team1Score,
    'team2': team2Score,
  };
}