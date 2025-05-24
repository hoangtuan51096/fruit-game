import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const _keyUnlockedLevel = 'unlocked_level';

  // Lấy level đã mở
  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUnlockedLevel) ?? 1;
  }

  // Cập nhật level mới (nếu lớn hơn)
  static Future<void> updateUnlockedLevel(int newLevel) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyUnlockedLevel) ?? 1;

    if (newLevel > current) {
      await prefs.setInt(_keyUnlockedLevel, newLevel);
    }
  }

  // Reset nếu cần
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUnlockedLevel);
  }
}
