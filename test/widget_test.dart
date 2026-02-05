// // This is a basic Flutter widget test for the Badminton App.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';

// import 'package:batminton_app/main.dart';
// import 'package:batminton_app/controllers/create_match_controller.dart';
// import 'package:batminton_app/models/badminton_models.dart';

// void main() {
//   testWidgets('Badminton App smoke test', (WidgetTester tester) async {
//     // Initialize GetX controller
//     Get.put(MatchController());
    
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());

//     // Wait for initial frame
//     await tester.pump();

//     // Verify that our app shows the home screen with title
//     expect(find.text('Badminton Matches'), findsOneWidget);
    
//     // Verify that the floating action button exists
//     expect(find.byIcon(Icons.add), findsOneWidget);
//   });

//   test('Match pause/resume functionality test', () {
//     // Test the pause/resume functionality
//     final controller = MatchController();
    
//     // Verify that pause and resume methods exist
//     expect(controller.pauseMatch, isA<Function>());
//     expect(controller.resumeMatch, isA<Function>());
//   });

//   test('BadmintonMatchStatus enum test', () {
//     // Test that our pause status enum works correctly
//     expect(BadmintonMatchStatus.paused.code, equals('paused'));
//     expect(BadmintonMatchStatus.paused.displayName, equals('Paused'));
//     expect(BadmintonMatchStatus.inProgress.isActive, isTrue);
//     expect(BadmintonMatchStatus.paused.isActive, isFalse);
//   });
// }
