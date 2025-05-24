import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' as material;
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class GameOverComponent extends PositionComponent with HasGameRef {
  late SpriteComponent image;
  late SpriteComponent imageLose;
  late ButtonComponent replayButton;
  late ButtonComponent backButton;
  final bool winner;
  final void Function()? onReplay;
  final void Function()? onBack;

  GameOverComponent({
    required Vector2 gameSize,
    this.onReplay,
    this.onBack,
    required this.winner
    }
  ) {
    size = gameSize;
    position = gameSize / 2 - size / 2;
    priority = 1000;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final overlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
      priority: 0,
    );
    add(overlay);

    replayButton = ButtonComponent(
      position: Vector2(size.x / 2 - 100, size.y / 2 + 50),
      size: Vector2(200, 40),
      button: _buildButtonBG('Chơi lại'),
      onPressed: () {
        gameRef.overlays.remove('GameOver');
        onReplay?.call();
      },
    );

    backButton = ButtonComponent(
      position: Vector2(size.x / 2 - 100, size.y / 2 + 100),
      size: Vector2(200, 40),
      button: _buildButtonBG('Menu'),
      onPressed: () {
        gameRef.overlays.remove('GameOver');
        onBack?.call();
      },
    );
    if (winner) {
      image = SpriteComponent()
      ..sprite = await Sprite.load('winner.png')
      ..size = Vector2(size.x, 300)
      ..position = Vector2(0, 100);
    } else {
      image = SpriteComponent()
      ..sprite = await Sprite.load('lose.png')
      ..size = Vector2(size.x, 300)
      ..position = Vector2(0, 100);
    }

    addAll([image, replayButton, backButton]);
  }

  PositionComponent _buildButtonBG(String text) {
    final button = PositionComponent(size: Vector2(200, 40));

    final bg = RectangleComponent(
      size: Vector2(200, 40),
      paint: Paint()..color = material.Colors.blue,
      anchor: Anchor.topLeft,
      position: Vector2.zero(),
    );

    final label = TextComponent(
      text: text,
      anchor: Anchor.center,
      position: Vector2(100, 20), // giữa nút
      textRenderer: TextPaint(
        style: const material.TextStyle(
          color: material.Colors.white,
          fontSize: 16,
          fontWeight: material.FontWeight.bold,
        ),
      ),
    );

    button.add(bg);
    button.add(label);
    return button;
  }
}
