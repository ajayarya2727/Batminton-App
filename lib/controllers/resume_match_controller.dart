import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/badminton_models.dart';
import '../services/storage_service.dart';

class ResumeMatchController extends GetxController {
  final RxList<BadmintonMatchModel> matches = <BadmintonMatchModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  // Load matches from storage
  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      final loadedMatches = await StorageService.loadAllMatches();
      matches.value = loadedMatches;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load matches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Get match by ID
  // BadmintonMatchModel? getMatchById(String id) {
  //   try {
  //     return matches.firstWhere((match) => match.matchId == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // PAUSE/RESUME/COMPLETE functionality
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

  // Complete match
  Future<void> completeMatch(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      matches[matchIndex] = matches[matchIndex].copyWith(status: BadmintonMatchStatus.completed);
      await StorageService.saveMatch(matches[matchIndex]);
      Get.snackbar('Match Completed', 'Match has been marked as completed!');
    }
  }

  // Delete match
  // Future<void> deleteMatch(String matchId) async {
  //   matches.removeWhere((match) => match.matchId == matchId);
  //   await StorageService.deleteMatch(matchId);
  //   // Get.snackbar('Deleted', 'Match deleted successfully!');
  // }

  // Get paused/incomplete matches for resume screen
  List<BadmintonMatchModel> showPausedMatchesInList() {
    return matches.where((match) => 
      !match.isCompleted || match.status == BadmintonMatchStatus.paused
    ).toList();
  }

  // Get matches by type
  // List<BadmintonMatchModel> getMatchesByType(String type) {
  //   return matches.where((match) => match.matchType.code == type).toList();
  // }

  // // Clear all matches
  // void clearAllMatches() async {
  //   matches.clear();
  //   await StorageService.clearAllMatches();
  // }
}