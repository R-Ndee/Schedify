plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.schedify"
    compileSdk = 36  // ✅ UBAH: Dari flutter.compileSdkVersion ke 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ TAMBAHKAN: Enable desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.schedify"
        minSdk = flutter.minSdkVersion  // ✅ UBAH: Dari flutter.minSdkVersion ke 21
        targetSdk = 36  // ✅ UBAH: Dari flutter.targetSdkVersion ke 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ✅ TAMBAHKAN: MultiDex support
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ TAMBAHKAN: Desugaring library
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
