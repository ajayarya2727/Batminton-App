import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../../services/storage_service.dart';
import '../../controllers/app_controllers.dart';

class MatchController extends GetxController {
  final RxBool showManualServiceDialog = false.obs;
  final RxBool showRoundCompleteDialog = false.obs;
  final RxBool showNextRoundServiceDialog = false.obs;
  final RxBool showMatchCompleteDialog = false.obs;
  final RxBool showInfoDialog = false.obs;
  final RxString infoDialogMessage = ''.obs;
  final Rx<BadmintonMatchModel?> pendingMatch = Rx<BadmintonMatchModel?>(null);
  
  final RxInt breakStopwatch = 0.obs;
  Timer? _breakTimer;
  
  Future<void> initializeMatchWithService(String matchId, String initialServer) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    
    if (match.rounds.isNotEmpty) return;
    
    Map<String, int> initialPlayerScores = {};
    for (final player in match.team1.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    for (final player in match.team2.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    
    final firstRound = BadmintonRoundModel(
      roundNumber: 1,
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
      initialServer: initialServer,
      currentServer: initialServer,
      pointSequence: [],
      playerScores: initialPlayerScores,
    );
    
    final updatedTeam1 = match.team1.copyWith(
      players: match.team1.players.map((player) => player.copyWith(
        currentRoundScore: 0,
        isCurrentServer: player.playerId == initialServer,
      )).toList(),
    );
    
    final updatedTeam2 = match.team2.copyWith(
      players: match.team2.players.map((player) => player.copyWith(
        currentRoundScore: 0,
        isCurrentServer: player.playerId == initialServer,
      )).toList(),
    );
    
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(
      rounds: [firstRound],
      currentRoundNumber: 1,
      team1: updatedTeam1,
      team2: updatedTeam2,
    );
    
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    
    debugPrint('\n========== MATCH STARTED ==========');
    debugPrint('Match JSON:');
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(AppControllers.myMatches.matches[matchIndex].toJson());
    debugPrint(jsonString, wrapWidth: 1024);
    debugPrint('===================================\n');
  }
  
  Future<void> markContinueTo30(String matchId) async {
    // This method is no longer needed with official rules
    // Keeping for backward compatibility but does nothing
    return;
  }

  Future<void> updatePlayerScore(String matchId, String playerId, int newPlayerScore) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    
    final currentRound = getCurrentRound(match);
    if (currentRound == null) return;
    
    final prevPlayerScore = currentRound.playerScores[playerId] ?? 0;
    final updatedPlayerScores = Map<String, int>.from(currentRound.playerScores);
    updatedPlayerScores[playerId] = newPlayerScore;
    
    int newTeam1Score = 0;
    int newTeam2Score = 0;
    for (final player in match.team1.players) {
      newTeam1Score += updatedPlayerScores[player.playerId] ?? 0;
    }
    for (final player in match.team2.players) {
      newTeam2Score += updatedPlayerScores[player.playerId] ?? 0;
    }
    
    final previousTeam1Score = getTeam1Score(match);
    final previousTeam2Score = getTeam2Score(match);
    
    List<String> updatedPointSequence = List<String>.from(currentRound.pointSequence);
    String? newCurrentServer;
    
    if (newPlayerScore > prevPlayerScore) {
      updatedPointSequence.add(playerId);
      newCurrentServer = playerId;
    } else if (newPlayerScore < prevPlayerScore) {
      if (updatedPointSequence.isNotEmpty) {
        updatedPointSequence.removeLast();
        newCurrentServer = updatedPointSequence.isEmpty 
            ? currentRound.initialServer 
            : updatedPointSequence.last;
      } else {
        newCurrentServer = getCurrentServer(match);
      }
    } else {
      newCurrentServer = getCurrentServer(match);
    }
    
    if (updatedPointSequence.isEmpty) {
      newCurrentServer = currentRound.initialServer;
    }
    
    final updatedRound = currentRound.copyWith(
      playerScores: updatedPlayerScores,
      team1Score: newTeam1Score,
      team2Score: newTeam2Score,
      pointSequence: updatedPointSequence,
      currentServer: newCurrentServer,
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
    updatedRounds[match.currentRoundNumber - 1] = updatedRound;
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(rounds: updatedRounds);
    
    final updatedMatch = AppControllers.myMatches.matches[matchIndex];
    final updatedCurrentRound = getCurrentRound(updatedMatch);
    
    if (updatedCurrentRound != null) {
      final scoreDiff = (newTeam1Score - newTeam2Score).abs();
      bool shouldCompleteRound = false;
      String? roundWinner;
      
      // Check if someone just reached 21 for the FIRST TIME without 2-point lead
      // Only show popup once when first player reaches 21 (not when both are at 21)
      if (scoreDiff == 1) {
        // Exactly 1-point difference
        if ((newTeam1Score == 21 && previousTeam1Score == 20 && newTeam2Score == 20) ||
            (newTeam2Score == 21 && previousTeam2Score == 20 && newTeam1Score == 20)) {
          // First player just reached 21, other is at 20
          final message = "Game continues!\n\n2-point lead is required to win the round.";
          infoDialogMessage.value = message;
          showInfoDialog.value = true;
        }
      }
      
      // Official Badminton Rules - Automatic Round Completion
      if (newTeam1Score == 30 || newTeam2Score == 30) {
        shouldCompleteRound = true;
        roundWinner = newTeam1Score == 30 ? 'team1' : 'team2';
      } else if (newTeam1Score >= 21 && newTeam2Score >= 21) {
        if (scoreDiff >= 2) {
          shouldCompleteRound = true;
          roundWinner = newTeam1Score > newTeam2Score ? 'team1' : 'team2';
        }
      } else if (newTeam1Score >= 21 && scoreDiff >= 2) {
        shouldCompleteRound = true;
        roundWinner = 'team1';
      } else if (newTeam2Score >= 21 && scoreDiff >= 2) {
        shouldCompleteRound = true;
        roundWinner = 'team2';
      }
      
      if (shouldCompleteRound && roundWinner != null) {
        await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
        AppControllers.myMatches.matches.refresh();
        await completeCurrentRound(matchId, roundWinner, newTeam1Score, newTeam2Score);
        return;
      }
    }
    
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    AppControllers.myMatches.matches.refresh();
    await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
    _logScoreUpdate(AppControllers.myMatches.matches[matchIndex]);
  }

  Future<void> manuallySetService(String matchId, String servingPlayerId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    final currentRound = getCurrentRound(match);
    if (currentRound == null) return;
    
    final updatedRound = currentRound.copyWith(currentServer: servingPlayerId);
    final updatedmatchRounds = List<BadmintonRoundModel>.from(match.rounds);
    updatedmatchRounds[match.currentRoundNumber - 1] = updatedRound;
    
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(rounds: updatedmatchRounds);
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    AppControllers.myMatches.matches.refresh();
    
    await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
    _printJsonWithTag('badminton.server_change', AppControllers.myMatches.matches[matchIndex].toJson());
  }
  
  Future<void> completeCurrentRound(String matchId, String roundWinner, int team1Score, int team2Score) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    
    final currentRound = getCurrentRound(match);
    if (currentRound == null) return;
    
    final completedRound = currentRound.complete(roundWinner);
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
    updatedRounds[match.currentRoundNumber - 1] = completedRound;
    
    final updatedMatch = match.copyWith(rounds: updatedRounds);
    final team1Wins = getTeam1RoundsWon(updatedMatch);
    final team2Wins = getTeam2RoundsWon(updatedMatch);
    
    BadmintonMatchModel finalMatch;
    if (team1Wins >= 2 || team2Wins >= 2) {
      final matchWinner = team1Wins >= 2 ? 'team1' : 'team2';
      finalMatch = updatedMatch.copyWith(
        status: BadmintonMatchStatus.completed,
        winnerId: matchWinner,
      );
    } else {
      finalMatch = updatedMatch;
    }
    
    AppControllers.myMatches.matches[matchIndex] = finalMatch;
    await StorageService.saveMatchToStorage(finalMatch);
    AppControllers.myMatches.matches.refresh();
    
    debugPrint('🎯 Setting pendingMatch and triggering dialog...');
    pendingMatch.value = finalMatch;
    
    // Small delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (isMatchComplete(finalMatch)) {
      debugPrint('✅ Match complete - showing match complete dialog');
      debugPrint('\n========== MATCH COMPLETED ==========');
      debugPrint('Match JSON:');
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(finalMatch.toJson());
      debugPrint(jsonString, wrapWidth: 1024);
      debugPrint('=====================================\n');
      
      showMatchCompleteDialog.value = true;
    } else {
      debugPrint('✅ Round complete - showing round complete dialog');
      debugPrint('ROUND ${finalMatch.currentRoundNumber} COMPLETE: Winner=$roundWinner | Team1 Rounds Won=${getTeam1RoundsWon(finalMatch)}, Team2 Rounds Won=${getTeam2RoundsWon(finalMatch)}');
      
      showRoundCompleteDialog.value = true;
    }
  }

  Future<void> startNextRound(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    
    if (isMatchComplete(match) || match.currentRoundNumber >= 3) return;
    
    final nextRoundNumber = match.currentRoundNumber + 1;
    
    final previousRound = match.rounds.isNotEmpty ? match.rounds.last : null;
    String? nextRoundServer;
    
    if (previousRound?.winnerId != null) {
      final winnerTeamId = previousRound!.winnerId!;
      if (winnerTeamId == 'team1') {
        nextRoundServer = match.team1.players.first.playerId;
      } else if (winnerTeamId == 'team2') {
        nextRoundServer = match.team2.players.first.playerId;
      }
    }
    
    nextRoundServer ??= match.team1.players.first.playerId;
    
    Map<String, int> initialPlayerScores = {};
    for (final player in match.team1.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    for (final player in match.team2.players) {
      initialPlayerScores[player.playerId] = 0;
    }
    
    final nextRound = BadmintonRoundModel(
      roundNumber: nextRoundNumber,
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
      initialServer: nextRoundServer,
      currentServer: nextRoundServer,
      pointSequence: [],
      playerScores: initialPlayerScores,
      breaks: [],
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds)..add(nextRound);
    
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
    
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    AppControllers.myMatches.matches.refresh();
    
    await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
    _printJsonWithTag('badminton.round_start', AppControllers.myMatches.matches[matchIndex].toJson());
  }

  Future<void> startNextRoundWithService(String matchId, String initialServer) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    if (isMatchComplete(match) || match.currentRoundNumber >= 3) return;
    
    final nextRoundNumber = match.currentRoundNumber + 1;
    
    Map<String, int> initialPlayerScores = {};
    for (final player in [...match.team1.players, ...match.team2.players]) {
      initialPlayerScores[player.playerId] = 0;
    }
    
    final nextRound = BadmintonRoundModel(
      roundNumber: nextRoundNumber,
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
      initialServer: initialServer,
      currentServer: initialServer,
      pointSequence: [],
      playerScores: initialPlayerScores,
      breaks: [],
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds)..add(nextRound);
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
    
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    AppControllers.myMatches.matches.refresh();
    
    await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
    _printJsonWithTag('badminton.round_start', AppControllers.myMatches.matches[matchIndex].toJson());
  }

  Future<void> pauseMatch(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    final currentRound = getCurrentRound(match);
    if (match.status == BadmintonMatchStatus.inProgress && currentRound != null) {
      final updatedRound = currentRound.takeBreak();
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      AppControllers.myMatches.matches[matchIndex] = match.copyWith(
        status: BadmintonMatchStatus.paused,
        rounds: updatedRounds,
      );
      
      await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
      AppControllers.myMatches.matches.refresh();
      
      await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
      _logBreakStart(AppControllers.myMatches.matches[matchIndex]);
    }
  }

  Future<void> resumeMatch(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    final currentRound = getCurrentRound(match);
    if (match.status == BadmintonMatchStatus.paused && currentRound != null) {
      final updatedRound = currentRound.resumeFromBreak();
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      AppControllers.myMatches.matches[matchIndex] = match.copyWith(
        status: BadmintonMatchStatus.inProgress,
        rounds: updatedRounds,
      );
      
      await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
      AppControllers.myMatches.matches.refresh();
      
      await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
      _logBreakEnd(AppControllers.myMatches.matches[matchIndex]);
    }
  }
  
  Future<void> completeMatch(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    AppControllers.myMatches.matches[matchIndex] = AppControllers.myMatches.matches[matchIndex].copyWith(
      status: BadmintonMatchStatus.completed
    );
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
  }
  
  void triggerManualServiceDialog(BadmintonMatchModel match) {
    pendingMatch.value = match;
    showManualServiceDialog.value = true;
  }

  void triggerNextRoundServiceDialog(String matchId) {
    final match = AppControllers.myMatches.getMatchById(matchId);
    if (match != null) {
      pendingMatch.value = match;
      showNextRoundServiceDialog.value = true;
    }
  }
  
  void startBreakStopwatch() {
    breakStopwatch.value = 0;
    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      breakStopwatch.value++;
    });
  }
  
  void stopAndResetBreakStopwatch() {
    _breakTimer?.cancel();
    _breakTimer = null;
    breakStopwatch.value = 0;
  }
  
  
  String formatBreakTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  void onClose() {
    _breakTimer?.cancel();
    super.onClose();
  }
  
  // MATCH DATA HELPERS
  
  bool isMatchCompleted(BadmintonMatchModel match) {
    return match.status == BadmintonMatchStatus.completed;
  }
  
  bool isMatchInProgress(BadmintonMatchModel match) {
    return match.status == BadmintonMatchStatus.inProgress;
  }
  
  BadmintonRoundModel? getCurrentRound(BadmintonMatchModel match) {
    if (match.rounds.isEmpty || match.currentRoundNumber > match.rounds.length) return null;
    return match.rounds[match.currentRoundNumber - 1];
  }
  
  int getTeam1Score(BadmintonMatchModel match) {
    final currentRound = getCurrentRound(match);
    return currentRound?.team1Score ?? 0;
  }
  
  int getTeam2Score(BadmintonMatchModel match) {
    final currentRound = getCurrentRound(match);
    return currentRound?.team2Score ?? 0;
  }
  
  int getTeam1RoundsWon(BadmintonMatchModel match) {
    return match.rounds.where((r) => r.winnerId == 'team1').length;
  }
  
  int getTeam2RoundsWon(BadmintonMatchModel match) {
    return match.rounds.where((r) => r.winnerId == 'team2').length;
  }
  
  bool isMatchComplete(BadmintonMatchModel match) {
    return getTeam1RoundsWon(match) >= 2 || getTeam2RoundsWon(match) >= 2;
  }
  
  String? getMatchWinner(BadmintonMatchModel match) {
    final team1Wins = getTeam1RoundsWon(match);
    final team2Wins = getTeam2RoundsWon(match);
    if (team1Wins >= 2) return 'team1';
    if (team2Wins >= 2) return 'team2';
    return null;
  }
  
  String? getCurrentServer(BadmintonMatchModel match) {
    final currentRound = getCurrentRound(match);
    return currentRound?.currentServer;
  }
  
  int getDisplayRoundNumber(BadmintonMatchModel match) {
    if (match.rounds.isEmpty) return 1;
    
    if (isMatchCompleted(match)) return match.rounds.length;
    
    final completedRounds = match.rounds.where((r) => r.isCompleted).length;
    
    if (completedRounds == match.rounds.length) {
      return match.rounds.length;
    }
    
    for (final round in match.rounds) {
      if (round.isInProgress) {
        return round.roundNumber;
      }
    }
    
    return completedRounds + 1;
  }
  
  List<String> getTeam1Players(BadmintonMatchModel match) {
    return match.team1.players.map((p) => p.name).toList();
  }
  
  List<String> getTeam2Players(BadmintonMatchModel match) {
    return match.team2.players.map((p) => p.name).toList();
  }
  
  List<Map<String, int>> getRoundScores(BadmintonMatchModel match) {
    return match.rounds
        .where((r) => r.isCompleted)
        .map((r) => {
          'team1': r.team1Score,
          'team2': r.team2Score,
          'winner': r.winnerId == 'team1' ? 1 : 2,
          'round': r.roundNumber,
        })
        .toList();
  }
  
  String? getWinner(BadmintonMatchModel match) {
    return getMatchWinner(match);
  }
  
  BadmintonMatchScorecard generateMatchScorecard(BadmintonMatchModel match) {
    final team1PlayerStats = match.team1.players.map((player) {
      int totalPoints = 0;
      int roundsWon = 0;
      int roundsLost = 0;
      Map<int, int> pointsPerRound = {};

      for (final round in match.rounds.where((r) => r.isCompleted)) {
        final playerScore = round.playerScores[player.playerId] ?? 0;
        pointsPerRound[round.roundNumber] = playerScore;
        totalPoints += playerScore;
        if (round.winnerId == 'team1') {
          roundsWon++;
        } else {
          roundsLost++;
        }
      }

      final currentRound = getCurrentRound(match);
      if (currentRound != null && currentRound.isInProgress) {
        final playerScore = currentRound.playerScores[player.playerId] ?? 0;
        pointsPerRound[match.currentRoundNumber] = playerScore;
        totalPoints += playerScore;
      }

      return BadmintonPlayerStats(
        playerId: player.playerId,
        playerName: player.name,
        totalPointsScored: totalPoints,
        roundsWon: roundsWon,
        roundsLost: roundsLost,
        pointsPerRound: pointsPerRound,
        winPercentage: (roundsWon + roundsLost) > 0 ? ((roundsWon / (roundsWon + roundsLost)) * 100).toDouble() : 0.0,
      );
    }).toList();

    final team2PlayerStats = match.team2.players.map((player) {
      int totalPoints = 0;
      int roundsWon = 0;
      int roundsLost = 0;
      Map<int, int> pointsPerRound = {};

      for (final round in match.rounds.where((r) => r.isCompleted)) {
        final playerScore = round.playerScores[player.playerId] ?? 0;
        pointsPerRound[round.roundNumber] = playerScore;
        totalPoints += playerScore;
        if (round.winnerId == 'team2') {
          roundsWon++;
        } else {
          roundsLost++;
        }
      }

      final currentRound = getCurrentRound(match);
      if (currentRound != null && currentRound.isInProgress) {
        final playerScore = currentRound.playerScores[player.playerId] ?? 0;
        pointsPerRound[match.currentRoundNumber] = playerScore;
        totalPoints += playerScore;
      }

      return BadmintonPlayerStats(
        playerId: player.playerId,
        playerName: player.name,
        totalPointsScored: totalPoints,
        roundsWon: roundsWon,
        roundsLost: roundsLost,
        pointsPerRound: pointsPerRound,
        winPercentage: (roundsWon + roundsLost) > 0 ? ((roundsWon / (roundsWon + roundsLost)) * 100).toDouble() : 0.0,
      );
    }).toList();

    final team1TotalPoints = team1PlayerStats.fold<int>(0, (sum, player) => sum + player.totalPointsScored);
    final team2TotalPoints = team2PlayerStats.fold<int>(0, (sum, player) => sum + player.totalPointsScored);

    final team1Stats = BadmintonTeamStats(
      teamId: match.team1.teamId,
      teamName: match.team1.teamName,
      teamLogo: match.team1.teamLogo,
      playerStats: team1PlayerStats,
      totalTeamPoints: team1TotalPoints,
      roundsWon: getTeam1RoundsWon(match),
      roundsLost: getTeam2RoundsWon(match),
      teamWinPercentage: (getTeam1RoundsWon(match) + getTeam2RoundsWon(match)) > 0 
          ? (getTeam1RoundsWon(match) / (getTeam1RoundsWon(match) + getTeam2RoundsWon(match))) * 100 
          : 0.0,
    );

    final team2Stats = BadmintonTeamStats(
      teamId: match.team2.teamId,
      teamName: match.team2.teamName,
      teamLogo: match.team2.teamLogo,
      playerStats: team2PlayerStats,
      totalTeamPoints: team2TotalPoints,
      roundsWon: getTeam2RoundsWon(match),
      roundsLost: getTeam1RoundsWon(match),
      teamWinPercentage: (getTeam1RoundsWon(match) + getTeam2RoundsWon(match)) > 0 
          ? (getTeam2RoundsWon(match) / (getTeam1RoundsWon(match) + getTeam2RoundsWon(match))) * 100 
          : 0.0,
    );

    Map<int, Map<String, int>> roundScoresMap = {};
    for (final round in match.rounds.where((r) => r.isCompleted)) {
      roundScoresMap[round.roundNumber] = {
        'team1': round.team1Score,
        'team2': round.team2Score,
      };
    }

    return BadmintonMatchScorecard(
      matchId: match.matchId,
      team1Stats: team1Stats,
      team2Stats: team2Stats,
      matchDate: match.createdAt,
      matchType: match.matchType.displayName,
      matchStatus: match.status.displayName,
      matchWinner: getMatchWinner(match),
      totalRounds: 3,
      roundScores: roundScoresMap,
    );
  }
  
  Future<void> _saveLiveMatchJson(BadmintonMatchModel match) async {
    try {
      await StorageService.saveMatchToStorage(match);
    } catch (e) {
      print('Error saving live match JSON: $e');
    }
  }

  void _printJsonWithTag(String tag, Map<String, dynamic> json) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(json);
    
    print('\n[$tag]');
    
    final lines = jsonString.split('\n');
    const int maxLinesPerChunk = 30;
    
    for (int i = 0; i < lines.length; i += maxLinesPerChunk) {
      final int end = (i + maxLinesPerChunk < lines.length) ? i + maxLinesPerChunk : lines.length;
      final chunk = lines.sublist(i, end).join('\n');
      print(chunk);
    }
    
    print('');
  }

  void _logScoreUpdate(BadmintonMatchModel match) {
    log('badminton.score_update ${match.toJson()}');
  }

  void _logBreakStart(BadmintonMatchModel match) {
    _printJsonWithTag('badminton.break_start', match.toJson());
  }

  void _logBreakEnd(BadmintonMatchModel match) {
    _printJsonWithTag('badminton.break_end', match.toJson());
  }
}