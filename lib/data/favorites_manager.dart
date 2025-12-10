import 'dart:async';
import '../models/course.dart';
import 'firebase_service.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final List<String> _favoriteCourseIds = [];
  StreamSubscription<List<String>>? _favoritesSubscription;
  bool _initialized = false;
  
  // Stream controller for notifying listeners of favorite changes
  final _favoritesController = StreamController<List<String>>.broadcast();
  Stream<List<String>> get favoritesStream => _favoritesController.stream;

  List<String> get favoriteIds => List.unmodifiable(_favoriteCourseIds);
  
  bool get isInitialized => _initialized;

  // Initialize favorites from Firebase
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    
    try {
      // Load initial favorites
      final favorites = await _firebaseService.fetchFavoriteIds();
      _favoriteCourseIds.clear();
      _favoriteCourseIds.addAll(favorites);
      _favoritesController.add(List.unmodifiable(_favoriteCourseIds));
      
      // Listen to real-time changes
      if (_firebaseService.isAuthenticated) {
        _favoritesSubscription?.cancel();
        _favoritesSubscription = _firebaseService.streamFavoriteIds().listen(
          (favorites) {
            _favoriteCourseIds.clear();
            _favoriteCourseIds.addAll(favorites);
            _favoritesController.add(List.unmodifiable(_favoriteCourseIds));
          },
          onError: (error) {
            print('Error listening to favorites stream: $error');
          },
        );
      }
      
      _initialized = true;
      print('FavoritesManager initialized with ${_favoriteCourseIds.length} favorites');
    } catch (e) {
      print('Error initializing FavoritesManager: $e');
      _initialized = false;
    }
  }

  // Reload favorites from Firebase (useful after login/logout)
  Future<void> reload() async {
    _initialized = false;
    _favoritesSubscription?.cancel();
    await initialize();
  }

  bool isFavorite(String courseId) {
    return _favoriteCourseIds.contains(courseId);
  }

  Future<void> addFavorite(String courseId) async {
    if (!_firebaseService.isAuthenticated) {
      throw Exception('User must be authenticated to add favorites');
    }
    
    if (!_favoriteCourseIds.contains(courseId)) {
      try {
        await _firebaseService.addToFavorites(courseId);
        // The local list will be updated via the stream listener
        // But we can also update it optimistically
        if (!_favoriteCourseIds.contains(courseId)) {
          _favoriteCourseIds.add(courseId);
          _favoritesController.add(List.unmodifiable(_favoriteCourseIds));
        }
      } catch (e) {
        print('Error adding favorite: $e');
        rethrow;
      }
    }
  }

  Future<void> removeFavorite(String courseId) async {
    if (!_firebaseService.isAuthenticated) {
      throw Exception('User must be authenticated to remove favorites');
    }
    
    try {
      await _firebaseService.removeFromFavorites(courseId);
      // The local list will be updated via the stream listener
      // But we can also update it optimistically
      if (_favoriteCourseIds.contains(courseId)) {
        _favoriteCourseIds.remove(courseId);
        _favoritesController.add(List.unmodifiable(_favoriteCourseIds));
      }
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String courseId) async {
    if (isFavorite(courseId)) {
      await removeFavorite(courseId);
    } else {
      await addFavorite(courseId);
    }
  }

  List<Course> getFavoriteCourses(List<Course> allCourses) {
    return allCourses.where((course) => _favoriteCourseIds.contains(course.id)).toList();
  }
  
  void dispose() {
    _favoritesSubscription?.cancel();
    _favoritesController.close();
  }
}

