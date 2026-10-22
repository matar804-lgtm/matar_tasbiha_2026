import 'package:adhan/adhan.dart';

import '../models/prayer_settings_model.dart';

/// 🕌 خدمة حساب مواقيت الصلاة المتقدمة
class AdvancedPrayerCalculationService {
  /// تحويل جهة الاعتماد إلى طريقة الحساب المتاحة في مكتبة adhan
  static CalculationMethod _convertAuthorityToCalculationMethod(
    PrayerAuthority authority,
  ) {
    switch (authority) {
      case PrayerAuthority.umAlQura:
      case PrayerAuthority.kingAbdulaziz:
        return CalculationMethod.umm_al_qura;

      case PrayerAuthority.egyptian:
        return CalculationMethod.egyptian;

      case PrayerAuthority.isna:
        return CalculationMethod.north_america;

      case PrayerAuthority.mwl:
        return CalculationMethod.muslim_world_league;

      case PrayerAuthority.kuwait:
        return CalculationMethod.kuwait;

      case PrayerAuthority.algerian:
      case PrayerAuthority.tunisian:
      case PrayerAuthority.alAzhar:
      case PrayerAuthority.islamic:
        return CalculationMethod.other;
    }
  }

  /// تحويل المذهب الفقهي إلى Madhab
  ///
  /// مكتبة adhan تدعم فقط:
  /// - Madhab.hanafi
  /// - Madhab.shafi
  ///
  /// المالكية والحنابلة والشفـاعية تستخدم حكم الشافعية
  /// لحساب وقت العصر.
  static Madhab _convertSchoolToMadhab(IslamicSchool school) {
    switch (school) {
      case IslamicSchool.hanafi:
        return Madhab.hanafi;

      case IslamicSchool.shafi:
      case IslamicSchool.maliki:
      case IslamicSchool.hanbali:
        return Madhab.shafi;
    }
  }

  /// حساب مواقيت الصلاة مع تطبيق جميع الإعدادات
  static PrayerTimes calculatePrayerTimes({
    required DateTime date,
    required PrayerSettings settings,
  }) {
    // ========================================
    // إعداد الإحداثيات
    // ========================================
    final Coordinates coordinates = Coordinates(
      settings.selectedCity.latitude,
      settings.selectedCity.longitude,
    );

    // ========================================
    // إعداد اليوم (DateComponents)
    // ========================================
    final DateComponents dateComponents = DateComponents(
      date.year,
      date.month,
      date.day,
    );

    // ========================================
    // إعداد طريقة الحساب والمذهب
    // ========================================
    final CalculationMethod calculationMethod =
        _convertAuthorityToCalculationMethod(
      settings.selectedAuthority,
    );

    final CalculationParameters params = calculationMethod.getParameters();

    params.madhab = _convertSchoolToMadhab(
      settings.selectedSchool,
    );

    // ========================================
    // تطبيق التعديلات والدعم للتوقيت الصيفي
    // ========================================
    final int daylightOffset = settings.isDaylightSavingEnabled ? 60 : 0;

    params.adjustments.fajr = settings.fajrAdjustmentMinutes + daylightOffset;

    params.adjustments.dhuhr = settings.dhuhrAdjustmentMinutes + daylightOffset;

    params.adjustments.asr = settings.asrAdjustmentMinutes + daylightOffset;

    params.adjustments.maghrib =
        settings.maghribAdjustmentMinutes + daylightOffset;

    params.adjustments.isha = settings.ishaAdjustmentMinutes + daylightOffset;

    // ========================================
    // حساب مواقيت الصلاة
    // ========================================
    return PrayerTimes(
      coordinates,
      dateComponents,
      params,
    );
  }
}

/// 🎯 محسنات PrayerTimes للحصول على Map بسهولة
extension PrayerTimesAdjustment on PrayerTimes {
  /// الحصول على خريطة بأوقات الصلاة
  Map<Prayer, DateTime> getPrayerTimesMap() {
    return {
      Prayer.fajr: fajr,
      Prayer.sunrise: sunrise,
      Prayer.dhuhr: dhuhr,
      Prayer.asr: asr,
      Prayer.maghrib: maghrib,
      Prayer.isha: isha,
    };
  }
}
