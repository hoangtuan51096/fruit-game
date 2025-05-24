import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'animated_gradient_background.dart';
import 'fruit_tile.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_over_component.dart';
import 'top_bar_component.dart';
import 'package:collection/collection.dart';
late TopBarComponent topBar;

class FruitGame extends FlameGame with TapDetector {
  final int numRows = 10;
  final int numCols = 7;
  final double tileSize = 48.0;
  final int maxMoves = 1;
  late List<List<FruitTile?>> grid;
  FruitTile? selectedTile;
  late TextComponent scoreText;
  int score = 0;
  late double offsetX, offsetY;
  int movesLeft = 1;
  late TextComponent movesText;
  bool isAnimating = false;
  int levelPoint = 40;
  final int level;

  FruitGame({required this.level});

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'apple.png',
      'banana.png',
      'grape.png',
      'watermelon.png',
      'blue-berries.png',
      'orange.png',
    ]);
    add(AnimatedGradientBackground());

    // Đợi có size màn hình
    await Future.delayed(Duration.zero);
    generateInitialBoard();
    topBar = TopBarComponent(level: level, movesLeft: maxMoves, score: 0)
    ..size = Vector2(size.x, 80)
    ..position = Vector2(0, 20)
    ..priority = 100;
    add(topBar);

  }
  
  void generateInitialBoard() {
    final fruitTypes = ['apple', 'banana', 'grape', 'watermelon', 'blue-berries'];
    grid = List.generate(numRows, (_) => List.filled(numCols, null));

    double totalWidth = numCols * tileSize;
    double totalHeight = numRows * tileSize;

    offsetX = (size.x - totalWidth) / 2;
    offsetY = (size.y - totalHeight) / 2;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        String name;
        do {
          name = fruitTypes[Random().nextInt(fruitTypes.length)];
        } while (
          (col >= 2 && grid[row][col - 1]?.name == name && grid[row][col - 2]?.name == name) ||
          (row >= 2 && grid[row - 1][col]?.name == name && grid[row - 2][col]?.name == name)
        );

        final tile = FruitTile(name, row, col, tileSize, offsetX, offsetY);
        grid[row][col] = tile;
        add(tile);
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) async {
    final pos = info.eventPosition.global;
    final col = ((pos.x - offsetX) ~/ tileSize);
    final row = ((pos.y - offsetY) ~/ tileSize);

    if (row < 0 || row >= numRows || col < 0 || col >= numCols) return;
    final tapped = grid[row][col];
    if (tapped == null) return;

    if(movesLeft <= 0) {
      return;
    }
    if (selectedTile == null) {
      selectedTile = tapped..select();
    } else if (selectedTile == tapped) {
      tapped.deselect();
      selectedTile = null;
    } else if (areAdjacent(selectedTile!, tapped)) {
      swapTiles(selectedTile!, tapped);
    } else {
      selectedTile?.deselect();
      selectedTile = tapped..select();
    }
  }

  void useMove() {
    movesLeft--;
    topBar.updateMoves(movesLeft);
    checkGameOverCondition();
  }

  void checkGameOverCondition() async {
    if ((movesLeft <= 0) || (score >= levelPoint)) {
      // Đợi cho hiệu ứng hoàn tất
      while (isAnimating) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Khi chắc chắn mọi hiệu ứng đã dừng → show Game Over
      final gameOver = GameOverComponent(
        gameSize: size,
        winner: score >= levelPoint,
        onReplay: () {
          // Reset lại game
          resetGame();
        },
        onBack: () {
          // Quay về màn menu
          Navigator.of(buildContext!).pop();
        },
      );
    await add(gameOver);
    }
  }

  void resetGame() {
    // Xoá toàn bộ ô cũ
    children.whereType<FruitTile>().forEach((tile) => tile.removeFromParent());

    // Tạo lại board
    generateInitialBoard();

    // Reset lượt, điểm, v.v...
    movesLeft = maxMoves;
    score = 0;

    topBar.updateMoves(maxMoves);
    topBar.updateScore(0);

    // Xoá màn hình chiến thắng nếu có
    final winner = children.firstWhereOrNull((c) => c is GameOverComponent);
    winner?.removeFromParent();
  }

  bool areAdjacent(FruitTile a, FruitTile b) {
    return (a.row == b.row && (a.col - b.col).abs() == 1) ||
            (a.col == b.col && (a.row - b.row).abs() == 1);
  }

  Set<FruitTile> findMatches() {
    final matched = <FruitTile>{};

    // Ngang
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

    // Dọc
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

  handleMatches(Set<FruitTile> matched) async {
    isAnimating = true;

    if (matched.isEmpty) return;

    for (final tile in matched) {
      remove(tile);
      grid[tile.row][tile.col] = null;
    }
    score += matched.length * 10;
    topBar.updateScore(score);

    await applyGravity();
  }

  swapTiles(FruitTile a, FruitTile b) async {
  // Lưu vị trí ban đầu
    final aRow = a.row, aCol = a.col;
    final bRow = b.row, bCol = b.col;

    // Đổi vị trí trong lưới
    grid[aRow][aCol] = b;
    grid[bRow][bCol] = a;

    // Cập nhật vị trí hàng/cột trong tile
    a.setPosition(bRow, bCol);
    b.setPosition(aRow, aCol);

    // Tạm đổi row/col nội bộ
    a.row = bRow;
    a.col = bCol;
    b.row = aRow;
    b.col = aCol;

    // Xóa các ảnh cũ
    remove(a);
    remove(b);

    // Thêm các ô mới với ảnh mới
    add(a);
    add(b);

    // Kiểm tra match
    await Future.delayed(Duration(milliseconds: 300), () async {
      final matched = findMatches();
      if (matched.isEmpty) {
        // Không match, đổi lại
        grid[aRow][aCol] = a;
        grid[bRow][bCol] = b;

        a.setPosition(aRow, aCol);
        b.setPosition(bRow, bCol);

        a.row = aRow;
        a.col = aCol;
        b.row = bRow;
        b.col = bCol;
        add(a);
        add(b);
      } else {
        await handleMatches(matched);
        useMove();
      }
      selectedTile!.deselect();
      selectedTile = null;
    });

  }

  applyGravity() async {
    final fruitTypes = ['apple', 'banana', 'grape', 'watermelon', 'blue-berries', 'orange'];

    // Đảm bảo chỉ cập nhật grid chứ không tạo lại grid mới
    for (int col = 0; col < numCols; col++) {
      int emptyRow = numRows - 1;

      for (int row = numRows - 1; row >= 0; row--) {
        final tile = grid[row][col];
        if (tile != null) {
          if (row != emptyRow) {
            // Di chuyển tile xuống
            grid[emptyRow][col] = tile..fallToPosition(emptyRow, col);
            grid[row][col] = null;

            // Xóa ô cũ khỏi màn hình
            remove(tile);
            add(tile); // Thêm lại ô với vị trí mới
          }
          emptyRow--;
        }
      }

      // Tạo mới ô ở trên
      for (int row = emptyRow; row >= 0; row--) {
        final name = fruitTypes[Random().nextInt(fruitTypes.length)];
        final spawnRow = row - emptyRow - 1;
        final tile = FruitTile(name, spawnRow, col, tileSize, offsetX, offsetY);
        tile.position = Vector2(col * tileSize + offsetX, spawnRow * tileSize + offsetY);
        add(tile);

        grid[row][col] = tile;
        tile.fallToPosition(row, col);
      }
    }

    // Kiểm tra lại match sau khi rơi
    Future.delayed(const Duration(milliseconds: 300), () async {
      final newMatches = findMatches();
      if (newMatches.isNotEmpty) {
        await handleMatches(newMatches);
      } else {
        isAnimating = false;
      }
    });

  }

}

