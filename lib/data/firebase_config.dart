import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for the gametibe2025 project
/// 
/// To get these values:
/// 1. Go to Firebase Console → gametibe2025 project
/// 2. Project Settings → General
/// 3. Scroll to "Your apps" section
/// 4. Select your Android app (or create one)
/// 5. Copy the values from google-services.json or the Firebase config
class Gametibe2025FirebaseConfig {
  // Database URL
  static const String databaseUrl = 'https://gametibe2025-default-rtdb.firebaseio.com';
  
  // Secondary Firebase app name
  static const String appName = 'gametibe2025';
  
  // Firebase Options for gametibe2025 project
  // Values extracted from google-services.json for com.example.gamebridge app
  static FirebaseOptions? get options {
    return const FirebaseOptions(
      apiKey: 'AIzaSyA0H0yvh8ikGTeMqyszD-xSntJZ8d3WYaI',
      appId: '1:587355158666:android:839d3957a89f7635721573',
      messagingSenderId: '587355158666',
      projectId: 'gametibe2025',
      storageBucket: 'gametibe2025.firebasestorage.app',
      databaseURL: databaseUrl,
    );
  }
  
  /// Initialize the secondary Firebase app for gametibe2025
  /// Returns true if initialization was successful
  static Future<bool> initializeSecondaryApp() async {
    try {
      // Check if app already exists
      try {
        Firebase.app(appName);
        print('✅ Secondary Firebase app "$appName" already initialized');
        return true;
      } catch (e) {
        // App doesn't exist, proceed with initialization
      }
      
      // Try to initialize with full FirebaseOptions if available
      final opts = options;
      if (opts != null) {
        await Firebase.initializeApp(
          name: appName,
          options: opts,
        );
        print('✅ Successfully initialized secondary Firebase app: $appName');
        print('   Database URL: $databaseUrl');
        return true;
      } else {
        print('ℹ️ FirebaseOptions not configured - will use fallback method');
        print('   Database will use explicit URL: $databaseUrl');
        print('   To configure full options, update firebase_config.dart with values from');
        print('   Firebase Console → gametibe2025 → Project Settings → Your apps');
        return false; // Will use fallback in FirebaseService
      }
    } catch (e) {
      print('⚠️ Warning: Could not initialize secondary Firebase app: $e');
      print('   Will use fallback method with explicit database URL');
      return false;
    }
  }
  
  /// Check if the secondary Firebase app is initialized
  static bool get isAppInitialized {
    try {
      Firebase.app(appName);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get the secondary Firebase app instance
  /// Returns null if the app is not initialized
  static FirebaseApp? getAppOrNull() {
    try {
      return Firebase.app(appName);
    } catch (e) {
      return null;
    }
  }
  
  /// Get the secondary Firebase app instance
  /// Throws exception if app is not initialized
  static FirebaseApp getApp() {
    try {
      return Firebase.app(appName);
    } catch (e) {
      throw Exception(
        'Secondary Firebase app "$appName" not initialized. '
        'Call Gametibe2025FirebaseConfig.initializeSecondaryApp() first.'
      );
    }
  }
}

