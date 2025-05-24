import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Canvas, Colors, Paint, Rect;

/// Một component gradient động để làm nền cho Flame game
class AnimatedGradientBackground extends Component with HasGameRef {
  late final Paint _paint;
  double _time = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _paint = Paint();
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final gradient = ui.Gradient.linear(
      const ui.Offset(0, 0),
      ui.Offset(size.x, size.y),
      [
        Colors.purple.withOpacity(0.6),
        Colors.deepOrange.withOpacity(0.6),
        Colors.blue.withOpacity(0.6),
      ],
      [0.0, 0.5 + 0.3 * (ui.lerpDouble(-1, 1, (_time % 1)) ?? 0).abs(), 1.0],
    );

    _paint.shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }

  @override
  void update(double dt) {
    _time += dt * 0.2;
    super.update(dt);
  }
}
