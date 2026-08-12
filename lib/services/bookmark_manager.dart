import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkManager {
  static const String _bookmarksKey = 'quran_bookmarks';

  static Future<void> addBookmark({
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
    required String ayahText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = _getBookmarksList(prefs);

    final bookmark = {
      'surahName': surahName,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final exists = bookmarks.any((b) =>
        b['surahNumber'] == surahNumber && b['ayahNumber'] == ayahNumber);

    if (!exists) {
      bookmarks.add(bookmark);
      await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
    }
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return _getBookmarksList(prefs);
  }

  static Future<void> removeBookmark({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = _getBookmarksList(prefs);

    bookmarks.removeWhere((b) =>
        b['surahNumber'] == surahNumber && b['ayahNumber'] == ayahNumber);

    await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
  }

  static List<Map<String, dynamic>> _getBookmarksList(SharedPreferences prefs) {
    final bookmarksString = prefs.getString(_bookmarksKey);
    if (bookmarksString == null || bookmarksString.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(bookmarksString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
}
