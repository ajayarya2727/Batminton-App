import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../../controllers/app_controllers.dart';

class CreateMatchScreen extends StatelessWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ CORRECT: No listeners in build() method
    // All listeners are in controller's onInit()
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Match',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchTypeSelector(context),
            const SizedBox(height: 24),
            Obx(() => _buildTeamInputs(context)),
            const SizedBox(height: 32),
            _buildCreateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchTypeSelector(
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
                  groupValue: AppControllers.createMatch.selectedMatchType.value,
                  onChanged: (value) {
                    AppControllers.createMatch.selectedMatchType.value = value!;
                    AppControllers.createMatch.updatePlayerNameBox(1);
                  },
                  activeColor: Colors.green.shade600,
                ),
                RadioListTile<BadmintonMatchType>(
                  title: const Text('2v2'),
                  subtitle: const Text('Double player match'),
                  value: BadmintonMatchType.doubles,
                  groupValue: AppControllers.createMatch.selectedMatchType.value,
                  onChanged: (value) {
                    AppControllers.createMatch.selectedMatchType.value = value!;
                    AppControllers.createMatch.updatePlayerNameBox(2);
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
    BuildContext context,
  ) {
    final int playersPerTeam = AppControllers.createMatch.selectedMatchType.value.requiredPlayersPerTeam;

    return Column(
      children: [
        _buildTeamCard('Team 1', AppControllers.createMatch.team1NameController, AppControllers.createMatch.team1PlayerNameBox, playersPerTeam, AppControllers.createMatch.team1Logo, Colors.blue, AppControllers.createMatch.availableLogos, context),
        const SizedBox(height: 16),
        _buildTeamCard('Team 2', AppControllers.createMatch.team2NameController, AppControllers.createMatch.team2PlayerNameBox, playersPerTeam, AppControllers.createMatch.team2Logo, Colors.green, AppControllers.createMatch.availableLogos, context),
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
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
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
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: AppControllers.createMatch.isCreating.value ? null : () async {
          await AppControllers.createMatch.createMatch();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AppControllers.createMatch.isCreating.value 
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
}
