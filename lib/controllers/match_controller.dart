import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/badminton_models.dart';
import '../services/storage_service.dart';
// import '../utils/sample_data.dart';

class MatchController extends GetxController {
  final RxList<BadmintonMatchModel> matches = <BadmintonMatchModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  // Load matches from individual JSON files
  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      
      // Try to load from new JSON file storage first
      final loadedMatches = await StorageService.loadAllMatches();
      
      if (loadedMatches.isNotEmpty) {
        matches.value = loadedMatches;
      } else {
        // Check if we have old SharedPreferences data to migrate
        final prefs = await SharedPreferences.getInstance();
        final matchesJson = prefs.getString('Batminton matches');
        
        if (matchesJson != null) {
          // Migrate old data to new storage format
          final List<dynamic> matchesList = json.decode(matchesJson);
          final oldMatches = matchesList
              .map((json) => BadmintonMatchModel.fromJson(json))
              .toList();
          
          // Save each match to individual files
          for (final match in oldMatches) {
            await StorageService.saveMatch(match);
          }
          
          // Clear old storage
          await prefs.remove('Batminton matches');
          
          matches.value = oldMatches;
        
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Batminton matches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save matches to individual JSON files
  Future<void> saveMatches() async {
    try {
      // Save all matches to individual files
      for (final match in matches) {
        await StorageService.saveMatch(match);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save Batminton matches: $e');
    }
  }

  // Add new match with service selection
  Future<void> addMatch(BadmintonMatchModel match) async {
    matches.add(match);
    await StorageService.saveMatch(match);
    Get.snackbar('Success', 'Batminton Match created successfully!');
  }

  // Show manual service selection dialog (can be called anytime during match)
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
            Text(
              '${match.team1.teamName.isNotEmpty ? match.team1.teamName : "Team 1"}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
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
                    Text(match.team1.teamLogo, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      player.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (match.currentServer == player.playerId)
                      const Icon(Icons.sports_tennis, size: 16),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 16),
            
            // Team 2 Players
            Text(
              '${match.team2.teamName.isNotEmpty ? match.team2.teamName : "Team 2"}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
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
                    const SizedBox(width: 8),
                    Text(
                      player.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(match.team2.teamLogo, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )),
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

  // Manually set service for current round
  Future<void> _manuallySetService(String matchId, String servingPlayerId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      
      if (match.currentRound == null) return;
      
      // Update current server in the current round
      final updatedRound = match.currentRound!.copyWith(
        currentServer: servingPlayerId,
      );
      
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      matches[matchIndex] = match.copyWith(rounds: updatedRounds);
      
      await StorageService.saveMatch(matches[matchIndex]);
      
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
            Text(
              '${match.team1.teamName.isNotEmpty ? match.team1.teamName : "Team 1"}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(match.team1.teamLogo, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      player.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 16),
            
            // Team 2 Players
            Text(
              '${match.team2.teamName.isNotEmpty ? match.team2.teamName : "Team 2"}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(match.team2.teamLogo, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )),
            // Back button
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

  // Initialize match with selected server (public method)
  Future<void> initializeMatchWithService(String matchId, String initialServer) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      
      // Initialize first round with selected server
      matches[matchIndex] = match.initializeFirstRound(initialServer: initialServer);
      
      await StorageService.saveMatch(matches[matchIndex]);
      
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

  // Update individual player score and recalculate team totals
  Future<void> updatePlayerScore(String matchId, String playerId, int newPlayerScore) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      
      // Don't allow score updates if match is completed or paused
      if (match.isCompleted || match.status == BadmintonMatchStatus.paused) return;
      
      // If match hasn't started yet (no rounds), show service selection
      if (match.rounds.isEmpty) {
        showServiceSelectionDialog(match);
        return;
      }
      
      if (match.currentRound == null) return;
      
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
      
      // Update players with new individual scores and server status
      final updatedTeam1 = match.team1.copyWith(
        players: match.team1.players.map((player) => player.copyWith(
          currentRoundScore: updatedPlayerScores[player.playerId] ?? 0,
          totalMatchScore: _calculatePlayerTotalMatchScore(match, player.playerId, updatedPlayerScores),
          isCurrentServer: match.currentServer == player.playerId,
        )).toList(),
      );
      
      final updatedTeam2 = match.team2.copyWith(
        players: match.team2.players.map((player) => player.copyWith(
          currentRoundScore: updatedPlayerScores[player.playerId] ?? 0,
          totalMatchScore: _calculatePlayerTotalMatchScore(match, player.playerId, updatedPlayerScores),
          isCurrentServer: match.currentServer == player.playerId,
        )).toList(),
      );
      
      // Update the round with new player scores and team totals
      final updatedRound = match.currentRound!.copyWith(
        playerScores: updatedPlayerScores,
        team1Score: newTeam1Score,
        team2Score: newTeam2Score,
      );
      
      final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
      updatedRounds[match.currentRoundNumber - 1] = updatedRound;
      
      matches[matchIndex] = match.copyWith(
        rounds: updatedRounds,
        team1: updatedTeam1,
        team2: updatedTeam2,
      );
      
      // Handle service changes - point winner gets service
      if (newTeam1Score > prevTeam1Score || newTeam2Score > prevTeam2Score) {
        // A point was scored, the scoring player gets service
        final updatedRoundWithService = updatedRound.copyWith(currentServer: playerId);
        updatedRounds[match.currentRoundNumber - 1] = updatedRoundWithService;
        
        // Update server status in players
        final finalTeam1 = updatedTeam1.copyWith(
          players: updatedTeam1.players.map((player) => player.copyWith(
            isCurrentServer: player.playerId == playerId,
          )).toList(),
        );
        
        final finalTeam2 = updatedTeam2.copyWith(
          players: updatedTeam2.players.map((player) => player.copyWith(
            isCurrentServer: player.playerId == playerId,
          )).toList(),
        );
        
        matches[matchIndex] = match.copyWith(
          rounds: updatedRounds,
          team1: finalTeam1,
          team2: finalTeam2,
        );
      }
      
      // Check if someone JUST reached 30 - complete current round AFTER updating scores
      if (newTeam1Score == 30 || newTeam2Score == 30) {
        final roundWinner = newTeam1Score == 30 ? 'team1' : 'team2';
        await StorageService.saveMatch(matches[matchIndex]); // Save first with 30 points
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
        matches[matchIndex] = matches[matchIndex].markMilestone21Reached();
        _showContinueDialog(matchId, newTeam1Score, newTeam2Score);
      } else {
        // Normal score, just save
        await StorageService.saveMatch(matches[matchIndex]);
      }
    }
  }

  // Update match score - Smart milestone logic with multi-round support and proper undo service tracking
  Future<void> updateMatchScore(String matchId, int team1Score, int team2Score) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      
      // Don't allow score updates if match is completed or paused
      if (match.isCompleted || match.status == BadmintonMatchStatus.paused) return;
      
      // If match hasn't started yet (no rounds), show service selection
      if (match.rounds.isEmpty) {
        showServiceSelectionDialog(match);
        return;
      }
      
      // Get previous scores to check milestones and service changes
      final prevTeam1Score = match.team1Score;
      final prevTeam2Score = match.team2Score;
      
      // Update scores with proper service tracking
      matches[matchIndex] = updateScoresWithProperService(match, team1Score, team2Score, prevTeam1Score, prevTeam2Score);
      
      // Check if someone JUST reached 30 - complete current round AFTER updating scores
      if (team1Score == 30 || team2Score == 30) {
        final roundWinner = team1Score == 30 ? 'team1' : 'team2';
        await StorageService.saveMatch(matches[matchIndex]); // Save first with 30 points
        await _completeCurrentRound(matchId, roundWinner, team1Score, team2Score);
        return;
      }
      
      // Check if someone JUST reached 21 AND 21 milestone hasn't been reached before
      bool showPopup = false;
      
      if (!match.milestone21Reached) {
        // Team 1 just reached 21
        if (team1Score == 21 && prevTeam1Score < 21) {
          showPopup = true;
        }
        // Team 2 just reached 21
        else if (team2Score == 21 && prevTeam2Score < 21) {
          showPopup = true;
        }
      }
      
      if (showPopup) {
        // Mark 21 milestone as reached
        matches[matchIndex] = matches[matchIndex].markMilestone21Reached();
        _showContinueDialog(matchId, team1Score, team2Score);
      } else {
        // Normal score, just save
        await StorageService.saveMatch(matches[matchIndex]);
      }
    }
  }

  // Proper service tracking with undo support (public for testing)
  BadmintonMatchModel updateScoresWithProperService(BadmintonMatchModel match, int team1Score, int team2Score, int prevTeam1Score, int prevTeam2Score) {
    if (match.currentRound == null) return match;
    
    final currentRound = match.currentRound!;
    final totalPoints = team1Score + team2Score;
    final prevTotalPoints = prevTeam1Score + prevTeam2Score;
    
    // Build point sequence from current scores
    List<String> pointSequence = List<String>.from(currentRound.pointSequence);
    
    if (totalPoints > prevTotalPoints) {
      // Points were added - determine who scored
      if (team1Score > prevTeam1Score) {
        pointSequence.add('team1');
      } else if (team2Score > prevTeam2Score) {
        pointSequence.add('team2');
      }
    } else if (totalPoints < prevTotalPoints) {
      // Points were removed (undo) - remove from end
      final pointsToRemove = prevTotalPoints - totalPoints;
      for (int i = 0; i < pointsToRemove; i++) {
        if (pointSequence.isNotEmpty) {
          pointSequence.removeLast();
        }
      }
    }
    
    // Calculate current server based on consecutive point logic
    String currentServer = currentRound.initialServer ?? match.team1.players.first.playerId;
    
    if (pointSequence.isNotEmpty) {
      // Find the last point winner - they serve next
      final lastPointWinner = pointSequence.last;
      if (lastPointWinner == 'team1') {
        // Use the first player from team1 as the server
        currentServer = match.team1.players.first.playerId;
      } else if (lastPointWinner == 'team2') {
        // Use the first player from team2 as the server
        currentServer = match.team2.players.first.playerId;
      } else {
        // If it's already a player ID, use it directly
        currentServer = lastPointWinner;
      }
    }
    
    // Update the round
    final updatedRound = currentRound.copyWith(
      team1Score: team1Score,
      team2Score: team2Score,
      currentServer: currentServer,
      pointSequence: pointSequence,
    );
    
    final updatedRounds = List<BadmintonRoundModel>.from(match.rounds);
    updatedRounds[match.currentRoundNumber - 1] = updatedRound;
    
    return match.copyWith(rounds: updatedRounds);
  }

  // Complete current round and check if match should continue
  Future<void> _completeCurrentRound(String matchId, String roundWinner, int team1Score, int team2Score) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;

    final match = matches[matchIndex];
    
    // Complete the current round
    final updatedMatch = match.completeCurrentRound(roundWinner);
    matches[matchIndex] = updatedMatch;
    
    await StorageService.saveMatch(updatedMatch);
    
    if (updatedMatch.isMatchComplete) {
      // Show match complete dialog
      _showMatchCompleteDialog(matchId, updatedMatch.matchWinner!, updatedMatch.team1RoundsWon, updatedMatch.team2RoundsWon);
    } else {
      // Show round complete dialog and start next round
      _showRoundCompleteDialog(matchId, roundWinner, match.currentRoundNumber, team1Score, team2Score);
    }
  }

  // Start next round
  Future<void> _startNextRound(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;

    final match = matches[matchIndex];
    
    // Start next round
    matches[matchIndex] = match.startNextRound();
    
    await StorageService.saveMatch(matches[matchIndex]);
  }

  // Show dialog only for 21 points (first time) - Updated for rounds
  void _showContinueDialog(String matchId, int team1Score, int team2Score) {
    final match = getMatchById(matchId);
    if (match == null) return;

    final winnerPlayer = team1Score == 21 
        ? match.team1Players.join(' & ') 
        : match.team2Players.join(' & ');

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
              StorageService.saveMatch(matches[matches.indexWhere((m) => m.matchId == matchId)]);
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

  // Show round complete dialog
  void _showRoundCompleteDialog(String matchId, String roundWinner, int roundNumber, int team1Score, int team2Score) {
    final match = getMatchById(matchId);
    if (match == null) return;
    
    final winnerName = roundWinner == 'team1' 
        ? match.team1Players.join(' & ') 
        : match.team2Players.join(' & ');
    
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

  // Show service selection for next round
  void _showNextRoundServiceDialog(String matchId, String defaultServer) {
    final match = getMatchById(matchId);
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
            const SizedBox(height: 20),
            // Team 1 option
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  _startNextRoundWithService(matchId, match.team1.players.first.playerId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: defaultServer == 'team1' 
                      ? Colors.green.shade600 
                      : Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(match.team1.teamLogo, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        const Text(
                          'Team 1',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          match.team1Players.join(' & '),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    if (defaultServer == 'team1')
                      const Text('(Winner)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            // Team 2 option
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  _startNextRoundWithService(matchId, match.team2.players.first.playerId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: defaultServer == 'team2' 
                      ? Colors.green.shade600 
                      : Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (defaultServer == 'team2')
                      const Text('(Winner)', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        const Text(
                          'Team 2',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          match.team2Players.join(' & '),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(match.team2.teamLogo, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Start next round with custom service
  Future<void> _startNextRoundWithService(String matchId, String initialServer) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex == -1) return;

    final match = matches[matchIndex];
    
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
    
    matches[matchIndex] = match.copyWith(
      rounds: updatedRounds,
      currentRoundNumber: nextRoundNumber,
    );
    
    await StorageService.saveMatch(matches[matchIndex]);
    
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

  // Show final match complete dialog
  void _showMatchCompleteDialog(String matchId, String matchWinner, int team1Rounds, int team2Rounds) {
    final match = getMatchById(matchId);
    if (match == null) return;
    
    final winnerName = matchWinner == 'team1' 
        ? match.team1Players.join(' & ') 
        : match.team2Players.join(' & ');
    
    Get.dialog(
      AlertDialog(
        title: const Text('🏆 Match Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$winnerName Won the Match!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Final Match Score',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$team1Rounds - $team2Rounds',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Best of 3 Rounds',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Show round by round scores
            if (match.roundScores.isNotEmpty) ...[
              const Text(
                'Round by Round:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...match.roundScores.asMap().entries.map((entry) {
                final roundData = entry.value;
                final roundNum = entry.key + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'Round $roundNum: ${roundData['team1']} - ${roundData['team2']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  // Complete match
  Future<void> completeMatch(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      matches[matchIndex] = matches[matchIndex].copyWith(status: BadmintonMatchStatus.completed);
      await StorageService.saveMatch(matches[matchIndex]);
      Get.snackbar('Batminton Match Completed', 'Batminton Match has been marked as completed!');
    }
  }

  // Delete match
  Future<void> deleteMatch(String matchId) async {
    matches.removeWhere((match) => match.matchId == matchId);
    await StorageService.deleteMatch(matchId);
    Get.snackbar('Deleted', 'Batminton Match deleted successfully!');
  }

  // Get matches by type
  List<BadmintonMatchModel> getMatchesByType(String type) {
    return matches.where((match) => match.matchType.code == type).toList();
  }

  // Get match by ID
  BadmintonMatchModel? getMatchById(String id) {
    try {
      return matches.firstWhere((match) => match.matchId == id);
    } catch (e) {
      return null;
    }
  }

  void clearAllMatches() async {
    matches.clear();
    await StorageService.clearAllMatches();
  }

  // DEMO: Print any match JSON by ID for sir's evaluation
  Future<void> printMatchJsonById(String matchId) async {
    await StorageService.printMatchById(matchId);
  }

  // DEMO: Print complete JSON for current match state
  Future<void> printCompleteMatchJson(String matchId) async {
    final match = getMatchById(matchId);
    if (match != null) {
      // Save current state first
      await StorageService.saveMatch(match);
      // Print complete JSON in chunks
      await StorageService.printMatchById(matchId);
      // Also save to debug file for complete viewing
      await StorageService.saveMatchJsonToFile(matchId);
    }
  }

  // BREAK FEATURE: Pause/Resume match
  Future<void> pauseMatch(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      if (match.status == BadmintonMatchStatus.inProgress) {
        matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.paused);
        await StorageService.saveMatch(matches[matchIndex]);
        Get.snackbar(
          'Match Paused', 
          'Match has been paused. You can resume anytime.',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade700,
          icon: Icon(Icons.pause_circle, color: Colors.orange.shade700),
        );
      }
    }
  }

  Future<void> resumeMatch(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      if (match.status == BadmintonMatchStatus.paused) {
        matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.inProgress);
        await StorageService.saveMatch(matches[matchIndex]);
        Get.snackbar(
          'Match Resumed', 
          'Match has been resumed. Continue playing!',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade700,
          icon: Icon(Icons.play_circle, color: Colors.green.shade700),
        );
      }
    }
  }

  // Helper method to calculate total match score for a player
  int _calculatePlayerTotalMatchScore(BadmintonMatchModel match, String playerId, Map<String, int> currentRoundPlayerScores) {
    int totalScore = 0;
    
    // Add scores from all completed rounds
    for (final round in match.rounds.where((r) => r.isCompleted)) {
      totalScore += round.playerScores[playerId] ?? 0;
    }
    
    // Add current round score if in progress
    if (match.currentRound != null && match.currentRound!.isInProgress) {
      totalScore += currentRoundPlayerScores[playerId] ?? 0;
    }
    
    return totalScore;
  }
}