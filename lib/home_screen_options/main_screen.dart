import 'package:flutter/material.dart';
import 'horizontal_menu.dart';  // ← Contains all 5 buttons

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar with app title
      appBar: AppBar(
        title: const Text(
          'Badminton App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
      ),
      
      // Main content area
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const HorizontalMenu(),
          ],
        ),
      ),
    );
  }
}