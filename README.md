# Badminton Score App

A Flutter app for tracking badminton match scores with support for both 1v1 and 2v2 matches.

## Features

- **Match Types**: Support for both 1v1 and 2v2 matches
- **Score Tracking**: Real-time score updates with increment/decrement buttons
- **Local Storage**: All match data is stored locally using SharedPreferences and JSON
- **GetX State Management**: Reactive UI with GetX for state management
- **StatelessWidget Architecture**: All UI components are StatelessWidgets
- **Match Management**: Create, view, update, and delete matches
- **Match Completion**: Mark matches as completed with winner detection

## App Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── match_model.dart        # Match data model with JSON serialization
├── controllers/
│   └── match_controller.dart   # GetX controller for match management
├── screens/
│   ├── home_screen.dart        # Main screen showing all matches
│   ├── match_detail_screen.dart # Match details and score updating
│   └── create_match_screen.dart # Create new match form
└── utils/
    └── sample_data.dart        # Sample data for testing
```

## Key Technologies

- **Flutter**: Cross-platform mobile development
- **GetX**: State management and navigation
- **SharedPreferences**: Local data persistence
- **JSON**: Data serialization format

## How to Use

1. **Home Screen**: View all matches categorized by type (1v1 and 2v2)
2. **Create Match**: Tap the + button to create a new match
3. **Match Details**: Tap on any match to view details and update scores
4. **Score Updates**: Use +/- buttons to update team scores
5. **Complete Match**: Mark matches as completed when finished

## Data Structure

All match data is stored in JSON format with the following structure:

```json
{
  "id": "unique_match_id",
  "matchType": "1v1" or "2v2",
  "team1Players": ["Player1", "Player2"],
  "team2Players": ["Player3", "Player4"],
  "team1Score": 0,
  "team2Score": 0,
  "createdAt": "2024-01-20T10:30:00.000Z",
  "isCompleted": false
}
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Dependencies

- `get: ^4.6.6` - State management
- `shared_preferences: ^2.2.2` - Local storage
