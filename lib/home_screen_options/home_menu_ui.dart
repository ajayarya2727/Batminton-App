import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/create_match_screen.dart';
import 'create_team_screen.dart';
import 'create_tournament_ui_screen.dart';
import 'resume_matches_ui_screen.dart';
import '../screens/matches_list_ui_screen.dart';

class MenuButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
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

class HorizontalMenu extends StatelessWidget {
  const HorizontalMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: MenuButton(
                title: 'CREATE MATCH',
                color: Colors.green.shade600,
                onTap: () => Get.to(() => const CreateMatchScreen()),
              ),
            ),
            Expanded(
              child: MenuButton(
                title: 'CREATE TOURNAMENT',
                color: Colors.orange.shade600,
                onTap: () => Get.to(() => const CreateTournamentScreen()),
              ),
            ),
            Expanded(
              child: MenuButton(
                title: 'RESUME MATCH',
                color: Colors.teal.shade600,
                onTap: () => Get.to(() => const ResumeMatchesScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MenuButton(
                title: 'CREATE TEAM',
                color: Colors.purple.shade600,
                onTap: () => Get.to(() => const CreateTeamScreen()),
              ),
            ),
            Expanded(
              child: MenuButton(
                title: 'MY MATCH',
                color: Colors.red.shade600,
                onTap: () => Get.to(() => const MatchesListScreen()),
              ),
            ),

                        Expanded(
              child: MenuButton(
                title: 'MY MATCH',
                color: Colors.red.shade600,
                onTap: () => Get.to(() => const MatchesListScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}