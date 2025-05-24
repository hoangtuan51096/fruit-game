import 'package:flutter/material.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn màn')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: 100,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final level = index + 1;
            final isLocked = level > 10; // Giả sử unlock tới level 10

            return GestureDetector(
              onTap: () {
                if (!isLocked) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(level: level),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[400] : Colors.green[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: isLocked
                    ? const Icon(Icons.lock, color: Colors.white)
                    : Text('Level $level',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
              ),
            );
          },
        ),
      ),
    );
  }
}
