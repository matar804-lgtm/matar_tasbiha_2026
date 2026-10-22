enum SurahRevelationStatus { meccan, medinan, disputed }

class SurahRevelationService {
  static const Set<int> _medinan = <int>{
    2,
    3,
    4,
    5,
    8,
    9,
    24,
    33,
    47,
    48,
    49,
    57,
    58,
    59,
    60,
    62,
    63,
    65,
    66,
    110,
  };

  static const Set<int> _disputed = <int>{
    1,
    13,
    55,
    61,
    64,
    83,
    97,
    98,
    99,
    112,
    113,
    114,
  };

  static SurahRevelationStatus classify(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) {
      return SurahRevelationStatus.disputed;
    }
    if (_disputed.contains(surahNumber)) {
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
