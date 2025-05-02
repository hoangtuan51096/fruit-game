import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart'; // Dành cho TapDetector, TapDownInfo
import 'fruit_tile.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart'; // để dùng Curves

class FruitGame extends FlameGame with TapDetector {
  final fruitTypes = ['apple', 'banana', 'grape', 'orange'];
  final int numRows = 7;
  final int numCols = 7;
  final double tileSize = 48.0;
  late List<List<FruitTile?>> grid;
  FruitTile? selectedTile;
  int score = 0;

  FruitTile? firstSelected;
  @override
  Future<void> onLoad() async {
    super.onLoad();

    grid = List.generate(numRows, (_) => List.filled(numCols, null));
    final names = ['apple', 'banana', 'grape', 'orange'];

    for (int row = 0; row < numRows; row++) {
    for (int col = 0; col < numCols; col++) {
        final name = names[Random().nextInt(names.length)];
        final tile = FruitTile(name, row, col, tileSize);
        grid[row][col] = tile;
        add(tile);
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    final tapPosition = info.eventPosition.global;
    FruitTile? tappedTile;

    try {
      tappedTile = children.whereType<FruitTile>().firstWhere(
        (tile) => tile.containsPoint(tapPosition),
      );
    } catch (e) {
      tappedTile = null;
    }
    if (tappedTile == null) return;

    if (firstSelected == null) {
      firstSelected = tappedTile;
      firstSelected!.isSelected = true;  
    } else {
      final secondTile = tappedTile;

      final dx = (firstSelected!.position.x - secondTile.position.x).abs();
      final dy = (firstSelected!.position.y - secondTile.position.y).abs();

      final isAdjacent = (dx == tileSize && dy == 0) || (dy == tileSize && dx == 0);

      if (isAdjacent) {
        final posA = firstSelected!.position.clone();
        final posB = secondTile.position.clone();

        firstSelected!.add(
          MoveEffect.to(posB, EffectController(duration: 0.2, curve: Curves.easeInOut)),
        );

        secondTile.add(
          MoveEffect.to(posA, EffectController(duration: 0.2, curve: Curves.easeInOut)),
        );
      }
      firstSelected!.isSelected = false;  
      firstSelected = null;
    }
  }



  bool areAdjacent(FruitTile a, FruitTile b) {
    return (a.row == b.row && (a.col - b.col).abs() == 1) ||
           (a.col == b.col && (a.row - b.row).abs() == 1);
  }

  void swapTiles(FruitTile a, FruitTile b) {
    final rowA = a.row, colA = a.col;
    final rowB = b.row, colB = b.col;

    grid[rowA][colA] = b..setPosition(rowA, colA);
    grid[rowB][colB] = a..setPosition(rowB, colB);
  } 


  void handleMatches(Set<FruitTile> matched) {
    for (final tile in matched) {
      remove(tile);
      grid[tile.row][tile.col] = null;
    }
    score += matched.length * 10;
    print("Score: $score");

    applyGravity();
  }
  void applyGravity() {
    final fruitTypes = ['apple', 'banana', 'grape', 'orange'];
    for (int col = 0; col < numCols; col++) {
      int emptyRow = numRows - 1;

      for (int row = numRows - 1; row >= 0; row--) {
        final tile = grid[row][col];
        if (tile != null) {
          if (row != emptyRow) {
            grid[emptyRow][col] = tile..setPosition(emptyRow, col);
            grid[row][col] = null;
          }
          emptyRow--;
        }
      }

      // Tạo mới ô ở trên
      for (int row = emptyRow; row >= 0; row--) {
        final name = fruitTypes[Random().nextInt(fruitTypes.length)];
        final tile = FruitTile(name, row, col, tileSize);
        grid[row][col] = tile;
        add(tile);
      }
    }

    Future.delayed(Duration(milliseconds: 250), () {
      final newMatches = findMatches();
      if (newMatches.isNotEmpty) {
        handleMatches(newMatches);
      }
    });
  }

  Set<FruitTile> findMatches() {
    final matched = <FruitTile>{};

    for (int row = 0; row < numRows; row++) {
      int count = 1;
      for (int col = 1; col < numCols; col++) {
        final prev = grid[row][col - 1];
        final curr = grid[row][col];

        if (prev != null && curr != null && prev.name == curr.name) {
          count++;
        } else {
          if (count >= 3) {
            for (int k = 0; k < count; k++) {
              matched.add(grid[row][col - 1 - k]!);
            }
          }
          count = 1;
        }
      }
      if (count >= 3) {
        for (int k = 0; k < count; k++) {
          matched.add(grid[row][numCols - 1 - k]!);
        }
      }
    }

    // Kiểm tra hàng dọc
    for (int col = 0; col < numCols; col++) {
      int count = 1;
      for (int row = 1; row < numRows; row++) {
        final prev = grid[row - 1][col];
        final curr = grid[row][col];

        if (prev != null && curr != null && prev.name == curr.name) {
          count++;
        } else {
          if (count >= 3) {
            for (int k = 0; k < count; k++) {
              matched.add(grid[row - 1 - k][col]!);
            }
          }
          count = 1;
        }
      }
      if (count >= 3) {
        for (int k = 0; k < count; k++) {
          matched.add(grid[numRows - 1 - k][col]!);
        }
      }
    }

    return matched;
  }

}
