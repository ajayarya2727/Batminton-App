import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CreateTeamController extends GetxController {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController player1NameController = TextEditingController();
  final TextEditingController player2NameController = TextEditingController();
  
  final RxString selectedLogo = '🏸'.obs;
  final RxBool isCreating = false.obs;
  
  // State variables for UI
  final RxString errorMessage = ''.obs;
  final RxBool teamCreated = false.obs;

  final List<String> availableLogos = [
    '🏸', '⚡', '🔥', '💪', '🏆', '⭐', '🎯', '🚀', '💎', '👑'
  ];

  void updateSelectedLogo(String logo) {
    selectedLogo.value = logo;
  }

  Future<void> createTeam() async {
    if (teamNameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a team name';
      return;
    }

    if (player1NameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter at least one player name';
      return;
    }

    isCreating.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      teamCreated.value = true;
      
    } catch (e) {
      errorMessage.value = 'Failed to create team. Please try again.';
    } finally {
      isCreating.value = false;
    }
  }

  @override
  void onClose() {
    teamNameController.dispose();
    player1NameController.dispose();
    player2NameController.dispose();
    super.onClose();
  }
}
