class BreakRecord {
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;

  const BreakRecord({
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
  });

  // Check if break is currently active (not ended yet)
  bool get isActive => endTime == null;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  // JSON deserialization
  factory BreakRecord.fromJson(Map<String, dynamic> json) {
    return BreakRecord(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }

  // Copy with method
  BreakRecord copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
  }) {
    return BreakRecord(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  // End the break and calculate duration
  BreakRecord end() {
    if (!isActive) return this; // Already ended
    
    final now = DateTime.now();
    final duration = now.difference(startTime).inSeconds;
    return copyWith(
      endTime: now,
      durationSeconds: duration,
    );
  }

  @override
  String toString() => 'BreakRecord(start: $startTime, end: $endTime, duration: ${durationSeconds}s)';
}


/// Helper class to manage multiple breaks in a round
class BreakManager {
  final List<BreakRecord> breaks;

  const BreakManager({this.breaks = const []});

  // Get total number of breaks
  int get breakCount => breaks.length;

  // Get total duration of all breaks (in seconds)
  int get totalDurationSeconds {
    return breaks.fold<int>(0, (sum, breakRecord) => sum + breakRecord.durationSeconds);
  }

  // Check if there's an active break
  bool get hasActiveBreak => breaks.any((b) => b.isActive);

  // Get the currently active break (if any)
  BreakRecord? get activeBreak => breaks.firstWhere(
    (b) => b.isActive,
    orElse: () => breaks.isEmpty ?  BreakRecord(startTime: DateTime.now()) : breaks.last,
  );

  // Start a new break
  BreakManager startBreak() {
    // Don't start a new break if one is already active
    if (hasActiveBreak) return this;

    final newBreak = BreakRecord(startTime: DateTime.now());
    final updatedBreaks = List<BreakRecord>.from(breaks)..add(newBreak);
    return BreakManager(breaks: updatedBreaks);
  }

  // End the current active break
  BreakManager endBreak() {
    if (!hasActiveBreak) return this;

    final updatedBreaks = breaks.map((breakRecord) {
      if (breakRecord.isActive) {
        return breakRecord.end();
      }
      return breakRecord;
    }).toList();

    return BreakManager(breaks: updatedBreaks);
  }

  // Convert to JSON
  List<Map<String, dynamic>> toJson() {
    return breaks.map((b) => b.toJson()).toList();
  }

  // Create from JSON
  static BreakManager fromJson(List<dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const BreakManager();
    }

    final breaksList = json
        .map((item) => BreakRecord.fromJson(item as Map<String, dynamic>))
        .toList();

    return BreakManager(breaks: breaksList);
  }

  @override
  String toString() => 'BreakManager(breaks: $breakCount, totalDuration: ${totalDurationSeconds}s)';
}
