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
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 120),  // Space from top
          HorizontalMenu(),       // ← 5 swipeable buttons
          SizedBox(height: 30),   // Space at bottom
        ],
      ),
    );
  }
}