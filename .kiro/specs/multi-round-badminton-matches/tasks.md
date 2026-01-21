# Implementation Plan: Multi-Round Badminton Matches

## Overview

This implementation plan converts the existing single-round badminton match system into a proper 3-round best-of-3 format. The approach focuses on enhancing the existing `MatchModel`, `MatchController`, and `MatchDetailScreen` classes rather than creating new files. Each task builds incrementally on the previous work to ensure the system remains functional throughout development.

## Tasks

- [ ] 1. Enhance MatchModel with multi-round computed properties
  - Add new computed properties for round management (team1RoundsWon, team2RoundsWon, matchWinner)
  - Modify existing isMatchComplete property to check for 2 round wins instead of single round completion
  - Update isRoundComplete logic to work with multi-round context
  - _Requirements: 1.2, 1.4, 4.2, 6.2, 6.3, 6.4_

- [ ]* 1.1 Write property tests for MatchModel enhancements
  - **Property 2: Round Number Bounds**
  - **Property 4: Match Score Consistency**  
  - **Property 8: Round Winner Determination**
  - **Validates: Requirements 1.2, 1.4, 2.3, 2.4, 4.2**

- [ ] 2. Implement round completion logic in MatchController
  - [ ] 2.1 Add helper methods for round management
    - Implement _completeCurrentRound method to handle round winner recording
    - Implement _startNextRound method to reset scores and increment round number
    - Implement _isMatchComplete and _determineMatchWinner helper methods
    - _Requirements: 3.1, 3.2, 4.1, 4.2_

  - [ ]* 2.2 Write property tests for round completion logic
    - **Property 9: Match Completion on Two Wins**
    - **Property 5: Automatic Round Progression**
    - **Validates: Requirements 3.3, 4.1, 1.5, 3.2**

  - [ ] 2.3 Modify updateMatchScore method for multi-round support
    - Enhance existing 21-point popup logic to work per round
    - Enhance existing 30-point auto-end logic to complete rounds instead of matches
    - Add round transition logic after round completion
    - Preserve existing dialog behavior but extend for round context
    - _Requirements: 2.1, 2.2, 3.3, 3.5_

  - [ ]* 2.4 Write property tests for score update logic
    - **Property 6: Twenty-One Point Dialog Trigger**
    - **Property 7: Thirty Point Auto-End**
    - **Property 3: Round Score Reset on Transition**
    - **Validates: Requirements 2.1, 2.2, 2.5, 3.5**

- [ ] 3. Checkpoint - Test round logic with existing UI
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Implement match completion and data persistence
  - [ ] 4.1 Update match completion logic
    - Modify existing _completeMatch method to handle multi-round completion
    - Update match winner determination for best-of-3 format
    - Ensure completed matches prevent further score updates
    - _Requirements: 4.3, 4.4_

  - [ ]* 4.2 Write property tests for match completion
    - **Property 10: Completed Match Immutability**
    - **Property 11: Data Preservation and Integrity**
    - **Validates: Requirements 4.3, 3.4, 4.4, 6.1, 6.2, 6.3, 6.4, 6.5**

  - [ ] 4.3 Enhance data serialization for multi-round support
    - Ensure toJson and fromJson methods handle all multi-round fields correctly
    - Add validation for round data consistency during deserialization
    - Test backward compatibility with existing single-round match data
    - _Requirements: 6.5, 7.1, 7.4_

  - [ ]* 4.4 Write property tests for data persistence
    - **Property 15: Serialization Round Trip**
    - **Property 13: Legacy Match Compatibility**
    - **Validates: Requirements 6.5, 7.1, 7.2, 7.4**

- [ ] 5. Enhance UI for multi-round display
  - [ ] 5.1 Add round progress display to match header
    - Modify _buildMatchHeader to show current round (e.g., "Round 2 of 3")
    - Add match score display showing rounds won by each team
    - Maintain existing styling and layout patterns
    - _Requirements: 5.1, 5.2_

  - [ ] 5.2 Add round score history display
    - Create _buildRoundScoreHistory method to show completed round scores
    - Display historical round results in a clean, organized format
    - Show which team won each completed round
    - _Requirements: 5.3_

  - [ ] 5.3 Update current score display for round context
    - Modify _buildScoreSection to emphasize current round scoring
    - Update helper text to reflect multi-round context
    - Ensure existing score increment/decrement buttons work correctly
    - _Requirements: 5.4_

  - [ ]* 5.4 Write property tests for UI rendering
    - **Property 12: UI Rendering Completeness**
    - **Property 14: Match Type Distinction**
    - **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 7.5**

- [ ] 6. Implement new match initialization
  - [ ] 6.1 Update match creation to use multi-round format
    - Ensure new matches initialize with currentRound = 1
    - Initialize empty round wins lists and round scores
    - Set appropriate default values for multi-round fields
    - _Requirements: 1.1, 7.3_

  - [ ]* 6.2 Write property tests for match initialization
    - **Property 1: New Match Initialization**
    - **Validates: Requirements 1.1, 7.3**

- [ ] 7. Add enhanced dialog system for round transitions
  - [ ] 7.1 Create round completion dialog
    - Implement _showRoundCompleteDialog to announce round winners
    - Show brief round summary before transitioning to next round
    - Maintain consistent styling with existing dialogs
    - _Requirements: 5.5_

  - [ ] 7.2 Update match completion dialog for multi-round context
    - Modify existing match completion dialog to show final match score
    - Display round-by-round results in completion summary
    - Show overall match winner with proper context
    - _Requirements: 4.2_

- [ ]* 7.3 Write unit tests for dialog integration
  - Test dialog triggering conditions
  - Test dialog content accuracy
  - Test dialog flow integration with match state

- [ ] 8. Final integration and testing
  - [ ] 8.1 Integration testing with existing app flow
    - Test complete match flow from creation to completion
    - Verify compatibility with existing match list and home screen
    - Test data persistence across app restarts
    - _Requirements: 7.2_

  - [ ] 8.2 Backward compatibility validation
    - Test loading and displaying existing single-round matches
    - Ensure legacy matches display correctly in match history
    - Verify no data corruption when mixing old and new match formats
    - _Requirements: 7.1, 7.2, 7.4, 7.5_

  - [ ]* 8.3 Write integration tests
    - Test controller-model integration
    - Test UI-controller integration  
    - Test storage integration
    - Test legacy data compatibility

- [ ] 9. Final checkpoint - Complete system validation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation throughout development
- Property tests validate universal correctness properties across all match states
- Unit tests validate specific examples, edge cases, and integration points
- The implementation preserves all existing functionality while adding multi-round support
- Backward compatibility ensures existing match data continues to work correctly