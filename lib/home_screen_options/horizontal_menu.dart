import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Screen imports - where each button navigates to
import '../screens/create_match_screen.dart';  // ← Existing match creation
import 'create_team_screen.dart';              // ← New team creation
import 'create_tournament_screen.dart';        // ← New tournament creation  
import 'resume_matches_screen.dart';           // ← New resume matches
import '../screens/matches_list_screen.dart';     // ← Matches list screen

// Individual button widget
class MenuButton extends StatelessWidget {
  final String title;   // Button text
  final Color color;    // Button color
  final VoidCallback onTap;  // What happens when tapped

  const MenuButton({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,  // Handle button tap
      child: Container(
        height: 70, // Fixed height for all buttons
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                // offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
  }
}

// Main menu with 5 swipeable buttons
class HorizontalMenu extends StatelessWidget {
  const HorizontalMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40), // Add space to push buttons down
        Row(  
            children: [
              // Button 1: Create Match (Green)
              Expanded(
                flex: 1,
                child: MenuButton(
                  title: 'CREATE MATCH',
                  color: Colors.green.shade600,
                  onTap: () => Get.to(() => const CreateMatchScreen()),
                ),
              ),
              
              // Button 2: Create Tournament (Orange)
              Expanded(
                flex: 1,
                child: MenuButton(
                  title: 'CREATE TOURNAMENT',
                  color: Colors.orange.shade600,
                  onTap: () => Get.to(() => const CreateTournamentScreen()),
                ),
              ),
               //Button 3:CREATE TOURNAMENT
              Expanded(
                flex: 1,
                child: MenuButton(
                  title: 'RESUME MATCH',
                  color: Colors.blue.shade600,
                  onTap: () => Get.to(() => const ResumeMatchesScreen()),
                ),
              ),
              
            ],
          ),
          const SizedBox(height: 16),
           Column(
             children: [
               Row(
                  children: [
                    //Button 4:Create Team
                    Expanded(
                      flex: 1,
                      child: MenuButton(
                        title: 'CREATE TEAM',
                        color: Colors.blue.shade600,
                        onTap: () => Get.to(() => const CreateTeamScreen()),
                      ),
                    ),
                
                    // Button 5: My Match (Orange)
                    Expanded(
                      flex: 1,
                      child: MenuButton(
                        title: 'MY MATCH',
                        color: Colors.orange.shade600,
                        onTap: () => Get.to(() => const MatchesListScreen()),
                      ),
                    ),
               
                    Expanded(
                      flex: 1,
                      child: MenuButton(
                        title: 'MY MATCH',
                        color: Colors.orange.shade600,
                        onTap: () => Get.to(() => const MatchesListScreen()),
                      ),
                    ),
                  ],
                
                ),
             ],
           ),
           
           // Add "Badminton Matches" text below buttons
           const SizedBox(height: 40),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 20),
             child: Text(
               'Badminton Matches',
               style: TextStyle(
                 fontSize: 24,
                 fontWeight: FontWeight.bold,
                 color: Colors.green.shade700,
               ),
               textAlign: TextAlign.center,
             ),
           ),
           Text('ajay'),
          // Image.asset('name'),
          
      ],
    );
  }
}