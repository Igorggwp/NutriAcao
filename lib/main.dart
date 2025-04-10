import 'package:flutter/material.dart';
import 'screens/nutriacao_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriAção',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A),
        useMaterial3: true,
      ),
      home: const NutriacaoScreen(),
    );
  }
}
