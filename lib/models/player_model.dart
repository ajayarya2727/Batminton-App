class BadmintonPlayerModel {
  final String playerId;
  final String name;
  final int currentRoundScore;
  final bool isCurrentServer;

  const BadmintonPlayerModel({
    required this.playerId,
    required this.name,
    this.currentRoundScore = 0,
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
      isCurrentServer: json['isCurrentServer'] as bool? ?? false,
    );
  }

  // Copy with method for immutability
  BadmintonPlayerModel copyWith({
    String? playerId,
    String? name,
    int? currentRoundScore,
    bool? isCurrentServer,
  }) {
    return BadmintonPlayerModel(
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      currentRoundScore: currentRoundScore ?? this.currentRoundScore,
      isCurrentServer: isCurrentServer ?? this.isCurrentServer,
    );
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