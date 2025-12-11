# Setting Up gametibe2025 Firebase Project

## Problem
You're getting authentication errors because the app is trying to use credentials from `gamebridge-ec7cd` to connect to `gametibe2025` database.

## Solution: Get Firebase Credentials from gametibe2025 Project

### Step 1: Go to Firebase Console
1. Open https://console.firebase.google.com/
2. Select the **gametibe2025** project

### Step 2: Get Android App Configuration
1. Click **⚙️ Settings** (gear icon) → **Project settings**
2. Scroll down to **Your apps** section
3. If you don't have an Android app:
   - Click **Add app** → Select **Android** icon
   - **Android package name**: `com.example.gamebridge`
   - **App nickname** (optional): Gamebridge Android
   - Click **Register app**
4. Download the `google-services.json` file (or view it in the console)

### Step 3: Extract Required Values
Open the `google-services.json` file and find these values:

```json
{
  "project_info": {
    "project_number": "XXXXX",  // ← This is messagingSenderId
    "firebase_url": "https://gametibe2025-default-rtdb.firebaseio.com",
    "project_id": "gametibe2025",  // ← This is projectId
    "storage_bucket": "gametibe2025.appspot.com"  // ← This is storageBucket
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "1:XXXXX:android:XXXXX"  // ← This is appId
    },
    "api_key": [{
      "current_key": "AIzaSyXXXXXXXXXXXXXXXXXXXXX"  // ← This is apiKey
    }]
  }]
}
```

### Step 4: Update firebase_config.dart
Open `lib/data/firebase_config.dart` and update the `options` getter:

```dart
static FirebaseOptions? get options {
  // Replace these with actual values from gametibe2025 google-services.json
  return const FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXX',  // ← From api_key.current_key
    appId: '1:XXXXX:android:XXXXX',  // ← From mobilesdk_app_id
    messagingSenderId: 'XXXXX',  // ← From project_number
    projectId: 'gametibe2025',
    storageBucket: 'gametibe2025.appspot.com',  // ← From storage_bucket
    databaseURL: databaseUrl,
  );
}
```

### Step 5: Restart the App
After updating the configuration:
1. Stop the app
2. Run `flutter clean` (optional but recommended)
3. Run `flutter pub get`
4. Restart the app

## Verify It's Working
After restarting, you should see in the logs:
```
✅ Successfully initialized secondary Firebase app: gametibe2025
   Database URL: https://gametibe2025-default-rtdb.firebaseio.com
```

And courses should start fetching successfully!

## Alternative: Quick Test
If you want to test quickly, you can temporarily allow unauthenticated access in the database rules:

1. Go to Firebase Console → gametibe2025 → Realtime Database → Rules
2. Set rules to:
```json
{
  "rules": {
    "Gamebridge_courses": {
      ".read": true,
      ".write": false
    },
    ".read": true,
    ".write": false
  }
}
```
3. Click **Publish**

**⚠️ Warning:** This allows anyone to read your database. Only use for testing!

## Need Help?
If you're still having issues:
1. Check that the database URL is correct: `https://gametibe2025-default-rtdb.firebaseio.com`
2. Verify the API key is correct (no typos)
3. Make sure Realtime Database is enabled in the gametibe2025 project
4. Check the database rules allow reading `Gamebridge_courses`

