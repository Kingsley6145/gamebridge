import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static const String _themePreferenceKey = 'is_dark_mode';
  bool _isDarkMode = false;
  bool _isInitialized = false;
  
  bool get isDarkMode => _isDarkMode;

  /// Initialize theme manager by loading saved preference
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
      _isDarkMode = false;
      _isInitialized = true;
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, isDark);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
        primaryColor: const Color(0xFFBA1E4D),
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardColor: Colors.white,
        useMaterial3: true,
        brightness: Brightness.light,
      );

  ThemeData get darkTheme => ThemeData(
        primaryColor: const Color(0xFFBA1E4D),
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
        brightness: Brightness.dark,
      );
}

