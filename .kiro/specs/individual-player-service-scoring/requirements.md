# Requirements Document

## Introduction

This specification addresses critical issues in the badminton scoring app where service tracking and scoring are incorrectly implemented at the team level instead of the individual player level. The current system shows service icons on both players in a team and stores team IDs instead of player IDs for service tracking, which violates badminton rules where service is tracked per individual player.

## Glossary

- **Service_Tracker**: The system component responsible for tracking which individual player is currently serving
- **Player_Scorer**: The system component responsible for tracking individual player scores
- **Service_Icon**: The visual indicator (🏸) that shows which specific player is currently serving
- **Player_ID**: Unique identifier for an individual player (not team)
- **Team_ID**: Unique identifier for a team containing multiple players
- **Current_Server**: The player ID of the individual player who is currently serving
- **Service_Selection_Dialog**: UI component for selecting which individual player should serve
- **Match_Detail_Screen**: The main screen displaying match scores and service indicators

## Requirements

### Requirement 1: Individual Player Service Tracking

**User Story:** As a badminton match participant, I want the service to be tracked per individual player, so that the correct player serves according to badminton rules.

#### Acceptance Criteria

1. WHEN a match starts, THE Service_Tracker SHALL store the serving player's Player_ID instead of Team_ID
2. WHEN service changes during a match, THE Service_Tracker SHALL update to the new serving player's Player_ID
3. WHEN displaying service information, THE System SHALL reference individual Player_IDs not Team_IDs
4. WHEN a point is scored, THE Service_Tracker SHALL determine the next serving player based on individual player rotation rules
5. THE Current_Server field SHALL store Player_ID values exclusively

### Requirement 2: Service Icon Display Accuracy

**User Story:** As a match observer, I want to see the service icon only on the player who is currently serving, so that I can clearly identify who should serve next.

#### Acceptance Criteria

1. WHEN displaying the match screen, THE Match_Detail_Screen SHALL show the Service_Icon only next to the currently serving player
2. WHEN the Current_Server is a specific Player_ID, THE Service_Icon SHALL appear only next to that player's name
3. WHEN service changes to a different player, THE Service_Icon SHALL move to the new serving player and disappear from the previous player
4. THE Service_Icon SHALL NOT appear on multiple players simultaneously
5. WHEN no Current_Server is set, THE Service_Icon SHALL not be displayed

### Requirement 3: Service Selection Dialog Accuracy

**User Story:** As a match administrator, I want to select individual players for service, so that the correct player ID is stored and tracked.

#### Acceptance Criteria

1. WHEN the Service_Selection_Dialog is displayed, THE System SHALL show individual player options with their Player_IDs
2. WHEN a player is selected from the Service_Selection_Dialog, THE System SHALL store that player's Player_ID as the Current_Server
3. WHEN service is manually changed, THE System SHALL update the Current_Server to the selected player's Player_ID
4. THE Service_Selection_Dialog SHALL NOT store or reference Team_IDs for service tracking
5. WHEN confirming service selection, THE System SHALL validate that the selected ID is a valid Player_ID

### Requirement 4: Individual Player Scoring System

**User Story:** As a badminton player, I want my individual score to be tracked separately from my teammate's score, so that individual performance can be measured.

#### Acceptance Criteria

1. WHEN a point is scored, THE Player_Scorer SHALL attribute the point to the individual player who scored it
2. WHEN displaying player statistics, THE System SHALL show individual player scores separately
3. WHEN generating match scorecards, THE System SHALL include individual player scoring data
4. THE System SHALL maintain both individual player scores and team totals
5. WHEN a match is completed, THE System SHALL preserve individual player scoring history

### Requirement 5: Service and Scoring Integration

**User Story:** As a match participant, I want service tracking and individual scoring to work together correctly, so that the match follows proper badminton rules.

#### Acceptance Criteria

1. WHEN an individual player scores a point, THE Service_Tracker SHALL update to that player's Player_ID for the next serve
2. WHEN service rotates between players, THE Player_Scorer SHALL continue tracking individual scores correctly
3. WHEN undoing scores, THE Service_Tracker SHALL revert to the correct previous serving player
4. THE System SHALL maintain consistency between individual player service tracking and individual player scoring
5. WHEN a round completes, THE System SHALL preserve both individual service history and individual scoring data

### Requirement 6: Data Model Consistency

**User Story:** As a system maintainer, I want all data models to consistently use Player_IDs for individual player operations, so that the system maintains data integrity.

#### Acceptance Criteria

1. THE BadmintonRoundModel.currentServer field SHALL store Player_ID values exclusively
2. THE BadmintonRoundModel.initialServer field SHALL store Player_ID values exclusively  
3. WHEN serializing match data, THE System SHALL preserve Player_ID references for service tracking
4. WHEN deserializing match data, THE System SHALL correctly restore Player_ID references for service tracking
5. THE System SHALL validate that all service-related fields contain valid Player_IDs before processing

### Requirement 7: Backward Compatibility and Migration

**User Story:** As a system user, I want existing matches to continue working after the fix, so that no match data is lost.

#### Acceptance Criteria

1. WHEN loading existing matches with Team_ID service data, THE System SHALL migrate them to use Player_IDs
2. WHEN encountering legacy service data, THE System SHALL convert Team_IDs to the first player's Player_ID in that team
3. WHEN saving migrated matches, THE System SHALL use the new Player_ID format
4. THE System SHALL handle both old and new data formats during the transition period
5. WHEN migration is complete, THE System SHALL function entirely with Player_ID service tracking

### Requirement 8: User Interface Updates

**User Story:** As a match participant, I want the user interface to clearly show individual player service and scoring information, so that I can follow the match progress accurately.

#### Acceptance Criteria

1. WHEN displaying match information, THE Match_Detail_Screen SHALL show individual player names with correct service indicators
2. WHEN showing service selection options, THE Service_Selection_Dialog SHALL display individual player names and IDs clearly
3. WHEN service changes, THE User_Interface SHALL provide clear feedback about which individual player is now serving
4. THE User_Interface SHALL distinguish between individual players visually in service selection
5. WHEN displaying match statistics, THE System SHALL show individual player performance data separately