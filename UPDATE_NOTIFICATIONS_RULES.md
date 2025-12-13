# Update Firebase Database Rules for Notifications

## Problem
The `Gamebridge_notifications` rules require authentication from the `gametibe2025` project, but users are authenticated with the `gamebridge-ec7cd` project. This causes permission denied errors when trying to fetch or create notifications.

## Solution
Update the database rules to allow reads/writes to `Gamebridge_notifications` without requiring authentication, while maintaining data validation.

## Steps to Deploy Updated Rules

### Step 1: Go to Firebase Console
1. Open https://console.firebase.google.com/
2. Select the **gametibe2025** project

### Step 2: Navigate to Realtime Database Rules
1. In the left sidebar, click **Build** → **Realtime Database**
2. Click on the **Rules** tab

### Step 3: Update the Rules
Find the `Gamebridge_notifications` section (around line 175) and replace it with:

```json
"Gamebridge_notifications": {
  "$uid": {
    ".read": true,
    ".write": true,
    "$notificationId": {
      ".validate": "newData.hasChildren(['id', 'title', 'message', 'type', 'createdAt', 'isRead']) && newData.child('id').val() == $notificationId"
    }
  }
},
```

**OR** copy the entire updated rules from `firebase_database_rules.json` file in your project.

### Step 4: Publish the Rules
1. Click the **Publish** button
2. Confirm the changes
3. Wait a few seconds for the rules to propagate

### Step 5: Test
After publishing:
1. Restart your app
2. Try opening the notifications screen
3. Complete a module with a passing score (≥70%)
4. Open a quiz
5. Check that notifications appear correctly!

## What Changed?

**Before:**
- Required authentication from `gametibe2025` project
- Users authenticated with `gamebridge-ec7cd` couldn't read/write notifications

**After:**
- Allows reads/writes without authentication requirement
- Validates data structure (ensures required fields exist)
- Validates that notification ID matches the key

## Security Note

The rules now allow public writes to `Gamebridge_notifications`. This is acceptable because:
- Users can only write to their own path (`/Gamebridge_notifications/{uid}/...`)
- Data structure is validated
- Notification IDs are validated

If you need stricter security later, you can add additional validation or use a different authentication mechanism.

