# Requirements Document

## Introduction

This feature implements proper 3-round badminton match functionality in the Flutter app. Currently, the app only supports single-round matches that end when a team reaches 21 or 30 points with a popup asking to continue. The new system will implement best-of-3 rounds where the first team to win 2 rounds wins the overall match, while maintaining the existing 21/30 point logic for individual rounds.

## Glossary

- **Match**: The overall competition between two teams, consisting of up to 3 rounds
- **Round**: An individual game within a match that follows the 21/30 point scoring rules
- **Round_Score**: The points accumulated by each team within a single round
- **Match_Score**: The number of rounds won by each team (0-2)
- **Scoring_System**: The existing 21/30 point logic with popup at 21 and auto-end at 30
- **Best_of_Three**: Match format where first team to win 2 rounds wins the match
- **Round_Transition**: The process of moving from one completed round to the next

## Requirements

### Requirement 1: Multi-Round Match Structure

**User Story:** As a badminton player, I want matches to consist of up to 3 rounds with best-of-3 scoring, so that matches follow proper badminton tournament rules.

#### Acceptance Criteria

1. WHEN a new match is created, THE Match_System SHALL initialize with round 1 of 3
2. THE Match_System SHALL track the current round number (1, 2, or 3)
3. THE Match_System SHALL maintain separate Round_Scores for each completed and current round
4. THE Match_System SHALL track Match_Score as rounds won by each team (0-2)
5. WHEN 2 rounds are completed without a match winner, THE Match_System SHALL automatically start round 3

### Requirement 2: Individual Round Scoring

**User Story:** As a badminton player, I want each round to follow the existing 21/30 point logic, so that individual round gameplay remains familiar.

#### Acceptance Criteria

1. WHEN a team reaches 21 points in any round, THE Scoring_System SHALL display the existing popup asking to continue
2. WHEN a team reaches 30 points in any round, THE Scoring_System SHALL automatically end that round
3. WHEN a round ends at 21 points (user chooses not to continue), THE Match_System SHALL determine the round winner
4. WHEN a round ends at 30 points, THE Match_System SHALL determine the round winner
5. THE Scoring_System SHALL reset Round_Scores to 0-0 when starting each new round

### Requirement 3: Round Completion and Transition

**User Story:** As a badminton player, I want completed rounds to automatically transition to the next round when the match isn't over, so that gameplay flows smoothly.

#### Acceptance Criteria

1. WHEN a round ends and neither team has won 2 rounds, THE Match_System SHALL increment the Match_Score for the round winner
2. WHEN a round ends and neither team has won 2 rounds, THE Match_System SHALL automatically start the next round
3. WHEN a round ends and one team reaches 2 round wins, THE Match_System SHALL end the entire match
4. WHEN transitioning between rounds, THE Match_System SHALL preserve all previous Round_Scores
5. WHEN starting a new round, THE Round_Transition SHALL reset the current Round_Scores to 0-0

### Requirement 4: Match Completion Logic

**User Story:** As a badminton player, I want the match to end when one team wins 2 out of 3 rounds, so that matches follow best-of-3 tournament format.

#### Acceptance Criteria

1. WHEN a team wins their second round, THE Match_System SHALL immediately end the entire match
2. THE Match_System SHALL declare the team with 2 round wins as the overall match winner
3. WHEN a match ends, THE Match_System SHALL prevent further scoring or round progression
4. THE Match_System SHALL preserve the final Match_Score and all Round_Scores for match history

### Requirement 5: User Interface Updates

**User Story:** As a badminton player, I want to see the current round number and all round scores during play, so that I can track match progress.

#### Acceptance Criteria

1. THE UI SHALL display the current round number (e.g., "Round 2 of 3")
2. THE UI SHALL display the Match_Score showing rounds won by each team (e.g., "Team A: 1, Team B: 0")
3. THE UI SHALL display Round_Scores for all completed rounds
4. THE UI SHALL display the current Round_Score prominently during active play
5. WHEN a round completes, THE UI SHALL briefly show the round result before transitioning

### Requirement 6: Data Persistence

**User Story:** As a badminton player, I want match data to include all round information, so that I can review complete match history.

#### Acceptance Criteria

1. THE Match_Model SHALL store individual Round_Scores for each completed round
2. THE Match_Model SHALL store the current Match_Score (rounds won by each team)
3. THE Match_Model SHALL store the current round number
4. THE Match_Model SHALL store the overall match winner when the match completes
5. WHEN saving match data, THE Match_System SHALL preserve all round-by-round scoring history

### Requirement 7: Backward Compatibility

**User Story:** As an existing app user, I want the new multi-round system to work with existing match data, so that my previous matches remain accessible.

#### Acceptance Criteria

1. WHEN loading existing single-round matches, THE Match_System SHALL treat them as completed 1-round matches
2. THE Match_System SHALL display legacy matches appropriately in the match history
3. WHEN creating new matches, THE Match_System SHALL default to the new 3-round format
4. THE Match_Model SHALL handle both legacy single-round and new multi-round data structures
5. THE UI SHALL clearly distinguish between legacy single-round and new multi-round matches in the match list