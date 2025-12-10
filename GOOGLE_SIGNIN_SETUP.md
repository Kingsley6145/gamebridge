# Google Sign-In Setup Guide

## Issue: Google Sign-In Not Working

The error "An unexpected error occurred" is happening because Google Sign-In is not properly configured in Firebase Console.

## Step 1: Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **gamebridge-ec7cd**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Toggle **Enable** to ON
6. Enter a **Project support email** (your email)
7. Click **Save**

## Step 2: Get Your SHA-1 Fingerprint

You need to add your app's SHA-1 fingerprint to Firebase for Google Sign-In to work.

### For Debug Build (Development):

Run this command in PowerShell:

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Or in Command Prompt:

```cmd
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Look for the line that says **SHA1:** and copy that value (it looks like: `AA:BB:CC:DD:EE:FF:...`)

### For Release Build (Production):

If you have a release keystore, use:

```powershell
keytool -list -v -keystore "path\to\your\release.keystore" -alias your-key-alias
```

## Step 3: Add SHA-1 to Firebase

1. In Firebase Console, go to **Project Settings** (⚙️ gear icon)
2. Scroll down to **Your apps** section
3. Click on your Android app
4. Click **Add fingerprint**
5. Paste your SHA-1 fingerprint
6. Click **Save**

## Step 4: Download Updated google-services.json

1. Still in **Project Settings**
2. Scroll to **Your apps** section
3. Click the **Download google-services.json** button
4. Replace the existing file at `android/app/google-services.json`

## Step 5: Verify Configuration

After downloading the new `google-services.json`, check that it contains OAuth client IDs:

```json
"oauth_client": [
  {
    "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

If `oauth_client` is still empty, make sure:
- Google Sign-In is enabled in Authentication → Sign-in method
- SHA-1 fingerprint is added to your Android app
- You've downloaded a fresh `google-services.json` after adding the SHA-1

## Step 6: Rebuild Your App

After updating `google-services.json`:

```bash
flutter clean
flutter pub get
flutter run
```

## Troubleshooting

### If Google Sign-In still doesn't work:

1. **Check Firebase Console**: Make sure Google Sign-In is enabled
2. **Verify SHA-1**: Make sure you added the correct SHA-1 fingerprint
3. **Check google-services.json**: Make sure `oauth_client` array is not empty
4. **Check Logs**: Look at the console output for more detailed error messages
5. **Wait a few minutes**: Sometimes Firebase takes a few minutes to propagate changes

### Common Errors:

- **"sign_in_failed"**: SHA-1 fingerprint not added or wrong fingerprint
- **"oauth_client is empty"**: Google Sign-In not enabled or wrong google-services.json
- **"PlatformException"**: Configuration issue, check Firebase setup

## Alternative: Use Web Client ID (Advanced)

If you continue having issues, you can manually configure Google Sign-In with a Web Client ID:

1. In Firebase Console → Authentication → Sign-in method → Google
2. Copy the **Web client ID** (ends with `.apps.googleusercontent.com`)
3. Update `lib/data/auth_service.dart`:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
);
```

But the recommended approach is to properly configure it via SHA-1 fingerprint as described above.

