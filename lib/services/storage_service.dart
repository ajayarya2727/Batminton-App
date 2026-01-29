import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/badminton_models.dart';

class StorageService {
  static const String _matchesFolder = 'matches';
  
  // Get the matches directory
  static Future<Directory> _getMatchesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final matchesDir = Directory('${appDir.path}/$_matchesFolder');
    
    if (!await matchesDir.exists()) {
      await matchesDir.create(recursive: true);
    }
    
    return matchesDir;
  }
  
  // Save a single match to its own JSON file
  static Future<void> saveMatch(BadmintonMatchModel match) async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matchFile = File('${matchesDir.path}/${match.matchId}.json');
      
      final matchJson = json.encode(match.toJson());
      await matchFile.writeAsString(matchJson);
      
      // AUTOMATIC PRINTING: Print JSON when match is saved (score changes)
      await printMatchById(match.matchId);
      
    } catch (e) {
      throw Exception('Failed to save match ${match.matchId}: $e');
    }
  }
  
  // Load a single match from its JSON file
  static Future<BadmintonMatchModel?> loadMatch(String matchId) async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matchFile = File('${matchesDir.path}/$matchId.json');
      
      if (!await matchFile.exists()) {
        return null;
      }
      
      final matchJson = await matchFile.readAsString();
      final matchData = json.decode(matchJson) as Map<String, dynamic>;
      
      return BadmintonMatchModel.fromJson(matchData);
    } catch (e) {
      throw Exception('Failed to load match $matchId: $e');
    }
  }
  
  // Load all matches from individual JSON files
  static Future<List<BadmintonMatchModel>> loadAllMatches() async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matches = <BadmintonMatchModel>[];
      
      if (!await matchesDir.exists()) {
        return matches;
      }
      
      final files = await matchesDir.list().toList();
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final matchJson = await file.readAsString();
            final matchData = json.decode(matchJson) as Map<String, dynamic>;
            final match = BadmintonMatchModel.fromJson(matchData);
            matches.add(match);
          } catch (e) {
            // Skip corrupted files and continue
            // Log warning for debugging but don't crash the app
            continue;
          }
        }
      }
      
      return matches;
    } catch (e) {
      throw Exception('Failed to load matches: $e');
    }
  }
  
  // Delete a match file
  static Future<void> deleteMatch(String matchId) async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matchFile = File('${matchesDir.path}/$matchId.json');
      
      if (await matchFile.exists()) {
        await matchFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete match $matchId: $e');
    }
  }
  
  // Get all match IDs (file names without .json extension)
  static Future<List<String>> getAllMatchIds() async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matchIds = <String>[];
      
      if (!await matchesDir.exists()) {
        return matchIds;
      }
      
      final files = await matchesDir.list().toList();
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final fileName = file.path.split('/').last;
          final matchId = fileName.replaceAll('.json', '');
          matchIds.add(matchId);
        }
      }
      
      return matchIds;
    } catch (e) {
      throw Exception('Failed to get match IDs: $e');
    }
  }
  
  // Check if a match file exists
  static Future<bool> matchExists(String matchId) async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matchFile = File('${matchesDir.path}/$matchId.json');
      return await matchFile.exists();
    } catch (e) {
      return false;
    }
  }
  
  // Clear all match files (for testing/reset purposes)
  static Future<void> clearAllMatches() async {
    try {
      final matchesDir = await _getMatchesDirectory();
      
      if (await matchesDir.exists()) {
        await matchesDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear all matches: $e');
    }
  }
  
  // DEMO: Print any match JSON by ID for sir's evaluation
  static Future<void> printMatchById(String matchId) async {
    try {
      final match = await loadMatch(matchId);
      
      if (match == null) {
        print('MATCH NOT FOUND: $matchId');
        return;
      }
      
      // Build complete match result object in the exact order as string format
      final matchResult = <String, dynamic>{
        // Match Info Section
        'matchInfo': <String, dynamic>{
          'matchId': match.matchId,
          'matchType': match.matchType.displayName,
          'matchStatus': match.status.displayName,
          'currentRound': match.currentRoundNumber,
          'totalRounds': 3,
        },
        
        // Team 1 Section
        'team1': <String, dynamic>{
          'teamId': match.team1.teamId,
          'teamName': match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1',
          'teamLogo': match.team1.teamLogo,
          'currentRoundScore': '${match.team1Score}/21 points',
          'roundsWon': match.team1RoundsWon,
          'players': match.team1.players.asMap().entries.map((entry) {
            final index = entry.key;
            final p = entry.value;
            return <String, dynamic>{
              'name': p.name,
              'playerId': p.playerId,
              'pointsInThisRound': p.currentRoundScore,
              'totalMatchPoints': p.totalMatchScore,
              'isCurrentServer': p.isCurrentServer,
            };
          }).toList(),
        },
        
        // Team 2 Section
        'team2': <String, dynamic>{
          'teamId': match.team2.teamId,
          'teamName': match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2',
          'teamLogo': match.team2.teamLogo,
          'currentRoundScore': '${match.team2Score}/21 points',
          'roundsWon': match.team2RoundsWon,
          'players': match.team2.players.asMap().entries.map((entry) {
            final index = entry.key;
            final p = entry.value;
            return <String, dynamic>{
              'name': p.name,
              'playerId': p.playerId,
              'pointsInThisRound': p.currentRoundScore,
              'totalMatchPoints': p.totalMatchScore,
              'isCurrentServer': p.isCurrentServer,
            };
          }).toList(),
        },
      };
      
      // Add match result data if rounds exist
      if (match.rounds.isNotEmpty) {
        final matchResultData = <String, dynamic>{};
        
        // Overall match result
        if (match.isCompleted) {
          final team1Name = match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1';
          final team2Name = match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2';
          final matchWinnerName = match.matchWinner == 'team1' ? team1Name : 
                                 match.matchWinner == 'team2' ? team2Name : 'Draw';
          matchResultData['matchWinner'] = matchWinnerName;
          matchResultData['finalMatchScore'] = '${match.team1RoundsWon} - ${match.team2RoundsWon} (Rounds Won)';
          matchResultData['matchStatus'] = 'COMPLETED';
        } else {
          final team1Name = match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1';
          final team2Name = match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2';
          matchResultData['roundsWonByTeams'] = <String, dynamic>{
            team1Name: '${match.team1RoundsWon} rounds won',
            team2Name: '${match.team2RoundsWon} rounds won',
          };
          matchResultData['matchStatus'] = 'IN PROGRESS';
          matchResultData['currentRound'] = '${match.currentRoundNumber} of 3';
        }
        
        // Round by round results
        matchResultData['roundByRoundResults'] = match.rounds.map((round) {
          final status = round.isCompleted ? 'COMPLETED' : 'IN PROGRESS';
          final team1Name = match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1';
          final team2Name = match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2';
          final winner = round.winnerId == 'team1' ? team1Name : 
                        round.winnerId == 'team2' ? team2Name : 'Ongoing';
          
          final roundResult = <String, dynamic>{
            'roundNumber': round.roundNumber,
            'score': '${round.team1Score} - ${round.team2Score}',
            'status': status,
          };
          
          if (round.isCompleted) {
            roundResult['roundWinner'] = winner;
            roundResult['duration'] = _calculateRoundDuration(round);
            roundResult['totalPointsPlayed'] = round.team1Score + round.team2Score;
            roundResult['playerContributions'] = <String, dynamic>{
              team1Name: match.team1.players.map((player) => <String, dynamic>{
                'name': player.name,
                'points': round.playerScores[player.playerId] ?? 0,
              }).toList(),
              team2Name: match.team2.players.map((player) => <String, dynamic>{
                'name': player.name,
                'points': round.playerScores[player.playerId] ?? 0,
              }).toList(),
            };
          } else {
            roundResult['currentServer'] = _getPlayerNameById(match, round.currentServer ?? '');
            roundResult['pointsPlayedSoFar'] = round.team1Score + round.team2Score;
          }
          
          return roundResult;
        }).toList();
        
        // Match statistics
        final totalPointsTeam1 = match.rounds.fold<int>(0, (sum, round) => sum + round.team1Score);
        final totalPointsTeam2 = match.rounds.fold<int>(0, (sum, round) => sum + round.team2Score);
        final totalPointsPlayed = totalPointsTeam1 + totalPointsTeam2;
        
        final team1Name = match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1';
        final team2Name = match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2';
        
        matchResultData['matchStatistics'] = <String, dynamic>{
          'totalPointsPlayed': totalPointsPlayed,
          '${team1Name}TotalPoints': totalPointsTeam1,
          '${team2Name}TotalPoints': totalPointsTeam2,
        };
        
        if (totalPointsPlayed > 0) {
          final team1Percentage = (totalPointsTeam1 / totalPointsPlayed * 100).toStringAsFixed(1);
          final team2Percentage = (totalPointsTeam2 / totalPointsPlayed * 100).toStringAsFixed(1);
          matchResultData['matchStatistics']['${team1Name}PointPercentage'] = '$team1Percentage%';
          matchResultData['matchStatistics']['${team2Name}PointPercentage'] = '$team2Percentage%';
        }
        
        // Individual player statistics
        matchResultData['individualPlayerStatistics'] = <String, dynamic>{
          'team1Players': match.team1.players.map((player) {
            return <String, dynamic>{
              'playerId': player.playerId,
              'name': player.name,
              'currentRoundPoints': player.currentRoundScore,
              'totalMatchPoints': player.totalMatchScore,
              'currentlyServing': player.isCurrentServer,
            };
          }).toList(),
          'team2Players': match.team2.players.map((player) {
            return <String, dynamic>{
              'playerId': player.playerId,
              'name': player.name,
              'currentRoundPoints': player.currentRoundScore,
              'totalMatchPoints': player.totalMatchScore,
              'currentlyServing': player.isCurrentServer,
            };
          }).toList(),
        };
        
        matchResult['matchResult'] = matchResultData;
      } else {
        matchResult['matchResult'] = <String, dynamic>{'status': 'No rounds played yet'};
      }
      
      // Print complete JSON object in chunks to avoid truncation
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String prettyJson = encoder.convert(matchResult);
      
      // Debug information
      print('=== MATCH JSON DEBUG INFO ===');
      print('Total JSON length: ${prettyJson.length} characters');
      print('Team1 players count: ${match.team1.players.length}');
      print('Team2 players count: ${match.team2.players.length}');
      print('Rounds count: ${match.rounds.length}');
      print('=== COMPLETE MATCH JSON START ===');
      
      // Print in smaller chunks to avoid console truncation, but break at line boundaries
      const int chunkSize = 1000;
      final lines = prettyJson.split('\n');
      String currentChunk = '';
      
      for (final line in lines) {
        // If adding this line would exceed chunk size, print current chunk and start new one
        if (currentChunk.length + line.length + 1 > chunkSize && currentChunk.isNotEmpty) {
          print(currentChunk);
          currentChunk = line;
        } else {
          if (currentChunk.isNotEmpty) {
            currentChunk += '\n$line';
          } else {
            currentChunk = line;
          }
        }
      }
      
      // Print any remaining content
      if (currentChunk.isNotEmpty) {
        print(currentChunk);
      }
      
      print('=== COMPLETE MATCH JSON END ===');
      
    } catch (e) {
      print('ERROR: $e');
    }
  }

  // Helper method to build match result object
  static Map<String, dynamic> _buildMatchResult(BadmintonMatchModel match) {
    final result = <String, dynamic>{};
    
    if (match.rounds.isEmpty) {
      return {'status': 'No rounds played yet'};
    }
    
    // Overall match result
    if (match.isCompleted) {
      final team1Name = match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1';
      final team2Name = match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2';
      final matchWinnerName = match.matchWinner == 'team1' ? team1Name : 
                             match.matchWinner == 'team2' ? team2Name : 'Draw';
      result['matchWinner'] = matchWinnerName;
      result['finalMatchScore'] = '${match.team1RoundsWon} - ${match.team2RoundsWon}';
      result['matchStatus'] = 'COMPLETED';
    } else {
      result['currentMatchScore'] = '${match.team1RoundsWon} - ${match.team2RoundsWon}';
      result['matchStatus'] = 'IN PROGRESS';
      result['currentRound'] = '${match.currentRoundNumber} of 3';
    }
    
    // Round by round results
    result['roundByRoundResults'] = match.rounds.map((round) {
      final status = round.isCompleted ? 'COMPLETED' : 'IN PROGRESS';
      final team1Name = match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1';
      final team2Name = match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2';
      final winner = round.winnerId == 'team1' ? team1Name : 
                    round.winnerId == 'team2' ? team2Name : 'Ongoing';
      
      final roundResult = {
        'roundNumber': round.roundNumber,
        'score': '${round.team1Score} - ${round.team2Score}',
        'status': status,
      };
      
      if (round.isCompleted) {
        roundResult['roundWinner'] = winner;
        roundResult['duration'] = _calculateRoundDuration(round);
        roundResult['totalPointsPlayed'] = round.team1Score + round.team2Score;
        roundResult['playerContributions'] = {
          team1Name: match.team1.players.map((player) => {
            'name': player.name,
            'points': round.playerScores[player.playerId] ?? 0,
          }).toList(),
          team2Name: match.team2.players.map((player) => {
            'name': player.name,
            'points': round.playerScores[player.playerId] ?? 0,
          }).toList(),
        };
      } else {
        roundResult['currentServer'] = _getPlayerNameById(match, round.currentServer ?? '');
        roundResult['pointsPlayedSoFar'] = round.team1Score + round.team2Score;
      }
      
      return roundResult;
    }).toList();
    
    // Match statistics
    final totalPointsTeam1 = match.rounds.fold<int>(0, (sum, round) => sum + round.team1Score);
    final totalPointsTeam2 = match.rounds.fold<int>(0, (sum, round) => sum + round.team2Score);
    final totalPointsPlayed = totalPointsTeam1 + totalPointsTeam2;
    
    result['matchStatistics'] = {
      'totalPointsPlayed': totalPointsPlayed,
      'team1TotalPoints': totalPointsTeam1,
      'team2TotalPoints': totalPointsTeam2,
    };
    
    if (totalPointsPlayed > 0) {
      final team1Percentage = (totalPointsTeam1 / totalPointsPlayed * 100).toStringAsFixed(1);
      final team2Percentage = (totalPointsTeam2 / totalPointsPlayed * 100).toStringAsFixed(1);
      result['matchStatistics']['team1PointPercentage'] = '$team1Percentage%';
      result['matchStatistics']['team2PointPercentage'] = '$team2Percentage%';
    }
    
    // Individual player statistics
    result['individualPlayerStatistics'] = {
      'team1Players': match.team1.players.map((player) {
        final totalPoints = match.rounds.fold<int>(0, (sum, round) => 
          sum + (round.playerScores[player.playerId] ?? 0));
        return {
          'playerId': player.playerId,
          'name': player.name,
          'totalPoints': totalPoints,
          'currentRoundPoints': player.currentRoundScore,
          'totalMatchPoints': player.totalMatchScore,
          'currentlyServing': player.isCurrentServer,
        };
      }).toList(),
      'team2Players': match.team2.players.map((player) {
        final totalPoints = match.rounds.fold<int>(0, (sum, round) => 
          sum + (round.playerScores[player.playerId] ?? 0));
        return {
          'playerId': player.playerId,
          'name': player.name,
          'totalPoints': totalPoints,
          'currentRoundPoints': player.currentRoundScore,
          'totalMatchPoints': player.totalMatchScore,
          'currentlyServing': player.isCurrentServer,
        };
      }).toList(),
    };
    
    return result;
  }

  // Helper method to get player name by ID
  static String _getPlayerNameById(BadmintonMatchModel match, String playerId) {
    for (final player in [...match.team1.players, ...match.team2.players]) {
      if (player.playerId == playerId) {
        return player.name;
      }
    }
    return 'Unknown Player';
  }

  // Helper method to calculate round duration
  static String _calculateRoundDuration(BadmintonRoundModel round) {
    if (round.startedAt == null) return 'Unknown';
    
    final endTime = round.completedAt ?? DateTime.now();
    final duration = endTime.difference(round.startedAt!);
    
    if (duration.inMinutes < 1) {
      return '${duration.inSeconds} seconds';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes} minutes ${duration.inSeconds % 60} seconds';
    } else {
      return '${duration.inHours} hours ${duration.inMinutes % 60} minutes';
    }
  }



  // DEMO: Save match JSON to a readable file for debugging
  static Future<void> saveMatchJsonToFile(String matchId) async {
    try {
      final match = await loadMatch(matchId);
      
      if (match == null) {
        print('Match not found: $matchId');
        return;
      }
      
      final matchesDir = await _getMatchesDirectory();
      final debugFile = File('${matchesDir.path}/${matchId}_debug.json');
      
      // Create pretty formatted JSON
      final Map<String, dynamic> jsonMap = match.toJson();
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String prettyJson = encoder.convert(jsonMap);
      
      // Save to debug file
      await debugFile.writeAsString(prettyJson);
      
      print('');
      print('================================');
      print('MATCH JSON SAVED TO DEBUG FILE');
      print('================================');
      print('Match ID: ${match.matchId}');
      print('Debug File: ${debugFile.path}');
      print('File size: ${prettyJson.length} characters');
      print('You can view the complete JSON in the debug file');
      print('================================');
      print('');
      
    } catch (e) {
      print('Error saving debug JSON: $e');
    }
  }


}