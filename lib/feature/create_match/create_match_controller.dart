import 'package:batminton_app/controllers/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../match_rule/match_rule_ui_screen.dart';
import '../../models/badminton_models.dart';

class CreateMatchController extends GetxController {
  final Rx<BadmintonMatchType> selectedMatchType = BadmintonMatchType.singles.obs;
  final RxString team1Logo = '🏸'.obs;
  final RxString team2Logo = '⚡'.obs;
  final RxBool isCreating = false.obs;
  
  // State variables for UI
  final RxString errorMessage = ''.obs;
  final RxBool showServiceDialog = false.obs;
  final Rx<BadmintonMatchModel?> pendingMatch = Rx<BadmintonMatchModel?>(null);
  final RxString createdMatchAndNavigate = ''.obs;
  final RxString cancelledMatchId = ''.obs;

  final List<String> availableLogos = [
    '🏸', '⚡', '🔥', '💪', '🚀', '⭐', '🎯', '🏆', 
    '💎', '🌟', '🦅', '🐅', '🦁', '🐺', '🔱', '⚔️'
  ];
  
  final TextEditingController team1NameController = TextEditingController();
  final TextEditingController team2NameController = TextEditingController();
  final RxList<TextEditingController> team1PlayerNameBox = <TextEditingController>[].obs;
  final RxList<TextEditingController> team2PlayerNameBox = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    print('🎬 [CreateMatch] Controller initialized');
    
    // Initialize player name boxes
    team1PlayerNameBox.add(TextEditingController());
    team2PlayerNameBox.add(TextEditingController());
    
    // ✅ CORRECT: Setup listeners in onInit (NOT in build method)
    _setupListeners();
  }

  void _setupListeners() {
    print('🎧 [CreateMatch] Setting up listeners...');
    
    // Error message listener
    ever(errorMessage, (String message) {
      if (message.isNotEmpty) {
        print('❌ [CreateMatch] Error: $message');
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade700,
          icon: Icon(Icons.error, color: Colors.red.shade700),
        );
        errorMessage.value = '';
      }
    });

    // Service dialog listener
    ever(showServiceDialog, (bool show) {
      if (show && pendingMatch.value != null) {
        print('🎯 [CreateMatch] Showing service dialog');
        _showServiceSelectionDialog(pendingMatch.value!);
        showServiceDialog.value = false;
      }
    });

    // Match cancellation listener
    ever(cancelledMatchId, (String matchId) {
      if (matchId.isNotEmpty) {
        print('🗑️ [CreateMatch] Match cancelled: $matchId');
        Get.back();
        _resetForm();
        cancelledMatchId.value = '';
      }
    });

    // Match creation and navigation listener
    ever(createdMatchAndNavigate, (String matchId) {
      if (matchId.isNotEmpty) {
        print('✅ [CreateMatch] Navigating to match: $matchId');
        Get.off(() => MatchDetailScreen(matchId: matchId));
        _resetForm();
        createdMatchAndNavigate.value = '';
      }
    });
    
    print('✅ [CreateMatch] Listeners setup complete');
  }

  void _showServiceSelectionDialog(BadmintonMatchModel match) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Text('🏸 ', style: TextStyle(fontSize: 24)),
            const Text('Select First Server'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Team 1 Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(match.team1.teamLogo, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          match.team1.teamName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...match.team1.players.map((player) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              initializeMatchAndNavigate(match.matchId, player.playerId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              player.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Team 2 Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(match.team2.teamLogo, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          match.team2.teamName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...match.team2.players.map((player) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              initializeMatchAndNavigate(match.matchId, player.playerId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              player.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.back();
              cancelMatchCreation(match.matchId);
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel Match Creation'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _resetForm() {
    print('🔄 [CreateMatch] Resetting form...');
    
    // Reset match type to singles
    selectedMatchType.value = BadmintonMatchType.singles;
    
    // Reset logos
    team1Logo.value = '🏸';
    team2Logo.value = '⚡';
    
    // Clear text controllers
    team1NameController.clear();
    team2NameController.clear();
    
    // Clear player name controllers
    for (final controller in team1PlayerNameBox) {
      controller.clear();
    }
    for (final controller in team2PlayerNameBox) {
      controller.clear();
    }
    
    // Reset to 1 player per team
    updatePlayerNameBox(1);
    
    // Clear states
    isCreating.value = false;
    errorMessage.value = '';
    pendingMatch.value = null;
    
    print('✅ [CreateMatch] Form reset complete');
  }

  void updatePlayerNameBox(int playersPerTeam) {
    if (team1PlayerNameBox.length == playersPerTeam) {
      return;
    }

    if (team1PlayerNameBox.length < playersPerTeam) {
      int createMoreInputBox = playersPerTeam - team1PlayerNameBox.length;
      for (int i = 0; i < createMoreInputBox; i++) {
        team1PlayerNameBox.add(TextEditingController());
        team2PlayerNameBox.add(TextEditingController());
      }
      return;
    }

    if (team1PlayerNameBox.length > playersPerTeam) {
      int removeExtraInputBox = team1PlayerNameBox.length - playersPerTeam;
      for (int i = 0; i < removeExtraInputBox; i++) {
        team1PlayerNameBox.last.dispose();
        team1PlayerNameBox.removeLast();
        team2PlayerNameBox.last.dispose();
        team2PlayerNameBox.removeLast();
      }
    }
  }

  Future<void> createMatch() async {
    print('\n🎯 [CreateMatch] ========== STARTING MATCH CREATION ==========');
    
    final team1Name = team1NameController.text.trim();
    final team2Name = team2NameController.text.trim();
    
    if (team1Name.isEmpty) {
      errorMessage.value = 'Please enter Team 1 name';
      return;
    }
    
    if (team2Name.isEmpty) {
      errorMessage.value = 'Please enter Team 2 name';
      return;
    }

    final requiredPlayers = selectedMatchType.value.requiredPlayersPerTeam;
    
    List<String> team1Players = [];
    for (int i = 0; i < team1PlayerNameBox.length; i++) {
      String name = team1PlayerNameBox[i].text.trim();
      if (name.isNotEmpty) {
        team1Players.add(name);
      }
    }

    List<String> team2Players = [];
    for (int i = 0; i < team2PlayerNameBox.length; i++) {
      String name = team2PlayerNameBox[i].text.trim();
      if (name.isNotEmpty) {
        team2Players.add(name);
      }
    }

    if (team1Players.length != requiredPlayers) {
      errorMessage.value = 'Please enter all player names for Team 1';
      return;
    }

    if (team2Players.length != requiredPlayers) {
      errorMessage.value = 'Please enter all player names for Team 2';
      return;
    }

    try {
      isCreating.value = true;
      
      // Generate UNIQUE IDs using timestamp + random component
      final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
      final randomComponent = DateTime.now().microsecondsSinceEpoch % 1000;
      final matchId = '${baseTimestamp}_$randomComponent';
      final team1Id = baseTimestamp;
      final team2Id = baseTimestamp + 1;
      
      print('📝 [CreateMatch] Match ID: $matchId');
      print('📝 [CreateMatch] Type: ${selectedMatchType.value.displayName}');
      print('📝 [CreateMatch] Team 1: $team1Name (${team1Players.join(", ")})');
      print('📝 [CreateMatch] Team 2: $team2Name (${team2Players.join(", ")})');
      
      List<BadmintonPlayerModel> team1PlayersList = [];
      for (int i = 0; i < team1Players.length; i++) {
        final playerId = '${matchId}_team1_player$i';
        team1PlayersList.add(
          BadmintonPlayerModel(
            playerId: playerId,
            name: team1Players[i],
          )
        );
      }
      
      final team1 = BadmintonTeamModel(
        teamId: 'team_$team1Id',
        teamName: team1Name,
        teamLogo: team1Logo.value,
        players: team1PlayersList,
      );
      
      List<BadmintonPlayerModel> team2PlayersList = [];
      for (int i = 0; i < team2Players.length; i++) {
        final playerId = '${matchId}_team2_player$i';
        team2PlayersList.add(
          BadmintonPlayerModel(
            playerId: playerId,
            name: team2Players[i],
          )
        );
      }
      
      final team2 = BadmintonTeamModel(
        teamId: 'team_$team2Id',
        teamName: team2Name,
        teamLogo: team2Logo.value,
        players: team2PlayersList,
      );
      
      // Create match with default status = inProgress
      final match = BadmintonMatchModel(
        matchId: matchId,
        matchType: selectedMatchType.value,
        team1: team1,
        team2: team2,
        createdAt: DateTime.now(),
      );

      print('💾 [CreateMatch] Saving match to storage...');
      await AppControllers.myMatches.addMatch(match);
      print('✅ [CreateMatch] Match saved successfully');

      pendingMatch.value = match;
      showServiceDialog.value = true;
      
      print('🎯 [CreateMatch] ========== MATCH CREATION COMPLETE ==========\n');
      
    } catch (e, stackTrace) {
      print('❌ [CreateMatch] CRITICAL ERROR: $e');
      print('Stack trace: $stackTrace');
      errorMessage.value = 'Failed to create match. Please try again.';
    } finally {
      isCreating.value = false;
    }
  }
           
  Future<void> initializeMatchAndNavigate(String matchId, String initialServer) async {
    try {
      print('🎯 [CreateMatch] Initializing match: $matchId with server: $initialServer');
      
      await AppControllers.match.initializeMatchWithService(matchId, initialServer);
      
      print('✅ [CreateMatch] Match initialized successfully');
      
      createdMatchAndNavigate.value = matchId;
      
    } catch (e, stackTrace) {
      print('❌ [CreateMatch] Initialization error: $e');
      print('Stack trace: $stackTrace');
      errorMessage.value = 'Failed to initialize match. Please try again.';
    }
  }

  Future<void> cancelMatchCreation(String matchId) async {
    try {
      print('🗑️ [CreateMatch] Cancelling match: $matchId');
      await AppControllers.myMatches.deleteMatch(matchId);
      cancelledMatchId.value = matchId;
    } catch (e) {
      print('❌ [CreateMatch] Cancel error: $e');
      cancelledMatchId.value = matchId;
    }
  }

  @override
  void onClose() {
    print('🛑 [CreateMatch] Controller closing...');
    team1NameController.dispose();
    team2NameController.dispose();
    for (final controller in team1PlayerNameBox) {
      controller.dispose();
    }
    for (final controller in team2PlayerNameBox) {
      controller.dispose();
    }
    super.onClose();
  }
}
