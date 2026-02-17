import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../../services/storage_service.dart';
import '../../controllers/app_controllers.dart';

class ResumeMatchController extends GetxController {
  // All matches loaded from storage
  final RxList<BadmintonMatchModel> allMatches = <BadmintonMatchModel>[].obs;
  
  // Filtered resumable matches (computed from allMatches)
  final RxList<BadmintonMatchModel> resumableMatches = <BadmintonMatchModel>[].obs;
  
  // Loading state indicator
  final RxBool isLoading = false.obs;
  
  // Error message for display
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎬 [ResumeMatch] Controller initialized');
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      print('\n📂 [ResumeMatch] ========== LOADING MATCHES ==========');
      final loadedMatches = await StorageService.getAllMatchesFromStorage();
      
      print('📊 [ResumeMatch] Loaded ${loadedMatches.length} total matches from storage');
      
      // Update all matches
      allMatches.value = loadedMatches;
      
      // Log each match
      for (final match in loadedMatches) {
        print('  📄 Match: ${match.matchId}');
        print('     Teams: ${match.team1.teamName} vs ${match.team2.teamName}');
        print('     Status: ${match.status.code}');
        print('     isCompleted: ${AppControllers.match.isMatchCompleted(match)}');
        print('     isInProgress: ${AppControllers.match.isMatchInProgress(match)}');
      }
      
      // Filter and update resumable matches
      _updateResumableMatches();
      
      print('========================================\n');
      
    } catch (e, stackTrace) {
      print('❌ [ResumeMatch] Failed to load: $e');
      print('Stack trace: $stackTrace');
      errorMessage.value = 'Failed to load matches';
      allMatches.clear();
      resumableMatches.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateResumableMatches() {
    print('🔍 [ResumeMatch] Filtering ${allMatches.length} matches...');
    
    final filtered = allMatches.where((match) {
      final isInProgress = match.status == BadmintonMatchStatus.inProgress;
      final isPaused = match.status == BadmintonMatchStatus.paused;
      final isResumable = isInProgress || isPaused;
      
      print('  🔎 ${match.matchId}:');
      print('     status = ${match.status.code}');
      print('     isInProgress = $isInProgress');
      print('     isPaused = $isPaused');
      print('     isResumable = $isResumable');
      
      return isResumable;
    }).toList();
    
    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Update observable list
    resumableMatches.value = filtered;
    
    print('✅ [ResumeMatch] Found ${filtered.length} resumable matches');
    if (filtered.isEmpty) {
      print('⚠️ [ResumeMatch] No resumable matches found!');
      print('   This means all matches are either completed or cancelled');
    }
  }
  
  Future<void> refreshMatches() async {
    print('🔄 [ResumeMatch] Manual refresh triggered...');
    await loadMatches();
  }
  
  // Legacy getter for backward compatibility
  List<BadmintonMatchModel> get resumeMatches => resumableMatches.value;
}
