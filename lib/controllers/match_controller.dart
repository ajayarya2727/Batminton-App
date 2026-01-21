import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';
import '../utils/sample_data.dart';

class MatchController extends GetxController {
  final RxList<MatchModel> matches = <MatchModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  // Load matches from local storage
  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final matchesJson = prefs.getString('Batminton matches');
      
      if (matchesJson != null) {
        final List<dynamic> matchesList = json.decode(matchesJson);
        matches.value = matchesList
            .map((json) => MatchModel.fromJson(json))
            .toList();
      } else {
        // Load sample data if no matches exist
        matches.value = SampleData.getSampleMatches();
        saveMatches(); // Save sample data to local storage
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Batminton matches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save matches to local storage
  Future<void> saveMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchesJson = json.encode(
        matches.map((match) => match.toJson()).toList(),
      );
      await prefs.setString('Batminton matches', matchesJson);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save Batminton matches: $e');
    }
  }

  // Add new match
  void addMatch(MatchModel match) {
    matches.add(match);
    saveMatches();
    Get.snackbar('Success', 'Batminton Match created successfully!');
  }

  // Update match score - Smart milestone logic with multi-round support
  void updateMatchScore(String matchId, int team1Score, int team2Score) {
    final matchIndex = matches.indexWhere((match) => match.id == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      
      // Don't allow score updates if match is completed
      if (match.isCompleted) return;
      
      // Get previous scores to check milestones
      final prevTeam1Score = match.team1Score;
      final prevTeam2Score = match.team2Score;
      
      // Check if someone just reached 30 - complete current round
      if (team1Score == 30 || team2Score == 30) {
        final roundWinner = team1Score == 30 ? 'team1' : 'team2';
        _completeCurrentRound(matchId, roundWinner, team1Score, team2Score);
        return;
      }
      
      // Update current score
      matches[matchIndex] = match.copyWith(
        team1Score: team1Score,
        team2Score: team2Score,
      );
      
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
        matches[matchIndex] = matches[matchIndex].copyWith(milestone21Reached: true);
        _showContinueDialog(matchId, team1Score, team2Score);
      } else {
        // Normal score, just save
        saveMatches();
      }
    }
  }

  // Complete current round and check if match should continue
  void _completeCurrentRound(String matchId, String roundWinner, int team1Score, int team2Score) {
    final matchIndex = matches.indexWhere((match) => match.id == matchId);
    if (matchIndex == -1) return;

    final match = matches[matchIndex];
    
    // Add round winner to appropriate list
    List<int> newTeam1RoundWins = List.from(match.team1RoundWins);
    List<int> newTeam2RoundWins = List.from(match.team2RoundWins);
    
    if (roundWinner == 'team1') {
      newTeam1RoundWins.add(match.currentRound);
    } else {
      newTeam2RoundWins.add(match.currentRound);
    }
    
    // Add current round scores to history
    List<Map<String, int>> newRoundScores = List.from(match.roundScores);
    newRoundScores.add({
      'team1': team1Score,
      'team2': team2Score,
      'winner': roundWinner == 'team1' ? 1 : 2,
      'round': match.currentRound,
    });
    
    // Check if match is complete (someone won 2 rounds)
    bool matchComplete = newTeam1RoundWins.length >= 2 || newTeam2RoundWins.length >= 2;
    String? matchWinner;
    
    if (matchComplete) {
      matchWinner = newTeam1RoundWins.length >= 2 ? 'team1' : 'team2';
    }
    
    // Update match with round completion
    matches[matchIndex] = match.copyWith(
      team1Score: team1Score,
      team2Score: team2Score,
      team1RoundWins: newTeam1RoundWins,
      team2RoundWins: newTeam2RoundWins,
      roundScores: newRoundScores,
      isCompleted: matchComplete,
      winner: matchWinner,
    );
    
    saveMatches();
    
    if (matchComplete) {
      // Show match complete dialog
      _showMatchCompleteDialog(matchId, matchWinner!, newTeam1RoundWins.length, newTeam2RoundWins.length);
    } else {
      // Show round complete dialog and start next round
      _showRoundCompleteDialog(matchId, roundWinner, match.currentRound, team1Score, team2Score);
    }
  }

  // Start next round
  void _startNextRound(String matchId) {
    final matchIndex = matches.indexWhere((match) => match.id == matchId);
    if (matchIndex == -1) return;

    final match = matches[matchIndex];
    
    // Reset for next round
    matches[matchIndex] = match.copyWith(
      currentRound: match.currentRound + 1,
      team1Score: 0,
      team2Score: 0,
      milestone21Reached: false,
    );
    
    saveMatches();
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
        title: Text('🏸 21 Points Reached! (Round ${match.currentRound})'),
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
                'Round ${match.currentRound} Score: $team1Score - $team2Score',
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
              saveMatches();
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

  // Show match complete dialog (for 30 points or manual end)
  void _showMatchComplete(String matchId, String winner, int team1Score, int team2Score, String reason) {
    final match = getMatchById(matchId);
    if (match == null) return;
    
    final winnerName = winner == 'team1' 
        ? match.team1Players.join(' & ') 
        : match.team2Players.join(' & ');
    
    Get.dialog(
      AlertDialog(
        title: const Text('🏆 Match Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$winnerName Won!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(reason),
            const SizedBox(height: 12),
            Text('Final Score: $team1Score - $team2Score'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
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
              }).toList(),
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

  // Complete match (simple version)
  void _completeMatch(String matchId, String winner, int team1Score, int team2Score) {
    final matchIndex = matches.indexWhere((match) => match.id == matchId);
    if (matchIndex == -1) return;

    final match = matches[matchIndex];
    
    // Complete the match
    matches[matchIndex] = match.copyWith(
      team1Score: team1Score,
      team2Score: team2Score,
      isCompleted: true,
      winner: winner,
    );
    
    saveMatches();
    
    final winnerName = winner == 'team1' 
        ? match.team1Players.join(' & ') 
        : match.team2Players.join(' & ');
    
    Get.dialog(
      AlertDialog(
        title: const Text('🏆 Match Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$winnerName Won!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Final Score: $team1Score - $team2Score'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Complete match
  void completeMatch(String matchId) {
    final matchIndex = matches.indexWhere((match) => match.id == matchId);
    if (matchIndex != -1) {
      matches[matchIndex] = matches[matchIndex].copyWith(isCompleted: true);
      saveMatches();
      Get.snackbar('Batminton Match Completed', 'Batminton Match has been marked as completed!');
    }
  }

  // Delete match
  void deleteMatch(String matchId) {
    matches.removeWhere((match) => match.id == matchId);
    saveMatches();
    Get.snackbar('Deleted', 'Batminton Match deleted successfully!');
  }

  // Get matches by type
  List<MatchModel> getMatchesByType(String type) {
    return matches.where((match) => match.matchType == type).toList();
  }

  // Get match by ID
  MatchModel? getMatchById(String id) {
    try {
      return matches.firstWhere((match) => match.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearAllMatches() {}
}