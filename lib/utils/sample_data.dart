// import '../models/badminton_models.dart';

// class SampleData {
//   static List<BadmintonMatchModel> getSampleMatches() {
//     final now = DateTime.now();
//     return [
//       // Completed 1v1 match
//       BadmintonMatchModel(
//         matchId: '1',
//         matchType: BadmintonMatchType.singles,
//         team1: BadmintonTeamModel(
//           teamId: 'team1_1',
//           players: [
//             BadmintonPlayerModel(playerId: 'p1', name: 'Rahul'),
//           ],
//         ),
//         team2: BadmintonTeamModel(
//           teamId: 'team2_1',
//           players: [
//             BadmintonPlayerModel(playerId: 'p2', name: 'Amit'),
//           ],
//         ),
//         status: BadmintonMatchStatus.completed,
//         createdAt: now.subtract(const Duration(hours: 2)),
//         currentRoundNumber: 3,
//         rounds: [
//           BadmintonRoundModel(
//             roundNumber: 1,
//             team1Score: 21,
//             team2Score: 18,
//             status: BadmintonRoundStatus.completed,
//             winnerId: 'team1',
//             completedAt: now.subtract(const Duration(hours: 2, minutes: 45)),
//           ),
//           BadmintonRoundModel(
//             roundNumber: 2,
//             team1Score: 19,
//             team2Score: 21,
//             status: BadmintonRoundStatus.completed,
//             winnerId: 'team2',
//             completedAt: now.subtract(const Duration(hours: 2, minutes: 30)),
//           ),
//           BadmintonRoundModel(
//             roundNumber: 3,
//             team1Score: 21,
//             team2Score: 16,
//             status: BadmintonRoundStatus.completed,
//             winnerId: 'team1',
//             completedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
//           ),
//         ],
//         winnerId: 'team1',
//       ),
      
//       // In-progress 2v2 match
//       BadmintonMatchModel(
//         matchId: '2',
//         matchType: BadmintonMatchType.doubles,
//         team1: BadmintonTeamModel(
//           teamId: 'team1_2',
//           players: [
//             BadmintonPlayerModel(playerId: 'p3', name: 'Vikas'),
//             BadmintonPlayerModel(playerId: 'p4', name: 'Suresh'),
//           ],
//         ),
//         team2: BadmintonTeamModel(
//           teamId: 'team2_2',
//           players: [
//             BadmintonPlayerModel(playerId: 'p5', name: 'Ravi'),
//             BadmintonPlayerModel(playerId: 'p6', name: 'Deepak'),
//           ],
//         ),
//         status: BadmintonMatchStatus.inProgress,
//         createdAt: now.subtract(const Duration(minutes: 30)),
//         currentRoundNumber: 1,
//         rounds: [
//           BadmintonRoundModel(
//             roundNumber: 1,
//             team1Score: 15,
//             team2Score: 12,
//             status: BadmintonRoundStatus.inProgress,
//             startedAt: now.subtract(const Duration(minutes: 30)),
//           ),
//         ],
//       ),
      
//       // In-progress 1v1 match (round 2)
//       BadmintonMatchModel(
//         matchId: '3',
//         matchType: BadmintonMatchType.singles,
//         team1: BadmintonTeamModel(
//           teamId: 'team1_3',
//           players: [
//             BadmintonPlayerModel(playerId: 'p7', name: 'Priya'),
//           ],
//         ),
//         team2: BadmintonTeamModel(
//           teamId: 'team2_3',
//           players: [
//             BadmintonPlayerModel(playerId: 'p8', name: 'Neha'),
//           ],
//         ),
//         status: BadmintonMatchStatus.inProgress,
//         createdAt: now.subtract(const Duration(hours: 1)),
//         currentRoundNumber: 2,
//         rounds: [
//           BadmintonRoundModel(
//             roundNumber: 1,
//             team1Score: 18,
//             team2Score: 21,
//             status: BadmintonRoundStatus.completed,
//             winnerId: 'team2',
//             completedAt: now.subtract(const Duration(minutes: 45)),
//           ),
//           BadmintonRoundModel(
//             roundNumber: 2,
//             team1Score: 8,
//             team2Score: 12,
//             status: BadmintonRoundStatus.inProgress,
//             startedAt: now.subtract(const Duration(minutes: 30)),
//           ),
//         ],
//       ),
//     ];
//   }
// }