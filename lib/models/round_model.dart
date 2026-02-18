import 'enums.dart';
import 'break_record.dart';

class BadmintonRoundModel {
  final int roundNumber;
  final int team1Score;
  final int team2Score;
  final BadmintonRoundStatus status;
  final String? winnerId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? currentServer;
  final String? initialServer;
  final List<String> pointSequence;
  final Map<String, int> playerScores;
  
  final List<BreakRecord> breaks;

  const BadmintonRoundModel({
    required this.roundNumber,
    this.team1Score = 0,
    this.team2Score = 0,
    this.status = BadmintonRoundStatus.notStarted,
    this.winnerId,
    this.startedAt,
    this.completedAt,
    this.currentServer,
    this.initialServer,
    this.pointSequence = const [],
    this.playerScores = const {},
    this.breaks = const [],
  });

  bool get isCompleted => status == BadmintonRoundStatus.completed;
  bool get isInProgress => status == BadmintonRoundStatus.inProgress;
  bool get hasWinner => winnerId != null;
  
  int get breakCount => breaks.length;
  int get totalBreakDurationSeconds => breaks.fold<int>(0, (sum, b) => sum + b.durationSeconds);
  bool get hasActiveBreak => breaks.any((b) => b.isActive);

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'status': status.code,
      'winnerId': winnerId,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentServer': currentServer,
      'initialServer': initialServer,
      'breaks': breaks.map((breakrecord) => breakrecord.toJson()).toList(),
      'breakCount': breakCount,
      'totalBreakDurationSeconds': totalBreakDurationSeconds,
    };
  }

  factory BadmintonRoundModel.fromJson(Map<String, dynamic> json) {
    return BadmintonRoundModel(
      roundNumber: json['roundNumber'] as int,
      team1Score: json['team1Score'] as int? ?? 0,
      team2Score: json['team2Score'] as int? ?? 0,
      status: BadmintonRoundStatus.fromCode(json['status'] as String? ?? 'not_started'),
      winnerId: json['winnerId'] as String?,
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
          (json['serviceHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      playerScores: Map<String, int>.from(json['playerScores'] as Map<String, dynamic>? ?? {}),
      breaks: (json['breaks'] as List<dynamic>?)
          ?.map((item) => BreakRecord.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  BadmintonRoundModel copyWith({
    int? roundNumber,
    int? team1Score,
    int? team2Score,
    BadmintonRoundStatus? status,
    String? winnerId,
    DateTime? startedAt,
    DateTime? completedAt,
    String? currentServer,
    String? initialServer,
    List<String>? pointSequence,
    Map<String, int>? playerScores,
    List<BreakRecord>? breaks,
  }) {
    return BadmintonRoundModel(
      roundNumber: roundNumber ?? this.roundNumber,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentServer: currentServer ?? this.currentServer,
      initialServer: initialServer ?? this.initialServer,
      pointSequence: pointSequence ?? this.pointSequence,
      playerScores: playerScores ?? this.playerScores,
      breaks: breaks ?? this.breaks,
    );
  }

  BadmintonRoundModel start({String? initialServer}) {
    return copyWith(
      status: BadmintonRoundStatus.inProgress,
      startedAt: DateTime.now(),
      currentServer: initialServer,
      initialServer: initialServer,
      pointSequence: [],
      playerScores: {},
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

  BadmintonRoundModel updateServer(String newServer) {
    return copyWith(currentServer: newServer);
  }

  BadmintonRoundModel takeBreak() {
    final manager = BreakManager(breaks: breaks);
    final updated = manager.startBreak();
    return copyWith(breaks: updated.breaks);
  }

  BadmintonRoundModel resumeFromBreak() {
    final manager = BreakManager(breaks: breaks);
    final updated = manager.endBreak();
    return copyWith(breaks: updated.breaks);
  }

  @override
  String toString() => 'BadmintonRoundModel(round: $roundNumber, score: $team1Score-$team2Score, status: ${status.displayName})';
}