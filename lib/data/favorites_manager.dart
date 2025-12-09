import '../models/course.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final List<String> _favoriteCourseIds = [];

  List<String> get favoriteIds => List.unmodifiable(_favoriteCourseIds);

  bool isFavorite(String courseId) {
    return _favoriteCourseIds.contains(courseId);
  }

  void addFavorite(String courseId) {
    if (!_favoriteCourseIds.contains(courseId)) {
      _favoriteCourseIds.add(courseId);
    }
  }

  void removeFavorite(String courseId) {
    _favoriteCourseIds.remove(courseId);
  }

  void toggleFavorite(String courseId) {
    if (_favoriteCourseIds.contains(courseId)) {
      removeFavorite(courseId);
    } else {
      addFavorite(courseId);
    }
  }

  List<Course> getFavoriteCourses(List<Course> allCourses) {
    return allCourses.where((course) => _favoriteCourseIds.contains(course.id)).toList();
  }
}

