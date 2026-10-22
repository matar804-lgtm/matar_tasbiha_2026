import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_settings_model.dart';
import '../data/jordan_ministry_2026.dart';

class PrayerSettingsService {
  static const String _countryKey = 'prayer_selected_country';
  static const String _cityNameKey = 'prayer_selected_city_name';
  static const String _schoolKey = 'prayer_selected_school';
  static const String _authorityKey = 'prayer_selected_authority';
  static const String _fajrAdjustKey = 'prayer_fajr_adjust';
  static const String _dhuhrAdjustKey = 'prayer_dhuhr_adjust';
  static const String _asrAdjustKey = 'prayer_asr_adjust';
  static const String _maghribAdjustKey = 'prayer_maghrib_adjust';
  static const String _ishaAdjustKey = 'prayer_isha_adjust';
  static const String _daylightSavingKey = 'prayer_daylight_saving';
  static const String _jordanMinistryMigrationKey =
      'prayer_jordan_ministry_migrated_v1';

  static Future<bool> savePrayerSettings(PrayerSettings settings) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_countryKey, settings.selectedCountry.name);
      await prefs.setString(_cityNameKey, settings.selectedCity.name);
      await prefs.setString(_schoolKey, settings.selectedSchool.name);
      await prefs.setString(_authorityKey, settings.selectedAuthority.name);
      await prefs.setInt(_fajrAdjustKey, settings.fajrAdjustmentMinutes);
      await prefs.setInt(_dhuhrAdjustKey, settings.dhuhrAdjustmentMinutes);
      await prefs.setInt(_asrAdjustKey, settings.asrAdjustmentMinutes);
      await prefs.setInt(_maghribAdjustKey, settings.maghribAdjustmentMinutes);
      await prefs.setInt(_ishaAdjustKey, settings.ishaAdjustmentMinutes);
      await prefs.setBool(
        _daylightSavingKey,
        settings.isDaylightSavingEnabled,
      );

      // Keep the old manual-location keys synchronized for compatibility
      // with older screens/versions that may still read them.
      await prefs.setBool('prayer_manual_location', true);
      await prefs.setString('prayer_country', settings.selectedCountry.label);
      await prefs.setString('prayer_city', settings.selectedCity.name);
      await prefs.setDouble(
        'prayer_latitude',
        settings.selectedCity.latitude,
      );
      await prefs.setDouble(
        'prayer_longitude',
        settings.selectedCity.longitude,
      );

      return true;
    } catch (e) {
      debugPrint('خطأ في حفظ إعدادات الصلاة: $e');
      return false;
    }
  }

  static Future<PrayerSettings?> loadPrayerSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? countryName = prefs.getString(_countryKey);
      final String? cityName = prefs.getString(_cityNameKey);

      if (countryName == null || cityName == null) {
        return null;
      }

      final ArabCountry country = ArabCountry.values.firstWhere(
        (ArabCountry item) => item.name == countryName,
        orElse: () => ArabCountry.jordan,
      );

      final List<CityInfo> cities = arabCitiesByCountry[country] ?? const [];
      if (cities.isEmpty) {
        return null;
      }

      final CityInfo city = cities.firstWhere(
        (CityInfo item) => item.name == cityName,
        orElse: () => cities.first,
      );

      final String? schoolName = prefs.getString(_schoolKey);
      String? authorityName = prefs.getString(_authorityKey);

      // One-time migration: only the old MWL default in the supported central
      // Jordan region becomes the official 2026 Ministry calendar. Other
      // explicitly selected calculation authorities are preserved.
      if (country == ArabCountry.jordan &&
          _isJordanCentralCity(city) &&
          !(prefs.getBool(_jordanMinistryMigrationKey) ?? false)) {
        if (authorityName == null ||
            authorityName == PrayerAuthority.mwl.name) {
          authorityName = PrayerAuthority.jordanMinistry.name;
          await prefs.setString(_authorityKey, authorityName);
        }
        await prefs.setBool(_jordanMinistryMigrationKey, true);
      }

      final IslamicSchool school = schoolName == null
          ? IslamicSchool.shafi
          : IslamicSchool.values.firstWhere(
              (IslamicSchool item) => item.name == schoolName,
              orElse: () => IslamicSchool.shafi,
            );

      final PrayerAuthority authority = authorityName == null
          ? defaultAuthorityForCountry(country)
          : PrayerAuthority.values.firstWhere(
              (PrayerAuthority item) => item.name == authorityName,
              orElse: () => PrayerAuthority.umAlQura,
            );

      return PrayerSettings(
        selectedCountry: country,
        selectedCity: city,
        selectedSchool: school,
        selectedAuthority: authority,
        fajrAdjustmentMinutes: prefs.getInt(_fajrAdjustKey) ?? 0,
        dhuhrAdjustmentMinutes: prefs.getInt(_dhuhrAdjustKey) ?? 0,
        asrAdjustmentMinutes: prefs.getInt(_asrAdjustKey) ?? 0,
        maghribAdjustmentMinutes: prefs.getInt(_maghribAdjustKey) ?? 0,
        ishaAdjustmentMinutes: prefs.getInt(_ishaAdjustKey) ?? 0,
        isDaylightSavingEnabled: prefs.getBool(_daylightSavingKey) ?? false,
      );
    } catch (e) {
      debugPrint('خطأ في تحميل إعدادات الصلاة: $e');
      return null;
    }
  }

  static Future<void> clearPrayerSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_countryKey);
    await prefs.remove(_cityNameKey);
    await prefs.remove(_schoolKey);
    await prefs.remove(_authorityKey);
    await prefs.remove(_fajrAdjustKey);
    await prefs.remove(_dhuhrAdjustKey);
    await prefs.remove(_asrAdjustKey);
    await prefs.remove(_maghribAdjustKey);
    await prefs.remove(_ishaAdjustKey);
    await prefs.remove(_daylightSavingKey);

    await prefs.setBool('prayer_manual_location', false);
    await prefs.remove('prayer_country');
    await prefs.remove('prayer_city');
    await prefs.remove('prayer_latitude');
    await prefs.remove('prayer_longitude');
  }

  static PrayerAuthority defaultAuthorityForCountry(ArabCountry country) {
    switch (country) {
      case ArabCountry.egypt:
        return PrayerAuthority.egyptian;
      case ArabCountry.saudiArabia:
        return PrayerAuthority.umAlQura;
      case ArabCountry.kuwait:
        return PrayerAuthority.kuwait;
      case ArabCountry.algeria:
        return PrayerAuthority.algerian;
      case ArabCountry.tunisia:
        return PrayerAuthority.tunisian;
      case ArabCountry.jordan:
        return PrayerAuthority.jordanMinistry;
      default:
        return PrayerAuthority.mwl;
    }
  }

  static PrayerSettings getDefaultSettings() {
    final List<CityInfo> jordanCities =
        arabCitiesByCountry[ArabCountry.jordan] ?? const [];

    if (jordanCities.isEmpty) {
      throw Exception(
          'No cities configured for default Jordan prayer settings');
    }

    return PrayerSettings(
      selectedCountry: ArabCountry.jordan,
      selectedCity: jordanCities.first,
      selectedSchool: IslamicSchool.shafi,
      selectedAuthority: PrayerAuthority.jordanMinistry,
    );
  }

  /// Converts the user's selected authority into the corresponding
  /// calculation-method enum when it exists in the installed `adhan` version.
  /// Using the enum name keeps this compatible with adhan releases that may
  /// not expose every authority-specific method.
  static CalculationMethod _methodForAuthority(
    PrayerAuthority authority,
  ) {
    final String preferredName;

    switch (authority) {
      case PrayerAuthority.umAlQura:
      case PrayerAuthority.kingAbdulaziz:
        preferredName = 'umm_al_qura';
        break;
      case PrayerAuthority.egyptian:
      case PrayerAuthority.alAzhar:
        preferredName = 'egyptian';
        break;
      case PrayerAuthority.isna:
        preferredName = 'north_america';
        break;
      case PrayerAuthority.jordanMinistry:
      case PrayerAuthority.mwl:
        preferredName = 'muslim_world_league';
        break;
      case PrayerAuthority.kuwait:
        preferredName = 'kuwait';
        break;
      case PrayerAuthority.algerian:
        preferredName = 'algeria';
        break;
      case PrayerAuthority.tunisian:
        preferredName = 'tunisia';
        break;
      case PrayerAuthority.islamic:
        preferredName = 'muslim_world_league';
        break;
    }

    return CalculationMethod.values.firstWhere(
      (CalculationMethod method) => method.name == preferredName,
      orElse: () => CalculationMethod.muslim_world_league,
    );
  }

  static CalculationParameters getCalculationParameters(
    PrayerSettings settings,
  ) {
    final CalculationParameters params =
        _methodForAuthority(settings.selectedAuthority).getParameters();

    params.madhab = settings.selectedSchool == IslamicSchool.hanafi
        ? Madhab.hanafi
        : Madhab.shafi;

    int dst = 0;
    if (settings.isDaylightSavingEnabled) {
      dst = 60;
    }

    params.adjustments.fajr = settings.fajrAdjustmentMinutes + dst;
    params.adjustments.dhuhr = settings.dhuhrAdjustmentMinutes + dst;
    params.adjustments.asr = settings.asrAdjustmentMinutes + dst;
    params.adjustments.maghrib = settings.maghribAdjustmentMinutes + dst;
    params.adjustments.isha = settings.ishaAdjustmentMinutes + dst;

    return params;
  }

  static bool _isJordanCentralCity(CityInfo city) {
    final String normalizedName = city.name
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), '');
    const Set<String> supportedNames = <String>{
      'عمان',
      'الزرقاء',
      'السلط',
      'مادبا',
      'البلقاء',
    };
    if (supportedNames.contains(normalizedName)) return true;

    // Fallback for alternate city labels within the calendar's central region.
    return city.latitude >= 31.65 &&
        city.latitude <= 32.15 &&
        city.longitude >= 35.65 &&
        city.longitude <= 36.25;
  }

  static int _officialOffsetMinutes(DateTime calculated, DateTime official) {
    return official.difference(calculated).inMinutes;
  }

  static PrayerTimes calculatePrayerTimes(
    PrayerSettings settings, {
    DateTime? date,
  }) {
    final DateTime target = date ?? DateTime.now();
    final Coordinates coordinates = Coordinates(
      settings.selectedCity.latitude,
      settings.selectedCity.longitude,
    );
    final DateComponents components = DateComponents(
      target.year,
      target.month,
      target.day,
    );

    final bool useOfficialCalendar =
        settings.selectedCountry == ArabCountry.jordan &&
            settings.selectedAuthority == PrayerAuthority.jordanMinistry &&
            _isJordanCentralCity(settings.selectedCity);
    final JordanMinistryPrayerCalendarDay? officialDay = useOfficialCalendar
        ? JordanMinistryPrayerCalendarDay.forDate(target)
        : null;

    if (officialDay == null) {
      // Outside the 2026 table or outside its supported region, keep the
      // existing calculation behaviour rather than inventing official values.
      return PrayerTimes(
        coordinates,
        components,
        getCalculationParameters(settings),
      );
    }

    // Re-use adhan's PrayerTimes type, but calibrate its minute adjustments so
    // all six displayed events match the Ministry's published wall-clock times.
    // User-entered prayer adjustments remain relative to the official values.
    // The table already includes the seasonal clock change, so don't add the
    // app's manual daylight-saving hour a second time for dates in this table.
    final CalculationParameters baselineParameters =
        CalculationMethod.muslim_world_league.getParameters();
    final PrayerTimes baseline =
        PrayerTimes(coordinates, components, baselineParameters);
    final CalculationParameters officialParameters =
        CalculationMethod.muslim_world_league.getParameters();

    officialParameters.adjustments.fajr =
        _officialOffsetMinutes(baseline.fajr, officialDay.fajrAt(target)) +
            settings.fajrAdjustmentMinutes;
    officialParameters.adjustments.sunrise =
        _officialOffsetMinutes(baseline.sunrise, officialDay.sunriseAt(target));
    officialParameters.adjustments.dhuhr =
        _officialOffsetMinutes(baseline.dhuhr, officialDay.dhuhrAt(target)) +
            settings.dhuhrAdjustmentMinutes;
    officialParameters.adjustments.asr =
        _officialOffsetMinutes(baseline.asr, officialDay.asrAt(target)) +
            settings.asrAdjustmentMinutes;
    officialParameters.adjustments.maghrib = _officialOffsetMinutes(
            baseline.maghrib, officialDay.maghribAt(target)) +
        settings.maghribAdjustmentMinutes;
    officialParameters.adjustments.isha =
        _officialOffsetMinutes(baseline.isha, officialDay.ishaAt(target)) +
            settings.ishaAdjustmentMinutes;

    return PrayerTimes(coordinates, components, officialParameters);
  }
}
