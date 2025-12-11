# Adding Android App to gametibe2025 Firebase Project

## Step-by-Step Guide

### Step 1: Go to Firebase Console
1. Open your browser and go to: https://console.firebase.google.com/
2. Make sure you're logged in with the correct Google account

### Step 2: Select the gametibe2025 Project
1. In the Firebase Console, you'll see a list of projects
2. Click on **gametibe2025** project
   - If you don't see it, make sure you have access to it
   - If it doesn't exist, you'll need to create it first

### Step 3: Add Android App
1. Once you're in the **gametibe2025** project:
2. Look for the **⚙️ Settings** icon (gear) in the top left, next to "Project Overview"
3. Click on it → Select **Project settings**
4. Scroll down to the **Your apps** section
5. You'll see cards for different platforms (iOS, Android, Web)
6. Click on the **Android** icon (or the **+ Add app** button if no apps exist)

### Step 4: Register the Android App
Fill in the registration form:

1. **Android package name**: 
   ```
   com.example.gamebridge
   ```
   (This must match exactly what's in your `android/app/build.gradle.kts`)

2. **App nickname** (optional):
   ```
   Gamebridge Android
   ```
   (This is just for your reference)

3. **Debug signing certificate SHA-1** (optional for now):
   - You can skip this for now
   - We can add it later if needed for Google Sign-In

4. Click **Register app**

### Step 5: Download google-services.json
1. After registering, Firebase will show you a download page
2. Click **Download google-services.json**
3. **IMPORTANT**: Do NOT replace your existing `android/app/google-services.json` file
   - Your current file is for `gamebridge-ec7cd` project
   - We need to keep both projects working
   - Just save this file somewhere temporarily (like Desktop)

### Step 6: Extract the Values
Open the downloaded `google-services.json` file and find these values:

```json
{
  "project_info": {
    "project_number": "123456789012",  // ← messagingSenderId
    "firebase_url": "https://gametibe2025-default-rtdb.firebaseio.com",
    "project_id": "gametibe2025",  // ← projectId
    "storage_bucket": "gametibe2025.appspot.com"  // ← storageBucket
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "1:123456789012:android:abcdef123456"  // ← appId
    },
    "api_key": [{
      "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"  // ← apiKey
    }]
  }]
}
```

### Step 7: Update firebase_config.dart
Open `lib/data/firebase_config.dart` and update the `options` getter with the values you found:

```dart
static FirebaseOptions? get options {
  return const FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',  // ← From api_key.current_key
    appId: '1:123456789012:android:abcdef123456',  // ← From mobilesdk_app_id
    messagingSenderId: '123456789012',  // ← From project_number
    projectId: 'gametibe2025',
    storageBucket: 'gametibe2025.appspot.com',  // ← From storage_bucket
    databaseURL: databaseUrl,
  );
}
```

### Step 8: Restart the App
1. Stop your app
2. Run `flutter clean` (optional but recommended)
3. Run `flutter pub get`
4. Restart the app

## Troubleshooting

### "I don't see the gametibe2025 project"
- Make sure you're logged in with the correct Google account
- Check if you have access to the project
- If the project doesn't exist, create it first:
  1. Click "Add project" in Firebase Console
  2. Name it "gametibe2025"
  3. Follow the setup wizard

### "Package name already exists"
- This means the Android app is already registered
- Go to Project Settings → Your apps → Android
- You can download the existing `google-services.json` or view the config

### "I can't find the values"
- Make sure you're looking at the correct `google-services.json` file
- The file structure should match the example above
- Double-check that you're in the **gametibe2025** project, not **gamebridge-ec7cd**

## Next Steps
After completing these steps, your app should be able to connect to the gametibe2025 database without authentication errors!

