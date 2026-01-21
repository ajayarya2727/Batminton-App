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
      
      // DEMO: Print JSON to console for sir's evaluation
      _printMatchJsonToConsole(match, matchFile.path, matchJson);
      
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
        print('');
        print('================================');
        print('MATCH NOT FOUND');
        print('================================');
        print('Match ID: $matchId');
        print('Status: No match found with this ID');
        print('================================');
        print('');
        return;
      }
      
      final matchesDir = await _getMatchesDirectory();
      final filePath = '${matchesDir.path}/$matchId.json';
      final jsonString = json.encode(match.toJson());
      
      _printMatchJsonToConsole(match, filePath, jsonString, isManualPrint: true);
      
    } catch (e) {
      print('');
      print('================================');
      print('ERROR LOADING MATCH');
      print('================================');
      print('Match ID: $matchId');
      print('Error: $e');
      print('================================');
      print('');
    }
  }
  // DEMO: Print match JSON to console for sir's evaluation
  static void _printMatchJsonToConsole(BadmintonMatchModel match, String filePath, String jsonString, {bool isManualPrint = false}) {
    try {
      // Convert JSON string to Map for pretty printing
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      // Create pretty formatted JSON with proper indentation
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final String prettyJson = encoder.convert(jsonMap);
      
      // Print formatted output for demo
      print('');
      print('================================');
      if (isManualPrint) {
        print('MATCH JSON RETRIEVED BY ID');
      } else {
        print('MATCH JSON SAVED');
      }
      print('================================');
      print('Match ID: ${match.matchId}');
      print('Match Type: ${match.matchType.displayName}');
      print('Status: ${match.status.displayName}');
      print('File Path: $filePath');
      print('JSON Content:');
      print(prettyJson);
      print('================================');
      print('');
      
    } catch (e) {
      // Fallback to simple print if pretty formatting fails
      print('');
      print('================================');
      if (isManualPrint) {
        print('MATCH JSON RETRIEVED BY ID');
      } else {
        print('MATCH JSON SAVED');
      }
      print('================================');
      print('Match ID: ${match.matchId}');
      print('File Path: $filePath');
      print('JSON Content: $jsonString');
      print('================================');
      print('');
    }
  }
}