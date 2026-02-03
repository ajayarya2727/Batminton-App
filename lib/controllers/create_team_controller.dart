import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_screen_options/main_screen.dart';

class CreateTeamController extends GetxController {
  // Text controllers
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController player1NameController = TextEditingController();
  final TextEditingController player2NameController = TextEditingController();
  
  // Reactive variables
  final RxString selectedLogo = '🏸'.obs;
  final RxBool isCreating = false.obs;

  // Available logos
  final List<String> availableLogos = [
    '🏸', '⚡', '🔥', '💪', '🏆', '⭐', '🎯', '🚀', '💎', '👑'
  ];

  // Update selected logo
  void updateSelectedLogo(String logo) {
    selectedLogo.value = logo;
  }

  // Validate and create team
  Future<void> createTeam() async {
    // Validate inputs
    if (teamNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a team name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return;
    }

    if (player1NameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter at least one player name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return;
    }

    isCreating.value = true;

    try {
      // Simulate team creation process
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to home screen
      navigateToHome();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create team. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
    } finally {
      isCreating.value = false;
    }
  }

  // Navigate to home screen function
  void navigateToHome() {
    Get.off(() => const MainScreen());
  }

  @override
  void dispose() {
    // Dispose controllers
    teamNameController.dispose();
    player1NameController.dispose();
    player2NameController.dispose();
    super.onClose();
  }
}