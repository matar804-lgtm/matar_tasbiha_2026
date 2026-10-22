enum SurahRevelationStatus { meccan, medinan, disputed }

class SurahRevelationService {
  // Classification transcribed from the published surah index at Quranpedia,
  // which lists all 114 surahs as either Makki or Madani.
  // Keep the change limited to revelation-place information only.
  static const Set<int> _medinan = <int>{
    2,
    3,
    4,
    5,
    8,
    9,
    13,
    22,
    24,
    33,
    47,
    48,
    49,
    55,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    76,
    98,
    99,
    110,
  };

  static SurahRevelationStatus classify(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) {
      return SurahRevelationStatus.disputed;
    }
    if (_medinan.contains(surahNumber)) {
      return SurahRevelationStatus.medinan;
    }
    return SurahRevelationStatus.meccan;
  }

  static String? labelAr(int surahNumber) {
    switch (classify(surahNumber)) {
      case SurahRevelationStatus.meccan:
        return '\u0645\u0643\u064a\u0629';
      case SurahRevelationStatus.medinan:
        return '\u0645\u062f\u0646\u064a\u0629';
      case SurahRevelationStatus.disputed:
        return null;
    }
  }

  static String subtitlePrefixAr(int surahNumber) {
    final String? label = labelAr(surahNumber);
    return label == null ? '' : '$label \u2022 ';
  }
}
