import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../../services/storage_service.dart';
import '../matches_list/my_matches_list_controller.dart';

class MatchController extends GetxController {
  // Dialog visibility flags
  final RxBool showManualServiceDialog = false.obs;
  final RxBool showContinueDialog = false.obs;
  final RxBool showRoundCompleteDialog = false.obs;
  final RxBool showNextRoundServiceDialog = false.obs;
  final RxBool showMatchCompleteDialog = false.obs;
  
  // Pending match for dialogs (stores current match being processed)
  final Rx<BadmintonMatchModel?> pendingMatch = Rx<BadmintonMatchModel?>(null);

  MyMatchesController get _matchesController => Get.find<MyMatchesController>();

  // Initialize match with first server
  Future<void> initializeMatchWithService(String matchId, String initialServer) async {
    final matchIndex = _matchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    _matchesController.matches[matchIndex] = match.initializeFirstRound(initialServer: initialServer);
    await StorageService.saveMatch(_matchesController.matches[matchIndex]);
  }

  // Manually change server during match
  Future<void> manuallySetService(String matchId, String servingPlayerId) async {
    final matchIndex = _matchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    if (match.currentRound == null) return;
    
    final updatedRound = match.currentRound!.copyWith(currentServer: servingPlayerId);
    final updatedmatchRounds = List<BadmintonRoundModel>.from(match.rounds);
    updatedmatchRounds[match.currentRoundNumber - 1] = updatedRound;
    
    _matchesController.matches[matchIndex] = match.copyWith(rounds: updatedmatchRounds);
    await StorageService.saveMatch(_matchesController.matches[matchIndex]);
  }

  // Update player score and handle game logic
  Future<void> updatePlayerScore(String matchId, String playerId, int newPlayerScore) async {
    final matchIndex = _matchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    
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
      updatedPointSequence.add(playerId);
      newCurrentServer = playerId;
    } else if (newPlayerScore < prevPlayerScore) {
      if (updatedPointSequence.isNotEmpty) {
        updatedPointSequence.removeLast();
        newCurrentServer = updatedPointSequence.isEmpty 
            ? match.currentRound!.initialServer 
            : updatedPointSequence.last;
      } else {
        newCurrentServer = match.currentServer;
      }
    } else {
      newCurrentServer = match.currentServer;
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
    _matchesController.matches[matchIndex] = match.copyWith(rounds: updatedRounds);
    
    // Check for 30 points (round complete)
    if (newTeam1Score == 30 || newTeam2Score == 30) {
      final roundWinner = newTeam1Score == 30 ? 'team1' : 'team2';
      await StorageService.saveMatch(_matchesController.matches[matchIndex]);
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
      _matchesController.matches[matchIndex] = _matchesController.matches[matchIndex].markMilestone21Reached();
      pendingMatch.value = _matchesController.matches[matchIndex];
      showContinueDialog.value = true;
    } else {
      await StorageService.saveMatch(_matchesController.matches[matchIndex]);
    }
  }

  // Complete current round
  Future<void> completeCurrentRound(String matchId, String roundWinner, int team1Score, int team2Score) async {
    final matchIndex = _matchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    final updatedMatch = match.completeCurrentRound(roundWinner);
    _matchesController.matches[matchIndex] = updatedMatch;
    await StorageService.saveMatch(updatedMatch);
    
    // Store match for dialog display
    pendingMatch.value = updatedMatch;
    
    if (updatedMatch.isMatchComplete) {
      // Match is complete - show match complete dialog
      showMatchCompleteDialog.value = true;
    } else {
      // Round complete but match continues - show round complete dialog
      showRoundCompleteDialog.value = true;
    }
  }

  // Start next round with default server
  Future<void> startNextRound(String matchId) async {
    final matchIndex = _matchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    _matchesController.matches[matchIndex] = match.startNextRound();
    await StorageService.saveMatch(_matchesController.matches[matchIndex]);
  }

  // Start next round with custom server
  Future<void> startNextRoundWithService(String matchId, String initialServer) async {
    final matchIndex = _matchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    if (match.isMatchComplete || match.currentRoundNumber >= 3) return;
    
    final nextRoundNumber = match.currentRoundNumber + 1;
    
    Map<String, int> initialPlayerScores = {};
    for (final player in [...match.team1.players, ...match.team2.players]) {
      initialPlayerScores[player.playerId] = 0;
    }
    
    final nextRound = BadmintonRoundModel(
      roundNumber: nextRoundNumber,
      status: BadmintonRoundStatus.inProgress,
      initialServer: initialServer,
      currentServer: initialServer,
      pointSequence: [],
      playerScores: initialPlayerScores,
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds)..add(nextRound);
    _matchesController.matches[matchIndex] = match.copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
    
    await StorageService.saveMatch(_matchesController.matches[matchIndex]);
  }

  // Pause match
  Future<void> pauseMatch(String matchId) async {
    final matchIndex = _matchesController.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    if (match.status == BadmintonMatchStatus.inProgress) {
      _matchesController.matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.paused);
      await StorageService.saveMatch(_matchesController.matches[matchIndex]);
      _matchesController.matches.refresh();
    }
  }

  // Resume match
  Future<void> resumeMatch(String matchId) async {
    final matchIndex = _matchesController.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = _matchesController.matches[matchIndex];
    if (match.status == BadmintonMatchStatus.paused) {
      _matchesController.matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.inProgress);
      await StorageService.saveMatch(_matchesController.matches[matchIndex]);
      _matchesController.matches.refresh();
    }
  }

  // Manually complete match
  Future<void> completeMatch(String matchId) async {
    final matchIndex = _matchesController.matches.indexWhere((m) => m.matchId == matchId);
    if (matchIndex == -1) return;
    
    _matchesController.matches[matchIndex] = _matchesController.matches[matchIndex].copyWith(
      status: BadmintonMatchStatus.completed
    );
    await StorageService.saveMatch(_matchesController.matches[matchIndex]);
  }

  // Trigger dialogs (called by UI)
  void triggerManualServiceDialog(BadmintonMatchModel match) {
    pendingMatch.value = match;
    showManualServiceDialog.value = true;
  }

  void triggerNextRoundServiceDialog(String matchId) {
    final match = _matchesController.getMatchById(matchId);
    if (match != null) {
      pendingMatch.value = match;
      showNextRoundServiceDialog.value = true;
    }
  }
}