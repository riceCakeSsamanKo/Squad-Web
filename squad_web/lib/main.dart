// main.dart
import 'package:flutter/material.dart';

import './screens/home_screen.dart'; // 경로 중요

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quantum Split Learning UI',
      theme: ThemeData.dark(),
      home: const QuantumHomePage(), // 홈 화면으로 연결
      debugShowCheckedModeBanner: false,
    );
  }
}
