import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/match_controller.dart';
import 'home_screen_options/main_screen.dart';  // ← Main buttons screen
import 'screens/match_detail_screen.dart';

void main() {
  runApp(const MyApp());  // ← App start point
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Badminton Score App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),  // ← First screen to load
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/',
          page: () => const MyHomePage(),
        ),
        GetPage(
          name: '/match-detail',
          page: () {
            final String matchId = Get.arguments as String;
            return MatchDetailScreen(matchId: matchId);
          },
        ),
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize match controller for app
    Get.put(MatchController());
    
    // Load main screen with buttons
    return const MainScreen();  // ← Goes to home_screen_options/main_screen.dart
  }
}