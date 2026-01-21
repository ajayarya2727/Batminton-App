// =============================================================================
// BADMINTON SCORE APP - ALL MODELS IN ONE FILE
// =============================================================================
// This file contains all model classes for the badminton scoring application
// Classes are organized by responsibility but kept in single file for simplicity
// =============================================================================

// =============================================================================
// ENUMS - Match Types and Status
// =============================================================================

enum BadmintonMatchType {
  singles('1v1', 'Singles'),
  doubles('2v2', 'Doubles');

  const BadmintonMatchType(this.code, this.displayName);
  
  final String code;
  final String displayName;

  static BadmintonMatchType fromCode(String code) {
    switch (code) {
      case '1v1':
        return BadmintonMatchType.singles;
      case '2v2':
        return BadmintonMatchType.doubles;
      default:
        throw ArgumentError('Invalid match type code: $code');
    }
  }

  int get requiredPlayersPerTeam {
    switch (this) {
      case BadmintonMatchType.singles:
        return 1;
      case BadmintonMatchType.doubles:
        return 2;
    }
  }
}

enum BadmintonMatchStatus {
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  paused('paused', 'Paused'),
  cancelled('cancelled', 'Cancelled');

  const BadmintonMatchStatus(this.code, this.displayName);
  
  final String code;
  final String displayName;

  static BadmintonMatchStatus fromCode(String code) {
    switch (code) {
      case 'in_progress':
        return BadmintonMatchStatus.inProgress;
      case 'completed':
        return BadmintonMatchStatus.completed;
      case 'paused':
        return BadmintonMatchStatus.paused;
      case 'cancelled':
        return BadmintonMatchStatus.cancelled;
      default:
        throw ArgumentError('Invalid match status code: $code');
    }
  }

  bool get isActive => this == BadmintonMatchStatus.inProgress;
  bool get isFinished => this == BadmintonMatchStatus.completed || this == BadmintonMatchStatus.cancelled;
}

enum BadmintonRoundStatus {
  notStarted('not_started', 'Not Started'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed');

  const BadmintonRoundStatus(this.code, this.displayName);
  
  final String code;
  final String displayName;

  static BadmintonRoundStatus fromCode(String code) {
    switch (code) {
      case 'not_started':
        return BadmintonRoundStatus.notStarted;
      case 'in_progress':
        return BadmintonRoundStatus.inProgress;
      case 'completed':
        return BadmintonRoundStatus.completed;
      default:
        throw ArgumentError('Invalid round status code: $code');
    }
  }
}

// =============================================================================
// PLAYER MODEL - Individual Player Information
// =============================================================================

class BadmintonPlayerModel {
  final String playerId;
  final String name;

  const BadmintonPlayerModel({
    required this.playerId,
    required this.name,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'name': name,
    };
  }

  // JSON deserialization
  factory BadmintonPlayerModel.fromJson(Map<String, dynamic> json) {
    return BadmintonPlayerModel(
      playerId: json['playerId'] as String,
      name: json['name'] as String,
    );
  }

  // Copy with method for immutability
  BadmintonPlayerModel copyWith({
    String? playerId,
    String? playerName,
  }) {
    return BadmintonPlayerModel(
      playerId: playerId ?? this.playerId,
      name: playerName ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BadmintonPlayerModel &&
        other.playerId == playerId &&
        other.name == name;
  }

  @override
  int get hashCode => playerId.hashCode ^ name.hashCode;

  @override
  String toString() => 'BadmintonPlayerModel(playerId: $playerId, name: $name)';
}

// =============================================================================
// TEAM MODEL - Team Information with Players and Scores
// =============================================================================

class BadmintonTeamModel {
  final String teamId;
  final List<BadmintonPlayerModel> players;
  final int currentScore;
  final List<int> roundsWon;
  final int totalRoundsWon;

  const BadmintonTeamModel({
    required this.teamId,
    required this.players,
    this.currentScore = 0,
    this.roundsWon = const [],
    int? totalRoundsWon,
  }) : totalRoundsWon = totalRoundsWon ?? roundsWon.length;

  // Computed properties
  String get displayName => players.map((p) => p.name).join(' & ');
  bool get hasWonMatch => totalRoundsWon >= 2;
  int get playersCount => players.length;

  // Validation
  bool isValidForMatchType(int requiredPlayers) {
    return players.length == requiredPlayers && 
           players.every((player) => player.name.trim().isNotEmpty);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'players': players.map((player) => player.toJson()).toList(),
      'currentScore': currentScore,
      'roundsWon': roundsWon,
      'totalRoundsWon': totalRoundsWon,
    };
  }

  // JSON deserialization
  factory BadmintonTeamModel.fromJson(Map<String, dynamic> json) {
    return BadmintonTeamModel(
      teamId: json['teamId'] as String,
      players: (json['players'] as List<dynamic>)
          .map((playerJson) => BadmintonPlayerModel.fromJson(playerJson as Map<String, dynamic>))
          .toList(),
      currentScore: json['currentScore'] as int? ?? 0,
      roundsWon: (json['roundsWon'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
      totalRoundsWon: json['totalRoundsWon'] as int?,
    );
  }

  // Copy with method
  BadmintonTeamModel copyWith({
    String? teamId,
    List<BadmintonPlayerModel>? players,
    int? currentScore,
    List<int>? roundsWon,
    int? totalRoundsWon,
  }) {
    return BadmintonTeamModel(
      teamId: teamId ?? this.teamId,
      players: players ?? this.players,
      currentScore: currentScore ?? this.currentScore,
      roundsWon: roundsWon ?? this.roundsWon,
      totalRoundsWon: totalRoundsWon ?? this.totalRoundsWon,
    );
  }

  @override
  String toString() => 'BadmintonTeamModel(teamId: $teamId, players: ${players.length}, score: $currentScore)';
}

// =============================================================================
// ROUND MODEL - Individual Round Information
// =============================================================================

class BadmintonRoundModel {
  final int roundNumber;
  final int team1Score;
  final int team2Score;
  final BadmintonRoundStatus status;
  final String? winnerId;
  final bool milestone21Reached;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const BadmintonRoundModel({
    required this.roundNumber,
    this.team1Score = 0,
    this.team2Score = 0,
    this.status = BadmintonRoundStatus.notStarted,
    this.winnerId,
    this.milestone21Reached = false,
    this.startedAt,
    this.completedAt,
  });

  // Computed properties
  bool get isCompleted => status == BadmintonRoundStatus.completed;
  bool get isInProgress => status == BadmintonRoundStatus.inProgress;
  bool get hasWinner => winnerId != null;
  bool get hasReached21Points => team1Score >= 21 || team2Score >= 21;
  bool get hasReached30Points => team1Score >= 30 || team2Score >= 30;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'status': status.code,
      'winnerId': winnerId,
      'milestone21Reached': milestone21Reached,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // JSON deserialization
  factory BadmintonRoundModel.fromJson(Map<String, dynamic> json) {
    return BadmintonRoundModel(
      roundNumber: json['roundNumber'] as int,
      team1Score: json['team1Score'] as int? ?? 0,
      team2Score: json['team2Score'] as int? ?? 0,
      status: BadmintonRoundStatus.fromCode(json['status'] as String? ?? 'not_started'),
      winnerId: json['winnerId'] as String?,
      milestone21Reached: json['milestone21Reached'] as bool? ?? false,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  // Copy with method
  BadmintonRoundModel copyWith({
    int? roundNumber,
    int? team1Score,
    int? team2Score,
    BadmintonRoundStatus? status,
    String? winnerId,
    bool? milestone21Reached,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return BadmintonRoundModel(
      roundNumber: roundNumber ?? this.roundNumber,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      milestone21Reached: milestone21Reached ?? this.milestone21Reached,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Helper methods
  BadmintonRoundModel start() {
    return copyWith(
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
    );
  }

  BadmintonRoundModel complete(String winnerId) {
    return copyWith(
      status: BadmintonRoundStatus.completed,
      winnerId: winnerId,
      completedAt: DateTime.now(),
    );
  }

  BadmintonRoundModel updateScores(int team1Score, int team2Score) {
    return copyWith(
      team1Score: team1Score,
      team2Score: team2Score,
    );
  }

  BadmintonRoundModel markMilestone21Reached() {
    return copyWith(milestone21Reached: true);
  }

  @override
  String toString() => 'BadmintonRoundModel(round: $roundNumber, score: $team1Score-$team2Score, status: ${status.displayName})';
}

// =============================================================================
// MATCH MODEL - Main Match Information with Teams and Rounds
// =============================================================================

class BadmintonMatchModel {
  final String matchId;
  final BadmintonMatchType matchType;
  final BadmintonTeamModel team1;
  final BadmintonTeamModel team2;
  final BadmintonMatchStatus status;
  final DateTime createdAt;
  final int currentRoundNumber;
  final List<BadmintonRoundModel> rounds;
  final String? winnerId;

  const BadmintonMatchModel({
    required this.matchId,
    required this.matchType,
    required this.team1,
    required this.team2,
    this.status = BadmintonMatchStatus.inProgress,
    required this.createdAt,
    this.currentRoundNumber = 1,
    this.rounds = const [],
    this.winnerId,
  });

  // Computed properties
  bool get isCompleted => status == BadmintonMatchStatus.completed;
  bool get isInProgress => status == BadmintonMatchStatus.inProgress;
  
  // Get current round
  BadmintonRoundModel? get currentRound {
    if (rounds.isEmpty || currentRoundNumber > rounds.length) return null;
    return rounds[currentRoundNumber - 1];
  }
  
  // Get current scores from current round
  int get team1Score => currentRound?.team1Score ?? 0;
  int get team2Score => currentRound?.team2Score ?? 0;
  
  // Get rounds won by each team
  int get team1RoundsWon => rounds.where((r) => r.winnerId == 'team1').length;
  int get team2RoundsWon => rounds.where((r) => r.winnerId == 'team2').length;
  
  // Check if match is complete (best of 3)
  bool get isMatchComplete => team1RoundsWon >= 2 || team2RoundsWon >= 2;
  
  // Get match winner
  String? get matchWinner {
    if (team1RoundsWon >= 2) return 'team1';
    if (team2RoundsWon >= 2) return 'team2';
    return null;
  }
  
  // Check if 21 milestone reached in current round
  bool get milestone21Reached => currentRound?.milestone21Reached ?? false;
  
  // Legacy compatibility properties for existing code
  String get id => matchId;
  List<String> get team1Players => team1.players.map((p) => p.name).toList();
  List<String> get team2Players => team2.players.map((p) => p.name).toList();
  List<int> get team1RoundWins => rounds
      .where((r) => r.winnerId == 'team1')
      .map((r) => r.roundNumber)
      .toList();
  List<int> get team2RoundWins => rounds
      .where((r) => r.winnerId == 'team2')
      .map((r) => r.roundNumber)
      .toList();
  List<Map<String, int>> get roundScores => rounds
      .where((r) => r.isCompleted)
      .map((r) => {
        'team1': r.team1Score,
        'team2': r.team2Score,
        'winner': r.winnerId == 'team1' ? 1 : 2,
        'round': r.roundNumber,
      })
      .toList();
  String? get winner => matchWinner;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': matchId, // Keep 'id' for backward compatibility
      'matchId': matchId,
      'matchType': matchType.code,
      'team1': team1.toJson(),
      'team2': team2.toJson(),
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
      'currentRoundNumber': currentRoundNumber,
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'winnerId': winnerId,
    };
  }

  // JSON deserialization
  factory BadmintonMatchModel.fromJson(Map<String, dynamic> json) {
    return BadmintonMatchModel(
      matchId: json['matchId'] as String? ?? json['id'] as String, // Support both keys
      matchType: BadmintonMatchType.fromCode(json['matchType'] as String),
      team1: BadmintonTeamModel.fromJson(json['team1'] as Map<String, dynamic>),
      team2: BadmintonTeamModel.fromJson(json['team2'] as Map<String, dynamic>),
      status: BadmintonMatchStatus.fromCode(json['status'] as String? ?? 'in_progress'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      currentRoundNumber: json['currentRoundNumber'] as int? ?? 1,
      rounds: (json['rounds'] as List<dynamic>?)
          ?.map((r) => BadmintonRoundModel.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      winnerId: json['winnerId'] as String?,
    );
  }

  // Copy with method
  BadmintonMatchModel copyWith({
    String? matchId,
    BadmintonMatchType? matchType,
    BadmintonTeamModel? team1,
    BadmintonTeamModel? team2,
    BadmintonMatchStatus? status,
    DateTime? createdAt,
    int? currentRoundNumber,
    List<BadmintonRoundModel>? rounds,
    String? winnerId,
  }) {
    return BadmintonMatchModel(
      matchId: matchId ?? this.matchId,
      matchType: matchType ?? this.matchType,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      currentRoundNumber: currentRoundNumber ?? this.currentRoundNumber,
      rounds: rounds ?? this.rounds,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  // Match management methods
  BadmintonMatchModel initializeFirstRound() {
    if (rounds.isNotEmpty) return this;
    
    final firstRound = BadmintonRoundModel(
      roundNumber: 1,
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
    );
    
    return copyWith(
      rounds: [firstRound],
      currentRoundNumber: 1,
    );
  }
  
  BadmintonMatchModel updateCurrentRoundScores(int team1Score, int team2Score) {
    if (currentRound == null) return this;
    
    final updatedRound = currentRound!.updateScores(team1Score, team2Score);
    final updatedRounds = List<BadmintonRoundModel>.from(rounds);
    updatedRounds[currentRoundNumber - 1] = updatedRound;
    
    return copyWith(rounds: updatedRounds);
  }
  
  BadmintonMatchModel markMilestone21Reached() {
    if (currentRound == null) return this;
    
    final updatedRound = currentRound!.markMilestone21Reached();
    final updatedRounds = List<BadmintonRoundModel>.from(rounds);
    updatedRounds[currentRoundNumber - 1] = updatedRound;
    
    return copyWith(rounds: updatedRounds);
  }
  
  BadmintonMatchModel completeCurrentRound(String winnerId) {
    if (currentRound == null) return this;
    
    final completedRound = currentRound!.complete(winnerId);
    final updatedRounds = List<BadmintonRoundModel>.from(rounds);
    updatedRounds[currentRoundNumber - 1] = completedRound;
    
    final updatedMatch = copyWith(rounds: updatedRounds);
    
    if (updatedMatch.isMatchComplete) {
      return updatedMatch.copyWith(
        status: BadmintonMatchStatus.completed,
        winnerId: updatedMatch.matchWinner,
      );
    }
    
    return updatedMatch;
  }
  
  BadmintonMatchModel startNextRound() {
    if (isMatchComplete || currentRoundNumber >= 3) return this;
    
    final nextRoundNumber = currentRoundNumber + 1;
    final nextRound = BadmintonRoundModel(
      roundNumber: nextRoundNumber,
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(rounds)..add(nextRound);
    
    return copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
  }

  // Legacy compatibility methods for existing controller
  bool get isRoundComplete {
    return team1Score >= 21 || team2Score >= 21;
  }

  String get currentRoundWinner {
    if (team1Score >= 21 && team1Score - team2Score >= 2) {
      return 'team1';
    } else if (team2Score >= 21 && team2Score - team1Score >= 2) {
      return 'team2';
    }
    return '';
  }

  Map<String, int> get currentRoundScore => {
    'team1': team1Score,
    'team2': team2Score,
  };

  @override
  String toString() => 'BadmintonMatchModel(id: $matchId, type: ${matchType.displayName}, status: ${status.displayName})';
}