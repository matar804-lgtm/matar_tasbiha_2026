import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookmarkManager {
  static const String _bookmarksKey = 'quran_bookmarks';

  static Future<void> addBookmark({
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
    required String ayahText,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> bookmarks = _getBookmarksList(prefs);

    final bool exists = bookmarks.any(
      (Map<String, dynamic> bookmark) {
        return bookmark['surahNumber'] == surahNumber &&
            bookmark['ayahNumber'] == ayahNumber;
      },
    );

    if (exists) {
      return;
    }

    final Map<String, dynamic> bookmark = <String, dynamic>{
      'surahName': surahName,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    bookmarks.add(bookmark);

    await prefs.setString(
      _bookmarksKey,
      jsonEncode(bookmarks),
    );
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return _getBookmarksList(prefs);
  }

  static Future<void> removeBookmark({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> bookmarks = _getBookmarksList(prefs);

    bookmarks.removeWhere(
      (Map<String, dynamic> bookmark) {
        return bookmark['surahNumber'] == surahNumber &&
            bookmark['ayahNumber'] == ayahNumber;
      },
    );

    await prefs.setString(
      _bookmarksKey,
      jsonEncode(bookmarks),
    );
  }

  static List<Map<String, dynamic>> _getBookmarksList(
    SharedPreferences prefs,
  ) {
    final String? bookmarksString = prefs.getString(_bookmarksKey);

    if (bookmarksString == null || bookmarksString.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final dynamic decoded = jsonDecode(bookmarksString);

      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (Map item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
