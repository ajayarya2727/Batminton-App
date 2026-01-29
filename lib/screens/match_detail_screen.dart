import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/match_controller.dart';
import '../models/badminton_models.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final MatchController controller = Get.find<MatchController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Match Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate directly to home screen
            Get.offAllNamed('/');
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(controller);
              } else if (value == 'print_json') {
                controller.printCompleteMatchJson(matchId);
                Get.snackbar(
                  'JSON Printed', 
                  'Complete match JSON printed to console and saved to debug file',
                  backgroundColor: Colors.blue.shade100,
                  colorText: Colors.blue.shade700,
                  icon: Icon(Icons.code, color: Colors.blue.shade700),
                  duration: Duration(seconds: 4),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print_json',
                child: Row(
                  children: [
                    Icon(Icons.code, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Print JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Match'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final match = controller.getMatchById(matchId);
        
        if (match == null) {
          return const Center(
            child: Text(
              'Match not found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMatchHeader(match),
              const SizedBox(height: 24),
              // Add round history if there are completed rounds
              if (match.roundScores.isNotEmpty) ...[
                _buildRoundHistory(match),
                const SizedBox(height: 24),
              ],
              _buildScoreSection(match, controller),
              const SizedBox(height: 24),
              // Add manual service selection button for in-progress matches
              if (!match.isCompleted && match.rounds.isNotEmpty) _buildManualServiceButton(match, controller),
              const SizedBox(height: 16),
              // Add break/resume button for in-progress matches
              if (!match.isCompleted) _buildBreakResumeButton(match, controller),
              const SizedBox(height: 16),
              _buildMatchInfo(match),
              const SizedBox(height: 24),
              _buildScorecard(match),
              const SizedBox(height: 24),
              if (!match.isCompleted) _buildCompleteButton(match, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMatchHeader(BadmintonMatchModel match) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: match.matchType == BadmintonMatchType.singles 
                          ? Colors.blue.shade100 
                          : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      match.matchType.displayName,
                      style: TextStyle(
                        color: match.matchType == BadmintonMatchType.singles 
                            ? Colors.blue.shade700 
                            : Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (match.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            // Add round progress display
            if (!match.isCompleted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Round ${match.currentRoundNumber} of 3',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            // Add match score (rounds won)
            if (match.team1RoundsWon > 0 || match.team2RoundsWon > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Match Score: ${match.team1RoundsWon} - ${match.team2RoundsWon}',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Team 1 Header with Logo and Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            match.team1.teamLogo,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              match.team1.teamName.isNotEmpty 
                                  ? match.team1.teamName 
                                  : 'Team 1',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...match.team1.players.map((player) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Service indicator for specific player - simple badminton icon
                            if (match.currentServer == player.playerId) ...[
                              const Text(
                                '🏸',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${match.team1Score} - ${match.team2Score}',
                        key: ValueKey('score-${match.matchId}-${match.currentRoundNumber}'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (!match.isCompleted)
                        Text(
                          'Round ${match.currentRoundNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      // Team 2 Header with Logo and Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              match.team2.teamName.isNotEmpty 
                                  ? match.team2.teamName 
                                  : 'Team 2',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            match.team2.teamLogo,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...match.team2.players.map((player) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Service indicator for specific player - simple badminton icon
                            if (match.currentServer == player.playerId) ...[
                              const SizedBox(width: 4),
                              const Text(
                                '🏸',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundHistory(BadmintonMatchModel match) {
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
              'Round History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...match.roundScores.asMap().entries.map((entry) {
              final index = entry.key;
              final roundData = entry.value;
              final roundNumber = index + 1;
              final team1Score = roundData['team1'] ?? 0;
              final team2Score = roundData['team2'] ?? 0;
              final winner = roundData['winner'] ?? 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'R$roundNumber',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$team1Score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: winner == 1 ? Colors.green.shade700 : Colors.black,
                            ),
                          ),
                          const Text(
                            '-',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$team2Score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: winner == 2 ? Colors.green.shade700 : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        winner == 1 ? 'Team 1' : 'Team 2',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(BadmintonMatchModel match, MatchController controller) {
    if (match.isCompleted) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Match Completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Winner: ${_getMatchWinner(match)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Final Match Score: ${match.team1RoundsWon} - ${match.team2RoundsWon}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Check if match is paused
    final bool isPaused = match.status == BadmintonMatchStatus.paused;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Individual Player Scoring',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPaused)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pause_circle, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'PAUSED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isPaused 
                ? 'Match is paused - Resume to continue scoring'
                : 'Round ${match.currentRoundNumber} - Tap player buttons to score points',
              style: TextStyle(
                fontSize: 12,
                color: isPaused ? Colors.orange.shade600 : Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            
            // Team 1 Players
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(match.team1.teamLogo, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Team Total: ${match.team1Score}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team1.players.map((player) {
                    final playerScore = match.currentRound?.playerScores[player.playerId] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        children: [
                          // Service indicator
                          if (match.currentServer == player.playerId) ...[
                            const Text('🏸', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Score controls
                          IconButton(
                            onPressed: isPaused ? null : () {
                              if (playerScore > 0) {
                                controller.updatePlayerScore(
                                  match.matchId,
                                  player.playerId,
                                  playerScore - 1,
                                );
                              }
                            },
                            icon: const Icon(Icons.remove_circle),
                            color: isPaused ? Colors.grey : Colors.red,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                              color: playerScore >= 10 ? Colors.green.shade50 : Colors.white,
                            ),
                            child: Text(
                              '$playerScore',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: playerScore >= 10 ? Colors.green.shade700 : Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isPaused ? null : () {
                              controller.updatePlayerScore(
                                match.matchId,
                                player.playerId,
                                playerScore + 1,
                              );
                            },
                            icon: const Icon(Icons.add_circle),
                            color: isPaused ? Colors.grey : Colors.green,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team 2 Players
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(match.team2.teamLogo, style: const TextStyle(fontSize: 18)),
                      const Spacer(),
                      Text(
                        'Team Total: ${match.team2Score}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...match.team2.players.map((player) {
                    final playerScore = match.currentRound?.playerScores[player.playerId] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          // Service indicator
                          if (match.currentServer == player.playerId) ...[
                            const Text('🏸', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Score controls
                          IconButton(
                            onPressed: isPaused ? null : () {
                              if (playerScore > 0) {
                                controller.updatePlayerScore(
                                  match.matchId,
                                  player.playerId,
                                  playerScore - 1,
                                );
                              }
                            },
                            icon: const Icon(Icons.remove_circle),
                            color: isPaused ? Colors.grey : Colors.red,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                              color: playerScore >= 10 ? Colors.green.shade50 : Colors.white,
                            ),
                            child: Text(
                              '$playerScore',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: playerScore >= 10 ? Colors.green.shade700 : Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isPaused ? null : () {
                              controller.updatePlayerScore(
                                match.matchId,
                                player.playerId,
                                playerScore + 1,
                              );
                            },
                            icon: const Icon(Icons.add_circle),
                            color: isPaused ? Colors.grey : Colors.green,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchInfo(BadmintonMatchModel match) {
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
              'Match Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Match ID', match.matchId),
            _buildInfoRow('Match Type', match.matchType.displayName),
            _buildInfoRow('Current Round', '${match.currentRoundNumber} of 3'),
            _buildInfoRow('Rounds Won', '${match.team1RoundsWon} - ${match.team2RoundsWon}'),
             _buildInfoRow('Created', _formatDate(match.createdAt)),
            _buildInfoRow('Status', match.isCompleted ? 'Completed' : 'In Progress'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualServiceButton(BadmintonMatchModel match, MatchController controller) {
    final bool isPaused = match.status == BadmintonMatchStatus.paused;
    
    // Find the current server's name by player ID
    String currentServerName = 'Unknown Player';
    if (match.currentServer != null) {
      for (final player in [...match.team1.players, ...match.team2.players]) {
        if (player.playerId == match.currentServer) {
          currentServerName = player.name;
          break;
        }
      }
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.sports_tennis, color: Colors.green.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Server',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentServerName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isPaused ? null : () {
                    controller.showManualServiceSelectionDialog(match);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.swap_horiz, size: 20),
                  label: const Text(
                    'Change Service',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (isPaused) ...[
              const SizedBox(height: 8),
              Text(
                'Resume match to change service',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakResumeButton(BadmintonMatchModel match, MatchController controller) {
    final bool isPaused = match.status == BadmintonMatchStatus.paused;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (isPaused) {
            controller.resumeMatch(match.matchId);
          } else {
            _showBreakDialog(match, controller);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPaused ? Colors.green.shade600 : Colors.orange.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          isPaused ? Icons.play_circle : Icons.pause_circle,
          size: 24,
        ),
        label: Text(
          isPaused ? 'Resume Match' : 'Take a Break',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showBreakDialog(BadmintonMatchModel match, MatchController controller) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pause_circle, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Take a Break'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Do you want to pause this match?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Score: ${match.team1Score} - ${match.team2Score}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Round ${match.currentRoundNumber} of 3',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can resume the match anytime from where you left off.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              controller.pauseMatch(match.matchId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.pause_circle, size: 20),
            label: const Text('Pause Match'),
          ),
        ],
      ),
    );
  }
  Widget _buildCompleteButton(BadmintonMatchModel match, MatchController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showCompleteDialog(match, controller);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Complete Match',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showCompleteDialog(BadmintonMatchModel match, MatchController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Complete Match'),
        content: const Text('Are you sure you want to mark this match as completed?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.completeMatch(match.matchId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(MatchController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Match'),
        content: const Text('Are you sure you want to delete this match? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteMatch(matchId);
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getMatchWinner(BadmintonMatchModel match) {
    if (match.winner == 'team1') {
      return match.team1Players.join(' & ');
    } else if (match.winner == 'team2') {
      return match.team2Players.join(' & ');
    } else {
      return 'Draw';
    }
  }

  Widget _buildScorecard(BadmintonMatchModel match) {
    final scorecard = match.generateScorecard();
    
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
                Icon(Icons.analytics, color: Colors.blue.shade600, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Match Scorecard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Match Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Match Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: match.isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          match.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: match.isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${scorecard.team1Stats.roundsWon}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: scorecard.team1Stats.roundsWon >= 2 ? Colors.green.shade700 : Colors.black,
                            ),
                          ),
                          Text(
                            'Rounds Won',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '-',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${scorecard.team2Stats.roundsWon}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: scorecard.team2Stats.roundsWon >= 2 ? Colors.green.shade700 : Colors.black,
                            ),
                          ),
                          Text(
                            'Rounds Won',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Team Performance
            Row(
              children: [
                // Team 1 Performance
                Expanded(
                  child: _buildTeamPerformance(scorecard.team1Stats, 'Team 1'),
                ),
                const SizedBox(width: 16),
                // Team 2 Performance  
                Expanded(
                  child: _buildTeamPerformance(scorecard.team2Stats, 'Team 2'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Round by Round Breakdown
            if (scorecard.roundScores.isNotEmpty) ...[
              Text(
                'Round by Round Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ...scorecard.roundScores.entries.map((entry) {
                final roundNumber = entry.key;
                final scores = entry.value;
                final team1Score = scores['team1'] ?? 0;
                final team2Score = scores['team2'] ?? 0;
                final winner = team1Score > team2Score ? 'Team 1' : 'Team 2';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'R$roundNumber',
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$team1Score',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: team1Score > team2Score ? Colors.green.shade700 : Colors.black,
                              ),
                            ),
                            const Text('-', style: TextStyle(fontSize: 14)),
                            Text(
                              '$team2Score',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: team2Score > team1Score ? Colors.green.shade700 : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          winner,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamPerformance(BadmintonTeamStats teamStats, String teamLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Header
          Row(
            children: [
              Text(
                teamStats.teamLogo,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  teamStats.teamName.isNotEmpty ? teamStats.teamName : teamLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Team Stats
          _buildStatRow('Total Points', teamStats.totalTeamPoints.toString()),
          _buildStatRow('Win Rate', '${teamStats.teamWinPercentage.toStringAsFixed(1)}%'),
          
          const SizedBox(height: 12),
          
          // Player Performance
          Text(
            'Players:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          ...teamStats.playerStats.map((player) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    player.playerName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${player.totalPointsScored} pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}