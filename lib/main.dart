import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen/home_menu_ui.dart';
import 'controllers/app_controllers.dart';

void main() {      
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force initialization of AppControllers
  AppControllers.createMatch;
  AppControllers.match;
  AppControllers.myMatches;
  AppControllers.resumeMatch;
  AppControllers.createTeam;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Badminton App'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: HorizontalMenu(),
      ),
    );
  }
}