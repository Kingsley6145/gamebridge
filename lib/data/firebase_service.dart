import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';

class FirebaseService {
  // Use the default Firebase Database instance from google-services.json
  // This ensures authentication credentials match the initialized Firebase app
  late final FirebaseDatabase _database;
  late final DatabaseReference _databaseRef;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the database URL (for logging/debugging)
  String get databaseURL => _database.databaseURL ?? 'unknown';
  
  FirebaseService() {
    try {
      // Use the default Firebase Database instance
      // This matches the project configured in google-services.json (gamebridge-ec7cd)
      _database = FirebaseDatabase.instance;
      _databaseRef = _database.ref();
      print('Firebase Database initialized with URL: ${_database.databaseURL}');
    } catch (e) {
      print('Error initializing Firebase Database: $e');
      rethrow;
    }
  }
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Fetch all courses from Firebase Realtime Database
  Future<List<Course>> fetchCourses() async {
    try {
      print('Attempting to fetch courses from: ${_database.databaseURL}/Gamebridge_courses');
      
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
      
      print('Snapshot received. Exists: ${snapshot.exists}');
      
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Found ${data.length} course entries in database');
        final List<Course> courses = [];
        
        data.forEach((key, value) {
          try {
            final courseData = value as Map<dynamic, dynamic>;
            final course = Course.fromJson(Map<String, dynamic>.from(courseData));
            courses.add(course);
            print('Successfully parsed course: ${course.title}');
            print('  - coverImagePath: ${course.coverImagePath ?? "null"}');
            print('  - Firebase coverImage: ${courseData['coverImage'] ?? "null"}');
            print('  - Firebase coverImagePath: ${courseData['coverImagePath'] ?? "null"}');
            print('  - Firebase imageUrl: ${courseData['imageUrl'] ?? "null"}');
            // Debug modules and their video URLs
            if (course.modules.isNotEmpty) {
              print('  - Modules count: ${course.modules.length}');
              course.modules.forEach((module) {
                print('    Module "${module.title}": videoUrl = ${module.videoUrl.isEmpty ? "EMPTY" : module.videoUrl}');
              });
            }
          } catch (e) {
            print('Error parsing course $key: $e');
            print('Course data: $value');
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
      print('Error fetching courses from Firebase: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      print('Database URL: ${_database.databaseURL}');
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

