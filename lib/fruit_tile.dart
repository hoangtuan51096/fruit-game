import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class FruitTile extends SpriteComponent {
  final String name;
  int row;
  int col;
  final double tileSize;
  bool isSelected = false;

  FruitTile(this.name, this.row, this.col, this.tileSize)
      : super(size: Vector2.all(tileSize)) {
    position = Vector2(col * tileSize, row * tileSize);
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('$name.png');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Vẽ viền nếu muốn thêm khung sáng
    if (isSelected) {
      final borderPaint = Paint()
        ..color = const Color(0xFFFFD700)  // Vàng viền
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(size.toRect(), borderPaint);
    }
  }

  void select() {
    isSelected = true;
    add(OpacityEffect.to(0.5, EffectController(duration: 0.2)));
  }

  void deselect() {
    isSelected = false;
    add(OpacityEffect.to(1.0, EffectController(duration: 0.2)));
  }


  void setPosition(int newRow, int newCol) {
    row = newRow;
    col = newCol;
    add(MoveEffect.to(Vector2(col * tileSize, row * tileSize),
        EffectController(duration: 0.2, curve: Curves.easeInOut)));
  }
}

