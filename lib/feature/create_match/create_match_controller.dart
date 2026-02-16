import 'package:batminton_app/controllers/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../match_rule/match_rule_ui_screen.dart';
import '../match_rule/match_rule_controller.dart';
import '../matches_list/my_matches_list_controller.dart';
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
  final RxString CreatedMatchAndNevigate = ''.obs;
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
    super.onInit(); // Initialize player name boxes
    team1PlayerNameBox.add(TextEditingController());
    team2PlayerNameBox.add(TextEditingController());
  }

  void updatePlayerNameBox(int playersPerTeam) {
    // If already correct number of boxes, do nothing
    if (team1PlayerNameBox.length == playersPerTeam) {
      return;
    }

    // If need more boxes, add them
    if (team1PlayerNameBox.length < playersPerTeam) {
      int CreateMoreInputBox = playersPerTeam - team1PlayerNameBox.length;
      for (int i = 0; i < CreateMoreInputBox; i++) {
        team1PlayerNameBox.add(TextEditingController());
        team2PlayerNameBox.add(TextEditingController());
      }
      return;
    }

    // If need less boxes, remove extra ones
    if (team1PlayerNameBox.length > playersPerTeam) {
      int RemoveExtraInputBox = team1PlayerNameBox.length - playersPerTeam;
      for (int i = 0; i < RemoveExtraInputBox ; i++) {
        team1PlayerNameBox.last.dispose();
        team1PlayerNameBox.removeLast();
        team2PlayerNameBox.last.dispose();
        team2PlayerNameBox.removeLast();
      }
    }
  }

  Future<void> createMatch() async {
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
    
    // Get player names from Team 1 (loop will run requiredPlayers times)
    List<String> team1Players = [];
    for (int i = 0; i < team1PlayerNameBox.length; i++) {
      String name = team1PlayerNameBox[i].text.trim();
      if (name.isNotEmpty) {
        team1Players.add(name);
      }
    }

    // Get player names from Team 2 (loop will run requiredPlayers times)
    List<String> team2Players = [];
    for (int i = 0; i < team2PlayerNameBox.length; i++) {
      String name = team2PlayerNameBox[i].text.trim();//i = index for name
      if (name.isNotEmpty) {
        team2Players.add(name);
      }
    }

    if (team1Players.length != requiredPlayers) {
      errorMessage.value = 'Please enter all player name for Team 1';
      return;
    }

    if (team2Players.length != requiredPlayers) {
      errorMessage.value = 'Please enter all player name for Team 2';
      return;
    }

    try {
      isCreating.value = true;
    

      // Generate unique IDs using current timestamp
      final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
      final matchId = baseTimestamp.toString();
      final team1Id = baseTimestamp;
      final team2Id = baseTimestamp + 1;
      
      // Create Team 1 players list with unique timestamp IDs
      List<BadmintonPlayerModel> team1PlayersList = [];
      for (int i = 0; i < team1Players.length; i++) {
        final playerId = '${baseTimestamp}_team1_player${i}'; // Unique ID with counter
        team1PlayersList.add(
          BadmintonPlayerModel(//player object
            playerId: playerId,
            name: team1Players[i],
          )
        );
      }
      //team object
      final team1 = BadmintonTeamModel(
        teamId: 'team_$team1Id',
        teamName: team1Name,
        teamLogo: team1Logo.value,
        players: team1PlayersList,
      );
      
      // Create Team 2 players list with unique timestamp IDs
      List<BadmintonPlayerModel> team2PlayersList = [];
      for (int i = 0; i < team2Players.length; i++) {
        final playerId = '${baseTimestamp}_team2_player${i}'; // Unique ID with counter
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
      
      // Create Match with user's selected match type
      final match = BadmintonMatchModel(
        matchId: matchId,
        matchType: selectedMatchType.value,
        team1: team1,
        team2: team2,
        createdAt: DateTime.now(),
      );


      await AppControllers.myMatches.addMatch(match);

      pendingMatch.value = match;
      showServiceDialog.value = true;
      
    } catch (e) {
      errorMessage.value = 'Failed to create match. Please try again.';
    } finally {
      isCreating.value = false;
    }
  }
           

  // Start match with selected server
  Future<void> initializeMatchAndNavigate(String matchId, String initialServer) async {
    try {
      // Initialize match with first server
      await AppControllers.match.initializeMatchWithService(matchId, initialServer);
      
      // Match is ready, navigate to match screen
      CreatedMatchAndNevigate.value = matchId;
      
    } catch (e) {
      errorMessage.value = 'Failed to initialize match. Please try again.';
    }
  }


  Future<void> cancelMatchCreation(String matchId) async {
    try {
      await AppControllers.myMatches.deleteMatch(matchId);
      cancelledMatchId.value = matchId;
    } catch (e) {
      cancelledMatchId.value = matchId;
    }
  }
}