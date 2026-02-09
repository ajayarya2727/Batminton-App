import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/badminton_models.dart';
import '../../services/storage_service.dart';

class MyMatchesController extends GetxController {
  final RxList<BadmintonMatchModel> matches = <BadmintonMatchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  // Get sorted matches (newest first)
  List<BadmintonMatchModel> LetestFirstSortedMatches() {
    final sortedList = List<BadmintonMatchModel>.from(matches);
    sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedList;
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
        final oldStoredData = await SharedPreferences.getInstance();
        final matchesJson = oldStoredData.getString('Batminton matches');
        
        if (matchesJson != null) {
          // Migrate old data to new storage format
          final List<dynamic> matchesList = json.decode(matchesJson);
          final oldMatches = matchesList.map((json) => BadmintonMatchModel.fromJson(json)).toList();
          
          // Save each match to individual files
          for (final match in oldMatches) {
            await StorageService.saveMatch(match);
          }
          
          // Clear old storage
          await oldStoredData.remove('Batminton matches');
          
          matches.value = oldMatches;
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load matches: $e';
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
      errorMessage.value = 'Failed to save matches: $e';
    }
  }

  // Add new match
  Future<void> addMatch(BadmintonMatchModel match) async {
    matches.add(match);
    await StorageService.saveMatch(match);
    successMessage.value = 'Match created successfully!';
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
      
      successMessage.value = 'Match deleted successfully!';
    } catch (e) {
      errorMessage.value = 'Failed to delete match';
    }
  }
}