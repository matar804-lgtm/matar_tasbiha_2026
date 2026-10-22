## 🚀 البدء السريع - Quick Start Guide

---

## ✨ الملفات الأساسية فقط

### 1. استيراد البيانات
```dart
import 'lib/models/prayer_settings_model.dart';
```

### 2. الحصول على الدول والمدن
```dart
// جميع الدول
final countries = ArabCountry.values;
// الدول المتاحة: egypt, saudiArabia, uae, kuwait, ...

// مدن دول معينة
final egyptCities = arabCitiesByCountry[ArabCountry.egypt];
// النتيجة: [القاهرة، الإسكندرية، ...]
```

### 3. الحصول على المذاهب
```dart
// جميع المذاهب
final schools = IslamicSchool.values;
// hanafi, maliki, shafi, hanbali

// اختيار محدد
final selectedSchool = IslamicSchool.shafi;
print(selectedSchool.label); // الشافعي
```

### 4. الحصول على جهات الاعتماد
```dart
// جميع الجهات
final authorities = PrayerAuthority.values;

// معلومات جهة
final authority = PrayerAuthority.umAlQura;
print(authority.label);    // أم القرى
print(authority.country);  // المملكة العربية السعودية
```

### 5. إنشاء إعدادات
```dart
final settings = PrayerSettings(
  selectedCountry: ArabCountry.egypt,
  selectedCity: arabCitiesByCountry[ArabCountry.egypt]![0],
  selectedSchool: IslamicSchool.shafi,
  selectedAuthority: PrayerAuthority.egyptian,
  fajrAdjustmentMinutes: 0,
  dhuhrAdjustmentMinutes: 0,
  asrAdjustmentMinutes: 0,
  maghribAdjustmentMinutes: 0,
  ishaAdjustmentMinutes: 0,
  isDaylightSavingEnabled: false,
);
```

---

## 💾 حفظ وتحميل

### حفظ الإعدادات
```dart
import 'lib/services/prayer_settings_service.dart';

await PrayerSettingsService.savePrayerSettings(settings);
```

### تحميل الإعدادات
```dart
final loaded = await PrayerSettingsService.loadPrayerSettings();

if (loaded != null) {
  print('تم تحميل الإعدادات');
  print('المدينة: ${loaded.selectedCity.name}');
} else {
  print('لا توجد إعدادات محفوظة');
}
```

### الإعدادات الافتراضية
```dart
final defaults = PrayerSettingsService.getDefaultSettings();
// مصر، القاهرة، شافعي، مصري
```

---

## 🧮 حساب مواقيت الصلاة

```dart
import 'lib/services/advanced_prayer_calculation_service.dart';

// حساب مواقيت اليوم الحالي
final prayerTimes = AdvancedPrayerCalculationService.calculatePrayerTimes(
  date: DateTime.now(),
  settings: settings,
);

// الأوقات
print(prayerTimes.fajr);     // وقت الفجر
print(prayerTimes.dhuhr);    // وقت الظهر
print(prayerTimes.asr);      // وقت العصر
print(prayerTimes.maghrib);  // وقت المغرب
print(prayerTimes.isha);     // وقت العشاء
```

---

## 🎨 واجهة المستخدم

### فتح شاشة الإعدادات
```dart
import 'lib/screens/prayer_times_settings_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PrayerTimesSettingsScreen(
      initialSettings: settings,
      onSettingsSaved: (newSettings) {
        // تم حفظ الإعدادات الجديدة
        print('المدينة الجديدة: ${newSettings.selectedCity.name}');
        
        // إعادة حساب مواقيت الصلاة
        final newTimes = AdvancedPrayerCalculationService
          .calculatePrayerTimes(
            date: DateTime.now(),
            settings: newSettings,
          );
      },
    ),
  ),
);
```

---

## 📋 أمثلة عملية

### مثال 1: عرض جميع المدن
```dart
void printAllCities() {
  arabCitiesByCountry.forEach((country, cities) {
    print('${country.label}:');
    for (var city in cities) {
      print('  - ${city.name}');
    }
  });
}
```

### مثال 2: البحث عن مدينة
```dart
CityInfo? findCity(String cityName) {
  for (var cities in arabCitiesByCountry.values) {
    try {
      return cities.firstWhere((c) => c.name == cityName);
    } catch (e) {
      continue;
    }
  }
  return null;
}
```

### مثال 3: تعديل الإعدادات
```dart
final updatedSettings = settings.copyWith(
  selectedSchool: IslamicSchool.hanafi,
  fajrAdjustmentMinutes: 5,
  isDaylightSavingEnabled: true,
);

// لم نغير: الدولة، المدينة، الجهة
// فقط غيرنا: المذهب، تعديل الفجر، التوقيت الصيفي
```

### مثال 4: عرض معلومات المدينة
```dart
void printCityInfo(CityInfo city) {
  print('المدينة: ${city.name}');
  print('الدولة: ${city.country.label}');
  print('الإحداثيات: ${city.latitude}, ${city.longitude}');
  print('فارق التوقيت: UTC + ${city.timeZoneOffset / 60}');
}
```

---

## 🔄 تدفق العمل الكامل

```dart
// 1. تحميل الإعدادات
PrayerSettings settings = await PrayerSettingsService
  .loadPrayerSettings() ?? 
  PrayerSettingsService.getDefaultSettings();

// 2. حساب الأوقات
PrayerTimes times = AdvancedPrayerCalculationService
  .calculatePrayerTimes(
    date: DateTime.now(),
    settings: settings,
  );

// 3. عرض الأوقات
print('الفجر: ${times.fajr}');
print('الظهر: ${times.dhuhr}');
// ...

// 4. إذا أراد المستخدم تغيير الإعدادات
settings = settings.copyWith(
  selectedCity: newCity,
  fajrAdjustmentMinutes: 5,
);

// 5. حفظ الإعدادات الجديدة
await PrayerSettingsService.savePrayerSettings(settings);

// 6. إعادة حساب الأوقات
times = AdvancedPrayerCalculationService
  .calculatePrayerTimes(
    date: DateTime.now(),
    settings: settings,
  );
```

---

## 🎯 أسئلة شائعة

**س: كيف أضيف مدينة جديدة؟**
```dart
arabCitiesByCountry[ArabCountry.egypt]?.add(
  CityInfo(
    name: 'المنيا',
    latitude: 28.0469,
    longitude: 30.7461,
    country: ArabCountry.egypt,
    timeZoneOffset: 120,
  ),
);
```

**س: كيف أعدل التوقيت الصيفي؟**
```dart
final updated = settings.copyWith(
  isDaylightSavingEnabled: !settings.isDaylightSavingEnabled,
);
```

**س: كيف أعرف الفرق في الأوقات؟**
```dart
// الأوقات الأصلية
final original = prayerTimes.fajr;

// الأوقات المعدلة
final adjusted = original.add(
  Duration(minutes: settings.fajrAdjustmentMinutes),
);

print('الفرق: ${adjusted.difference(original)}');
```

---

## 📱 التكامل مع prayer_times_screen.dart

```dart
class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await PrayerSettingsService.loadPrayerSettings() ??
        PrayerSettingsService.getDefaultSettings();
    _calculatePrayers();
  }

  void _calculatePrayers() {
    if (_settings == null) return;
    
    _prayerTimes = AdvancedPrayerCalculationService
      .calculatePrayerTimes(
        date: DateTime.now(),
        settings: _settings!,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(),
          ),
        ],
      ),
      // ... باقي الكود
    );
  }

  void _openSettings() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PrayerTimesSettingsScreen(
        initialSettings: _settings!,
        onSettingsSaved: (newSettings) {
          setState(() => _settings = newSettings);
          _calculatePrayers();
        },
      ),
    ),
  );
}
```

---

## ✅ قائمة التحقق

- [ ] استيراد الملفات الأربعة
- [ ] إضافة الاستيرادات المطلوبة
- [ ] تحميل الإعدادات في initState
- [ ] حساب الأوقات باستخدام الخدمة الجديدة
- [ ] إضافة زر الإعدادات في AppBar
- [ ] اختبار جميع الدول والمدن
- [ ] اختبار المذاهب المختلفة
- [ ] اختبار التعديلات والتوقيت الصيفي

---

## 🆘 استكشاف الأخطاء

| المشكلة | الحل |
|--------|------|
| لا تظهر المدن | تأكد من أن الدولة موجودة في قاموس |
| الأوقات لا تتغير | أعد استدعاء `calculatePrayerTimes` بعد التعديل |
| التوقيت الصيفي لا يعمل | تأكد من تفعيل الخيار وإعادة الحساب |
| خطأ في الحفظ | تأكد من وجود `shared_preferences` في pubspec.yaml |

---

**جاهز للاستخدام الفوري! 🎉**
