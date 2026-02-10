import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_match_controller.dart';
import '../match_rule/match_rule_controller.dart';
import '../match_rule/match_rule_ui_screen.dart';
import '../matches_list/my_matches_list_controller.dart';
import '../../models/badminton_models.dart';

class CreateMatchScreen extends StatelessWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateMatchController controller = Get.put(CreateMatchController());
    // Get.put(MatchController());
    // Get.put(MyMatchesController());

    // Setup observers for error messages
    ever(controller.errorMessage, (String message) {
      if (message.isNotEmpty) {
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade700,
          icon: Icon(Icons.error, color: Colors.red.shade700),
        );
        controller.errorMessage.value = '';
      }
    });

    // Setup observer for service dialog
    ever(controller.showServiceDialog, (bool show) {
      if (show && controller.pendingMatch.value != null) {
        _showServiceSelectionDialog(context, controller, controller.pendingMatch.value!);
        controller.showServiceDialog.value = false;
      }
    });

    // Setup observer for match cancellation
    ever(controller.cancelledMatchId, (String matchId) {
      if (matchId.isNotEmpty) {
        Get.back();
        controller.cancelledMatchId.value = '';
      }
    });

    // Setup observer for successful match creation and navigation
    ever(controller.createdMatchId, (String matchId) {
      if (matchId.isNotEmpty) {
        // Navigate to match detail screen
        Get.off(() => MatchDetailScreen(matchId: matchId));
        controller.createdMatchId.value = '';
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Match',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        // elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchTypeSelector(controller, context),
            const SizedBox(height: 24),
            Obx(() => _buildTeamInputs(controller, context)),
            const SizedBox(height: 32),
            _buildCreateButton(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchTypeSelector(
    CreateMatchController controller,
    BuildContext context,
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
                  groupValue: controller.selectedMatchType.value,
                  onChanged: (value) {
                    controller.selectedMatchType.value = value!;
                    controller.updatePlayerNameBox(1);
                  },
                  activeColor: Colors.green.shade600,
                ),
                RadioListTile<BadmintonMatchType>(
                  title: const Text('2v2'),
                  subtitle: const Text('Double player match'),
                  value: BadmintonMatchType.doubles,
                  groupValue: controller.selectedMatchType.value,
                  onChanged: (value) {
                    controller.selectedMatchType.value = value!;
                    controller.updatePlayerNameBox(2);
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
    CreateMatchController controller,
    BuildContext context,
  ) {
    final int playersPerTeam = controller.selectedMatchType.value.requiredPlayersPerTeam;

    return Column(
      children: [
        _buildTeamCard('Team 1', controller.team1NameController, controller.team1PlayerNameBox, playersPerTeam, controller.team1Logo, Colors.blue, controller.availableLogos, context),
        const SizedBox(height: 16),
        _buildTeamCard('Team 2', controller.team2NameController, controller.team2PlayerNameBox, playersPerTeam, controller.team2Logo, Colors.green, controller.availableLogos, context),
      ],
    );
  }

  Widget _buildTeamCard(
    String teamNamelabel,
    TextEditingController teamNameController,
    RxList<TextEditingController> playerNameControllers,
    int playersCount,
    RxString teamLogo,
    MaterialColor teamColor,
    List<String> availableLogos,
    BuildContext context,
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
                    teamNamelabel,
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
                // prefixIcon: Icon(Icons.group, color: teamColor.shade600),
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
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableLogos.length,
                itemBuilder: (context, index) {
                  final logo = availableLogos[index];
                  return Obx(() => GestureDetector( //anything tapable
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
            Column(
              children: List.generate(playersCount, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: playerNameControllers[index],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton(
    CreateMatchController controller,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isCreating.value ? null : () async {
          await controller.createMatch();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: controller.isCreating.value 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
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

  // Service selection dialog
  static void _showServiceSelectionDialog(
    BuildContext context,
    CreateMatchController controller,
    BadmintonMatchModel match,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🏸 Who will serve first?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              
              // Team 1 Players
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
                        Text(match.team1.teamLogo, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          match.team1.teamName.isNotEmpty ? match.team1.teamName : "Team 1",
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
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          controller.initializeMatchAndNavigate(match.matchId, player.playerId);
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
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Team 2 Players
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
                          match.team2.teamName.isNotEmpty ? match.team2.teamName : "Team 2",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(match.team2.teamLogo, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...match.team2.players.map((player) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          controller.initializeMatchAndNavigate(match.matchId, player.playerId);
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
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    controller.cancelMatchCreation(match.matchId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.cancel, size: 20),
                  label: const Text(
                    'Cancel Match Creation',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
