# Firebase Android Configuration Guide

## Step 1: Check Current Status

### ❌ Current Status: Firebase is NOT configured

**Missing:**
- `google-services.json` file
- Google Services plugin in build.gradle files

## Step 2: Download google-services.json

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **gamebridge-ec7cd** (or gametibe2025 if that's your project)
3. Click the **⚙️ Settings** icon (gear) → **Project settings**
4. Scroll down to **Your apps** section
5. If you don't have an Android app yet:
   - Click **Add app** → Select **Android** icon
   - **Android package name**: `com.example.gamebridge` (from your build.gradle.kts)
   - **App nickname** (optional): Gamebridge Android
   - Click **Register app**
6. Download the `google-services.json` file
7. Place it in: `android/app/google-services.json`

**Important:** The file MUST be at `android/app/google-services.json` (not in android/ root)

## Step 3: Verify File Location

After downloading, verify the file exists:
```
android/
  app/
    google-services.json  ← Should be here
    build.gradle.kts
    src/
```

## Step 4: Update Build Files

The build files have been updated to include:
- Google Services plugin in project-level `build.gradle.kts`
- Google Services plugin in app-level `build.gradle.kts`
- Google Services dependency

## Step 5: Verify Configuration

Run these commands to verify:

```bash
# Navigate to project root
cd C:\Users\admin\Desktop\projects\Gamebridge

# Get Flutter dependencies
flutter pub get

# Clean build
flutter clean

# Try building (this will verify Firebase setup)
flutter build apk --debug
```

## Step 6: Check for Errors

If you see errors like:
- "File google-services.json is missing"
- "Failed to apply plugin 'com.google.gms.google-services'"

**Solution:** Make sure `google-services.json` is in `android/app/` directory

## Step 7: Verify Firebase Connection

After setup, run the app and check the console logs. You should see:
- No Firebase initialization errors
- Courses loading from Firebase (if data exists)

## Troubleshooting

### Error: "google-services.json file not found"
- Ensure file is at `android/app/google-services.json`
- Check file name spelling (case-sensitive)
- Restart Android Studio/IDE

### Error: "Plugin with id 'com.google.gms.google-services' not found"
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the project

### Error: "Default FirebaseApp is not initialized"
- Check that `google-services.json` matches your package name
- Verify Firebase project has Realtime Database enabled
- Check Firebase Console → Project Settings → Your apps

## Quick Verification Checklist

- [ ] `google-services.json` exists at `android/app/google-services.json`
- [ ] Google Services plugin added to `android/build.gradle.kts`
- [ ] Google Services plugin applied in `android/app/build.gradle.kts`
- [ ] Package name in `google-services.json` matches `com.example.gamebridge`
- [ ] Firebase Realtime Database is enabled in Firebase Console
- [ ] App builds without errors (`flutter build apk --debug`)

## Need Help?

If you're still having issues:
1. Check Firebase Console → Project Settings → Your apps
2. Verify the Android package name matches exactly
3. Make sure Realtime Database is enabled
4. Check that your Firebase project has the correct permissions

