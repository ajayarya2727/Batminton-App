import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/match_controller.dart';
import '../models/badminton_models.dart';
import 'home_screen.dart';
import 'match_detail_screen.dart';

class CreateMatchScreen extends StatelessWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchController controller = Get.find<MatchController>();
    final Rx<BadmintonMatchType> selectedMatchType = BadmintonMatchType.singles.obs;
    
    // Team name controllers
    final TextEditingController team1NameController = TextEditingController();
    final TextEditingController team2NameController = TextEditingController();
    
    // Player name controllers
    final RxList<TextEditingController> team1Controllers = <TextEditingController>[].obs;
    final RxList<TextEditingController> team2Controllers = <TextEditingController>[].obs;
    
    // Team logo selection
    final RxString team1Logo = '🏸'.obs;
    final RxString team2Logo = '⚡'.obs;

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
            Obx(() => _buildTeamInputs(
              selectedMatchType.value, 
              team1NameController, 
              team2NameController,
              team1Controllers, 
              team2Controllers,
              team1Logo,
              team2Logo,
            )),
            const SizedBox(height: 32),
            _buildCreateButton(
              controller, 
              selectedMatchType, 
              team1NameController,
              team2NameController,
              team1Controllers, 
              team2Controllers,
              team1Logo,
              team2Logo,
            ),
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
    TextEditingController team1NameController,
    TextEditingController team2NameController,
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
    RxString team1Logo,
    RxString team2Logo,
  ) {
    final int playersPerTeam = matchType.requiredPlayersPerTeam;

    return Column(
      children: [
        _buildTeamCard('Team 1', team1NameController, team1Controllers, playersPerTeam, team1Logo, Colors.blue),
        const SizedBox(height: 16),
        _buildTeamCard('Team 2', team2NameController, team2Controllers, playersPerTeam, team2Logo, Colors.green),
      ],
    );
  }

  Widget _buildTeamCard(
    String teamName,
    TextEditingController teamNameController,
    RxList<TextEditingController> controllers,
    int playersCount,
    RxString teamLogo,
    MaterialColor teamColor,
  ) {
    // Available team logos
    final List<String> availableLogos = [
      '🏸', '⚡', '🔥', '💪', '🚀', '⭐', '🎯', '🏆', 
      '💎', '🌟', '🦅', '🐅', '🦁', '🐺', '🔱', '⚔️'
    ];

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
            // Team Header with Logo
            Row(
              children: [
                Obx(() => Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: teamColor.shade100,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: teamColor.shade300, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      teamLogo.value,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    teamName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: teamColor.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Team Name Input
            TextFormField(
              controller: teamNameController,
              decoration: InputDecoration(
                labelText: 'Team Name',
                hintText: 'Enter team name (e.g., Thunder Bolts)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: teamColor.shade600),
                ),
                prefixIcon: Icon(Icons.group, color: teamColor.shade600),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            // Logo Selection
            const Text(
              'Choose Team Logo:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableLogos.length,
                itemBuilder: (context, index) {
                  final logo = availableLogos[index];
                  return Obx(() => GestureDetector(
                    onTap: () => teamLogo.value = logo,
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: teamLogo.value == logo 
                            ? teamColor.shade200 
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: teamLogo.value == logo 
                              ? teamColor.shade600 
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          logo,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ));
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Player Name Inputs
            const Text(
              'Player Names:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
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
                      borderSide: BorderSide(color: teamColor.shade600),
                    ),
                    prefixIcon: Icon(Icons.person, color: teamColor.shade600),
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
    TextEditingController team1NameController,
    TextEditingController team2NameController,
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
    RxString team1Logo,
    RxString team2Logo,
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
            team1NameController,
            team2NameController,
            team1Controllers,
            team2Controllers,
            team1Logo.value,
            team2Logo.value,
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
    TextEditingController team1NameController,
    TextEditingController team2NameController,
    RxList<TextEditingController> team1Controllers,
    RxList<TextEditingController> team2Controllers,
    String team1Logo,
    String team2Logo,
  ) async {
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
        teamLogo: team1Logo,
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
        teamLogo: team2Logo,
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
      
      final match = BadmintonMatchModel(
        matchId: matchId,
        matchType: actualMatchType,
        team1: team1,
        team2: team2,
        createdAt: DateTime.now(),
      );

      // Initialize first round with empty player scores for JSON
      final initializedMatch = match.initializeFirstRound();

      // Add match to controller first
      await controller.addMatch(initializedMatch);
      
      // Show service selection dialog with team names and logos
      _showServiceSelectionAndNavigate(controller, initializedMatch, team1Name, team2Name, team1Logo, team2Logo);
      
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

  void _showServiceSelectionAndNavigate(
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
            // const Text(
            //   'Select which team will serve first in Round 1:',
            //   style: TextStyle(fontSize: 16),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 20),
            // Team 1 option
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  _initializeMatchAndNavigate(controller, match.matchId, match.team1.players.first.playerId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      team1Logo,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      team1Name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Team 2 option
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  _initializeMatchAndNavigate(controller, match.matchId, match.team2.players.first.playerId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      team2Logo,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      team2Name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Back to Home button
            Container(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  try {
                    // Close dialog first
                    Get.back();
                    
                    // Delete the created match since user cancelled
                    await controller.deleteMatch(match.matchId);
                    
                    // Navigate back to home screen, clearing the navigation stack
                    Get.offAll(() => const HomeScreen());
                    
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
                    Get.offAll(() => const HomeScreen());
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

  Future<void> _initializeMatchAndNavigate(MatchController controller, String matchId, String initialServer) async {
    try {
      // Initialize match with selected server
      await controller.initializeMatchWithService(matchId, initialServer);
      
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
}