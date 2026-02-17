import 'enums.dart';
import 'team_model.dart';
import 'round_model.dart';

/// Pure data model for Badminton Match
/// Contains ONLY data fields, no business logic
class BadmintonMatchModel {
  final String matchId;
  final BadmintonMatchType matchType;
  final BadmintonTeamModel team1;
  final BadmintonTeamModel team2;
  final BadmintonMatchStatus status;
  final DateTime createdAt;
  final int currentRoundNumber;
  final List<BadmintonRoundModel> rounds;
  final String? winnerId;

  const BadmintonMatchModel({
    required this.matchId,
    required this.matchType,
    required this.team1,
    required this.team2,
    this.status = BadmintonMatchStatus.inProgress,
    required this.createdAt,
    this.currentRoundNumber = 1,
    this.rounds = const [],
    this.winnerId,
  });

  // ==================== JSON SERIALIZATION ====================
  
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'matchType': matchType.displayName,
      'team1': team1.toJson(),
      'team2': team2.toJson(),
      'status': status.code,
      'matchCreatedAt': createdAt.toIso8601String(),
      'currentRoundNumber': currentRoundNumber,
      'rounds': rounds.map((round) => round.toJson()).toList(),
      'winnerId': winnerId,
    };
  }

  // ==================== JSON DESERIALIZATION ====================
  
  factory BadmintonMatchModel.fromJson(Map<String, dynamic> json) {
    return BadmintonMatchModel(
      matchId: json['matchId'] as String? ?? json['id'] as String,
      matchType: BadmintonMatchType.fromCode(json['matchType'] as String),
      team1: BadmintonTeamModel.fromJson(json['team1'] as Map<String, dynamic>),
      team2: BadmintonTeamModel.fromJson(json['team2'] as Map<String, dynamic>),
      status: BadmintonMatchStatus.fromCode(json['status'] as String? ?? 'in_progress'),
      createdAt: DateTime.parse(json['matchCreatedAt'] as String? ?? json['createdAt'] as String),
      currentRoundNumber: json['currentRoundNumber'] as int? ?? 1,
      rounds: (json['rounds'] as List<dynamic>?)
          ?.map((r) => BadmintonRoundModel.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      winnerId: json['winnerId'] as String?,
    );
  }

  // ==================== COPY WITH METHOD ====================
  
  BadmintonMatchModel copyWith({
    String? matchId,
    BadmintonMatchType? matchType,
    BadmintonTeamModel? team1,
    BadmintonTeamModel? team2,
    BadmintonMatchStatus? status,
    DateTime? createdAt,
    int? currentRoundNumber,
    List<BadmintonRoundModel>? rounds,
    String? winnerId,
  }) {
    return BadmintonMatchModel(
      matchId: matchId ?? this.matchId,
      matchType: matchType ?? this.matchType,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      currentRoundNumber: currentRoundNumber ?? this.currentRoundNumber,
      rounds: rounds ?? this.rounds,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  @override
  String toString() => 'BadmintonMatchModel(id: $matchId, type: ${matchType.displayName}, status: ${status.displayName})';
}
