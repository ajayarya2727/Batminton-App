import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/match_controller.dart';
import 'screens/home_screen.dart';
import 'screens/match_detail_screen.dart';

void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(),
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
    // Initialize the controller
    Get.put(MatchController());
    
    return const HomeScreen();
  }
}