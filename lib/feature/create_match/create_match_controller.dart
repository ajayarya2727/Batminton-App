import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
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
  final RxString createdMatchId = ''.obs;
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
    team1PlayerNameBox.add(TextEditingController());
    team2PlayerNameBox.add(TextEditingController());
  }

  void updatePlayerNameBox(int playersPerTeam) {
    for (var controller in team1PlayerNameBox) {
      controller.dispose();
    }
    for (var controller in team2PlayerNameBox) {
      controller.dispose();
    }

    team1PlayerNameBox.clear();
    team2PlayerNameBox.clear();

    for (int i = 0; i < playersPerTeam; i++) {
      team1PlayerNameBox.add(TextEditingController());
      team2PlayerNameBox.add(TextEditingController());
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
    
    if (team1Name.toLowerCase() == team2Name.toLowerCase()) {
      errorMessage.value = 'Team names must be different';
      return;
    }

    List<String> team1Players = [];
    for (var nameBox  in team1PlayerNameBox) {
      String name = nameBox .text.trim();
      if (name.isNotEmpty) {
        team1Players.add(name); 
      }
    }

    List<String> team2Players = [];
    for (var nameBox  in team2PlayerNameBox) {
      String name = nameBox .text.trim();
      if (name.isNotEmpty) {
        team2Players.add(name);
      }
    }

    final requiredPlayers = selectedMatchType.value.requiredPlayersPerTeam;

    if (team1Players.length != requiredPlayers) {
      errorMessage.value = 'Please enter all player names for ';
      return;
    }

    if (team2Players.length != requiredPlayers) {
      errorMessage.value = 'Please enter all player names for ';
      return;
    }

    // final allPlayers = [...team1Players, ...team2Players];
    // if (allPlayers.length != allPlayers.toSet().length) {
    //   errorMessage.value = 'Player names must be unique';
    //   return;
    // }

    try {
      isCreating.value = true;
      
      final now = DateTime.now();
      final matchId = now.millisecondsSinceEpoch.toString();
      final team1Timestamp = now.add(Duration(milliseconds: 1)).millisecondsSinceEpoch;
      final team2Timestamp = now.add(Duration(milliseconds: 2)).millisecondsSinceEpoch;
      final playerBaseTimestamp = now.add(Duration(milliseconds: 3)).millisecondsSinceEpoch;
      
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
      
      final actualMatchType = team1Players.length == 1 && team2Players.length == 1 
          ? BadmintonMatchType.singles 
          : BadmintonMatchType.doubles;
      
      final match = BadmintonMatchModel(
        matchId: matchId,
        matchType: actualMatchType,
        team1: team1,
        team2: team2,
        createdAt: DateTime.now(),
      );

      await Get.find<MyMatchesController>().addMatch(match);
      
      pendingMatch.value = match;
      showServiceDialog.value = true;
      
    } catch (e) {
      errorMessage.value = 'Failed to create match. Please try again.';
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> initializeMatchAndNavigate(String matchId, String initialServer) async {
    try {
      await Get.find<MatchController>().initializeMatchWithService(matchId, initialServer);
      
      final myMatchesController = Get.find<MyMatchesController>();
      int attempts = 0;
      while (attempts < 10) {
        final match = myMatchesController.getMatchById(matchId);
        if (match != null && match.rounds.isNotEmpty) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 50));
        attempts++;
      }
      
      createdMatchId.value = matchId;
      
    } catch (e) {
      errorMessage.value = 'Failed to initialize match. Please try again.';
    }
  }

  Future<void> cancelMatchCreation(String matchId) async {
    try {
      await Get.find<MyMatchesController>().deleteMatch(matchId);
      cancelledMatchId.value = matchId;
    } catch (e) {
      cancelledMatchId.value = matchId;
    }
  }
}
