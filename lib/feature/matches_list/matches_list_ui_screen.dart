import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../match_rule/match_rule_ui_screen.dart';
import '../../main.dart';
import '../../controllers/app_controllers.dart';

class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller already initialized in AppControllers

    // Setup observers once
    ever(AppControllers.myMatches.successMessage, (String message) {
      if (message.isNotEmpty) {
        Get.snackbar(
          'Success',
          message,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade700,
          icon: Icon(Icons.check_circle, color: Colors.green.shade700),
        );
        AppControllers.myMatches.successMessage.value = '';
      }
    });

    ever(AppControllers.myMatches.errorMessage, (String message) {
      if (message.isNotEmpty) {
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade700,
          icon: Icon(Icons.error, color: Colors.red.shade700),
        );
        AppControllers.myMatches.errorMessage.value = '';
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Matches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAll(() => const MyHomePage()),
        ),
      ),
      body: Obx(() {
        if (AppControllers.myMatches.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (AppControllers.myMatches.matches.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: AppControllers.myMatches.loadMatches,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: AppControllers.myMatches.LetestFirstSortedMatches().length,
            itemBuilder: (context, index) {
              return _buildMatchCard(AppControllers.myMatches.LetestFirstSortedMatches()[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_tennis, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No matches yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first match',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BadmintonMatchModel match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => Get.to(() => MatchDetailScreen(matchId: match.matchId)),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMatchHeader(match),
                const SizedBox(height: 12),
                _buildMatchScore(match),
                const SizedBox(height: 8),
                _buildMatchFooter(match),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHeader(BadmintonMatchModel match) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: match.matchType == BadmintonMatchType.singles
                ? Colors.blue.shade100
                : Colors.purple.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            match.matchType.displayName,
            style: TextStyle(
              color: match.matchType == BadmintonMatchType.singles
                  ? Colors.blue.shade700
                  : Colors.purple.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        _buildStatusBadge(match),
      ],
    );
  }

  Widget _buildStatusBadge(BadmintonMatchModel match) {
    if (AppControllers.match.isMatchCompleted(match)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Completed',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      );
    } else if (match.status == BadmintonMatchStatus.paused) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pause_circle, size: 14, color: Colors.orange.shade700),
            const SizedBox(width: 4),
            Text(
              'Paused',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMatchScore(BadmintonMatchModel match) {
    return Row(
      children: [
        Expanded(child: _buildTeamInfo(match.team1, AppControllers.match.getTeam1Players(match), true)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${AppControllers.match.getTeam1Score(match)} - ${AppControllers.match.getTeam2Score(match)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(child: _buildTeamInfo(match.team2, AppControllers.match.getTeam2Players(match), false)),
      ],
    );
  }

  Widget _buildTeamInfo(BadmintonTeamModel team, List<String> players, bool isLeft) {
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (isLeft) ...[
              Text(team.teamLogo, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                team.teamName.isNotEmpty ? team.teamName : (isLeft ? 'Team 1' : 'Team 2'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: isLeft ? TextAlign.left : TextAlign.right,
              ),
            ),
            if (!isLeft) ...[
              const SizedBox(width: 8),
              Text(team.teamLogo, style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          players.join(' & '),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          textAlign: isLeft ? TextAlign.left : TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildMatchFooter(BadmintonMatchModel match) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Created: ${_formatDate(match.createdAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Text(
          _getTimeAgo(match.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.green.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }
}
