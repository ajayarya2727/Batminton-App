import '../models/match_model.dart';

class SampleData {
  static List<MatchModel> getSampleMatches() {
    final now = DateTime.now();
    return [
      MatchModel(
        id: '1',
        matchType: '1v1',
        team1Players: ['Rahul'],
        team2Players: ['Amit'],
        team1Score: 0,
        team2Score: 0,
        createdAt: now.subtract(const Duration(hours: 2)), // 2 hours ago
        isCompleted: true,
        currentRound: 3,
        team1RoundWins: [1, 3], // Won rounds 1 and 3
        team2RoundWins: [2], // Won round 2
        roundScores: [
          {'team1': 21, 'team2': 18, 'round': 1},
          {'team1': 19, 'team2': 21, 'round': 2},
          {'team1': 21, 'team2': 16, 'round': 3},
        ],
        winner: 'team1',
      ),
      MatchModel(
        id: '2',
        matchType: '2v2',
        team1Players: ['Vikas', 'Suresh'],
        team2Players: ['Ravi', 'Deepak'],
        team1Score: 15,
        team2Score: 12,
        createdAt: now.subtract(const Duration(minutes: 30)), // 30 minutes ago (latest)
        isCompleted: false,
        currentRound: 1,
        team1RoundWins: [],
        team2RoundWins: [],
        roundScores: [],
      ),
      MatchModel(
        id: '3',
        matchType: '1v1',
        team1Players: ['Priya'],
        team2Players: ['Neha'],
        team1Score: 8,
        team2Score: 12,
        createdAt: now.subtract(const Duration(hours: 1)), // 1 hour ago
        isCompleted: false,
        currentRound: 2,
        team1RoundWins: [],
        team2RoundWins: [1], // Team 2 won round 1
        roundScores: [
          {'team1': 18, 'team2': 21, 'round': 1},
        ],
      ),
    ];
  }
}