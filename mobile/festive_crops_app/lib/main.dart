import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FestiveCropsApp());
}

class FestiveCropsApp extends StatelessWidget {
  const FestiveCropsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Festive Crop Recommender',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5FBEF),
      ),
      home: const HomeScreen(),
    );
  }
}