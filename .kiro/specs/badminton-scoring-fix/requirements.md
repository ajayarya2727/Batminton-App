# Requirements Document

## Introduction

This specification addresses a critical bug in the badminton scoring system where multiple teams can receive the "continue playing" popup when reaching 21 points. The system should only show this popup to the FIRST team that reaches 21 points, and automatically end the match at 30 points without any popup.

## Glossary

- **Scoring_System**: The Flutter application component responsible for managing badminton match scores
- **Continue_Popup**: The dialog shown when a team reaches 21 points asking if they want to continue
- **Milestone_21**: The first occurrence of any team reaching 21 points in a match
- **Auto_End**: Automatic match completion without user interaction
- **Match_Controller**: The Flutter controller class that manages match state and scoring logic

## Requirements

### Requirement 1: Single Continue Popup

**User Story:** As a badminton player, I want only the first team to reach 21 points to receive the continue option, so that the game flow is correct and fair.

#### Acceptance Criteria

1. WHEN the first team reaches 21 points, THE Scoring_System SHALL display the Continue_Popup asking if they want to continue
2. WHEN the second team reaches 21 points after the first team already reached 21, THE Scoring_System SHALL NOT display any popup
3. WHEN a team reaches 21 points and the Milestone_21 has already been triggered, THE Scoring_System SHALL continue normal scoring without interruption
4. THE Scoring_System SHALL track whether the Milestone_21 has been reached to prevent duplicate popups

### Requirement 2: Continue Decision Handling

**User Story:** As a badminton player, I want the continue decision to be respected throughout the match, so that the game follows the chosen path consistently.

#### Acceptance Criteria

1. WHEN a team chooses "No" at 21 points, THE Scoring_System SHALL immediately end the match and declare them the winner
2. WHEN a team chooses "Yes" at 21 points, THE Scoring_System SHALL continue the match to 30 points without showing any more popups
3. WHEN a team chooses to continue, THE Scoring_System SHALL update the match state to prevent future continue prompts
4. THE Scoring_System SHALL persist the continue decision so it remains effective throughout the match

### Requirement 3: Automatic 30-Point Termination

**User Story:** As a badminton player, I want the match to automatically end when any team reaches 30 points, so that there is a definitive conclusion without manual intervention.

#### Acceptance Criteria

1. WHEN any team reaches exactly 30 points, THE Scoring_System SHALL automatically end the match
2. WHEN a match ends at 30 points, THE Scoring_System SHALL NOT display the Continue_Popup
3. WHEN a match ends at 30 points, THE Scoring_System SHALL declare the team with 30 points as the winner
4. THE Auto_End SHALL occur immediately upon reaching 30 points without requiring user confirmation

### Requirement 4: Score Update Logic

**User Story:** As a badminton player, I want the scoring system to handle all score updates correctly, so that the match progresses according to the established rules.

#### Acceptance Criteria

1. WHEN a score is updated via the UI, THE Match_Controller SHALL check for milestone conditions before applying the score
2. WHEN checking milestones, THE Match_Controller SHALL compare previous scores to current scores to detect transitions
3. WHEN a milestone is detected, THE Match_Controller SHALL execute the appropriate action based on the current match state
4. THE Match_Controller SHALL update the match model with the new score and any state changes atomically

### Requirement 5: Match State Persistence

**User Story:** As a badminton player, I want my match state to be preserved correctly, so that the game remembers important decisions and milestones.

#### Acceptance Criteria

1. WHEN the Milestone_21 is reached, THE Scoring_System SHALL persist this state to prevent future popups
2. WHEN a continue decision is made, THE Scoring_System SHALL save this decision to local storage
3. WHEN a match is completed, THE Scoring_System SHALL persist the final state and winner information
4. THE Scoring_System SHALL maintain data consistency across all state updates and storage operations