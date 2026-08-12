# 📿 تطبيق تسبيحة (Tasbih App)

<p align="center">
  <img src="assets/images/app_icon.png" alt="Tasbih App Logo" width="150" />
</p>

<p align="center">
  <strong>رفيقك الإسلامي اليومي لتقريبك إلى الله</strong>
  <br />
  <em>تم التطوير بفخر بواسطة استوديو AppNest</em>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.19.0-02569B?style=for-the-badge&logo=flutter" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.0.0-0175C2?style=for-the-badge&logo=dart" alt="Dart"></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase" alt="Firebase"></a>
  <a href="https://github.com/matar804-lgtm/matar_tasbiha_2026/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge" alt="License"></a>
</p>

---

## 📖 نبذة عن المشروع
تطبيق **"تسبيحة"** هو تطبيق إسلامي شامل ومتكامل، تم تطويره باستخدام إطار عمل **Flutter** لضمان أداء عالٍ وتجربة مستخدم سلسة على أجهزة Android. يهدف التطبيق إلى توفير بيئة روحانية عصرية تجمع بين عداد التسبيح الذكي، القرآن الكريم، مواقيت الصلاة، والمكتبة الإسلامية في واجهة مستخدم أنيقة مستوحاة من الهوية الإسلامية.

---

## ✨ الميزات الرئيسية

### 📿 عداد التسبيح الذكي
- عداد تفاعلي مع اهتزاز عند كل ضغطة.
- إمكانية تخصيص الأهداف اليومية ومتابعة التقدم.
- حفظ آخر ذكر تم استخدامه تلقائياً.

### 📖 القرآن الكريم
- قائمة كاملة بسور القرآن الكريم (114 سورة).
- عرض الآيات بخط "Amiri" الواضح والمريح للعين.
- **نظام إشارات مرجعية دقيق:** يحفظ رقم السورة ورقم الآية المحددة بدقة متناهية للعودة إليها لاحقاً.

### 🕌 مواقيت الصلاة والإشعارات
- تحديد الموقع الجغرافي تلقائياً لحساب أوقات الصلاة بدقة.
- إشعارات محلية (Local Notifications) تعمل في الخلفية حتى بعد إعادة تشغيل الجهاز.
- دعم حسابات أم القرى والرابطة العالمية.

### 🧭 بوصلة القبلة
- تحديد اتجاه القبلة بدقة باستخدام مستشعرات الجهاز (Flutter Compass).

### 📚 المكتبة الإسلامية
- **الأدعية المأثورة:** مجموعة شاملة من الأدعية مصنفة حسب المناسبات.
- **الأذكار:** أذكار الصباح، المساء، النوم، وبعد الصلاة.
- **الرقية الشرعية:** نصوص الرقية كاملة.
- **مفاتيح الفرج:** أدعية وأذكار مخصصة لرفع الهموم.

### ⚙️ ميزات تقنية متقدمة
- **Firebase Analytics:** لتحليل سلوك المستخدم وتحسين التجربة.
- **Firebase Crashlytics:** لمراقبة الأخطاء وضمان استقرار التطبيق.
- **Firebase Remote Config:** للتحكم في ميزات التطبيق عن بُعد دون الحاجة لتحديث.
- **نظام التحديث التلقائي (Upgrader):** إشعار المستخدم بوجود إصدار جديد من التطبيق باللغة العربية.

---

## 📸 لقطات من التطبيق
*(يمكنك استبدال روابط الصور أدناه بلقطات شاشة حقيقية من التطبيق لاحقاً)*

<p align="center">
  <img src="assets/images/bg_home.jpg" alt="الشاشة الرئيسية" width="200" />
  <img src="assets/images/bg_quran.jpg" alt="القرآن الكريم" width="200" />
  <img src="assets/images/bg_tasbih.jpg" alt="عداد التسبيح" width="200" />
  <img src="assets/images/bg_prayer_times.jpg" alt="مواقيت الصلاة" width="200" />
</p>

---

## 🛠️ تقنيات البناء (Tech Stack)

| التقنية | الاستخدام |
| :--- | :--- |
| **Flutter & Dart** | بناء واجهة المستخدم ومنطق التطبيق |
| **Firebase Core** | الربط مع خدمات جوجل السحابية |
| `flutter_local_notifications` | جدولة إشعارات الصلاة المحلية |
| `geolocator` | تحديد الموقع الحالي لحساب المواقيت |
| `shared_preferences` | حفظ الإعدادات، الأهداف، والإشارات المرجعية محلياً |
| `quran` | مكتبة نصوص القرآن الكريم والآيات |
| `upgrader` | فحص وإشعارات تحديثات التطبيق |

---

## 🚀 كيفية تشغيل المشروع محلياً

لبدء العمل على المشروع أو المساهمة فيه، اتبع الخطوات التالية:

1. **استنساخ المستودع:**
   ```bash
   git clone https://github.com/matar804-lgtm/matar_tasbiha_2026.git
