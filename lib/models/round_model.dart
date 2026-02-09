import 'enums.dart';

class BadmintonRoundModel {
  final int roundNumber;
  final int team1Score;
  final int team2Score;
  final BadmintonRoundStatus status;
  final String? winnerId;
  final bool milestone21Reached;
  final bool continueTo30Chosen; // Flag to track if user chose "Continue to 30"
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? currentServer; // Player ID who is currently serving
  final String? initialServer; // Who started serving this round
  final List<String> pointSequence; // Track who won each point: ['team1', 'team2', 'team1', ...]
  final Map<String, int> playerScores; // Individual player scores: playerId -> points scored

  const BadmintonRoundModel({
    required this.roundNumber,
    this.team1Score = 0,
    this.team2Score = 0,
    this.status = BadmintonRoundStatus.notStarted,
    this.winnerId,
    this.milestone21Reached = false,
    this.continueTo30Chosen = false,
    this.startedAt,
    this.completedAt,
    this.currentServer,
    this.initialServer,
    this.pointSequence = const [],
    this.playerScores = const {},
  });

  // Computed properties
  bool get isCompleted => status == BadmintonRoundStatus.completed;
  bool get isInProgress => status == BadmintonRoundStatus.inProgress;
  bool get hasWinner => winnerId != null;
  bool get hasReached21Points => team1Score >= 21 || team2Score >= 21;
  bool get hasReached30Points => team1Score >= 30 || team2Score >= 30;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'status': status.code,
      'winnerId': winnerId,
      'milestone21Reached': milestone21Reached,
      'continueTo30Chosen': continueTo30Chosen,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentServer': currentServer,
      'initialServer': initialServer,
      'pointSequence': pointSequence,
      'playerScores': playerScores,
    };
  }

  // JSON deserialization
  factory BadmintonRoundModel.fromJson(Map<String, dynamic> json) {
    return BadmintonRoundModel(
      roundNumber: json['roundNumber'] as int,
      team1Score: json['team1Score'] as int? ?? 0,
      team2Score: json['team2Score'] as int? ?? 0,
      status: BadmintonRoundStatus.fromCode(json['status'] as String? ?? 'not_started'),
      winnerId: json['winnerId'] as String?,
      milestone21Reached: json['milestone21Reached'] as bool? ?? false,
      continueTo30Chosen: json['continueTo30Chosen'] as bool? ?? false,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      currentServer: json['currentServer'] as String?,
      initialServer: json['initialServer'] as String?,
      pointSequence: (json['pointSequence'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? 
          // Fallback for old serviceHistory format
          (json['serviceHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      playerScores: Map<String, int>.from(json['playerScores'] as Map<String, dynamic>? ?? {}),
    );
  }

  // Copy with method
  BadmintonRoundModel copyWith({
    int? roundNumber,
    int? team1Score,
    int? team2Score,
    BadmintonRoundStatus? status,
    String? winnerId,
    bool? milestone21Reached,
    bool? continueTo30Chosen,
    DateTime? startedAt,
    DateTime? completedAt,
    String? currentServer,
    String? initialServer,
    List<String>? pointSequence,
    Map<String, int>? playerScores,
  }) {
    return BadmintonRoundModel(
      roundNumber: roundNumber ?? this.roundNumber,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      milestone21Reached: milestone21Reached ?? this.milestone21Reached,
      continueTo30Chosen: continueTo30Chosen ?? this.continueTo30Chosen,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentServer: currentServer ?? this.currentServer,
      initialServer: initialServer ?? this.initialServer,
      pointSequence: pointSequence ?? this.pointSequence,
      playerScores: playerScores ?? this.playerScores,
    );
  }

  // Helper methods
  BadmintonRoundModel start({String? initialServer}) {
    return copyWith(
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
      currentServer: initialServer,
      initialServer: initialServer,
      pointSequence: [], // Empty at start
      playerScores: {}, // Empty at start
    );
  }

  BadmintonRoundModel complete(String winnerId) {
    return copyWith(
      status: BadmintonRoundStatus.completed,
      winnerId: winnerId,
      completedAt: DateTime.now(),
    );
  }

  BadmintonRoundModel updateScores(int team1Score, int team2Score) {
    return copyWith(
      team1Score: team1Score,
      team2Score: team2Score,
    );
  }

  BadmintonRoundModel markMilestone21Reached() {
    return copyWith(milestone21Reached: true);
  }

  BadmintonRoundModel markContinueTo30Chosen() {
    return copyWith(continueTo30Chosen: true);
  }

  BadmintonRoundModel updateServer(String newServer) {
    return copyWith(currentServer: newServer);
  }

  @override
  String toString() => 'BadmintonRoundModel(round: $roundNumber, score: $team1Score-$team2Score, status: ${status.displayName})';
}