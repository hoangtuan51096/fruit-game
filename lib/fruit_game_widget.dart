import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'fruit_game.dart';

class FruitGameWidget extends StatelessWidget {
  final int level;

  const FruitGameWidget({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: FruitGame(level: level), // Truyền game bạn muốn chạy
      overlayBuilderMap: {
        'GameOver': (context, game) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Game Over!', style: TextStyle(fontSize: 32)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Quay lại menu
                  },
                  child: const Text('Trở về menu'),
                ),
              ],
            ),
          );
        },
      },
    );
  }
}
