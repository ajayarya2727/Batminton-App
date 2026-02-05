import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/badminton_models.dart';
import '../services/storage_service.dart';
import 'my_matches_list_controller.dart';

class MatchController extends GetxController {
  // Show service selection dialog when match starts 
  void showServiceSelectionDialog(BadmintonMatchModel match) {
    Get.dialog(
      AlertDialog(
        title: const Text('🏸 Who will serve first?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select which player will serve first in Round 1:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Team 1 Players
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(match.team1.teamLogo, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        match.team1.teamName.isNotEmpty ? match.team1.teamName : "Team 1",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team1.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        initializeMatchWithService(match.matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        player.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team 2 Players
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        match.team2.teamName.isNotEmpty ? match.team2.teamName : "Team 2",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(match.team2.teamLogo, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team2.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        initializeMatchWithService(match.matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        player.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Back button (OLD CODE HAD THIS)
            Container(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.snackbar(
                    'Service Selection Skipped', 
                    'You can select service by tapping score buttons',
                    backgroundColor: Colors.blue.shade100,
                    colorText: Colors.blue.shade700,
                    icon: Icon(Icons.info, color: Colors.blue.shade700),
                    snackPosition: SnackPosition.TOP,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text(
                  'Skip Service Selection',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Initialize match with selected server (OLD CODE BEHAVIOR)
  Future<void> initializeMatchWithService(String matchId, String initialServer) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = myMatchesController.matches[matchIndex];
      
      // Initialize first round with selected server (OLD CODE LOGIC)
      myMatchesController.matches[matchIndex] = match.initializeFirstRound(initialServer: initialServer);
      await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
      
      // Find the player name for the snackbar
      String playerName = 'Unknown Player';
      for (final player in [...match.team1.players, ...match.team2.players]) {
        if (player.playerId == initialServer) {
          playerName = player.name;
          break;
        }
      }
      
      Get.snackbar(
        'Service Set!', 
        '$playerName will serve first',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700,
        icon: Icon(Icons.sports_tennis, color: Colors.green.shade700),
      );
    }
  }

  // Show manual service selection dialog (can be called anytime during match) - OLD CODE BEHAVIOR
  void showManualServiceSelectionDialog(BadmintonMatchModel match) {
    Get.dialog(
      AlertDialog(
        title: const Text('🏸 Change Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Round: ${match.currentRoundNumber}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Current Score: ${match.team1Score} - ${match.team2Score}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Who should serve next?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Team 1 Players
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(match.team1.teamLogo, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        match.team1.teamName.isNotEmpty ? match.team1.teamName : "Team 1",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team1.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _manuallySetService(match.matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: match.currentServer == player.playerId 
                            ? Colors.green.shade600 
                            : Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (match.currentServer == player.playerId)
                            const Icon(Icons.sports_tennis, size: 16),
                          if (match.currentServer == player.playerId)
                            const SizedBox(width: 8),
                          Text(
                            player.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team 2 Players
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        match.team2.teamName.isNotEmpty ? match.team2.teamName : "Team 2",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(match.team2.teamLogo, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team2.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _manuallySetService(match.matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: match.currentServer == player.playerId 
                            ? Colors.green.shade600 
                            : Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (match.currentServer == player.playerId)
                            const Icon(Icons.sports_tennis, size: 16),
                          if (match.currentServer == player.playerId)
                            const SizedBox(width: 8),
                          Text(
                            player.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Manually set service for current round - OLD CODE BEHAVIOR
  Future<void> _manuallySetService(String matchId, String servingPlayerId) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = myMatchesController.matches[matchIndex];
      
      if (match.currentRound == null) return;
      
      // Update current server in the current round
      final updatedRound = match.currentRound!.copyWith(
        currentServer: servingPlayerId,
      );
      
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      myMatchesController.matches[matchIndex] = match.copyWith(rounds: updatedRounds);
      
      await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
      
      // Find player name for the snackbar
      String playerName = 'Unknown Player';
      for (final player in [...match.team1.players, ...match.team2.players]) {
        if (player.playerId == servingPlayerId) {
          playerName = player.name;
          break;
        }
      }
      
      Get.snackbar(
        'Service Changed!', 
        '$playerName will serve next',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700,
        icon: Icon(Icons.sports_tennis, color: Colors.green.shade700),
      );
    }
  }
  // Update individual player score and recalculate team totals - OLD CODE BEHAVIOR
  Future<void> updatePlayerScore(String matchId, String playerId, int newPlayerScore) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = myMatchesController.matches[matchIndex];
      
      // Don't allow score updates if match is completed or paused
      if (match.isCompleted || match.status == BadmintonMatchStatus.paused) return;
      
      // If match hasn't started yet (no rounds), show service selection
      if (match.rounds.isEmpty) {
        showServiceSelectionDialog(match);
        return;
      }
      
      if (match.currentRound == null) return;
      
      // Get previous player score to determine if this is an increase or decrease
      final prevPlayerScore = match.currentRound!.playerScores[playerId] ?? 0;
      
      // Update player score in current round
      final updatedPlayerScores = Map<String, int>.from(match.currentRound!.playerScores);
      updatedPlayerScores[playerId] = newPlayerScore;
      
      // Calculate new team totals from individual player scores
      int newTeam1Score = 0;
      int newTeam2Score = 0;
      
      for (final player in match.team1.players) {
        newTeam1Score += updatedPlayerScores[player.playerId] ?? 0;
      }
      
      for (final player in match.team2.players) {
        newTeam2Score += updatedPlayerScores[player.playerId] ?? 0;
      }
      
      // Get previous scores to check milestones and service changes
      final prevTeam1Score = match.team1Score;
      final prevTeam2Score = match.team2Score;
      
      // Update point sequence based on score changes
      List<String> updatedPointSequence = List<String>.from(match.currentRound!.pointSequence);
      String? newCurrentServer;
      
      if (newPlayerScore > prevPlayerScore) {
        // Point was scored - add to sequence and update server
        updatedPointSequence.add(playerId); // Store specific player ID who scored
        newCurrentServer = playerId; // Scoring player gets service
      } else if (newPlayerScore < prevPlayerScore) {
        // Point was undone - remove from sequence and revert server
        if (updatedPointSequence.isNotEmpty) {
          updatedPointSequence.removeLast();
          
          // Find who should serve based on the updated sequence
          if (updatedPointSequence.isEmpty) {
            // No points left, use initial server
            newCurrentServer = match.currentRound!.initialServer;
          } else {
            // Find who won the last point in the sequence (specific player ID)
            final lastScoringPlayer = updatedPointSequence.last;
            newCurrentServer = lastScoringPlayer; // Use the actual player who scored last
          }
        } else {
          // No sequence to remove from, keep current server
          newCurrentServer = match.currentServer;
        }
      } else {
        // Score didn't change, keep current server
        newCurrentServer = match.currentServer;
      }
      
      // Update the round with new player scores, team totals, sequence, and server
      final updatedRound = match.currentRound!.copyWith(
        playerScores: updatedPlayerScores,
        team1Score: newTeam1Score,
        team2Score: newTeam2Score,
        pointSequence: updatedPointSequence,
        currentServer: newCurrentServer,
      );
      
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      myMatchesController.matches[matchIndex] = match.copyWith(rounds: updatedRounds);
      
      // Check if someone JUST reached 30 - complete current round AFTER updating scores
      if (newTeam1Score == 30 || newTeam2Score == 30) {
        final roundWinner = newTeam1Score == 30 ? 'team1' : 'team2';
        await StorageService.saveMatch(myMatchesController.matches[matchIndex]); // Save first with 30 points
        await _completeCurrentRound(matchId, roundWinner, newTeam1Score, newTeam2Score);
        return;
      }
      
      // Check if someone JUST reached 21 AND 21 milestone hasn't been reached before
      bool showPopup = false;
      if (!match.milestone21Reached) {
        // Team 1 just reached 21
        if (newTeam1Score == 21 && prevTeam1Score < 21) {
          showPopup = true;
        }
        // Team 2 just reached 21
        else if (newTeam2Score == 21 && prevTeam2Score < 21) {
          showPopup = true;
        }
      }
      
      if (showPopup) {
        // Mark 21 milestone as reached
        myMatchesController.matches[matchIndex] = myMatchesController.matches[matchIndex].markMilestone21Reached();
        _showContinueDialog(matchId, newTeam1Score, newTeam2Score);
      } else {
        // Normal score, just save
        await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
      }
    }
  }

  // Show dialog only for 21 points (first time) - OLD CODE BEHAVIOR
  void _showContinueDialog(String matchId, int team1Score, int team2Score) {
    final myMatchesController = Get.find<MyMatchesController>();
    final match = myMatchesController.getMatchById(matchId);
    if (match == null) return;
    
    final winnerPlayer = team1Score == 21 ? match.team1Players.join(' & ') : match.team2Players.join(' & ');
    
    Get.dialog(
      AlertDialog(
        title: Text('🏸 21 Points Reached! (Round ${match.currentRoundNumber})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$winnerPlayer reached 21 points!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Round ${match.currentRoundNumber} Score: $team1Score - $team2Score',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Do you want to continue this round?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // No - End round, winner is who reached 21
              final roundWinner = team1Score == 21 ? 'team1' : 'team2';
              _completeCurrentRound(matchId, roundWinner, team1Score, team2Score);
            },
            child: const Text('No, End Round'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Yes - Continue playing
              final myMatchesController = Get.find<MyMatchesController>();
              final matchIndex = myMatchesController.matches.indexWhere((m) => m.matchId == matchId);
              if (matchIndex != -1) {
                StorageService.saveMatch(myMatchesController.matches[matchIndex]);
              }
              Get.snackbar(
                'Continue Playing', 
                'Round continues to 30 points...',
                backgroundColor: Colors.blue.shade100,
                colorText: Colors.blue.shade700,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Continue'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Complete current round and check if match should continue - OLD CODE BEHAVIOR
  Future<void> _completeCurrentRound(String matchId, String roundWinner, int team1Score, int team2Score) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = myMatchesController.matches[matchIndex];
    
    // Complete the current round
    final updatedMatch = match.completeCurrentRound(roundWinner);
    myMatchesController.matches[matchIndex] = updatedMatch;
    await StorageService.saveMatch(updatedMatch);
    
    if (updatedMatch.isMatchComplete) {
      // Show match complete dialog
      _showMatchCompleteDialog(matchId, updatedMatch.matchWinner!, updatedMatch.team1RoundsWon, updatedMatch.team2RoundsWon);
    } else {
      // Show round complete dialog and start next round
      _showRoundCompleteDialog(matchId, roundWinner, match.currentRoundNumber, team1Score, team2Score);
    }
  }

  // Show round complete dialog - OLD CODE BEHAVIOR
  void _showRoundCompleteDialog(String matchId, String roundWinner, int roundNumber, int team1Score, int team2Score) {
    final myMatchesController = Get.find<MyMatchesController>();
    final match = myMatchesController.getMatchById(matchId);
    if (match == null) return;
    
    final winnerName = roundWinner == 'team1' ? match.team1Players.join(' & ') : match.team2Players.join(' & ');
    
    Get.dialog(
      AlertDialog(
        title: Text('🎯 Round $roundNumber Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$winnerName won Round $roundNumber!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Round $roundNumber Score: $team1Score - $team2Score',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Match Score: ${match.team1RoundsWon} - ${match.team2RoundsWon}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    '🏸 Next Round Service',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$winnerName will serve first in next round',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // Show manual service selection for next round
              _showNextRoundServiceDialog(matchId, roundWinner);
            },
            child: const Text('Change Service'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _startNextRound(matchId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue to Next Round'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Start next round - OLD CODE BEHAVIOR
  Future<void> _startNextRound(String matchId) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = myMatchesController.matches[matchIndex];
    
    // Start next round
    myMatchesController.matches[matchIndex] = match.startNextRound();
    await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
  }
  // Show service selection for next round - INDIVIDUAL PLAYER SELECTION
  void _showNextRoundServiceDialog(String matchId, String defaultServer) {
    final myMatchesController = Get.find<MyMatchesController>();
    final match = myMatchesController.getMatchById(matchId);
    if (match == null) return;
    
    Get.dialog(
      AlertDialog(
        title: Text('🏸 Round ${match.currentRoundNumber + 1} Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Who should serve first in the next round?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose any player from either team',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Team 1 Players Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(match.team1.teamLogo, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      if (defaultServer == 'team1') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Winner',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team1.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _startNextRoundWithService(matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: defaultServer == 'team1' 
                            ? Colors.green.shade600 
                            : Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.sports_tennis, size: 18),
                      label: Text(
                        player.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team 2 Players Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (defaultServer == 'team2') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Winner',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(match.team2.teamLogo, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team2.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        _startNextRoundWithService(matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: defaultServer == 'team2' 
                            ? Colors.green.shade600 
                            : Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.sports_tennis, size: 18),
                      label: Text(
                        player.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Start next round with custom service - OLD CODE BEHAVIOR
  Future<void> _startNextRoundWithService(String matchId, String initialServer) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;
    
    final match = myMatchesController.matches[matchIndex];
    if (match.isMatchComplete || match.currentRoundNumber >= 3) return;
    
    final nextRoundNumber = match.currentRoundNumber + 1;
    
    // Initialize player scores to 0 for all players in the new round
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
      initialServer: initialServer,
      currentServer: initialServer,
      pointSequence: [], // Empty at start
      playerScores: initialPlayerScores,
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds)..add(nextRound);
    
    myMatchesController.matches[matchIndex] = match.copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
    
    await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
    
    // Find the player name for the snackbar
    String playerName = 'Unknown Player';
    for (final player in [...match.team1.players, ...match.team2.players]) {
      if (player.playerId == initialServer) {
        playerName = player.name;
        break;
      }
    }
    
    Get.snackbar(
      'Round $nextRoundNumber Started!', 
      '$playerName will serve first',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade700,
      icon: Icon(Icons.sports_tennis, color: Colors.green.shade700),
    );
  }

  // Show final match complete dialog - CARD STYLE (NOT FULL SCREEN)
  void _showMatchCompleteDialog(String matchId, String matchWinner, int team1Rounds, int team2Rounds) {
    final myMatchesController = Get.find<MyMatchesController>();
    final match = myMatchesController.getMatchById(matchId);
    if (match == null) return;
    
    final winnerName = matchWinner == 'team1' ? match.team1Players.join(' & ') : match.team2Players.join(' & ');
    
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16), // Reduced padding for bigger dialog
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy Icon
              Container(
                width: 90, // Slightly bigger
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 55, // Slightly bigger
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 20),
              
              // Match Complete Title
              const Text(
                'Match Completed',
                style: TextStyle(
                  fontSize: 26, // Slightly bigger
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Winner
              Text(
                'Winner: $winnerName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Final Score Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Final Match Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$team1Rounds - $team2Rounds',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Best of 3 Rounds',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Button - Normal size
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Just close the dialog, stay on match detail screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // PAUSE/RESUME functionality - work through MyMatchesController for proper synchronization
  Future<void> pauseMatch(String matchId) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = myMatchesController.matches[matchIndex];
      if (match.status == BadmintonMatchStatus.inProgress) {
        myMatchesController.matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.paused);
        await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
        
        // Force UI update
        myMatchesController.matches.refresh();
        
        Get.snackbar(
          'Match Paused', 
          'Match has been paused. You can resume anytime.',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade700,
          icon: Icon(Icons.pause_circle, color: Colors.orange.shade700),
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  Future<void> resumeMatch(String matchId) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = myMatchesController.matches[matchIndex];
      if (match.status == BadmintonMatchStatus.paused) {
        myMatchesController.matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.inProgress);
        await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
        
        // Force UI update
        myMatchesController.matches.refresh();
        
        Get.snackbar(
          'Match Resumed', 
          'Match has been resumed. Continue playing!',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade700,
          icon: Icon(Icons.play_circle, color: Colors.green.shade700),
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  // Complete match
  Future<void> completeMatch(String matchId) async {
    final myMatchesController = Get.find<MyMatchesController>();
    final matchIndex = myMatchesController.matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      myMatchesController.matches[matchIndex] = myMatchesController.matches[matchIndex].copyWith(status: BadmintonMatchStatus.completed);
      await StorageService.saveMatch(myMatchesController.matches[matchIndex]);
      
      Get.snackbar(
        'Match Completed', 
        'Match has been marked as completed!',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700,
        icon: Icon(Icons.check_circle, color: Colors.green.shade700),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Get match by ID (delegates to MyMatchesController)
  BadmintonMatchModel? getMatchById(String id) {
    final myMatchesController = Get.find<MyMatchesController>();
    return myMatchesController.getMatchById(id);
  }

  // Add match (delegates to MyMatchesController)
  Future<void> addMatch(BadmintonMatchModel match) async {
    final myMatchesController = Get.find<MyMatchesController>();
    await myMatchesController.addMatch(match);
  }
}