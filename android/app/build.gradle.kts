import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.appnest.tasbiha"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ السطر الجديد المطلوب لتفعيل Desugaring
        isCoreLibraryDesugaringEnabled = true 
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.appnest.tasbiha"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystorePropertiesFile = rootProject.file("key.properties")

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                
                keyAlias = keystoreProperties.getProperty("keyAlias") 
                    ?: throw GradleException("❌ خطأ: keyAlias غير موجود")
                keyPassword = keystoreProperties.getProperty("keyPassword") 
                    ?: throw GradleException("❌ خطأ: keyPassword غير موجود")
                storeFile = file(keystoreProperties.getProperty("storeFile") 
                    ?: throw GradleException("❌ خطأ: storeFile غير موجود"))
                storePassword = keystoreProperties.getProperty("storePassword") 
                    ?: throw GradleException("❌ خطأ: storePassword غير موجود")
            } else {
                throw GradleException("❌ خطأ فادح: ملف key.properties غير موجود")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

// ✅ الإضافة الجديدة المطلوبة لحل خطأ flutter_local_notifications
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}