import 'package:batminton_app/models/badminton_models.dart';
import 'app_controllers.dart';

class ResetFunctions {
  /// Reset CreateMatchController to initial state
  static void resetCreateMatch() {
    final controller = AppControllers.createMatch;
    
    // Reset match type to singles (default)
    controller.selectedMatchType.value = BadmintonMatchType.singles;
    
    // Reset logos to default
    controller.team1Logo.value = '🏸';
    controller.team2Logo.value = '⚡';
    
    // Reset loading state
    controller.isCreating.value = false;
    
    // Clear error messages
    controller.errorMessage.value = '';
    
    // Reset dialog states
    controller.showServiceDialog.value = false;
    controller.pendingMatch.value = null;
    controller.createdMatchAndNavigate.value = '';
    controller.cancelledMatchId.value = '';
    
    // Clear text controllers
    controller.team1NameController.clear();
    controller.team2NameController.clear();
    
    // Clear player name controllers
    for (final textController in controller.team1PlayerNameBox) {
      textController.clear();
    }
    for (final textController in controller.team2PlayerNameBox) {
      textController.clear();
    }
    
    // Reset player name boxes to default (1 player for singles)
    controller.updatePlayerNameBox(1);
  }
  
  /// Reset MatchController dialog states
  static void resetMatchDialogs() {
    final controller = AppControllers.match;
    
    controller.showManualServiceDialog.value = false;
    controller.showContinueDialog.value = false;
    controller.showRoundCompleteDialog.value = false;
    controller.showNextRoundServiceDialog.value = false;
    controller.showMatchCompleteDialog.value = false;
    controller.pendingMatch.value = null;
  }
  
  /// Reset all controllers at once
  static void resetAll() {
    resetCreateMatch();
    resetMatchDialogs();
    // resetResumeMatch();


  }
}
