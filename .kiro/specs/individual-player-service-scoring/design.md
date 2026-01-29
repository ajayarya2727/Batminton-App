# Design Document: Individual Player Service and Scoring System

## Overview

This design addresses critical architectural flaws in the badminton scoring app where service tracking and individual player scoring are incorrectly implemented at the team level. The current system violates badminton rules by showing service icons on all team players and storing team IDs instead of player IDs for service tracking.

The solution involves refactoring the service tracking system to use individual player IDs throughout the application, implementing proper individual player scoring, and updating the user interface to display service indicators accurately per player.

## Architecture

The fix involves changes across three main architectural layers:

### Data Layer
- **BadmintonRoundModel**: Update `currentServer` and `initialServer` fields to store player IDs instead of team IDs
- **BadmintonMatchModel**: Modify service-related methods to work with player IDs
- **Migration Logic**: Convert existing team-based service data to player-based data

### Business Logic Layer  
- **MatchController**: Update service selection dialogs and service tracking logic to use player IDs
- **Service Tracking**: Implement proper player-to-player service rotation logic
- **Individual Scoring**: Add player-level scoring attribution and tracking

### Presentation Layer
- **MatchDetailScreen**: Update service icon display logic to show icons only for the currently serving player
- **Service Selection Dialogs**: Modify to store player IDs instead of team IDs
- **Player Statistics**: Display individual player performance data

## Components and Interfaces

### Core Components

#### ServiceTracker
```dart
class ServiceTracker {
  // Track current serving player by player ID
  String? currentServingPlayerId;
  
  // Determine next serving player based on badminton rules
  String determineNextServer(String lastPointWinner, String currentServer);
  
  // Validate that player ID exists in current match
  bool isValidServingPlayer(String playerId, BadmintonMatchModel match);
  
  // Convert legacy team-based service data to player-based
  String migrateTeamServerToPlayerServer(String teamId, BadmintonMatchModel match);
}
```

#### PlayerScorer  
```dart
class PlayerScorer {
  // Attribute points to individual players
  void attributePointToPlayer(String playerId, int points);
  
  // Get individual player statistics
  BadmintonPlayerStats getPlayerStats(String playerId);
  
  // Calculate team totals from individual player scores
  int calculateTeamTotal(List<String> playerIds);
}
```

#### ServiceIconRenderer
```dart
class ServiceIconRenderer {
  // Determine if service icon should be shown for a specific player
  bool shouldShowServiceIcon(String playerId, String? currentServingPlayerId);
  
  // Render service icon widget for player
  Widget renderServiceIcon(String playerId, BadmintonMatchModel match);
}
```

### Data Model Updates

#### BadmintonRoundModel Changes
```dart
class BadmintonRoundModel {
  // CHANGED: Now stores player ID instead of team ID
  final String? currentServer; // Player ID: 'player_uuid_123'
  final String? initialServer; // Player ID: 'player_uuid_456'
  
  // NEW: Individual player scoring
  final Map<String, int> playerScores; // playerId -> points scored
  
  // ENHANCED: Point sequence with player attribution
  final List<PointEvent> pointSequence; // Who scored each point
}

class PointEvent {
  final String scoringPlayerId;
  final DateTime timestamp;
  final int pointValue; // Usually 1, but could be different for special scoring
}
```

#### BadmintonMatchModel Changes
```dart
class BadmintonMatchModel {
  // ENHANCED: Get current serving player ID (not team ID)
  String? get currentServingPlayerId => currentRound?.currentServer;
  
  // NEW: Get all player IDs in match
  List<String> get allPlayerIds => [
    ...team1.players.map((p) => p.playerId),
    ...team2.players.map((p) => p.playerId)
  ];
  
  // NEW: Get team ID for a given player ID
  String? getTeamIdForPlayer(String playerId);
  
  // NEW: Get player name for a given player ID
  String? getPlayerName(String playerId);
}
```

### Interface Contracts

#### IServiceTracker
```dart
abstract class IServiceTracker {
  String? getCurrentServingPlayer();
  void setCurrentServingPlayer(String playerId);
  String determineNextServingPlayer(String lastPointWinner);
  bool validateServingPlayer(String playerId);
}
```

#### IPlayerScorer
```dart
abstract class IPlayerScorer {
  void recordPlayerPoint(String playerId, int roundNumber);
  Map<String, int> getPlayerScores(int roundNumber);
  int getTeamScore(String teamId, int roundNumber);
  BadmintonPlayerStats generatePlayerStats(String playerId);
}
```

## Data Models

### Enhanced Point Tracking
```dart
class PointEvent {
  final String scoringPlayerId;
  final String servingPlayerId; // Who was serving when point was scored
  final DateTime timestamp;
  final int pointValue;
  final int roundNumber;
  
  const PointEvent({
    required this.scoringPlayerId,
    required this.servingPlayerId,
    required this.timestamp,
    this.pointValue = 1,
    required this.roundNumber,
  });
}
```

### Individual Player Statistics
```dart
class IndividualPlayerStats {
  final String playerId;
  final String playerName;
  final int totalPointsScored;
  final int pointsScoredWhileServing;
  final int pointsScoredWhileReceiving;
  final Map<int, int> pointsPerRound;
  final List<String> serviceSequence; // Track service history
  
  // Computed properties
  double get serviceEfficiency => pointsScoredWhileServing / serviceSequence.length;
  double get receivingEfficiency => pointsScoredWhileReceiving / totalReceivingOpportunities;
}
```

### Migration Data Structure
```dart
class ServiceMigrationData {
  final String oldTeamId;
  final String newPlayerId;
  final DateTime migrationTimestamp;
  final String migrationReason;
  
  // Convert team-based service to player-based service
  static String migrateTeamToPlayer(String teamId, BadmintonMatchModel match) {
    // Default to first player in team for migration
    final team = teamId == 'team1' ? match.team1 : match.team2;
    return team.players.first.playerId;
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Player ID Service Storage Consistency
*For any* badminton match operation involving service tracking, all service-related fields (currentServer, initialServer) should store valid player IDs and never team IDs
**Validates: Requirements 1.1, 1.5, 6.1, 6.2**

### Property 2: Service Icon Display Uniqueness  
*For any* match display state, exactly one service icon should be visible and it should appear next to the player whose ID matches the currentServer field
**Validates: Requirements 2.1, 2.2, 2.4**

### Property 3: Service Icon State Transitions
*For any* service change operation, the service icon should disappear from the previous serving player and appear next to the new serving player
**Validates: Requirements 2.3**

### Property 4: Service Icon Null State Handling
*For any* match state where currentServer is null or empty, no service icons should be displayed
**Validates: Requirements 2.5**

### Property 5: Service Selection Dialog Player ID Operations
*For any* service selection dialog interaction, the dialog should display individual players with their player IDs and store the selected player's ID as currentServer
**Validates: Requirements 3.1, 3.2, 3.4**

### Property 6: Service Selection Validation
*For any* service selection attempt, the system should validate that the selected ID is a valid player ID before accepting the selection
**Validates: Requirements 3.5, 6.5**

### Property 7: Individual Player Point Attribution
*For any* point scoring event, the point should be attributed to the specific player who scored it and reflected in individual player statistics
**Validates: Requirements 4.1, 4.2**

### Property 8: Team Score Consistency
*For any* match state, the team total scores should equal the sum of individual player scores within that team
**Validates: Requirements 4.4**

### Property 9: Service Rotation After Point Scoring
*For any* point scoring event, the service should update to the player ID of the player who scored the point
**Validates: Requirements 1.4, 5.1**

### Property 10: Service and Scoring Integration Consistency
*For any* sequence of service changes and point scoring, the service tracking and individual scoring systems should remain consistent with each other
**Validates: Requirements 5.2, 5.4**

### Property 11: Undo Operation Service Consistency
*For any* score undo operation, the service should revert to the correct previous serving player based on the updated point sequence
**Validates: Requirements 5.3**

### Property 12: Data Persistence Round Trip
*For any* valid match with individual player service and scoring data, serializing then deserializing should produce equivalent player IDs and individual scores
**Validates: Requirements 6.3, 6.4**

### Property 13: Legacy Data Migration
*For any* existing match data with team-based service tracking, the migration process should convert team IDs to valid player IDs from the corresponding team
**Validates: Requirements 7.1, 7.2, 7.3**

### Property 14: Backward Compatibility During Migration
*For any* system state during migration, both legacy team-based and new player-based service data should be handled correctly
**Validates: Requirements 7.4**

### Property 15: Individual Player UI Display
*For any* UI component displaying player information, individual players should be shown separately with their own service indicators and statistics
**Validates: Requirements 8.1, 8.2, 8.5**

### Property 16: Service Change User Feedback
*For any* service change operation, the user interface should provide clear feedback indicating which specific player is now serving
**Validates: Requirements 8.3**

### Property 17: Data Preservation Across Round Boundaries
*For any* round completion, both individual service history and individual scoring data should be preserved in the match data
**Validates: Requirements 4.5, 5.5**

## Error Handling

### Service Tracking Errors
- **Invalid Player ID**: When an invalid player ID is provided for service tracking, the system should reject the operation and maintain the current valid state
- **Missing Current Server**: When currentServer is null during active play, the system should prompt for service selection or default to a valid player
- **Player Not in Match**: When a player ID is provided that doesn't belong to either team in the match, the system should reject the operation

### Individual Scoring Errors  
- **Point Attribution Failure**: When a point cannot be attributed to a specific player, the system should prompt for manual attribution or use the current serving player as default
- **Score Inconsistency**: When individual player scores don't sum to team totals, the system should flag the inconsistency and provide correction options
- **Negative Scores**: When score operations would result in negative individual player scores, the system should prevent the operation

### Migration Errors
- **Legacy Data Corruption**: When legacy team-based service data cannot be migrated, the system should log the error and use default player assignments
- **Missing Player Data**: When team IDs reference teams with no players, the system should create placeholder players or prompt for data correction
- **Partial Migration**: When migration is incomplete, the system should continue to support both formats until migration can be completed

### UI Error Handling
- **Service Icon Rendering Failure**: When service icons cannot be displayed, the system should fall back to text-based service indicators
- **Dialog Display Errors**: When service selection dialogs fail to display, the system should provide alternative service selection methods
- **Player Name Display Issues**: When player names cannot be displayed, the system should fall back to player IDs

## Testing Strategy

### Dual Testing Approach
The testing strategy employs both unit tests and property-based tests to ensure comprehensive coverage:

**Unit Tests** focus on:
- Specific examples of service tracking scenarios
- Edge cases like null currentServer states
- Integration points between service tracking and scoring systems
- Migration of specific legacy data formats
- UI component rendering with known player configurations

**Property-Based Tests** focus on:
- Universal properties that hold across all valid player and match configurations
- Service tracking consistency across random match sequences
- Individual scoring accuracy with randomized point attribution
- Data serialization round-trip properties with random match data
- UI display properties across random player and service combinations

### Property-Based Testing Configuration
- **Testing Framework**: Use Flutter's built-in test framework with the `test` package and `faker` for generating random test data
- **Minimum Iterations**: Each property test runs for minimum 100 iterations to ensure comprehensive input coverage
- **Test Data Generation**: Generate random matches with varying numbers of players, service states, and scoring scenarios
- **Property Test Tags**: Each property test includes a comment tag referencing its design document property

**Tag Format**: `// Feature: individual-player-service-scoring, Property {number}: {property_text}`

### Test Coverage Requirements
- **Service Tracking**: All service-related operations must be covered by both unit and property tests
- **Individual Scoring**: All player scoring operations must be validated through property tests
- **Data Migration**: Legacy data migration must be tested with both known examples and generated legacy data
- **UI Components**: All service-related UI components must be tested for correct player ID usage
- **Integration**: Service and scoring integration must be validated through comprehensive property tests

The combination of unit tests and property-based tests ensures that both specific known scenarios work correctly and that the universal properties hold across all possible valid inputs, providing confidence in the system's correctness and robustness.