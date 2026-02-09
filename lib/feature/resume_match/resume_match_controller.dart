import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../../services/storage_service.dart';

/// Resume Match Controller - Pure Business Logic Only
class ResumeMatchController extends GetxController {
  final RxList<BadmintonMatchModel> matches = <BadmintonMatchModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString successMessage = ''.obs;
  final RxString errorMessage = ''.obs;

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
      errorMessage.value = 'Failed to load matches: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Pause match
  Future<void> pauseMatch(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      if (match.status == BadmintonMatchStatus.inProgress) {
        matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.paused);
        await StorageService.saveMatch(matches[matchIndex]);
        successMessage.value = 'Match paused successfully';
      }
    }
  }

  // Resume match
  Future<void> resumeMatch(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      final match = matches[matchIndex];
      if (match.status == BadmintonMatchStatus.paused) {
        matches[matchIndex] = match.copyWith(status: BadmintonMatchStatus.inProgress);
        await StorageService.saveMatch(matches[matchIndex]);
        successMessage.value = 'Match resumed successfully';
      }
    }
  }

  // Complete match
  Future<void> completeMatch(String matchId) async {
    final matchIndex = matches.indexWhere((match) => match.matchId == matchId);
    if (matchIndex != -1) {
      matches[matchIndex] = matches[matchIndex].copyWith(status: BadmintonMatchStatus.completed);
      await StorageService.saveMatch(matches[matchIndex]);
      successMessage.value = 'Match completed successfully';
    }
  }

  // Get paused/incomplete matches
  List<BadmintonMatchModel> getPausedMatches() {
    return matches.where((match) => 
      !match.isCompleted || match.status == BadmintonMatchStatus.paused
    ).toList();
  }

  // Get sorted paused matches (newest first)
  List<BadmintonMatchModel> getSortedPausedMatches() {
    final pausedMatches = getPausedMatches();
    pausedMatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return pausedMatches;
  }
}