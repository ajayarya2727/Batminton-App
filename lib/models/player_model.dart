class BadmintonPlayerModel {
  final String playerId;
  final String name;
  final int currentRoundScore;
  final int totalMatchScore;
  final List<int> roundScores; // Score in each round
  final int roundsWon;
  final int roundsLost;
  final bool isCurrentServer;

  const BadmintonPlayerModel({
    required this.playerId,
    required this.name,
    this.currentRoundScore = 0,
    this.totalMatchScore = 0,
    this.roundScores = const [],
    this.roundsWon = 0,
    this.roundsLost = 0,
    this.isCurrentServer = false,
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'name': name,
      'currentRoundScore': currentRoundScore,
      'isCurrentServer': isCurrentServer,
    };
  }

  // JSON deserialization
  factory BadmintonPlayerModel.fromJson(Map<String, dynamic> json) {
    return BadmintonPlayerModel(
      playerId: json['playerId'] as String,
      name: json['name'] as String,
      currentRoundScore: json['currentRoundScore'] as int? ?? 0,
      totalMatchScore: json['totalMatchScore'] as int? ?? 0,
      roundScores: (json['roundScores'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
      roundsWon: json['roundsWon'] as int? ?? 0,
      roundsLost: json['roundsLost'] as int? ?? 0,
      isCurrentServer: json['isCurrentServer'] as bool? ?? false,
    );
  }

  // Copy with method for immutability
  BadmintonPlayerModel copyWith({
    String? playerId,
    String? name,
    int? currentRoundScore,
    int? totalMatchScore,
    List<int>? roundScores,
    int? roundsWon,
    int? roundsLost,
    bool? isCurrentServer,
  }) {
    return BadmintonPlayerModel(
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      currentRoundScore: currentRoundScore ?? this.currentRoundScore,
      totalMatchScore: totalMatchScore ?? this.totalMatchScore,
      roundScores: roundScores ?? this.roundScores,
      roundsWon: roundsWon ?? this.roundsWon,
      roundsLost: roundsLost ?? this.roundsLost,
      isCurrentServer: isCurrentServer ?? this.isCurrentServer,
    );
  }

  // Helper methods
  double get averageScorePerRound {
    if (roundScores.isEmpty) return 0.0;
    return roundScores.reduce((a, b) => a + b) / roundScores.length;
  }

  double get winPercentage {
    final totalRounds = roundsWon + roundsLost;
    if (totalRounds == 0) return 0.0;
    return (roundsWon / totalRounds) * 100;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BadmintonPlayerModel &&
        other.playerId == playerId &&
        other.name == name;
  }

  @override
  int get hashCode => playerId.hashCode ^ name.hashCode;

  @override
  String toString() => 'BadmintonPlayerModel(playerId: $playerId, name: $name, currentScore: $currentRoundScore)';
}