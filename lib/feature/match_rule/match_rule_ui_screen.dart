import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/badminton_models.dart';
import '../matches_list/matches_list_ui_screen.dart';
import '../../controllers/app_controllers.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
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
            // Go directly to My Matches list
            Get.offAll(() => const MatchesListScreen());
          },
        ),

      ),
      body: Stack(
        children: [
          Obx(() {
            final match = AppControllers.myMatches.getMatchById(matchId);
            
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
                  if (AppControllers.match.getRoundScores(match).isNotEmpty) ...[
                    _buildRoundHistory(match),
                    const SizedBox(height: 24),
                  ],
                  _buildScoreSection(match),
                  const SizedBox(height: 24),
                  // Add manual service selection button for in-progress matches
                  if (!AppControllers.match.isMatchCompleted(match) && match.rounds.isNotEmpty) _buildManualServiceButton(match),
                  const SizedBox(height: 16),
                  // Add break/resume button for in-progress matches
                  if (!AppControllers.match.isMatchCompleted(match)) _buildBreakResumeButton(match),
                  const SizedBox(height: 16),
                  _buildMatchInfo(match),
                  const SizedBox(height: 24),
                  _buildScorecard(match),
                  const SizedBox(height: 24),
                  if (!AppControllers.match.isMatchCompleted(match)) _buildCompleteButton(match),
                ],
              ),
            );
          }),
          
          // Dialog listeners as separate Obx widgets
          Obx(() {
            if (AppControllers.match.showInfoDialog.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final message = AppControllers.match.infoDialogMessage.value;
                debugPrint('📢 Info dialog triggered with message: "$message"');
                _showInfoDialog(message);
                AppControllers.match.showInfoDialog.value = false;
              });
            }
            return const SizedBox.shrink();
          }),
          
          Obx(() {
            if (AppControllers.match.showRoundCompleteDialog.value && AppControllers.match.pendingMatch.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final match = AppControllers.match.pendingMatch.value!;
                debugPrint('🔔 Round complete dialog triggered');
                final lastCompletedRound = match.rounds.lastWhere((r) => r.isCompleted);
                final roundWinner = lastCompletedRound.winnerId ?? '';
                
                _showRoundCompleteDialog(
                  matchId,
                  roundWinner,
                  lastCompletedRound.roundNumber,
                  lastCompletedRound.team1Score,
                  lastCompletedRound.team2Score,
                );
                AppControllers.match.showRoundCompleteDialog.value = false;
              });
            }
            return const SizedBox.shrink();
          }),
          
          Obx(() {
            if (AppControllers.match.showNextRoundServiceDialog.value && AppControllers.match.pendingMatch.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final match = AppControllers.match.pendingMatch.value!;
                final lastCompletedRound = match.rounds.lastWhere((r) => r.isCompleted);
                final defaultServer = lastCompletedRound.winnerId ?? '';
                
                _showNextRoundServiceDialog(
                  matchId,
                  defaultServer,
                );
                AppControllers.match.showNextRoundServiceDialog.value = false;
              });
            }
            return const SizedBox.shrink();
          }),
          
          Obx(() {
            if (AppControllers.match.showMatchCompleteDialog.value && AppControllers.match.pendingMatch.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final match = AppControllers.match.pendingMatch.value!;
                final winnerId = AppControllers.match.getMatchWinner(match) ?? '';
                final winnerName = winnerId == 'team1' 
                    ? (match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1')
                    : (match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2');
                
                _showMatchCompleteDialog(
                  winnerName,
                  AppControllers.match.getTeam1RoundsWon(match),
                  AppControllers.match.getTeam2RoundsWon(match),
                );
                AppControllers.match.showMatchCompleteDialog.value = false;
              });
            }
            return const SizedBox.shrink();
          }),
          
          Obx(() {
            if (AppControllers.match.showManualServiceDialog.value && AppControllers.match.pendingMatch.value != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showManualServiceSelectionDialog(
                  AppControllers.match.pendingMatch.value!,
                );
                AppControllers.match.showManualServiceDialog.value = false;
              });
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
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
                if (AppControllers.match.isMatchCompleted(match))
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
            if (!AppControllers.match.isMatchCompleted(match)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Round ${AppControllers.match.getDisplayRoundNumber(match)} of 3',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            // Add match score (rounds won)
            if (AppControllers.match.getTeam1RoundsWon(match) > 0 || AppControllers.match.getTeam2RoundsWon(match) > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Match Score: ${AppControllers.match.getTeam1RoundsWon(match)} - ${AppControllers.match.getTeam2RoundsWon(match)}',
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
                            style: TextStyle(fontSize: 20),
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
                      // Team 1 players list
                      for (int i = 0; i < match.team1.players.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Service indicator for specific player - simple badminton icon
                              if (AppControllers.match.getCurrentServer(match) == match.team1.players[i].playerId) ...[
                                const Text(
                                  '🏸',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(
                                child: Text(
                                  match.team1.players[i].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        '${AppControllers.match.getTeam1Score(match)} - ${AppControllers.match.getTeam2Score(match)}',
                        key: ValueKey('score-${match.matchId}-${match.currentRoundNumber}'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (!AppControllers.match.isMatchCompleted(match))
                        Text(
                          'Round ${AppControllers.match.getDisplayRoundNumber(match)}',
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
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Team 2 players list
                      for (int i = 0; i < match.team2.players.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  match.team2.players[i].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Service indicator for specific player - simple badminton icon
                              if (AppControllers.match.getCurrentServer(match) == match.team2.players[i].playerId) ...[
                                const SizedBox(width: 4),
                                const Text(
                                  '🏸',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ],
                          ),
                        ),
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
            // Round scores list
            for (int index = 0; index < AppControllers.match.getRoundScores(match).length; index++)
              Container(
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
                          'R${index + 1}',
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
                            '${AppControllers.match.getRoundScores(match)[index]['team1'] ?? 0}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: (AppControllers.match.getRoundScores(match)[index]['winner'] ?? 0) == 1 ? Colors.green.shade700 : Colors.black,
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
                            '${AppControllers.match.getRoundScores(match)[index]['team2'] ?? 0}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: (AppControllers.match.getRoundScores(match)[index]['winner'] ?? 0) == 2 ? Colors.green.shade700 : Colors.black,
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
                        (AppControllers.match.getRoundScores(match)[index]['winner'] ?? 0) == 1 ? 'Team 1' : 'Team 2',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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

  Widget _buildScoreSection(BadmintonMatchModel match) {
    if (AppControllers.match.isMatchCompleted(match)) {
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
                  Icon(Icons.emoji_events, color: Colors.green.shade600, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Match Completed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Winner: ${_getMatchWinner(match)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Final Match Score: ${AppControllers.match.getTeam1RoundsWon(match)} - ${AppControllers.match.getTeam2RoundsWon(match)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Teams & Players',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Team 1 Section
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(match.team1.teamLogo, style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Team 1 player names
                              for (int i = 0; i < match.team1.players.length; i++)
                                Text(
                                  match.team1.players[i].name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                '${AppControllers.match.getTeam1Score(match)} pts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // VS Divider
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        
                        // Team 2 Section
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    match.team2.teamName.isNotEmpty ? match.team2.teamName : 'Team 2',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(match.team2.teamLogo, style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Team 2 player names
                              for (int i = 0; i < match.team2.players.length; i++)
                                Text(
                                  match.team2.players[i].name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                '${AppControllers.match.getTeam2Score(match)} pts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
                : 'Round ${AppControllers.match.getDisplayRoundNumber(match)} - Tap player buttons to score points',
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
                      Text(match.team1.teamLogo, style: TextStyle(fontSize: 18)),
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
                        'Team Total: ${AppControllers.match.getTeam1Score(match)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Team 1 player scoring
                  for (int i = 0; i < match.team1.players.length; i++)
                    Builder(
                      builder: (context) {
                        final player = match.team1.players[i];
                        final playerScore = AppControllers.match.getCurrentRound(match)?.playerScores[player.playerId] ?? 0;
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
                              if (AppControllers.match.getCurrentServer(match) == player.playerId) ...[
                                const Text('🏸', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Score controls
                              IconButton(
                                onPressed: isPaused ? null : () {
                                  if (playerScore > 0) {
                                    AppControllers.match.updatePlayerScore(
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
                                  color: Colors.white,
                                ),
                                child: Text(
                                  '$playerScore',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: isPaused ? null : () {
                                  AppControllers.match.updatePlayerScore(
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
                      },
                    ),
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
                      Text(match.team2.teamLogo, style: TextStyle(fontSize: 18)),
                      const Spacer(),
                      Text(
                        'Team Total: ${AppControllers.match.getTeam2Score(match)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Team 2 player scoring
                  for (int i = 0; i < match.team2.players.length; i++)
                    Builder(
                      builder: (context) {
                        final player = match.team2.players[i];
                        final playerScore = AppControllers.match.getCurrentRound(match)?.playerScores[player.playerId] ?? 0;
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
                              if (AppControllers.match.getCurrentServer(match) == player.playerId) ...[
                                const Text('🏸', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Score controls
                              IconButton(
                                onPressed: isPaused ? null : () {
                                  if (playerScore > 0) {
                                    AppControllers.match.updatePlayerScore(
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
                                  color: Colors.white,
                                ),
                                child: Text(
                                  '$playerScore',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: isPaused ? null : () {
                                  AppControllers.match.updatePlayerScore(
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
                      },
                    ),
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
            _buildInfoRow('Current Round', '${AppControllers.match.getDisplayRoundNumber(match)} of 3'),
            _buildInfoRow('Rounds Won', '${AppControllers.match.getTeam1RoundsWon(match)} - ${AppControllers.match.getTeam2RoundsWon(match)}'),
             _buildInfoRow('Created', _formatDate(match.createdAt)),
            _buildInfoRow('Status', AppControllers.match.isMatchCompleted(match) ? 'Completed' : 'In Progress'),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualServiceButton(BadmintonMatchModel match) {
    final bool isPaused = match.status == BadmintonMatchStatus.paused;
    
    // Find the current server's name by player ID
    String currentServerName = 'Unknown Player';
    if (AppControllers.match.getCurrentServer(match) != null) {
      for (final player in [...match.team1.players, ...match.team2.players]) {
        if (player.playerId == AppControllers.match.getCurrentServer(match)) {
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
                    AppControllers.match.triggerManualServiceDialog(match);
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

  Widget _buildBreakResumeButton(BadmintonMatchModel match) {
    final bool isPaused = match.status == BadmintonMatchStatus.paused;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (isPaused) {
            await AppControllers.match.resumeMatch(match.matchId);
          } else {
            await AppControllers.match.pauseMatch(match.matchId);

            _showResumeDialog(match);
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showResumeDialog(BadmintonMatchModel match) {
    AppControllers.match.startBreakStopwatch();
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pause_circle, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Match Paused'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The match is currently paused.',
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
                    'Current Score: ${AppControllers.match.getTeam1Score(match)} - ${AppControllers.match.getTeam2Score(match)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Round ${AppControllers.match.getDisplayRoundNumber(match)} of 3',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Live Stopwatch
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Break Time: ${AppControllers.match.formatBreakTime(AppControllers.match.breakStopwatch.value)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            const Text(
              'Press Resume Match to continue playing.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                AppControllers.match.stopAndResetBreakStopwatch();
                Get.back(); 
                await AppControllers.match.resumeMatch(match.matchId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.play_circle, size: 20),
              label: const Text('Resume Match'),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  Widget _buildCompleteButton(BadmintonMatchModel match) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showCompleteDialog(match);
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

  void _showCompleteDialog(BadmintonMatchModel match) {
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
              Get.back();
              AppControllers.match.completeMatch(match.matchId);
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


  String _getMatchWinner(BadmintonMatchModel match) {
    if (AppControllers.match.getWinner(match) == 'team1') {
      return AppControllers.match.getTeam1Players(match).join(' & ');
    } else if (AppControllers.match.getWinner(match) == 'team2') {
      return AppControllers.match.getTeam2Players(match).join(' & ');
    } else {
      return 'Draw';
    }
  }

  Widget _buildScorecard(BadmintonMatchModel match) {
    final scorecard = AppControllers.match.generateMatchScorecard(match);
    
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
                          color: AppControllers.match.isMatchCompleted(match) ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppControllers.match.isMatchCompleted(match) ? 'COMPLETED' : 'IN PROGRESS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppControllers.match.isMatchCompleted(match) ? Colors.green.shade700 : Colors.orange.shade700,
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
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  teamStats.teamName.isNotEmpty ? teamStats.teamName : teamLabel,
                  style: TextStyle(
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
          // Player stats list
          for (int i = 0; i < teamStats.playerStats.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      teamStats.playerStats[i].playerName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${teamStats.playerStats[i].totalPointsScored} pts',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
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
            style: TextStyle(
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

  void _showInfoDialog(String message) {
    final displayMessage = message.isEmpty 
        ? "Game continues!\n\n2-point lead is required to win the round." 
        : message;
    
    debugPrint('🎨 Showing dialog with message: "$displayMessage"');
    
    Get.dialog(
      AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Game Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              displayMessage,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      barrierDismissible: true,
    );
  }

  void _showRoundCompleteDialog(
    String matchId,
    String roundWinner,
    int roundNumber,
    int team1Score,
    int team2Score,
  ) {
    final match = AppControllers.myMatches.getMatchById(matchId);
    if (match == null) return;
    
    final winnerName = roundWinner == 'team1' ? AppControllers.match.getTeam1Players(match).join(' & ') : AppControllers.match.getTeam2Players(match).join(' & ');
    
    Get.dialog(
      AlertDialog(
        title: Text('🎯 Round $roundNumber Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '$winnerName won Round $roundNumber!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Round $roundNumber Score: $team1Score - $team2Score',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Match Score: ${AppControllers.match.getTeam1RoundsWon(match)} - ${AppControllers.match.getTeam2RoundsWon(match)}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🏸 Next Round Service',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$winnerName will serve first in next round',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                AppControllers.match.triggerNextRoundServiceDialog(matchId);
              },
              child: const Text('Change Service'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                AppControllers.match.startNextRound(matchId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue to Next Round'),
            ),
          ],
        ),
      barrierDismissible: false,
    );
  }

  void _showNextRoundServiceDialog(
    String matchId,
    String defaultServer,
  ) {
    final match = AppControllers.myMatches.getMatchById(matchId);
    if (match == null) return;
    
    Get.dialog(
      AlertDialog(
          title: Text('🏸 Round ${match.currentRoundNumber + 1} Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Who should serve first in the next round?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
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
                          Text(match.team1.teamLogo, style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            match.team1.teamName.isNotEmpty ? match.team1.teamName : 'Team 1',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Team 1 player buttons
                      for (int i = 0; i < match.team1.players.length; i++)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              AppControllers.match.startNextRoundWithService(matchId, match.team1.players[i].playerId);
                              Get.snackbar(
                                'Round Started!',
                                '${match.team1.players[i].name} will serve first',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade700,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(match.team1.players[i].name),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Team 2 Players
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          Text(match.team2.teamLogo, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Team 2 player buttons
                      for (int i = 0; i < match.team2.players.length; i++)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              AppControllers.match.startNextRoundWithService(matchId, match.team2.players[i].playerId);
                              Get.snackbar(
                                'Round Started!',
                                '${match.team2.players[i].name} will serve first',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade700,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(match.team2.players[i].name),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      barrierDismissible: false,
    );
  }

  void _showMatchCompleteDialog(
    String matchWinner,
    int team1Rounds,
    int team2Rounds,
  ) {
    Get.dialog(
      Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    size: 55,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Match Completed',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Winner: $matchWinner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Final Match Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$team1Rounds - $team2Rounds',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
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
                      'View Match Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      barrierDismissible: false,
    );
  }


  void _showServiceSelectionDialog(
    BadmintonMatchModel match,
  ) {
    Get.dialog(
      AlertDialog(
          title: const Text('🏸 Select First Server'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Who will serve first?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
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
                          Text(match.team1.teamLogo, style: TextStyle(fontSize: 18)),
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
                      // Team 1 player buttons
                      for (int i = 0; i < match.team1.players.length; i++)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              AppControllers.match.initializeMatchWithService(match.matchId, match.team1.players[i].playerId);
                              Get.snackbar(
                                'Match Started!',
                                '${match.team1.players[i].name} will serve first',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade700,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(match.team1.players[i].name),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Team 2 Players
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
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
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(match.team2.teamLogo, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Team 2 player buttons
                      for (int i = 0; i < match.team2.players.length; i++)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              AppControllers.match.initializeMatchWithService(match.matchId, match.team2.players[i].playerId);
                              Get.snackbar(
                                'Match Started!',
                                '${match.team2.players[i].name} will serve first',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade700,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(match.team2.players[i].name),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      barrierDismissible: false,
    );
  }

  void _showManualServiceSelectionDialog(
    BadmintonMatchModel match,
  ) {
    Get.dialog(
      AlertDialog(
          title: const Text('🏸 Change Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Round: ${match.currentRoundNumber}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Score: ${AppControllers.match.getTeam1Score(match)} - ${AppControllers.match.getTeam2Score(match)}',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Who should serve next?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
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
                          Text(match.team1.teamLogo, style: TextStyle(fontSize: 18)),
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
                      // Team 1 player buttons
                      for (int i = 0; i < match.team1.players.length; i++)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              AppControllers.match.manuallySetService(match.matchId, match.team1.players[i].playerId);
                              Get.snackbar(
                                'Service Changed!',
                                '${match.team1.players[i].name} will serve next',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade700,
                                icon: Icon(Icons.sports_tennis, color: Colors.green.shade700),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppControllers.match.getCurrentServer(match) == match.team1.players[i].playerId
                                  ? Colors.green.shade600
                                  : Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (AppControllers.match.getCurrentServer(match) == match.team1.players[i].playerId)
                                  const Icon(Icons.sports_tennis, size: 16),
                                if (AppControllers.match.getCurrentServer(match) == match.team1.players[i].playerId)
                                  const SizedBox(width: 8),
                                Text(
                                  match.team1.players[i].name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Team 2 Players
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
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
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(match.team2.teamLogo, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Team 2 player buttons
                      for (int i = 0; i < match.team2.players.length; i++)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              AppControllers.match.manuallySetService(match.matchId, match.team2.players[i].playerId);
                              Get.snackbar(
                                'Service Changed!',
                                '${match.team2.players[i].name} will serve next',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade700,
                                icon: Icon(Icons.sports_tennis, color: Colors.green.shade700),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppControllers.match.getCurrentServer(match) == match.team2.players[i].playerId
                                  ? Colors.green.shade600
                                  : Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (AppControllers.match.getCurrentServer(match) == match.team2.players[i].playerId)
                                  const Icon(Icons.sports_tennis, size: 16),
                                if (AppControllers.match.getCurrentServer(match) == match.team2.players[i].playerId)
                                  const SizedBox(width: 8),
                                Text(
                                  match.team2.players[i].name,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      barrierDismissible: true,
    );
  }
}
