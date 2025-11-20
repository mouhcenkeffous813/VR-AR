# Android Release Build Guide

## Quick Release Build (Debug Signing - For Testing)

If you just want to test the release build quickly:

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## Production Release Build (Signed - For Google Play Store)

### Step 1: Generate a Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be prompted to enter:
- Password (remember this!)
- Your name, organization, etc.

### Step 2: Create key.properties file

Create a file `android/key.properties`:

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-your-keystore>/upload-keystore.jks
```

**IMPORTANT:** Add `android/key.properties` to `.gitignore` to keep your passwords safe!

### Step 3: Update build.gradle.kts

Update `android/app/build.gradle.kts` to use the keystore:

```kotlin
// Add at the top of the file
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing code ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### Step 4: Build Release

For APK:
```bash
flutter build apk --release
```

For AAB (Google Play Store):
```bash
flutter build appbundle --release
```

## Output Locations

- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`

## Additional Notes

- Update `applicationId` in `android/app/build.gradle.kts` to your unique package name
- Update app label in `android/app/src/main/AndroidManifest.xml`
- Update version code and version name in `pubspec.yaml`





