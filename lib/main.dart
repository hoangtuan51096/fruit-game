import 'package:flutter/material.dart';
import 'main_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Match Game',
      debugShowCheckedModeBanner: false,
      home: MainMenuScreen(),
    );
  }
}