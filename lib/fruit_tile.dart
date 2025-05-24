import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FruitTile extends SpriteComponent {
  final String name;
  int row;
  int col;
  final double offsetX;
  final double offsetY;
  final double tileSize;
  bool isSelected = false;
  
  late final RectangleComponent selectedOverlay;

  FruitTile(this.name, this.row, this.col, this.tileSize, this.offsetX, this.offsetY)
      : super(size: Vector2.all(tileSize)) {
    position = Vector2(col * tileSize + offsetX, row * tileSize + offsetY);
  }
   @override
  void render(Canvas canvas) {
    // Hiệu ứng nền trắng mờ khi chọn
    if (isSelected) {
      final backgroundPaint = Paint()
        ..color = const Color(0x88FFFFFF)  // Trắng mờ
        ..style = PaintingStyle.fill;

      canvas.drawRect(size.toRect(), backgroundPaint);
    }

    // Vẽ sprite (hoa quả)
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

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('$name.png');

    // Không reset position trong onLoad nếu đã có
    size = Vector2.all(tileSize);
    // Thêm lớp overlay trắng (ẩn ban đầu)
    selectedOverlay = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0x99FFFFFF),
    );
  }

  void select() {
    isSelected = true;
    add(OpacityEffect.to(0.5, EffectController(duration: 0.2)));
  }

  void deselect() {
    isSelected = false;
    add(OpacityEffect.to(1.0, EffectController(duration: 0.2)));
  }
  
  void setSelected(bool selected) {
    isSelected = selected;
    if (selected) {
      if (!children.contains(selectedOverlay)) {
        add(selectedOverlay);
      }
    } else {
      selectedOverlay.removeFromParent();
    }
  }

  void setPosition(int newRow, int newCol) {
    row = newRow;
    col = newCol;
    final newPos = Vector2(col * tileSize + offsetX, row * tileSize + offsetY);
    add(MoveEffect.to(newPos, EffectController(duration: 0.25, curve: Curves.easeInOut)));
  }

  void fallToPosition(int newRow, int newCol, {double delay = 0.0}) {
    row = newRow;
    col = newCol;

    final target = Vector2(col * tileSize + offsetX, row * tileSize + offsetY);
    final effect = MoveEffect.to(
      target,
      EffectController(duration: 0.25, startDelay: delay, curve: Curves.easeInOut),
    );

    add(effect);
  }
}
