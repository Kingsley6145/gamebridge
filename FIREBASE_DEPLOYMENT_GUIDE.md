# Firebase Hosting Deployment Guide for Gamebridge

This guide will walk you through deploying your Flutter app to Firebase Hosting step by step.

## Prerequisites

1. **Firebase Account**: You already have a Firebase project (`gamebridge-ec7cd`)
2. **Node.js and npm**: Required for Firebase CLI
3. **Flutter SDK**: Already installed

## Step 1: Enable PowerShell Script Execution (Windows)

Since PowerShell script execution is disabled, you need to enable it first:

1. Open PowerShell as Administrator
2. Run this command:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Type `Y` when prompted

Alternatively, you can use Command Prompt (cmd) instead of PowerShell for Firebase commands.

## Step 2: Login to Firebase

Open a terminal in your project directory and run:

```bash
firebase login
```

This will open a browser window for you to authenticate with your Google account.

## Step 3: Verify Firebase Project

Verify that you're using the correct Firebase project:

```bash
firebase use gamebridge-ec7cd
```

Or set it as default:
```bash
firebase use --add
```
Then select `gamebridge-ec7cd` from the list.

## Step 4: Initialize Firebase Hosting (if not already done)

If Firebase Hosting isn't initialized yet, run:

```bash
firebase init hosting
```

When prompted:
- **What do you want to use as your public directory?** → `build/web`
- **Configure as a single-page app?** → `Yes`
- **Set up automatic builds and deploys with GitHub?** → `No` (you can set this up later)
- **File build/web/index.html already exists. Overwrite?** → `No`

**Note**: The `firebase.json` file has already been created for you with the correct configuration.

## Step 5: Build Your Flutter Web App

Build your Flutter app for web:

```bash
flutter build web
```

This will create optimized web files in the `build/web` directory.

**Important**: Make sure your app works correctly in web mode. Test it locally first:

```bash
flutter run -d chrome
```

## Step 6: Deploy to Firebase Hosting

Once the build is complete, deploy to Firebase:

```bash
firebase deploy --only hosting
```

This will:
1. Upload your `build/web` files to Firebase Hosting
2. Provide you with a hosting URL (usually `https://gamebridge-ec7cd.web.app`)

## Step 7: Verify Deployment

After deployment, Firebase will provide you with:
- **Hosting URL**: `https://gamebridge-ec7cd.web.app`
- **Custom Domain**: You can set up a custom domain later in Firebase Console

Visit the URL to verify your app is live!

## Troubleshooting

### If Firebase CLI commands don't work in PowerShell:

1. Use Command Prompt (cmd) instead of PowerShell
2. Or enable script execution as shown in Step 1

### If build fails:

1. Make sure all dependencies are installed: `flutter pub get`
2. Check for web-specific issues in your code
3. Ensure all assets are properly referenced

### If deployment fails:

1. Verify you're logged in: `firebase login`
2. Check your project: `firebase projects:list`
3. Ensure `build/web` directory exists after running `flutter build web`

## Next Steps

1. **Set up Custom Domain**: Go to Firebase Console → Hosting → Add custom domain
2. **Enable HTTPS**: Firebase Hosting automatically provides SSL certificates
3. **Set up CI/CD**: Configure automatic deployments from GitHub (optional)
4. **Configure Caching**: The `firebase.json` already includes cache headers for optimal performance

## Useful Commands

- `firebase deploy --only hosting` - Deploy only hosting
- `firebase deploy` - Deploy everything (hosting, functions, etc.)
- `firebase hosting:channel:deploy preview` - Deploy to a preview channel
- `firebase open hosting:site` - Open your site in browser

## Additional Resources

- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

