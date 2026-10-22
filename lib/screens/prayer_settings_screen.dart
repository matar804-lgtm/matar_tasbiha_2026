import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_settings_model.dart';

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
        orElse: () => ArabCountry.egypt,
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
      final String? authorityName = prefs.getString(_authorityKey);

      final IslamicSchool school = schoolName == null
          ? IslamicSchool.shafi
          : IslamicSchool.values.firstWhere(
              (IslamicSchool item) => item.name == schoolName,
              orElse: () => IslamicSchool.shafi,
            );

      final PrayerAuthority authority = authorityName == null
          ? PrayerAuthority.umAlQura
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

  static PrayerSettings getDefaultSettings() {
    final List<CityInfo> egyptCities =
        arabCitiesByCountry[ArabCountry.egypt] ?? const [];

    if (egyptCities.isEmpty) {
      throw Exception('لم يتم العثور على أي مدن في الإعدادات الافتراضية');
    }

    return PrayerSettings(
      selectedCountry: ArabCountry.egypt,
      selectedCity: egyptCities.first,
      selectedSchool: IslamicSchool.shafi,
      selectedAuthority: PrayerAuthority.egyptian,
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

    return PrayerTimes(
      coordinates,
      components,
      getCalculationParameters(settings),
    );
  }
}
