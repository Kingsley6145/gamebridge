# Firebase Realtime Database Setup Guide

## Problem: App Hanging on Startup

Your app was hanging because Firebase Realtime Database wasn't properly configured. The error message was:
```
Firebase Database connection was forcefully killed by the server. 
Will not attempt reconnect. Reason: Firebase error. 
Please ensure that you have the URL of your Firebase Realtime Database instance configured correctly.
```

## Solution Steps

### Step 1: Enable Firebase Realtime Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **gamebridge-ec7cd**
3. In the left sidebar, click **Build** → **Realtime Database**
4. Click **Create Database**
5. Choose your location (select closest to your users)
6. Choose **Start in test mode** (for now - you can secure it later)
7. Click **Enable**

### Step 2: Get Your Database URL

After creating the database:
1. You'll see your database URL at the top of the page
2. It should look like: `https://gamebridge-ec7cd-default-rtdb.firebaseio.com/`
3. Copy this URL

### Step 3: Configure Database Rules (Important!)

1. Go to **Realtime Database** → **Rules** tab
2. For testing, use these rules:
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```
3. Click **Publish**

**⚠️ Warning:** These rules allow anyone to read/write. For production, you'll need to secure them.

### Step 4: Add Data Structure

Your database should have this structure:
```
Gamebridge_courses/
  course1/
    id: "1"
    title: "Course Title"
    description: "Course Description"
    category: "UI/UX"
    duration: "2h 46min"
    rating: 4.8
    students: 680
    isTrendy: true
    isPremium: true
    imageColor: "purple"
    modules: [...]
    questions: [...]
  course2/
    ...
```

### Step 5: Verify Database URL

The app is now configured to use the default Firebase instance. If you need to specify a custom URL:

1. Open `lib/data/firebase_service.dart`
2. If your database URL is different, update it there
3. The default should work if your Firebase project is properly configured

## Testing

After setting up:

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Check the console logs:**
   - You should see: "Successfully fetched X courses from Firebase"
   - If you see errors, check the database URL and rules

3. **Verify data:**
   - Make sure `/Gamebridge_courses` exists in your database
   - Add some test data if needed

## Common Issues

### Issue: "Database connection was forcefully killed"
**Solution:** 
- Make sure Realtime Database is enabled
- Check database rules allow read access
- Verify you're using the correct Firebase project

### Issue: "No courses found"
**Solution:**
- Check that `/Gamebridge_courses` path exists
- Verify data structure matches Course model
- Check database rules allow reading

### Issue: App still hanging
**Solution:**
- The app now loads asynchronously, so it shouldn't hang
- If it does, check Firebase initialization errors in logs
- Make sure `google-services.json` is correct

## Next Steps

1. ✅ Enable Realtime Database
2. ✅ Set database rules
3. ✅ Add course data at `/Gamebridge_courses`
4. ✅ Test the app
5. 🔒 Secure database rules for production

## Need Help?

If you're still having issues:
1. Check Firebase Console → Realtime Database → Data tab
2. Verify your database URL matches your project
3. Check the console logs for specific error messages
4. Make sure your admin panel is writing to `/Gamebridge_courses`

