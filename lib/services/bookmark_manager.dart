import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager {
  static const String _bookmarksKey = 'quran_bookmarks';
  static const int maxBookmarks = 10;

  /// إنشاء علامة مرجعية جديدة
  static Map<String, dynamic> createBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
  }) {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahName': surahName,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// حفظ علامة مرجعية (بحد أقصى 10)
  static Future<bool> addBookmark(Map<String, dynamic> bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

    if (bookmarksJson.length >= maxBookmarks) {
      return false;
    }

    final exists = bookmarksJson.any((element) {
      final data = jsonDecode(element) as Map<String, dynamic>;
      return data['surahNumber'] == bookmark['surahNumber'] &&
          data['ayahNumber'] == bookmark['ayahNumber'];
    });

    if (exists) return false;

    bookmarksJson.add(jsonEncode(bookmark));
    await prefs.setStringList(_bookmarksKey, bookmarksJson);
    return true;
  }

  /// استرجاع جميع العلامات المرجعية
  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

    return bookmarksJson.map((e) {
      return jsonDecode(e) as Map<String, dynamic>;
    }).toList();
  }

  /// حذف علامة مرجعية
  static Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarksJson = prefs.getStringList(_bookmarksKey) ?? [];

    bookmarksJson.removeWhere((element) {
      final data = jsonDecode(element) as Map<String, dynamic>;
      return data['surahNumber'] == surahNumber &&
          data['ayahNumber'] == ayahNumber;
    });

    await prefs.setStringList(_bookmarksKey, bookmarksJson);
  }

  /// تنسيق التاريخ والوقت للعرض
  static String formatDateTime(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
