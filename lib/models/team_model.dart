import 'player_model.dart';

class BadmintonTeamModel {
  final String teamId;
  final String teamName; // Team name field
  final String teamLogo; // Team logo field
  final List<BadmintonPlayerModel> players;

  const BadmintonTeamModel({
    required this.teamId,
    this.teamName = '', // Default empty team name
    this.teamLogo = '🏸', // Default logo
    required this.players,
  });

  // Computed properties
  String get displayName => teamName.isNotEmpty ? teamName : players.map((p) => p.name).join(' & ');
  int get playersCount => players.length;

  // Validation
  bool isValidForMatchType(int requiredPlayers) {
    return players.length == requiredPlayers && 
           players.every((player) => player.name.trim().isNotEmpty);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamLogo': teamLogo,
      'players': players.map((player) => player.toJson()).toList(),
    };
  }

  // JSON deserialization
  factory BadmintonTeamModel.fromJson(Map<String, dynamic> json) {
    return BadmintonTeamModel(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String? ?? '',
      teamLogo: json['teamLogo'] as String? ?? '🏸',
      players: (json['players'] as List<dynamic>)
          .map((playerJson) => BadmintonPlayerModel.fromJson(playerJson as Map<String, dynamic>))
          .toList(),
    );
  }

  // Copy with method
  BadmintonTeamModel copyWith({
    String? teamId,
    String? teamName,
    String? teamLogo,
    List<BadmintonPlayerModel>? players,
  }) {
    return BadmintonTeamModel(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      teamLogo: teamLogo ?? this.teamLogo,
      players: players ?? this.players,
    );
  }

  @override
  String toString() => 'BadmintonTeamModel(teamId: $teamId, teamName: $teamName, players: ${players.length})';
}