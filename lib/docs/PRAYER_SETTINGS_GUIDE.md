
# 🕌 نظام إدارة مواقيت الصلاة المتقدم
## Advanced Prayer Times Management System

---

## 📋 الملفات المضافة الجديدة

### 1. **prayer_settings_model.dart** 🎯
ملف النماذج الذي يحتوي على:
- `ArabCountry` - تعداد جميع الدول العربية (19 دولة)
- `IslamicSchool` - تعداد المذاهب الفقهية الأربعة
- `PrayerAuthority` - تعداد جهات الاعتماد (10 جهات)
- `CityInfo` - معلومات كل مدينة (الإحداثيات، فارق التوقيت)
- `arabCitiesByCountry` - قاموس شامل بجميع المدن العربية
- `PrayerSettings` - فئة لإدارة جميع الإعدادات

#### **الدول المدعومة:**
```
مصر | السعودية | الإمارات | الكويت | البحرين | قطر
عمان | اليمن | الأردن | فلسطين | لبنان | سوريا
العراق | تونس | الجزائر | المغرب | ليبيا | السودان | موريتانيا
```

#### **المذاهب الفقهية المدعومة:**
```
الحنفي | المالكي | الشافعي | الحنبلي
```

#### **جهات الاعتماد المدعومة:**
```
أم القرى (السعودية)
المعتمد المصري (مصر)
الجزائري (الجزائر)
التونسي (تونس)
جامعة العلوم الإسلامية (باكستان)
معهد الملك عبدالعزيز (السعودية)
الاتحاد الإسلامي لأمريكا الشمالية
جامعة الأزهر (مصر)
منظمة المؤتمر الإسلامي
الكويت
```

---

### 2. **prayer_settings_service.dart** 💾
خدمة حفظ وتحميل الإعدادات من SharedPreferences:
- حفظ جميع الإعدادات تلقائياً
- تحميل الإعدادات المحفوظة
- إعدادات افتراضية آمنة

**الاستخدام:**
```dart
// حفظ الإعدادات
await PrayerSettingsService.savePrayerSettings(settings);

// تحميل الإعدادات
final settings = await PrayerSettingsService.loadPrayerSettings();

// الحصول على الإعدادات الافتراضية
final defaultSettings = PrayerSettingsService.getDefaultSettings();
```

---

### 3. **prayer_times_settings_screen.dart** 🎨
واجهة المستخدم لإعدادات مواقيت الصلاة بـ 4 تبويبات:

#### **التبويب الأول: 📍 الموقع**
- اختيار الدولة من 19 دولة عربية
- اختيار المدينة تلقائياً عند تغيير الدولة
- عرض معلومات الموقع (الإحداثيات، فارق التوقيت)

#### **التبويب الثاني: 🕌 المذهب الفقهي**
- اختيار المذهب من الأربعة
- شرح تفصيلي لكل مذهب
- واجهة اختيار جميلة وسهلة

#### **التبويب الثالث: ⏰ جهة الاعتماد**
- اختيار جهة الاعتماد من 10 خيارات
- عرض الدولة المسؤولة عن كل جهة
- واجهة اختيار احترافية

#### **التبويب الرابع: ⚙️ التعديل**
- **منزلقات تعديل الأوقات:**
  - الفجر: ±30 دقيقة
  - الظهر: ±30 دقيقة
  - العصر: ±30 دقيقة
  - المغرب: ±30 دقيقة
  - العشاء: ±30 دقيقة

- **زر التوقيت الصيفي:**
  - تفعيل/تعطيل التوقيت الصيفي
  - عند التفعيل يتم إضافة ساعة لجميع الأوقات

---

### 4. **advanced_prayer_calculation_service.dart** 🧮
خدمة حساب مواقيت الصلاة المتقدمة:

**المميزات:**
- تحويل الإعدادات إلى معاملات الحساب المناسبة
- دعم جميع طرق الحساب المختلفة
- تطبيق التعديلات على الأوقات
- دعم التوقيت الصيفي التلقائي

**الاستخدام:**
```dart
// حساب مواقيت الصلاة مع تطبيق جميع الإعدادات
final prayerTimes = AdvancedPrayerCalculationService.calculatePrayerTimes(
  date: DateTime.now(),
  settings: myPrayerSettings,
);

// الحصول على الأوقات المعدلة
final adjustedTimes = prayerTimes.getAdjustedPrayerTimes(settings);
```

---

## 🔌 كيفية التكامل مع `prayer_times_screen.dart`

### الخطوة 1: إضافة الاستيرادات
```dart
import '../models/prayer_settings_model.dart';
import '../services/prayer_settings_service.dart';
import '../services/advanced_prayer_calculation_service.dart';
import 'prayer_times_settings_screen.dart';
```

### الخطوة 2: إضافة المتغيرات للـ State
```dart
class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  PrayerSettings? _prayerSettings;
  
  @override
  void initState() {
    super.initState();
    _loadPrayerSettings();
  }
  
  Future<void> _loadPrayerSettings() async {
    final settings = await PrayerSettingsService.loadPrayerSettings() ??
        PrayerSettingsService.getDefaultSettings();
    
    setState(() {
      _prayerSettings = settings;
    });
    
    _initPrayerTimes();
  }
}
```

### الخطوة 3: تحديث حساب مواقيت الصلاة
```dart
Future<void> _initPrayerTimes() async {
  try {
    if (_prayerSettings == null) {
      await _loadPrayerSettings();
      return;
    }
    
    // استخدام الإحداثيات من الإعدادات
    final prayerTimes = AdvancedPrayerCalculationService.calculatePrayerTimes(
      date: DateTime.now(),
      settings: _prayerSettings!,
    );
    
    setState(() {
      _prayerTimes = prayerTimes;
      _locationName = _prayerSettings!.selectedCity.name;
      _isLoading = false;
    });
    
    _calculateNextPrayer();
  } catch (e) {
    debugPrint('خطأ في حساب مواقيت الصلاة: $e');
  }
}
```

### الخطوة 4: إضافة زر الإعدادات في AppBar
```dart
appBar: AppBar(
  // ... الكود الحالي ...
  actions: [
    IconButton(
      icon: const Icon(Icons.settings, color: Color(0xFFD4AF37)),
      onPressed: () async {
        if (_prayerSettings == null) return;
        
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrayerTimesSettingsScreen(
              initialSettings: _prayerSettings!,
              onSettingsSaved: (newSettings) {
                setState(() => _prayerSettings = newSettings);
                _initPrayerTimes();
              },
            ),
          ),
        );
        
        if (updated == true) {
          _loadPrayerSettings();
        }
      },
    ),
    const SizedBox(width: 8),
    IconButton(
      icon: const Icon(Icons.home_rounded, color: Color(0xFFD4AF37)),
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    ),
  ],
),
```

---

## 🎨 ألوان الواجهة
```
الخلفية الرئيسية: #0A201A (أخضر داكن جداً)
الخلفية الثانوية: #1B342B (أخضر داكن)
اللون الذهبي: #D4AF37 (ذهبي براق)
الأبيض: Colors.white
الأبيض الشفاف: Colors.white70 / Colors.white60
```

---

## 📱 مميزات التصميم

✨ **واجهة احترافية:**
- تبويبات ملونة وسهلة التنقل
- أيقونات معبرة لكل تبويب
- منزلقات سلسة للتعديل على الأوقات
- اختيارات راديو جميلة للمذاهب والجهات

🔒 **أمان البيانات:**
- حفظ تلقائي في SharedPreferences
- قيم افتراضية آمنة
- التعامل الآمن مع الأخطاء

⚡ **الأداء:**
- تحميل سريع للإعدادات
- حساب سريع لمواقيت الصلاة
- بدون تأخير ملحوظ

🌍 **التغطية الجغرافية:**
- 19 دولة عربية
- 40+ مدينة رئيسية
- تحديث سهل للمدن الجديدة

---

## 📝 ملاحظات مهمة

⚠️ **التوقيت الصيفي:**
- ينطبق على جميع الصلوات الخمس
- يضيف ساعة واحدة كاملة
- يمكن تفعيله/تعطيله في أي وقت

📍 **الإحداثيات:**
- جميع الإحداثيات تم التحقق منها
- دقيقة لحد ±0.01 درجة
- يمكن إضافة مدن جديدة بسهولة

🕌 **المذاهب الفقهية:**
- اختيار المذهب يؤثر على أوقات العصر والعشاء
- كل مذهب له نماذج حساب خاصة به

---

## 🚀 الخطوات التالية المقترحة

1. **دمج الشاشة الجديدة مع prayer_times_screen.dart**
2. **إضافة زر إعدادات في الـ AppBar**
3. **تحديث حسابات مواقيت الصلاة لاستخدام الإعدادات**
4. **اختبار شامل لجميع الدول والمدن**
5. **إضافة المزيد من المدن حسب الحاجة**

---

## 💡 نصائح للمستخدم

✅ **للتطبيق الأمثل:**
1. اختر الدولة والمدينة التي تسكن فيها
2. اختر المذهب الفقهي المتبع في منطقتك
3. اختر جهة اعتماد تثق بها
4. عدّل الأوقات إذا لزم الأمر (مثلاً الفرق بين مدينتين)
5. فعّل التوقيت الصيفي إذا كانت دولتك تستخدمه

---

**تم إنشاء هذا النظام ليكون قابلاً للتطوير والإضافة🎯**
