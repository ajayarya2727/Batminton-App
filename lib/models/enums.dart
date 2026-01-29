// =============================================================================
// ENUMS - Match Types and Status
// =============================================================================

enum BadmintonMatchType {
  singles('1v1', 'Singles'),
  doubles('2v2', 'Doubles');

  const BadmintonMatchType(this.code, this.displayName);
  
  final String code;
  final String displayName;

  static BadmintonMatchType fromCode(String code) {
    switch (code) {
      case '1v1':
        return BadmintonMatchType.singles;
      case '2v2':
        return BadmintonMatchType.doubles;
      default:
        throw ArgumentError('Invalid match type code: $code');
    }
  }

  int get requiredPlayersPerTeam {
    switch (this) {
      case BadmintonMatchType.singles:
        return 1;
      case BadmintonMatchType.doubles:
        return 2;
    }
  }
}

enum BadmintonMatchStatus {
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed'),
  paused('paused', 'Paused'),
  cancelled('cancelled', 'Cancelled');

  const BadmintonMatchStatus(this.code, this.displayName);
  
  final String code;
  final String displayName;

  static BadmintonMatchStatus fromCode(String code) {
    switch (code) {
      case 'in_progress':
        return BadmintonMatchStatus.inProgress;
      case 'completed':
        return BadmintonMatchStatus.completed;
      case 'paused':
        return BadmintonMatchStatus.paused;
      case 'cancelled':
        return BadmintonMatchStatus.cancelled;
      default:
        throw ArgumentError('Invalid match status code: $code');
    }
  }

  bool get isActive => this == BadmintonMatchStatus.inProgress;
  bool get isFinished => this == BadmintonMatchStatus.completed || this == BadmintonMatchStatus.cancelled;
}

enum BadmintonRoundStatus {
  notStarted('not_started', 'Not Started'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed');

  const BadmintonRoundStatus(this.code, this.displayName);
  
  final String code;
  final String displayName;

  static BadmintonRoundStatus fromCode(String code) {
    switch (code) {
      case 'not_started':
        return BadmintonRoundStatus.notStarted;
      case 'in_progress':
        return BadmintonRoundStatus.inProgress;
      case 'completed':
        return BadmintonRoundStatus.completed;
      default:
        throw ArgumentError('Invalid round status code: $code');
    }
  }
}