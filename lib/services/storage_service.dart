import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/badminton_models.dart';

class StorageService {
  static const String _matchesFolder = 'matches';
  
  /// Get or create the matches storage directory
  static Future<Directory> _getMatchesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final matchesDir = Directory('${appDir.path}/$_matchesFolder');
    
    if (!await matchesDir.exists()) {
      await matchesDir.create(recursive: true);
    }
    
    return matchesDir;
  }
  
  /// Save a match to its JSON file
  static Future<void> saveMatchToStorage(BadmintonMatchModel match) async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matchFile = File('${matchesDir.path}/${match.matchId}.json');
      
      final matchJson = json.encode(match.toJson());
      await matchFile.writeAsString(matchJson);
    } catch (e) {
      throw Exception('Failed to save match ${match.matchId}: $e');
    }
  }
  
  /// Load a single match by ID
  static Future<BadmintonMatchModel?> getMatchById(String matchId) async {
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
  
  /// Load all matches from storage
  static Future<List<BadmintonMatchModel>> getAllMatchesFromStorage() async {
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
            // Skip corrupted files
            continue;
          }
        }
      }
      
      return matches;
    } catch (e) {
      throw Exception('Failed to load matches: $e');
    }
  }
  
  /// Delete a match file
  static Future<void> deleteMatchFromStorage(String matchId) async {
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
  
  /// Check if a match exists
  static Future<bool> checkIfMatchExists(String matchId) async {
    try {
      final matchesDir = await _getMatchesDirectory();
      final matchFile = File('${matchesDir.path}/$matchId.json');
      return await matchFile.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get all match IDs
  static Future<List<String>> getAllMatchIdsFromStorage() async {
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
  
  /// Clear all matches (use with caution)
  static Future<void> deleteAllMatchesFromStorage() async {
    try {
      final matchesDir = await _getMatchesDirectory();
      
      if (await matchesDir.exists()) {
        await matchesDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear all matches: $e');
    }
  }
}