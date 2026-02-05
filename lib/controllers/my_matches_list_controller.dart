import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/badminton_models.dart';
import '../services/storage_service.dart';

class MyMatchesController extends GetxController {
  final RxList<BadmintonMatchModel> matches = <BadmintonMatchModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  // Load matches from json file
  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      
      // load from new JSON file storage first
      final loadedMatches = await StorageService.loadAllMatches();
      
      if (loadedMatches.isNotEmpty) {
        matches.value = loadedMatches;
      } else {
        // Check if we have old SharedPreferences data to migrate
        final oldStorageData = await SharedPreferences.getInstance();
        final matchesJson = oldStorageData.getString('Batminton matches');
        
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
          await oldStorageData.remove('Batminton matches');
          
          matches.value = oldMatches;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load matches: $e');
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
      Get.snackbar('Error', 'Failed to save matches: $e');
    }
  }

  // Add new match
  Future<void> addMatch(BadmintonMatchModel match) async {
    matches.add(match);
    await StorageService.saveMatch(match);
    Get.snackbar('Success', 'Match created successfully!');
  }

  // Get match by ID
  BadmintonMatchModel? getMatchById(String id) {
    try {
      return matches.firstWhere((match) => match.matchId == id);
    } catch (e) {
      return null;
    }
  }

  // Update match in the list (for when match data changes)
  void updateMatch(BadmintonMatchModel updatedMatch) {
    final index = matches.indexWhere((match) => match.matchId == updatedMatch.matchId);
    if (index != -1) {
      matches[index] = updatedMatch;
    }
  }

  // Delete match
  Future<void> deleteMatch(String matchId) async {
    try {
      // Remove from list
      matches.removeWhere((match) => match.matchId == matchId);
      
      // Delete from storage
      await StorageService.deleteMatch(matchId);
      
      Get.snackbar('Success', 'Match deleted successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete match: $e');
    }
  }

  // DEMO/DEBUG METHODS for JSON operations
  Future<void> printMatchJsonById(String matchId) async {
    await StorageService.printMatchById(matchId);
  }

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

  // Get matches by status
  List<BadmintonMatchModel> getMatchesByStatus(BadmintonMatchStatus status) {
    return matches.where((match) => match.status == status).toList();
  }

  // Get completed matches
  List<BadmintonMatchModel> getCompletedMatches() {
    return matches.where((match) => match.isCompleted).toList();
  }

  // Get in-progress matches
  List<BadmintonMatchModel> getInProgressMatches() {
    return matches.where((match) => !match.isCompleted && match.status == BadmintonMatchStatus.inProgress).toList();
  }

  // Get paused matches
  List<BadmintonMatchModel> getPausedMatches() {
    return matches.where((match) => match.status == BadmintonMatchStatus.paused).toList();
  }
}