/// 🕌 نموذج إعدادات مواقيت الصلاة
/// يحتوي على جميع الإعدادات المتعلقة بحساب مواقيت الصلاة
library;
// ================================================================
// الدول العربية
// ================================================================

enum ArabCountry {
  egypt('مصر'),
  saudiArabia('المملكة العربية السعودية'),
  uae('الإمارات العربية المتحدة'),
  kuwait('الكويت'),
  bahrain('البحرين'),
  qatar('قطر'),
  oman('عمان'),
  yemen('اليمن'),
  jordan('الأردن'),
  palestine('فلسطين'),
  lebanon('لبنان'),
  syria('سوريا'),
  iraq('العراق'),
  tunisia('تونس'),
  algeria('الجزائر'),
  morocco('المغرب'),
  libya('ليبيا'),
  sudan('السودان'),
  mauritania('موريتانيا');

  final String label;
  const ArabCountry(this.label);
}

// ================================================================
// المذاهب الفقهية
// ================================================================

enum IslamicSchool {
  hanafi('الحنفي'),
  maliki('المالكي'),
  shafi('الشافعي'),
  hanbali('الحنبلي');

  final String label;
  const IslamicSchool(this.label);
}

// ================================================================
// جهات الاعتماد لحساب مواقيت الصلاة
// ================================================================

enum PrayerAuthority {
  // ============================================
  // المملكة العربية السعودية
  // ============================================
  umAlQura('أم القرى', 'أم القرى - المملكة العربية السعودية'),

  // ============================================
  // مصر
  // ============================================
  egyptian('المعتمد المصري', 'جمهورية مصر العربية'),

  // ============================================
  // الجزائر
  // ============================================
  algerian('الجزائري', 'الجزائر'),

  // ============================================
  // التونسي
  // ============================================
  tunisian('التونسي', 'تونس'),

  // ============================================
  // جامعة العلوم الإسلامية
  // ============================================
  islamic('جامعة العلوم الإسلامية', 'باكستان'),

  // ============================================
  // معهد الملك عبدالعزيز للفلك
  // ============================================
  kingAbdulaziz('معهد الملك عبدالعزيز', 'المملكة العربية السعودية'),

  // ============================================
  // الاتحاد العام للدول الإسلامية
  // ============================================
  isna('الاتحاد الإسلامي لأمريكا الشمالية', 'أمريكا الشمالية'),

  // ============================================
  // جامعة الأزهر
  // ============================================
  alAzhar('جامعة الأزهر', 'مصر'),

  // ============================================
  // منظمة المؤتمر الإسلامي
  // ============================================
  mwl('منظمة المؤتمر الإسلامي', 'دول إسلامية متعددة'),

  // ============================================
  // الكويت
  // ============================================
  kuwait('الكويت', 'الكويت'),
  jordanMinistry(
      'وزارة الأوقاف الأردنية 2026', 'عمّان والزرقاء والبلقاء ومأدبا - الأردن');

  final String label;
  final String country;
  const PrayerAuthority(this.label, this.country);
}

// ================================================================
// معلومات المدينة
// ================================================================

class CityInfo {
  final String name;
  final double latitude;
  final double longitude;
  final ArabCountry country;
  final int timeZoneOffset; // بالدقائق من UTC

  CityInfo({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.timeZoneOffset,
  });

  @override
  String toString() => name;
}

// ================================================================
// قاموس المدن حسب الدول
// ================================================================

final Map<ArabCountry, List<CityInfo>> arabCitiesByCountry = {
  // ================================
  // مصر
  // ================================
  ArabCountry.egypt: [
    CityInfo(
      name: 'القاهرة',
      latitude: 30.0444,
      longitude: 31.2357,
      country: ArabCountry.egypt,
      timeZoneOffset: 120, // UTC+2
    ),
    CityInfo(
      name: 'الإسكندرية',
      latitude: 31.2001,
      longitude: 29.9187,
      country: ArabCountry.egypt,
      timeZoneOffset: 120,
    ),
    CityInfo(
      name: 'الجيزة',
      latitude: 30.0131,
      longitude: 31.2089,
      country: ArabCountry.egypt,
      timeZoneOffset: 120,
    ),
    CityInfo(
      name: 'الأقصر',
      latitude: 25.2854,
      longitude: 32.6421,
      country: ArabCountry.egypt,
      timeZoneOffset: 120,
    ),
    CityInfo(
      name: 'أسوان',
      latitude: 23.9728,
      longitude: 32.9388,
      country: ArabCountry.egypt,
      timeZoneOffset: 120,
    ),
    CityInfo(
      name: 'المنصورة',
      latitude: 31.0461,
      longitude: 31.3822,
      country: ArabCountry.egypt,
      timeZoneOffset: 120,
    ),
    CityInfo(
      name: 'طنطا',
      latitude: 30.7617,
      longitude: 31.0034,
      country: ArabCountry.egypt,
      timeZoneOffset: 120,
    ),
  ],

  // ================================
  // المملكة العربية السعودية
  // ================================
  ArabCountry.saudiArabia: [
    CityInfo(
      name: 'الرياض',
      latitude: 24.7136,
      longitude: 46.6753,
      country: ArabCountry.saudiArabia,
      timeZoneOffset: 180, // UTC+3
    ),
    CityInfo(
      name: 'جدة',
      latitude: 21.5433,
      longitude: 39.1728,
      country: ArabCountry.saudiArabia,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'مكة المكرمة',
      latitude: 21.4225,
      longitude: 39.8262,
      country: ArabCountry.saudiArabia,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'المدينة المنورة',
      latitude: 24.4672,
      longitude: 39.5936,
      country: ArabCountry.saudiArabia,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'الدمام',
      latitude: 26.3931,
      longitude: 50.1971,
      country: ArabCountry.saudiArabia,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'الخبر',
      latitude: 26.1551,
      longitude: 50.1964,
      country: ArabCountry.saudiArabia,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // الإمارات العربية المتحدة
  // ================================
  ArabCountry.uae: [
    CityInfo(
      name: 'دبي',
      latitude: 25.2048,
      longitude: 55.2708,
      country: ArabCountry.uae,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'أبو ظبي',
      latitude: 24.4539,
      longitude: 54.3773,
      country: ArabCountry.uae,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'الشارقة',
      latitude: 25.3571,
      longitude: 55.3986,
      country: ArabCountry.uae,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'عجمان',
      latitude: 25.4001,
      longitude: 55.4699,
      country: ArabCountry.uae,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // الكويت
  // ================================
  ArabCountry.kuwait: [
    CityInfo(
      name: 'مدينة الكويت',
      latitude: 29.3759,
      longitude: 47.9774,
      country: ArabCountry.kuwait,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // البحرين
  // ================================
  ArabCountry.bahrain: [
    CityInfo(
      name: 'المنامة',
      latitude: 26.1667,
      longitude: 50.5557,
      country: ArabCountry.bahrain,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // قطر
  // ================================
  ArabCountry.qatar: [
    CityInfo(
      name: 'الدوحة',
      latitude: 25.2854,
      longitude: 51.5310,
      country: ArabCountry.qatar,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // عمان
  // ================================
  ArabCountry.oman: [
    CityInfo(
      name: 'مسقط',
      latitude: 23.6100,
      longitude: 58.5400,
      country: ArabCountry.oman,
      timeZoneOffset: 240, // UTC+4
    ),
  ],

  // ================================
  // اليمن
  // ================================
  ArabCountry.yemen: [
    CityInfo(
      name: 'صنعاء',
      latitude: 15.3694,
      longitude: 48.5165,
      country: ArabCountry.yemen,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'عدن',
      latitude: 12.7835,
      longitude: 45.3569,
      country: ArabCountry.yemen,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // الأردن
  // ================================
  ArabCountry.jordan: [
    CityInfo(
      name: 'عمّان',
      latitude: 31.9454,
      longitude: 35.9284,
      country: ArabCountry.jordan,
      timeZoneOffset: 120,
    ),
  ],

  // ================================
  // فلسطين
  // ================================
  ArabCountry.palestine: [
    CityInfo(
      name: 'القدس',
      latitude: 31.7683,
      longitude: 35.2137,
      country: ArabCountry.palestine,
      timeZoneOffset: 120,
    ),
    CityInfo(
      name: 'غزة',
      latitude: 31.5267,
      longitude: 34.4399,
      country: ArabCountry.palestine,
      timeZoneOffset: 120,
    ),
  ],

  // ================================
  // لبنان
  // ================================
  ArabCountry.lebanon: [
    CityInfo(
      name: 'بيروت',
      latitude: 33.8886,
      longitude: 35.4955,
      country: ArabCountry.lebanon,
      timeZoneOffset: 120,
    ),
  ],

  // ================================
  // سوريا
  // ================================
  ArabCountry.syria: [
    CityInfo(
      name: 'دمشق',
      latitude: 33.5138,
      longitude: 36.2765,
      country: ArabCountry.syria,
      timeZoneOffset: 120,
    ),
  ],

  // ================================
  // العراق
  // ================================
  ArabCountry.iraq: [
    CityInfo(
      name: 'بغداد',
      latitude: 33.3128,
      longitude: 44.3615,
      country: ArabCountry.iraq,
      timeZoneOffset: 180,
    ),
    CityInfo(
      name: 'البصرة',
      latitude: 30.5085,
      longitude: 47.8084,
      country: ArabCountry.iraq,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // تونس
  // ================================
  ArabCountry.tunisia: [
    CityInfo(
      name: 'تونس',
      latitude: 36.8065,
      longitude: 10.1686,
      country: ArabCountry.tunisia,
      timeZoneOffset: 60,
    ),
  ],

  // ================================
  // الجزائر
  // ================================
  ArabCountry.algeria: [
    CityInfo(
      name: 'الجزائر',
      latitude: 36.7538,
      longitude: 3.0588,
      country: ArabCountry.algeria,
      timeZoneOffset: 60,
    ),
  ],

  // ================================
  // المغرب
  // ================================
  ArabCountry.morocco: [
    CityInfo(
      name: 'الرباط',
      latitude: 34.0209,
      longitude: -6.8416,
      country: ArabCountry.morocco,
      timeZoneOffset: 0,
    ),
    CityInfo(
      name: 'فاس',
      latitude: 33.9716,
      longitude: -5.0025,
      country: ArabCountry.morocco,
      timeZoneOffset: 0,
    ),
    CityInfo(
      name: 'مراكش',
      latitude: 31.6295,
      longitude: -8.0100,
      country: ArabCountry.morocco,
      timeZoneOffset: 0,
    ),
  ],

  // ================================
  // ليبيا
  // ================================
  ArabCountry.libya: [
    CityInfo(
      name: 'طرابلس',
      latitude: 32.8872,
      longitude: 13.1913,
      country: ArabCountry.libya,
      timeZoneOffset: 120,
    ),
  ],

  // ================================
  // السودان
  // ================================
  ArabCountry.sudan: [
    CityInfo(
      name: 'الخرطوم',
      latitude: 15.5527,
      longitude: 32.5599,
      country: ArabCountry.sudan,
      timeZoneOffset: 180,
    ),
  ],

  // ================================
  // موريتانيا
  // ================================
  ArabCountry.mauritania: [
    CityInfo(
      name: 'نواكشوط',
      latitude: 18.0735,
      longitude: -15.9582,
      country: ArabCountry.mauritania,
      timeZoneOffset: 0,
    ),
  ],
};

// ================================================================
// إعدادات مواقيت الصلاة
// ================================================================

class PrayerSettings {
  final ArabCountry selectedCountry;
  final CityInfo selectedCity;
  final IslamicSchool selectedSchool;
  final PrayerAuthority selectedAuthority;

  // ========== تعديل الأوقات ==========
  final int fajrAdjustmentMinutes; // إضافة أو طرح دقائق من وقت الفجر
  final int dhuhrAdjustmentMinutes;
  final int asrAdjustmentMinutes;
  final int maghribAdjustmentMinutes;
  final int ishaAdjustmentMinutes;

  // ========== التوقيت الصيفي ==========
  final bool isDaylightSavingEnabled;

  PrayerSettings({
    required this.selectedCountry,
    required this.selectedCity,
    required this.selectedSchool,
    required this.selectedAuthority,
    this.fajrAdjustmentMinutes = 0,
    this.dhuhrAdjustmentMinutes = 0,
    this.asrAdjustmentMinutes = 0,
    this.maghribAdjustmentMinutes = 0,
    this.ishaAdjustmentMinutes = 0,
    this.isDaylightSavingEnabled = false,
  });

  /// نسخ الإعدادات مع تغيير بعضها
  PrayerSettings copyWith({
    ArabCountry? selectedCountry,
    CityInfo? selectedCity,
    IslamicSchool? selectedSchool,
    PrayerAuthority? selectedAuthority,
    int? fajrAdjustmentMinutes,
    int? dhuhrAdjustmentMinutes,
    int? asrAdjustmentMinutes,
    int? maghribAdjustmentMinutes,
    int? ishaAdjustmentMinutes,
    bool? isDaylightSavingEnabled,
  }) {
    return PrayerSettings(
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedSchool: selectedSchool ?? this.selectedSchool,
      selectedAuthority: selectedAuthority ?? this.selectedAuthority,
      fajrAdjustmentMinutes:
          fajrAdjustmentMinutes ?? this.fajrAdjustmentMinutes,
      dhuhrAdjustmentMinutes:
          dhuhrAdjustmentMinutes ?? this.dhuhrAdjustmentMinutes,
      asrAdjustmentMinutes: asrAdjustmentMinutes ?? this.asrAdjustmentMinutes,
      maghribAdjustmentMinutes:
          maghribAdjustmentMinutes ?? this.maghribAdjustmentMinutes,
      ishaAdjustmentMinutes:
          ishaAdjustmentMinutes ?? this.ishaAdjustmentMinutes,
      isDaylightSavingEnabled:
          isDaylightSavingEnabled ?? this.isDaylightSavingEnabled,
    );
  }
}
