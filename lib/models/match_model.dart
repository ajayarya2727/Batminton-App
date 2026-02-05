// =============================================================================
// MATCH MODEL - Main Match Information with Teams and Rounds
// =============================================================================

import 'enums.dart';
import 'team_model.dart';
import 'round_model.dart';
import 'scorecard_model.dart';

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
  
  // Get current round (active/in-progress round)
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
  
  // Get current server from current round
  String? get currentServer => currentRound?.currentServer;
  
  // Get display round number for UI (handles completed rounds properly)
  int get displayRoundNumber {
    if (rounds.isEmpty) return 1;
    
    // If match is completed, show the last round number
    if (isCompleted) return rounds.length;
    
    // Count completed rounds
    final completedRounds = rounds.where((r) => r.isCompleted).length;
    
    // If all rounds are completed but match isn't marked complete, show last round
    if (completedRounds == rounds.length) {
      return rounds.length;
    }
    
    // If there's an in-progress round, show its number
    for (final round in rounds) {
      if (round.isInProgress) {
        return round.roundNumber;
      }
    }
    
    // Otherwise, show the next round number (completed rounds + 1)
    return completedRounds + 1;
  }
  
  // Legacy compatibility properties for existing code
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
      'matchId': matchId,
      'matchType': matchType.displayName,
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
    // Handle match type - support both old code format and new displayName format
    BadmintonMatchType matchType;
    final matchTypeValue = json['matchType'] as String;
    if (matchTypeValue == 'Singles' || matchTypeValue == '1v1') {
      matchType = BadmintonMatchType.singles;
    } else if (matchTypeValue == 'Doubles' || matchTypeValue == '2v2') {
      matchType = BadmintonMatchType.doubles;
    } else {
      // Fallback to code-based parsing
      matchType = BadmintonMatchType.fromCode(matchTypeValue);
    }
    
    return BadmintonMatchModel(
      matchId: json['matchId'] as String? ?? json['id'] as String, // Support both keys
      matchType: matchType,
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
  BadmintonMatchModel initializeFirstRound({String? initialServer}) {
    if (rounds.isNotEmpty) return this;
    
    // If no initial server specified, default to first player of team1
    String defaultServer = initialServer ?? team1.players.first.playerId;
    
    // Initialize player scores to 0 for all players
    Map<String, int> initialPlayerScores = {};
    
    for (final player in team1.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    for (final player in team2.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    
    final firstRound = BadmintonRoundModel(
      roundNumber: 1,
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
      initialServer: defaultServer,
      currentServer: defaultServer,
      pointSequence: [], // Empty at start
      playerScores: initialPlayerScores,
      milestone21Reached: false, // Ensure milestone is reset
      continueTo30Chosen: false, // Ensure continue flag is reset
    );
    
    // Update players with current round scores and server status
    final updatedTeam1 = team1.copyWith(
      players: team1.players.map((player) => player.copyWith(
        currentRoundScore: 0,
        isCurrentServer: player.playerId == defaultServer,
      )).toList(),
    );
    
    final updatedTeam2 = team2.copyWith(
      players: team2.players.map((player) => player.copyWith(
        currentRoundScore: 0,
        isCurrentServer: player.playerId == defaultServer,
      )).toList(),
    );
    
    return copyWith(
      rounds: [firstRound],
      currentRoundNumber: 1,
      team1: updatedTeam1,
      team2: updatedTeam2,
    );
  }
  
  BadmintonMatchModel updateCurrentRoundScores(int team1Score, int team2Score) {
    if (currentRound == null) return this;
    
    final updatedRound = currentRound!.updateScores(team1Score, team2Score);
    final updatedRounds = List<BadmintonRoundModel>.from(rounds);
    updatedRounds[currentRoundNumber - 1] = updatedRound;
    
    return copyWith(rounds: updatedRounds);
  }
  
  BadmintonMatchModel updateCurrentRoundScoresWithService(int team1Score, int team2Score, {int? prevTeam1Score, int? prevTeam2Score}) {
    if (currentRound == null) return this;
    
    final totalPoints = team1Score + team2Score;
    
    // Build point sequence based on scores
    List<String> newPointSequence = [];
    
    // Reconstruct point sequence from scores
    int t1Points = 0;
    int t2Points = 0;
    
    while (t1Points + t2Points < totalPoints) {
      if (t1Points < team1Score && t2Points < team2Score) {
        // Both teams have points remaining, need to determine order
        // Use a simple alternating pattern based on final ratio
        double t1Ratio = (t1Points + 1.0) / team1Score;
        double t2Ratio = (t2Points + 1.0) / team2Score;
        
        if (t1Ratio <= t2Ratio) {
          newPointSequence.add('team1');
          t1Points++;
        } else {
          newPointSequence.add('team2');
          t2Points++;
        }
      } else if (t1Points < team1Score) {
        newPointSequence.add('team1');
        t1Points++;
      } else {
        newPointSequence.add('team2');
        t2Points++;
      }
    }
    
    // Calculate current server based on point sequence
    String currentServerForScore = currentRound!.initialServer ?? team1.players.first.playerId;
    
    if (newPointSequence.isNotEmpty) {
      // Find who won the last point
      final lastPointWinner = newPointSequence.last;
      if (lastPointWinner == 'team1') {
        // Use the first player from team1 as the server
        currentServerForScore = team1.players.first.playerId;
      } else if (lastPointWinner == 'team2') {
        // Use the first player from team2 as the server
        currentServerForScore = team2.players.first.playerId;
      } else {
        // If it's already a player ID, use it directly
        currentServerForScore = lastPointWinner;
      }
    }
    
    final updatedRound = currentRound!.copyWith(
      team1Score: team1Score,
      team2Score: team2Score,
      currentServer: currentServerForScore,
      pointSequence: newPointSequence,
    );
    
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

  BadmintonMatchModel markContinueTo30Chosen() {
    if (currentRound == null) return this;
    
    final updatedRound = currentRound!.markContinueTo30Chosen();
    final updatedRounds = List<BadmintonRoundModel>.from(rounds);
    updatedRounds[currentRoundNumber - 1] = updatedRound;
    
    return copyWith(rounds: updatedRounds);
  }
  
  BadmintonMatchModel completeCurrentRound(String winnerId) {
    if (currentRound == null) return this;
    
    // Complete the current round with winner
    final completedRound = currentRound!.complete(winnerId);
    final updatedRounds = List<BadmintonRoundModel>.from(rounds);
    updatedRounds[currentRoundNumber - 1] = completedRound;
    
    // Check if match is complete after this round
    final updatedMatch = copyWith(rounds: updatedRounds);
    final team1Wins = updatedMatch.team1RoundsWon;
    final team2Wins = updatedMatch.team2RoundsWon;
    
    // Best of 3: Match complete when someone wins 2 rounds
    if (team1Wins >= 2 || team2Wins >= 2) {
      final matchWinner = team1Wins >= 2 ? 'team1' : 'team2';
      return updatedMatch.copyWith(
        status: BadmintonMatchStatus.completed,
        winnerId: matchWinner,
      );
    }
    
    // Match continues - return updated match with completed round
    // Note: currentRoundNumber stays the same until next round is started
    return updatedMatch;
  }
  
  BadmintonMatchModel startNextRound() {
    print('DEBUG: startNextRound called - isMatchComplete: $isMatchComplete, currentRoundNumber: $currentRoundNumber');
    
    if (isMatchComplete) {
      print('DEBUG: Match is already complete, cannot start next round');
      return this;
    }
    
    if (currentRoundNumber >= 3) {
      print('DEBUG: Already at maximum rounds (3), cannot start next round');
      return this;
    }
    
    final nextRoundNumber = currentRoundNumber + 1;
    print('DEBUG: Creating round $nextRoundNumber');
    
    // Determine who should serve first in next round
    // In badminton, the winner of previous round serves first in next round
    final previousRound = rounds.isNotEmpty ? rounds.last : null;
    String? nextRoundServer;
    
    if (previousRound?.winnerId != null) {
      final winnerTeamId = previousRound!.winnerId!;
      if (winnerTeamId == 'team1') {
        nextRoundServer = team1.players.first.playerId;
      } else if (winnerTeamId == 'team2') {
        nextRoundServer = team2.players.first.playerId;
      }
      print('DEBUG: Previous round winner: $winnerTeamId, next server: $nextRoundServer');
    }
    
    // If no previous round winner, default to team1 first player
    nextRoundServer ??= team1.players.first.playerId;
    
    // Initialize player scores to 0 for all players in the new round
    Map<String, int> initialPlayerScores = {};
    for (final player in team1.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    for (final player in team2.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    
    final nextRound = BadmintonRoundModel(
      roundNumber: nextRoundNumber,
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
      initialServer: nextRoundServer,
      currentServer: nextRoundServer,
      pointSequence: [], // Empty at start
      playerScores: initialPlayerScores,
      milestone21Reached: false, // Reset milestone for new round
      continueTo30Chosen: false, // Reset continue flag for new round
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(rounds)..add(nextRound);
    
    final result = copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
    
    print('DEBUG: startNextRound completed - new currentRoundNumber: ${result.currentRoundNumber}, total rounds: ${result.rounds.length}');
    return result;
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

  // Generate scorecard from match data
  BadmintonMatchScorecard generateScorecard() {
    // Calculate team 1 stats
    final team1PlayerStats = team1.players.map((player) {
      int totalPoints = 0;
      int roundsWon = 0;
      int roundsLost = 0;
      Map<int, int> pointsPerRound = {};

      // Calculate points from completed rounds using individual player scores
      for (final round in rounds.where((r) => r.isCompleted)) {
        final playerScore = round.playerScores[player.playerId] ?? 0;
        pointsPerRound[round.roundNumber] = playerScore;
        totalPoints += playerScore;
        if (round.winnerId == 'team1') {
          roundsWon++;
        } else {
          roundsLost++;
        }
      }

      // Add current round points if in progress using individual player scores
      if (currentRound != null && currentRound!.isInProgress) {
        final playerScore = currentRound!.playerScores[player.playerId] ?? 0;
        pointsPerRound[currentRoundNumber] = playerScore;
        totalPoints += playerScore;
      }

      return BadmintonPlayerStats(
        playerId: player.playerId,
        playerName: player.name,
        totalPointsScored: totalPoints,
        roundsWon: roundsWon,
        roundsLost: roundsLost,
        pointsPerRound: pointsPerRound,
        winPercentage: (roundsWon + roundsLost) > 0 ? (roundsWon / (roundsWon + roundsLost)) * 100 : 0.0,
      );
    }).toList();

    // Calculate team 2 stats
    final team2PlayerStats = team2.players.map((player) {
      int totalPoints = 0;
      int roundsWon = 0;
      int roundsLost = 0;
      Map<int, int> pointsPerRound = {};

      // Calculate points from completed rounds using individual player scores
      for (final round in rounds.where((r) => r.isCompleted)) {
        final playerScore = round.playerScores[player.playerId] ?? 0;
        pointsPerRound[round.roundNumber] = playerScore;
        totalPoints += playerScore;
        if (round.winnerId == 'team2') {
          roundsWon++;
        } else {
          roundsLost++;
        }
      }

      // Add current round points if in progress using individual player scores
      if (currentRound != null && currentRound!.isInProgress) {
        final playerScore = currentRound!.playerScores[player.playerId] ?? 0;
        pointsPerRound[currentRoundNumber] = playerScore;
        totalPoints += playerScore;
      }

      return BadmintonPlayerStats(
        playerId: player.playerId,
        playerName: player.name,
        totalPointsScored: totalPoints,
        roundsWon: roundsWon,
        roundsLost: roundsLost,
        pointsPerRound: pointsPerRound,
        winPercentage: (roundsWon + roundsLost) > 0 ? (roundsWon / (roundsWon + roundsLost)) * 100 : 0.0,
      );
    }).toList();

    // Calculate total team points
    final team1TotalPoints = team1PlayerStats.fold<int>(0, (sum, player) => sum + player.totalPointsScored);
    final team2TotalPoints = team2PlayerStats.fold<int>(0, (sum, player) => sum + player.totalPointsScored);

    // Create team stats
    final team1Stats = BadmintonTeamStats(
      teamId: team1.teamId,
      teamName: team1.teamName,
      teamLogo: team1.teamLogo,
      playerStats: team1PlayerStats,
      totalTeamPoints: team1TotalPoints,
      roundsWon: team1RoundsWon,
      roundsLost: team2RoundsWon,
      teamWinPercentage: (team1RoundsWon + team2RoundsWon) > 0 ? (team1RoundsWon / (team1RoundsWon + team2RoundsWon)) * 100 : 0.0,
    );

    final team2Stats = BadmintonTeamStats(
      teamId: team2.teamId,
      teamName: team2.teamName,
      teamLogo: team2.teamLogo,
      playerStats: team2PlayerStats,
      totalTeamPoints: team2TotalPoints,
      roundsWon: team2RoundsWon,
      roundsLost: team1RoundsWon,
      teamWinPercentage: (team1RoundsWon + team2RoundsWon) > 0 ? (team2RoundsWon / (team1RoundsWon + team2RoundsWon)) * 100 : 0.0,
    );

    // Create round scores map
    Map<int, Map<String, int>> roundScoresMap = {};
    for (final round in rounds.where((r) => r.isCompleted)) {
      roundScoresMap[round.roundNumber] = {
        'team1': round.team1Score,
        'team2': round.team2Score,
      };
    }

    return BadmintonMatchScorecard(
      matchId: matchId,
      team1Stats: team1Stats,
      team2Stats: team2Stats,
      matchDate: createdAt,
      matchType: matchType.displayName,
      matchStatus: status.displayName,
      matchWinner: matchWinner,
      totalRounds: 3,
      roundScores: roundScoresMap,
    );
  }

  @override
  String toString() => 'BadmintonMatchModel(id: $matchId, type: ${matchType.displayName}, status: ${status.displayName})';
}