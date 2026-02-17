import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../../services/storage_service.dart';

class ResumeMatchController extends GetxController {
  final RxList<BadmintonMatchModel> _allMatches = <BadmintonMatchModel>[].obs;
  
  // Loading state indicator
  final RxBool isLoading = false.obs;
  
  // Error message for display
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMatches();
  }

  Future<void> loadMatches() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; //rerror message clear
      
      final loadedMatches = await StorageService.getAllMatchesFromStorage();
      _allMatches.value = loadedMatches;
    } catch (e) {
      errorMessage.value = 'Failed to load matches';
      _allMatches.clear();
    } finally {
      isLoading.value = false;
    }
  }

  List<BadmintonMatchModel> get resumeMatches {
    final matches = _allMatches;

    final filteredMatches = matches.where((match) => 
      !match.isCompleted || match.status == BadmintonMatchStatus.paused
    ).toList();
   
    filteredMatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filteredMatches;
  }
  Future<void> refreshMatches() => loadMatches();
}