import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';
import 'firebase_config.dart';

class FirebaseService {
  // Use the secondary Firebase app (gametibe2025) for database operations
  // Authentication still uses the default app (gamebridge-ec7cd)
  late final FirebaseDatabase _database;
  late final DatabaseReference _databaseRef;
  
  // Use default Firebase Auth (from gamebridge-ec7cd project)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the database URL (for logging/debugging)
  String get databaseURL => _database.databaseURL ?? 'unknown';
  
  FirebaseService() {
    // Check if secondary app is initialized, otherwise use fallback
    final gametibeApp = Gametibe2025FirebaseConfig.getAppOrNull();
    
    if (gametibeApp != null) {
      // Use the secondary Firebase app for gametibe2025 database
      _database = FirebaseDatabase.instanceFor(app: gametibeApp);
      _databaseRef = _database.ref();
      
      print('✅ Firebase Database initialized with secondary app');
      print('   App: ${gametibeApp.name}');
      print('   Database URL: ${_database.databaseURL}');
      print('   Auth App: ${_auth.app.name} (default)');
    } else {
      // Fallback: Use default app with explicit database URL
      const databaseUrl = Gametibe2025FirebaseConfig.databaseUrl;
      _database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );
      _databaseRef = _database.ref();
      
      print('✅ Firebase Database initialized (fallback method)');
      print('   Using default app with explicit database URL');
      print('   Database URL: ${_database.databaseURL}');
      print('   Auth App: ${_auth.app.name} (default)');
    }
  }
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Fetch all courses from Firebase Realtime Database
  Future<List<Course>> fetchCourses() async {
    try {
      print('═══════════════════════════════════════════════════════');
      print('🔍 FETCHING COURSES - DEBUG INFO');
      print('═══════════════════════════════════════════════════════');
      print('Database URL: ${_database.databaseURL}');
      print('Full path: ${_database.databaseURL}/Gamebridge_courses');
      print('User authenticated: ${_auth.currentUser != null}');
      if (_auth.currentUser != null) {
        print('User ID: ${_auth.currentUser!.uid}');
        print('User email: ${_auth.currentUser!.email ?? "N/A"}');
      }
      print('Attempting to fetch courses from: ${_database.databaseURL}/Gamebridge_courses');
      print('═══════════════════════════════════════════════════════');
      
      // Try to access root first to test permissions
      try {
        final rootSnapshot = await _databaseRef.get();
        print('✅ Root access test: ${rootSnapshot.exists ? "SUCCESS" : "FAILED"}');
        if (rootSnapshot.exists && rootSnapshot.value != null) {
          final rootData = rootSnapshot.value as Map<dynamic, dynamic>?;
          if (rootData != null) {
            print('📋 Root data keys: ${rootData.keys.toList()}');
            if (rootData.containsKey('Gamebridge_courses')) {
              print('✅ Gamebridge_courses EXISTS in root data!');
              print('   Data type: ${rootData['Gamebridge_courses'].runtimeType}');
            } else {
              print('❌ Gamebridge_courses NOT FOUND in root data');
            }
          }
        }
      } catch (e) {
        print('❌ Root access test failed: $e');
      }
      
      // Try accessing with a different reference path
      try {
        print('🔄 Trying direct child reference...');
        final directRef = _database.ref('Gamebridge_courses');
        final directSnapshot = await directRef.get();
        print('✅ Direct ref result: exists=${directSnapshot.exists}');
        if (directSnapshot.exists) {
          print('✅ SUCCESS with direct reference!');
          print('   Value type: ${directSnapshot.value?.runtimeType}');
        }
      } catch (e) {
        print('❌ Direct ref failed: $e');
      }
      
      // Add timeout to prevent hanging
      final snapshot = await _databaseRef
          .child('Gamebridge_courses')
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('Firebase fetch timeout after 15 seconds');
              print('Database URL: ${_database.databaseURL}');
              print('Path: Gamebridge_courses');
              throw TimeoutException('Firebase connection timeout');
            },
          );
      
      print('═══════════════════════════════════════════════════════');
      print('📊 SNAPSHOT RESULTS');
      print('═══════════════════════════════════════════════════════');
      print('Snapshot exists: ${snapshot.exists}');
      print('Snapshot hasValue: ${snapshot.value != null}');
      print('Snapshot value type: ${snapshot.value?.runtimeType ?? "null"}');
      
      // If snapshot doesn't exist, it might be a permissions issue
      if (!snapshot.exists) {
        print('');
        print('❌ ERROR: Snapshot.exists is FALSE');
        print('═══════════════════════════════════════════════════════');
        print('This means Firebase is DENYING access to /Gamebridge_courses');
        print('');
        print('Possible causes:');
        print('1. ⚠️ Database rules are blocking read access');
        print('2. ⚠️ Rules evaluation order issue');
        print('3. ⚠️ Rules not published/synced yet');
        print('4. ⚠️ Wrong Firebase project/database');
        print('');
        print('Current status:');
        print('  - User authenticated: ${_auth.currentUser != null}');
        if (_auth.currentUser != null) {
          print('  - User ID: ${_auth.currentUser!.uid}');
          print('  - User email: ${_auth.currentUser!.email ?? "N/A"}');
        }
        print('  - Database URL: ${_database.databaseURL}');
        print('');
        print('🔧 SOLUTION:');
        print('1. Go to Firebase Console: https://console.firebase.google.com/');
        print('2. Select project: gametibe2025');
        print('3. Go to Realtime Database → Rules tab');
        print('4. Make sure Gamebridge_courses rule is at the TOP:');
        print('   {');
        print('     "rules": {');
        print('       "Gamebridge_courses": {');
        print('         ".read": true,');
        print('         ".write": false');
        print('       },');
        print('       ".read": "auth != null",');
        print('       ".write": "auth != null"');
        print('     }');
        print('   }');
        print('5. Click PUBLISH');
        print('6. Wait 30 seconds for rules to propagate');
        print('7. Restart app');
        print('═══════════════════════════════════════════════════════');
      }
      
      // If direct access fails, try reading from root data
      Map<dynamic, dynamic>? data;
      if (snapshot.exists && snapshot.value != null) {
        data = snapshot.value as Map<dynamic, dynamic>;
        print('✅ Direct access successful - Found ${data.length} course entries');
      } else {
        print('⚠️ Direct access failed, trying to read from root data...');
        try {
          final rootSnapshot = await _databaseRef.get();
          if (rootSnapshot.exists && rootSnapshot.value != null) {
            final rootData = rootSnapshot.value as Map<dynamic, dynamic>;
            if (rootData.containsKey('Gamebridge_courses')) {
              print('✅ Found Gamebridge_courses in root data!');
              final coursesData = rootData['Gamebridge_courses'];
              if (coursesData is Map) {
                data = coursesData as Map<dynamic, dynamic>;
                print('✅ Successfully extracted courses from root: ${data.length} entries');
              } else {
                print('❌ Gamebridge_courses data is not a Map, type: ${coursesData.runtimeType}');
              }
            } else {
              print('❌ Gamebridge_courses not found in root data');
              print('   Available keys: ${rootData.keys.toList()}');
            }
          }
        } catch (e) {
          print('❌ Failed to read from root: $e');
        }
      }
      
      if (data != null) {
        print('Found ${data.length} course entries in database');
        final List<Course> courses = [];
        
        data.forEach((key, value) {
          try {
            final courseData = value as Map<dynamic, dynamic>;
            print('Parsing course with key: $key');
            print('Course data keys: ${courseData.keys.toList()}');
            
            // Check for required fields
            if (!courseData.containsKey('id') || courseData['id'] == null) {
              print('WARNING: Course $key is missing required field "id"');
            }
            if (!courseData.containsKey('title') || courseData['title'] == null) {
              print('WARNING: Course $key is missing required field "title"');
            }
            if (!courseData.containsKey('modules') || courseData['modules'] == null) {
              print('WARNING: Course $key is missing required field "modules"');
            }
            
            final course = Course.fromJson(Map<String, dynamic>.from(courseData));
            courses.add(course);
            print('✓ Successfully parsed course: ${course.title} (ID: ${course.id})');
            print('  - coverImagePath: ${course.coverImagePath ?? "null"}');
            print('  - Firebase coverImage: ${courseData['coverImage'] ?? "null"}');
            print('  - Firebase coverImagePath: ${courseData['coverImagePath'] ?? "null"}');
            print('  - Firebase imageUrl: ${courseData['imageUrl'] ?? "null"}');
            print('  - Modules count: ${course.modules.length}');
            // Debug modules and their video URLs
            if (course.modules.isNotEmpty) {
              course.modules.forEach((module) {
                print('    Module "${module.title}": videoUrl = ${module.videoUrl.isEmpty ? "EMPTY" : module.videoUrl}');
              });
            } else {
              print('  - WARNING: Course has no modules');
            }
          } catch (e, stackTrace) {
            print('✗ ERROR parsing course $key: $e');
            print('Stack trace: $stackTrace');
            print('Course data: $value');
            print('Course data type: ${value.runtimeType}');
            if (value is Map) {
              print('Course data keys: ${value.keys}');
            }
          }
        });
        
        print('Successfully fetched ${courses.length} courses from Firebase');
        return courses;
      } else {
        print('No courses found in Firebase at /Gamebridge_courses');
        print('Snapshot exists: ${snapshot.exists}');
        print('Snapshot value: ${snapshot.value}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching courses from Firebase: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      print('Database URL: ${_database.databaseURL}');
      
      // Check for authentication credential errors
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('authentication credentials') || 
          errorString.contains('invalid') ||
          errorString.contains('api_key') ||
          errorString.contains('firebase_url')) {
        print('');
        print('🔐 AUTHENTICATION CREDENTIALS ERROR DETECTED!');
        print('═══════════════════════════════════════════════════════');
        print('The issue: You are using credentials from "gamebridge-ec7cd"');
        print('to connect to "gametibe2025" database.');
        print('');
        print('SOLUTION: Configure the secondary Firebase app properly:');
        print('');
        print('1. Go to Firebase Console: https://console.firebase.google.com/');
        print('2. Select project: gametibe2025');
        print('3. Go to Project Settings → General');
        print('4. Scroll to "Your apps" section');
        print('5. If you don\'t have an Android app:');
        print('   - Click "Add app" → Select Android');
        print('   - Package name: com.example.gamebridge');
        print('   - Click "Register app"');
        print('6. Download the google-services.json file');
        print('7. Open the downloaded file and copy these values:');
        print('   - apiKey: from "api_key" → "current_key"');
        print('   - appId: from "mobilesdk_app_id"');
        print('   - messagingSenderId: from "project_number"');
        print('   - projectId: "gametibe2025"');
        print('   - storageBucket: from "storage_bucket"');
        print('8. Update lib/data/firebase_config.dart with these values');
        print('9. Restart the app');
        print('═══════════════════════════════════════════════════════');
      } else if (errorString.contains('permission') || 
          errorString.contains('rules') || 
          errorString.contains('unauthorized') ||
          errorString.contains('denied')) {
        print('');
        print('🔒 PERMISSION ERROR DETECTED!');
        print('   Your database rules are blocking read access.');
        print('   SOLUTION: Update your Firebase Realtime Database rules:');
        print('   1. Go to https://console.firebase.google.com/');
        print('   2. Select project: gametibe2025');
        print('   3. Go to Realtime Database → Rules tab');
        print('   4. Make sure Gamebridge_courses has:');
        print('      "Gamebridge_courses": { ".read": true }');
        print('   5. Click "Publish"');
      }
      
      print('');
      print('Make sure Firebase Realtime Database is enabled and accessible');
      print('Check database rules allow reading Gamebridge_courses');
      return [];
    }
  }

  // Stream courses for real-time updates
  Stream<List<Course>> streamCourses() {
    return _databaseRef.child('Gamebridge_courses').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final List<Course> courses = [];
        
        data.forEach((key, value) {
          try {
            final courseData = value as Map<dynamic, dynamic>;
            final course = Course.fromJson(Map<String, dynamic>.from(courseData));
            courses.add(course);
          } catch (e) {
            print('Error parsing course $key: $e');
          }
        });
        
        return courses;
      } else {
        return <Course>[];
      }
    });
  }

  // Add a course to user's favorites
  Future<void> addToFavorites(String courseId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User must be authenticated to add favorites');
    }
    
    try {
      await _databaseRef
          .child('user_favorites')
          .child(userId)
          .child(courseId)
          .set({
        'courseId': courseId,
        'addedAt': ServerValue.timestamp,
      });
      print('Added course $courseId to favorites for user $userId');
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove a course from user's favorites
  Future<void> removeFromFavorites(String courseId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User must be authenticated to remove favorites');
    }
    
    try {
      await _databaseRef
          .child('user_favorites')
          .child(userId)
          .child(courseId)
          .remove();
      print('Removed course $courseId from favorites for user $userId');
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Fetch all favorite course IDs for current user
  Future<List<String>> fetchFavoriteIds() async {
    final userId = currentUserId;
    if (userId == null) {
      return [];
    }
    
    try {
      final snapshot = await _databaseRef
          .child('user_favorites')
          .child(userId)
          .get();
      
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final favoriteIds = data.keys.map((key) => key.toString()).toList();
        print('Fetched ${favoriteIds.length} favorites for user $userId');
        return favoriteIds;
      } else {
        print('No favorites found for user $userId');
        return [];
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  // Stream favorite course IDs for real-time updates
  Stream<List<String>> streamFavoriteIds() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _databaseRef
        .child('user_favorites')
        .child(userId)
        .onValue
        .map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return data.keys.map((key) => key.toString()).toList();
      } else {
        return <String>[];
      }
    });
  }

  // Check if a course is in favorites
  Future<bool> isFavorite(String courseId) async {
    final userId = currentUserId;
    if (userId == null) {
      return false;
    }
    
    try {
      final snapshot = await _databaseRef
          .child('user_favorites')
          .child(userId)
          .child(courseId)
          .get();
      return snapshot.exists;
    } catch (e) {
      print('Error checking if favorite: $e');
      return false;
    }
  }
}

