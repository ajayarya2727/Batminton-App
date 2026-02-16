import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../../services/storage_service.dart';
import '../../controllers/app_controllers.dart';

class MatchController extends GetxController {
  // ================= STATE VARIABLES =================
  
  // Dialog visibility flags
  final RxBool showManualServiceDialog = false.obs;
  final RxBool showContinueDialog = false.obs;
  final RxBool showRoundCompleteDialog = false.obs;
  final RxBool showNextRoundServiceDialog = false.obs;
  final RxBool showMatchCompleteDialog = false.obs;
  
  // Pending match for dialogs (stores current match being processed)
  final Rx<BadmintonMatchModel?> pendingMatch = Rx<BadmintonMatchModel?>(null);
  
  // ================= INITIALIZATION =================

  // Initialize match with first server
  Future<void> initializeMatchWithService(String matchId, String initialServer) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    AppControllers.myMatches.matches[matchIndex] = match.initializeFirstRound(initialServer: initialServer);
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    
    // Print full JSON only once when match starts
    debugPrint('\n========== MATCH STARTED ==========');
    debugPrint('Match JSON:');
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(AppControllers.myMatches.matches[matchIndex].toJson());
    debugPrint(jsonString, wrapWidth: 1024);
    debugPrint('===================================\n');
  }
  
  // ================= SCORE LOGIC =================

  // Update player score and handle game logic
  Future<void> updatePlayerScore(String matchId, String playerId, int newPlayerScore) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    
    // If no rounds, trigger service selection
    if (match.currentRound == null) return;
    
    final prevPlayerScore = match.currentRound!.playerScores[playerId] ?? 0;
    final updatedPlayerScores = Map<String, int>.from(match.currentRound!.playerScores);
    updatedPlayerScores[playerId] = newPlayerScore;
    
    // Calculate team totals
    int newTeam1Score = 0;
    int newTeam2Score = 0;
    for (final player in match.team1.players) {
      newTeam1Score += updatedPlayerScores[player.playerId] ?? 0;//if vcalue null so use 0
    }
    for (final player in match.team2.players) {
      newTeam2Score += updatedPlayerScores[player.playerId] ?? 0;
    }
    
    final previousTeam1Score = match.team1Score;
    final previousTeam2Score = match.team2Score;
    
    // Update point sequence and server
    List<String> updatedPointSequence = List<String>.from(match.currentRound!.pointSequence);
    String? newCurrentServer;
    
    if (newPlayerScore > prevPlayerScore) {
      // Score increased - player scored a point
      updatedPointSequence.add(playerId);
      newCurrentServer = playerId;
    } else if (newPlayerScore < prevPlayerScore) {
      // Score decreased - undo last point
      if (updatedPointSequence.isNotEmpty) {
        updatedPointSequence.removeLast();
        newCurrentServer = updatedPointSequence.isEmpty 
            ? match.currentRound!.initialServer 
            : updatedPointSequence.last;
      } else {
        newCurrentServer = match.currentServer;
      }
    } else {
      // Score unchanged - keep current server
      newCurrentServer = match.currentServer;
    }
    
    // Safety check: If no points played yet, use initial server
    if (updatedPointSequence.isEmpty) {
      newCurrentServer = match.currentRound!.initialServer;
    }
    
    // Update round
    final updatedRound = match.currentRound!.copyWith(
      playerScores: updatedPlayerScores,
      team1Score: newTeam1Score,
      team2Score: newTeam2Score,
      pointSequence: updatedPointSequence,
      currentServer: newCurrentServer,
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
    updatedRounds[match.currentRoundNumber - 1] = updatedRound;
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(rounds: updatedRounds);
    
    // Check for 30 points (round complete)
    if (newTeam1Score == 30 || newTeam2Score == 30) {
      final roundWinner = newTeam1Score == 30 ? 'team1' : 'team2';
      await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
      AppControllers.myMatches.matches.refresh(); // Trigger UI update
      await completeCurrentRound(matchId, roundWinner, newTeam1Score, newTeam2Score);
      return;
    }
    
    // Check for 21 points milestone
    bool showPopup = false;
    if (!match.milestone21Reached) {
      if ((newTeam1Score == 21 && previousTeam1Score < 21) || 
          (newTeam2Score == 21 && previousTeam2Score < 21)) {
        showPopup = true;
      }
    }
    
    if (showPopup) {
      AppControllers.myMatches.matches[matchIndex] = AppControllers.myMatches.matches[matchIndex].markMilestone21Reached();
      await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
      AppControllers.myMatches.matches.refresh(); // Trigger UI update
      pendingMatch.value = AppControllers.myMatches.matches[matchIndex];
      showContinueDialog.value = true;
    } else {
      await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
      AppControllers.myMatches.matches.refresh(); // Trigger UI update
      
      // Update live JSON file
      await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
      
      // Log score update with full JSON
      _logScoreUpdate(AppControllers.myMatches.matches[matchIndex]);
    }
  }

  // Manually change server during match
  Future<void> manuallySetService(String matchId, String servingPlayerId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    if (match.currentRound == null) return;
    
    final updatedRound = match.currentRound!.copyWith(currentServer: servingPlayerId);
    final updatedmatchRounds = List<BadmintonRoundModel>.from(match.rounds);
    updatedmatchRounds[match.currentRoundNumber - 1] = updatedRound;
    
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(rounds: updatedmatchRounds);
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    AppControllers.myMatches.matches.refresh();
    
    // Log server change with full JSON
    await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
    _printJsonWithTag('badminton.server_change', AppControllers.myMatches.matches[matchIndex].toJson());
  }
  
  // ================= ROUND LOGIC =================

  // ================= ROUND LOGIC =================

  // Complete current round
  Future<void> completeCurrentRound(String matchId, String roundWinner, int team1Score, int team2Score) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    final updatedMatch = match.completeCurrentRound(roundWinner);
    AppControllers.myMatches.matches[matchIndex] = updatedMatch;
    await StorageService.saveMatchToStorage(updatedMatch);
    
    // Store match for dialog display
    pendingMatch.value = updatedMatch;
    
    if (updatedMatch.isMatchComplete) {
      // Match is complete - Print JSON for debugging/sharing
      debugPrint('\n========== MATCH COMPLETED ==========');
      debugPrint('Match JSON:');
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(updatedMatch.toJson());
      debugPrint(jsonString, wrapWidth: 1024);
      debugPrint('=====================================\n');
      
      // Match is complete - show match complete dialog
      showMatchCompleteDialog.value = true;
    } else {
      // Round complete but match continues - show compact summary
      debugPrint('ROUND ${updatedMatch.currentRoundNumber} COMPLETE: Winner=$roundWinner | Team1 Rounds Won=${updatedMatch.team1RoundsWon}, Team2 Rounds Won=${updatedMatch.team2RoundsWon}');
      
      // Round complete but match continues - show round complete dialog
      showRoundCompleteDialog.value = true;
    }
  }

  // Start next round with default server
  Future<void> startNextRound(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    AppControllers.myMatches.matches[matchIndex] = match.startNextRound();
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    AppControllers.myMatches.matches.refresh();
    
    // Log round start with full JSON
    await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
    _printJsonWithTag('badminton.round_start', AppControllers.myMatches.matches[matchIndex].toJson());
  }

  // Start next round with custom server
  Future<void> startNextRoundWithService(String matchId, String initialServer) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    if (match.isMatchComplete || match.currentRoundNumber >= 3) return;
    
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
      milestone21Reached: false,
      continueTo30Chosen: false,
      breaks: [], // Empty breaks list for new round
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds)..add(nextRound);
    AppControllers.myMatches.matches[matchIndex] = match.copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
    
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
    AppControllers.myMatches.matches.refresh();
    
    // Log round start with full JSON
    await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
    _printJsonWithTag('badminton.round_start', AppControllers.myMatches.matches[matchIndex].toJson());
  }
  
  // ================= BREAK LOGIC =================

  // ================= BREAK LOGIC =================

  // Pause match
  Future<void> pauseMatch(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    if (match.status == BadmintonMatchStatus.inProgress && match.currentRound != null) {
      // Update current round with break start time
      final updatedRound = match.currentRound!.takeBreak();
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      // Update match with paused status and updated round
      AppControllers.myMatches.matches[matchIndex] = match.copyWith(
        status: BadmintonMatchStatus.paused,
        rounds: updatedRounds,
      );
      
      await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
      AppControllers.myMatches.matches.refresh();
      
      // Log break start with full JSON
      await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
      _logBreakStart(AppControllers.myMatches.matches[matchIndex]);
    }
  }

  // Resume match
  Future<void> resumeMatch(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = AppControllers.myMatches.matches[matchIndex];
    if (match.status == BadmintonMatchStatus.paused && match.currentRound != null) {
      // Update current round with break end time and duration
      final updatedRound = match.currentRound!.resumeFromBreak();
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      // Update match with in-progress status and updated round
      AppControllers.myMatches.matches[matchIndex] = match.copyWith(
        status: BadmintonMatchStatus.inProgress,
        rounds: updatedRounds,
      );
      
      await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
      AppControllers.myMatches.matches.refresh();
      
      // Log break end with full JSON
      await _saveLiveMatchJson(AppControllers.myMatches.matches[matchIndex]);
      _logBreakEnd(AppControllers.myMatches.matches[matchIndex]);
    }
  }
  
  // ================= MATCH UPDATE HELPER =================

  // Manually complete match
  Future<void> completeMatch(String matchId) async {
    final matchIndex = AppControllers.myMatches.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    AppControllers.myMatches.matches[matchIndex] = AppControllers.myMatches.matches[matchIndex].copyWith(
      status: BadmintonMatchStatus.completed
    );
    await StorageService.saveMatchToStorage(AppControllers.myMatches.matches[matchIndex]);
  }
  
  // ================= DIALOG TRIGGERS =================

  // Trigger dialogs (called by UI)
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
  
  // ================= JSON LOGGING =================

  // ================= JSON LOGGING =================

  /// Save live match JSON to file
  Future<void> _saveLiveMatchJson(BadmintonMatchModel match) async {
    try {
      await StorageService.saveLiveMatchJson(match);
    } catch (e) {
      print('Error saving live match JSON: $e');
    }
  }

  /// Print JSON with tag (handles long JSON by splitting into chunks at line breaks)
  void _printJsonWithTag(String tag, Map<String, dynamic> json) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(json);
    
    // Print tag
    print('\n[$tag]');
    
    // Split by lines and print in batches to avoid truncation
    final lines = jsonString.split('\n');
    const int maxLinesPerChunk = 30; // Print 30 lines at a time (safer for console)
    
    for (int i = 0; i < lines.length; i += maxLinesPerChunk) {
      final int end = (i + maxLinesPerChunk < lines.length) ? i + maxLinesPerChunk : lines.length;
      final chunk = lines.sublist(i, end).join('\n');
      print(chunk);
    }
    
    print(''); // Empty line for readability
  }

  /// Log score update with full JSON
  void _logScoreUpdate(BadmintonMatchModel match) {
    log('badminton.score_update ${match.toJson()}');
  }

  /// Log break start
  void _logBreakStart(BadmintonMatchModel match) {
    _printJsonWithTag('badminton.break_start', match.toJson());
  }

  /// Log break end
  void _logBreakEnd(BadmintonMatchModel match) {
    _printJsonWithTag('badminton.break_end', match.toJson());
  }

  /// Log round complete
  void _logRoundComplete(BadmintonMatchModel match) {
    _printJsonWithTag('badminton.round_complete', match.toJson());
  }

  /// Log match complete
  void _logMatchComplete(BadmintonMatchModel match) {
    _printJsonWithTag('badminton.match_complete', match.toJson());
  }

  /// Log 21-point milestone
  void _logMilestone(BadmintonMatchModel match) {
    _printJsonWithTag('badminton.milestone_21', match.toJson());
  }
}