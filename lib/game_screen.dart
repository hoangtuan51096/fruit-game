import 'package:flutter/material.dart';
import 'package:fruit_match_game/fruit_game_widget.dart';
import 'fruit_game_widget.dart'; // Widget chứa FlameGame

class GameScreen extends StatelessWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FruitGameWidget(level: level),
        ],
      ),
    );
  }
}
