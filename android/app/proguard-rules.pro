# ==========================================
# قواعد ProGuard / R8 لتطبيق Flutter + Firebase
# ==========================================

# 1. تجاهل فئات Google Play Core المفقودة (لأننا لا نستخدم Deferred Components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# 2. الحفاظ على أكواد Flutter الأساسية
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# 3. الحفاظ على أكواد Firebase و Crashlytics
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# 4. الحفاظ على أسماء الفئات والحقول المستخدمة في الانعكاس (Reflection)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 5. قواعد عامة لتجنب الأخطاء
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod