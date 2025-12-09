import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/course.dart';

class FirebaseService {
  // Connect to the admin panel's Firebase project (gametibe2025)
  // Database URL for gametibe2025 project
  static const String _databaseURL = 'https://gametibe2025-default-rtdb.firebaseio.com/';
  
  late final DatabaseReference _databaseRef;
  
  FirebaseService() {
    try {
      // Create a Firebase Database instance pointing to gametibe2025 project
      final database = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: _databaseURL,
      );
      _databaseRef = database.ref();
      print('Firebase Database initialized with URL: $_databaseURL');
    } catch (e) {
      print('Error initializing Firebase Database: $e');
      // Fallback to default instance
      _databaseRef = FirebaseDatabase.instance.ref();
      print('Using default Firebase Database instance');
    }
  }

  // Fetch all courses from Firebase Realtime Database
  Future<List<Course>> fetchCourses() async {
    try {
      print('Attempting to fetch courses from: $_databaseURL/Gamebridge_courses');
      
      // Add timeout to prevent hanging
      final snapshot = await _databaseRef
          .child('Gamebridge_courses')
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print('Firebase fetch timeout after 15 seconds');
              print('Database URL: $_databaseURL');
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
      print('Database URL: $_databaseURL');
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
}

