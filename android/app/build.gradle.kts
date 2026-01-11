plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin (must be last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finalproject"

    // ✅ Best supported SDK for Flutter + notifications
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ REQUIRED for flutter_local_notifications & sqflite
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.finalproject"

        // ✅ REQUIRED: notifications + sqflite
        minSdk = flutter.minSdkVersion

        // ✅ Stable & supported
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug signing for now (OK for flutter run --release)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ REQUIRED for Java 8+ APIs on Android
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
