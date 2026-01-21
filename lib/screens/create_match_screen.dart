import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/match_controller.dart';
import '../models/badminton_models.dart';

class CreateMatchScreen extends StatelessWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchController controller = Get.find<MatchController>();
    final Rx<BadmintonMatchType> selectedMatchType = BadmintonMatchType.singles.obs;
    final RxList<TextEditingController> team1Controllers = <TextEditingController>[].obs;
    final RxList<TextEditingController> team2Controllers = <TextEditingController>[].obs;

    // Initialize controllers
    team1Controllers.add(TextEditingController());
    team2Controllers.add(TextEditingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Match',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchTypeSelector(selectedMatchType, team1Controllers, team2Controllers),
            const SizedBox(height: 24),
            Obx(() => _buildTeamInputs(selectedMatchType.value, team1Controllers, team2Controllers)),
            const SizedBox(height: 32),
            _buildCreateButton(controller, selectedMatchType, team1Controllers, team2Controllers),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchTypeSelector(
    Rx<BadmintonMatchType> selectedMatchType,
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                RadioListTile<BadmintonMatchType>(
                  title: const Text('1v1'),
                  subtitle: const Text('Single player match'),
                  value: BadmintonMatchType.singles,
                  groupValue: selectedMatchType.value,
                  onChanged: (value) {
                    selectedMatchType.value = value!;
                    _updateControllers(team1Controllers, team2Controllers, 1);
                  },
                  activeColor: Colors.green.shade600,
                ),
                RadioListTile<BadmintonMatchType>(
                  title: const Text('2v2'),
                  subtitle: const Text('Double player match'),
                  value: BadmintonMatchType.doubles,
                  groupValue: selectedMatchType.value,
                  onChanged: (value) {
                    selectedMatchType.value = value!;
                    _updateControllers(team1Controllers, team2Controllers, 2);
                  },
                  activeColor: Colors.green.shade600,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInputs(
    BadmintonMatchType matchType,
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
  ) {
    final int playersPerTeam = matchType.requiredPlayersPerTeam;

    return Column(
      children: [
        _buildTeamCard('Team 1', team1Controllers, playersPerTeam),
        const SizedBox(height: 16),
        _buildTeamCard('Team 2', team2Controllers, playersPerTeam),
      ],
    );
  }

  Widget _buildTeamCard(
    String teamName,
    RxList<TextEditingController> controllers,
    int playersCount,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              teamName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(playersCount, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: controllers[index],
                  decoration: InputDecoration(
                    labelText: playersCount == 1 
                        ? 'Player Name' 
                        : 'Player ${index + 1} Name',
                    hintText: 'Enter player name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(
    MatchController controller,
    Rx<BadmintonMatchType> selectedMatchType,
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
  ) {
    final RxBool isCreating = false.obs;
    
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: isCreating.value ? null : () async {
          isCreating.value = true;
          await _createMatch(
            controller,
            selectedMatchType.value,
            team1Controllers,
            team2Controllers,
          );
          isCreating.value = false;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isCreating.value 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Creating Match...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : const Text(
              'Create Match',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      )),
    );
  }

  void _updateControllers(
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
    int playersPerTeam,
  ) {
    // Clear existing controllers
    for (var controller in team1Controllers) {
      controller.dispose();
    }
    for (var controller in team2Controllers) {
      controller.dispose();
    }

    team1Controllers.clear();
    team2Controllers.clear();

    // Add new controllers
    for (int i = 0; i < playersPerTeam; i++) {
      team1Controllers.add(TextEditingController());
      team2Controllers.add(TextEditingController());
    }
  }

  Future<void> _createMatch(
    MatchController controller,
    BadmintonMatchType matchType,
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
  ) async {
    // Validate input
    final team1Players = team1Controllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    
    final team2Players = team2Controllers
        .map((c) => c.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    final requiredPlayers = matchType.requiredPlayersPerTeam;

    if (team1Players.length != requiredPlayers) {
      Get.snackbar(
        'Error',
        'Please enter all player names for Team 1',
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
        'Please enter all player names for Team 2',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check for duplicate names
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
      // Show creating feedback
      Get.snackbar(
        'Creating Match',
        'Setting up your badminton match...',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Create match
      final matchId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create teams with players
      final team1 = BadmintonTeamModel(
        teamId: 'team1_$matchId',
        players: team1Players.asMap().entries.map((entry) => 
          BadmintonPlayerModel(
            playerId: 'p${entry.key + 1}_$matchId',
            name: entry.value,
          )
        ).toList(),
      );
      
      final team2 = BadmintonTeamModel(
        teamId: 'team2_$matchId',
        players: team2Players.asMap().entries.map((entry) => 
          BadmintonPlayerModel(
            playerId: 'p${entry.key + 3}_$matchId',
            name: entry.value,
          )
        ).toList(),
      );
      
      final match = BadmintonMatchModel(
        matchId: matchId,
        matchType: matchType,
        team1: team1,
        team2: team2,
        createdAt: DateTime.now(),
      ).initializeFirstRound();

      // Add small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      await controller.addMatch(match);
      
      // Success feedback
      Get.snackbar(
        'Success! 🏸',
        'Match created successfully! Ready to play.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Go back to previous screen
      Get.back();
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create match. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }
}