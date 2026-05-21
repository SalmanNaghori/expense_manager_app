plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.antigravity.expense_manager_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.antigravity.expense_manager_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FLAVOR DIMENSIONS
    // Each flavor maps to a Dart entry-point via the --target (-t) flag:
    //   dev   → lib/main_dev.dart    (mock data, verbose logging)
    //   stage → lib/main_stage.dart  (staging API, no mock data)
    //   prod  → lib/main.dart        (production, clean build)
    // Run examples:
    //   fvm flutter run --flavor dev   -t lib/main_dev.dart
    //   fvm flutter run --flavor stage -t lib/main_stage.dart
    //   fvm flutter run --flavor prod  -t lib/main.dart
    //   fvm flutter build apk --flavor prod -t lib/main.dart
    // ─────────────────────────────────────────────────────────────────────────
    flavorDimensions += "environment"

    productFlavors {
        // Development flavor — installs alongside stage/prod with a unique bundle ID
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            // Override app display name on the device home screen
            resValue("string", "app_name", "Personal Expense (Dev)")
        }
        // Staging / QA flavor — pre-production API endpoint
        create("stage") {
            dimension = "environment"
            applicationIdSuffix = ".stage"
            versionNameSuffix = "-stage"
            resValue("string", "app_name", "Personal Expense (Stage)")
        }
        // Production flavor — clean App Store / Play Store build
        create("prod") {
            dimension = "environment"
            // No suffix — base production bundle ID is used as-is
            resValue("string", "app_name", "Personal Expense")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

