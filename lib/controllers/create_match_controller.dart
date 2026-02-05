import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/match_rule_controller.dart';
import '../controllers/my_matches_list_controller.dart';
import '../models/badminton_models.dart';
import '../screens/matches_list_ui_screen.dart';
import '../screens/match_rule_ui_screen.dart';

class CreateMatchController extends GetxController {
  // Reactive variables for form state
  final Rx<BadmintonMatchType> selectedMatchType = BadmintonMatchType.singles.obs;
  final RxString team1Logo = '🏸'.obs;
  final RxString team2Logo = '⚡'.obs;
  final RxBool isCreating = false.obs;

  // Available team logos
  final List<String> availableLogos = [
    '🏸', '⚡', '🔥', '💪', '🚀', '⭐', '🎯', '🏆', 
    '💎', '🌟', '🦅', '🐅', '🦁', '🐺', '🔱', '⚔️'
  ];
  
  // Team name controllers
  final TextEditingController team1NameController = TextEditingController();
  final TextEditingController team2NameController = TextEditingController();
  
  // Player name controllers
  final RxList<TextEditingController> team1PlayerNameControllers = <TextEditingController>[].obs;
  final RxList<TextEditingController> team2PlayerNameControllers = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    team1PlayerNameControllers.add(TextEditingController());
    team2PlayerNameControllers.add(TextEditingController());
  }

  void updatePlayerNameControllers(int playersPerTeam) {
    // Clear existing controllers
    for (var controller in team1PlayerNameControllers) {
      controller.dispose();
    }
    for (var controller in team2PlayerNameControllers) {
      controller.dispose();
    }

    team1PlayerNameControllers.clear();
    team2PlayerNameControllers.clear();

    // Add new controllers
    for (int i = 0; i < playersPerTeam; i++) {
      team1PlayerNameControllers.add(TextEditingController());
      team2PlayerNameControllers.add(TextEditingController());
    }
  }

  Future<void> createMatch() async {
    final MatchController controller = Get.find<MatchController>();
    final MyMatchesController myMatchesController = Get.find<MyMatchesController>();
    
    // Validate team names
    final team1Name = team1NameController.text.trim();
    final team2Name = team2NameController.text.trim();
    
    if (team1Name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Team 1 name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    
    if (team2Name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter Team 2 name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    
    if (team1Name.toLowerCase() == team2Name.toLowerCase()) {
      Get.snackbar(
        'Error',
        'Team names must be different',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validate player names
    List<String> team1Players = [];

    for (var controller in team1PlayerNameControllers) {
      String name = controller.text.trim(); // text lo + space hatao
      if (name.isNotEmpty) {
        team1Players.add(name); 
      }
    }

    List<String> team2Players = [];

    for (var controller in team2PlayerNameControllers) {
      String name = controller.text.trim();
      if (name.isNotEmpty) {
        team2Players.add(name);
      }
    }

    final requiredPlayers = selectedMatchType.value.requiredPlayersPerTeam;

    if (team1Players.length != requiredPlayers) {
      Get.snackbar(
        'Error',
        'Please enter all player names for $team1Name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (team2Players.length != requiredPlayers) {
      Get.snackbar(
        'Error',
        'Please enter all player names for $team2Name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check for duplicate player names
    final allPlayers = [...team1Players, ...team2Players];
    if (allPlayers.length != allPlayers.toSet().length) {
      Get.snackbar(
        'Error',
        'Player names must be unique',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isCreating.value = true;
      
      // Create match with unique timestamp
      final now = DateTime.now();
      final matchId = now.millisecondsSinceEpoch.toString();
      
      // Create different timestamps for teams and players
      final team1Timestamp = now.add(Duration(milliseconds: 1)).millisecondsSinceEpoch;
      final team2Timestamp = now.add(Duration(milliseconds: 2)).millisecondsSinceEpoch;
      final playerBaseTimestamp = now.add(Duration(milliseconds: 3)).millisecondsSinceEpoch;
      
      // Create teams with players and team info
      final team1 = BadmintonTeamModel(
        teamId: 'team_$team1Timestamp',
        teamName: team1Name,
        teamLogo: team1Logo.value,
        players: team1Players.asMap().entries.map((entry) => 
          BadmintonPlayerModel(
            playerId: 'player_${playerBaseTimestamp + entry.key + 1}',
            name: entry.value,
          )
        ).toList(),
      );
      
      final team2 = BadmintonTeamModel(
        teamId: 'team_$team2Timestamp',
        teamName: team2Name,
        teamLogo: team2Logo.value,
        players: team2Players.asMap().entries.map((entry) => 
          BadmintonPlayerModel(
            playerId: 'player_${playerBaseTimestamp + entry.key + 10}',
            name: entry.value,
          )
        ).toList(),
      );
      
      // Determine match type based on number of players per team
      final actualMatchType = team1Players.length == 1 && team2Players.length == 1 
          ? BadmintonMatchType.singles 
          : BadmintonMatchType.doubles;
      
      // Create match without initializing first round yet
      final match = BadmintonMatchModel(
        matchId: matchId,
        matchType: actualMatchType,
        team1: team1,
        team2: team2,
        createdAt: DateTime.now(),
      );

      // Add match to controller first (without initializing first round)
      await myMatchesController.addMatch(match);
      
      // Show service selection dialog with team names and logos
      showServiceSelectionAndNavigate(controller, match, team1Name, team2Name, team1Logo.value, team2Logo.value);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create match. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isCreating.value = false;
    }
  }

  void showServiceSelectionAndNavigate(
    MatchController controller, 
    BadmintonMatchModel match, 
    String team1Name, 
    String team2Name,
    String team1Logo,
    String team2Logo,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('🏸 Who will serve first?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            
            // Team 1 Players Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(team1Logo, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        team1Name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team1.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back(); // Close dialog
                        initializeMatchAndNavigate(controller, match.matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.sports_tennis, size: 18),
                      label: Text(
                        player.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team 2 Players Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        team2Name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(team2Logo, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team2.players.map((player) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back(); // Close dialog
                        initializeMatchAndNavigate(controller, match.matchId, player.playerId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.sports_tennis, size: 18),
                      label: Text(
                        player.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Back to Home button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    // Close dialog first
                    Get.back();
                    
                    // Delete the created match since user cancelled
                    await Get.find<MyMatchesController>().deleteMatch(match.matchId);

                    // Navigate back to home screen, clearing the navigation stack
                    Get.offAll(() => const MatchesListScreen());
                    
                    // Show cancellation message
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Get.snackbar(
                        'Match Cancelled', 
                        'Match creation was cancelled',
                        backgroundColor: Colors.orange.shade100,
                        colorText: Colors.orange.shade700,
                        icon: Icon(Icons.cancel, color: Colors.orange.shade700),
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                      );
                    });
                  } catch (e) {
                    // If there's an error, still navigate back
                    Get.offAll(() => const MatchesListScreen());
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.home, size: 20),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> initializeMatchAndNavigate(MatchController controller, String matchId, String initialServer) async {
    try {
      // Initialize match with selected server
      await controller.initializeMatchWithService(matchId, initialServer);
      
      // Ensure the match is properly loaded in MyMatchesController
      final myMatchesController = Get.find<MyMatchesController>();
      
      // Wait for the match to be available in the controller
      int attempts = 0;
      while (attempts < 10) {
        final match = myMatchesController.getMatchById(matchId);
        if (match != null && match.rounds.isNotEmpty) {
          // Match is properly initialized, safe to navigate
          break;
        }
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }
      
      // Navigate to match detail screen, removing create match screen from stack
      Get.off(() => MatchDetailScreen(matchId: matchId));
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize match. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    team1NameController.dispose();
    team2NameController.dispose();
    for (var controller in team1PlayerNameControllers) {
      controller.dispose();
    }
    for (var controller in team2PlayerNameControllers) {
      controller.dispose();
    }
    super.onClose();
  }
}