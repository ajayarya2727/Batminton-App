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
        // } else {
        //   // Load sample data if no matches exist
        //   final sampleMatches = SampleData.getSampleMatches();
        //   matches.value = sampleMatches;
          
        //   // Save sample data to new storage format
        //   for (final match in sampleMatches) {
        //     await StorageService.saveMatch(match);
        //   }
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

  // Show service selection dialog when match starts
  void showServiceSelectionDialog(BadmintonMatchModel match) {
    Get.dialog(
      AlertDialog(
        title: const Text('🏸 Who will serve first?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select which team will serve first in Round 1:',
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
                  initializeMatchWithService(match.matchId, 'team1');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Column(
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
              ),
            ),
            // Team 2 option
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  initializeMatchWithService(match.matchId, 'team2');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Column(
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
      
      final serverTeamName = initialServer == 'team1' 
          ? match.team1Players.join(' & ')
          : match.team2Players.join(' & ');
      
      Get.snackbar(
        'Service Set!', 
        '$serverTeamName will serve first',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700,
        icon: Icon(Icons.sports_tennis, color: Colors.green.shade700),
      );
    }
  }

  // Update match score - Smart milestone logic with multi-round support and service tracking
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
      
      // First update current round scores with service tracking (point winner serves next)
      matches[matchIndex] = match.updateCurrentRoundScoresWithService(
        team1Score, 
        team2Score, 
        prevTeam1Score: prevTeam1Score, 
        prevTeam2Score: prevTeam2Score
      );
      
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
            const SizedBox(height: 8),
            const Text(
              'Starting next round...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
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
}