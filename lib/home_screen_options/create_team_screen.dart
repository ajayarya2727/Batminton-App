import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/create_match_screen.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  
  String _selectedLogo = '🏸';
  bool _isCreating = false;

  final List<String> _availableLogos = [
    '🏸', '⚡', '🔥', '💪', '🏆', '⭐', '🎯', '🚀', '💎', '👑'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Team',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Logo Selection
            const Text(
              'Team Logo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableLogos.length,
                itemBuilder: (context, index) {
                  final logo = _availableLogos[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLogo = logo),
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: _selectedLogo == logo 
                            ? Colors.blue.shade100 
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _selectedLogo == logo 
                              ? Colors.blue.shade600 
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          logo,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Team Name
            const Text(
              'Team Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                hintText: 'Enter team name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.group),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Players Section
            const Text(
              'Players',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Player 1
            TextField(
              controller: _player1Controller,
              decoration: InputDecoration(
                hintText: 'Player 1 name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Player 2
            TextField(
              controller: _player2Controller,
              decoration: InputDecoration(
                hintText: 'Player 2 name (optional for singles)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Create Team Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createTeam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Team & Start Match',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Info Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'After creating your team, you can immediately start a match with another team.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createTeam() async {
    // Validate inputs
    if (_teamNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a team name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return;
    }

    if (_player1Controller.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter at least one player name',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Show success message
      Get.snackbar(
        'Success',
        'Team "${_teamNameController.text}" created successfully!',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade700,
      );

      // Wait a moment for user to see the success message
      // await Future.delayed(const Duration(milliseconds:500));

      // Navigate to create match screen
      // Get.off(() => const CreateMatchScreen());
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create team. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
    } finally {
      setState(() => _isCreating = false);
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }
}