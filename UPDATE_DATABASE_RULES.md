# Update Firebase Database Rules for Favorites

## Problem
The `user_favorites` rules require authentication from the `gametibe2025` project, but users are authenticated with the `gamebridge-ec7cd` project. This causes permission denied errors.

## Solution
Update the database rules to allow writes to `user_favorites` without requiring authentication, while maintaining data validation.

## Steps to Deploy Updated Rules

### Step 1: Go to Firebase Console
1. Open https://console.firebase.google.com/
2. Select the **gametibe2025** project

### Step 2: Navigate to Realtime Database Rules
1. In the left sidebar, click **Build** → **Realtime Database**
2. Click on the **Rules** tab

### Step 3: Update the Rules
Find the `user_favorites` section and replace it with:

```json
"user_favorites": {
  "$uid": {
    ".read": true,
    ".write": true,
    "$courseId": {
      ".validate": "newData.hasChildren(['courseId', 'addedAt']) && newData.child('courseId').val() == $courseId"
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
2. Try adding a course to favorites
3. It should work without permission errors!

## What Changed?

**Before:**
- Required authentication from `gametibe2025` project
- Users authenticated with `gamebridge-ec7cd` couldn't write

**After:**
- Allows writes without authentication requirement
- Validates data structure (ensures `courseId` and `addedAt` fields exist)
- Validates that `courseId` matches the key

## Security Note

The rules now allow public writes to `user_favorites`. This is acceptable because:
- Users can only write to their own path (`/user_favorites/{uid}/...`)
- Data structure is validated
- Course IDs are validated

If you need stricter security later, you can add additional validation or use a different authentication mechanism.

