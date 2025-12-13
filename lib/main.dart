import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/course_detail_screen.dart';
import 'models/course.dart';
import 'data/courses_data.dart' show initializeCourses;
import 'data/theme_manager.dart';
import 'widgets/auth_wrapper.dart';

// Import Android webview implementation to ensure it's registered
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'data/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize default Firebase app (from google-services.json - gamebridge-ec7cd)
  try {
    await Firebase.initializeApp();
    print('✅ Default Firebase app initialized (gamebridge-ec7cd)');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  // Initialize secondary Firebase app for gametibe2025 database
  try {
    await Gametibe2025FirebaseConfig.initializeSecondaryApp();
  } catch (e) {
    print('Secondary Firebase app initialization error: $e');
  }
  
  // Register the Android WebView platform implementation
  if (Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }
  
  // Initialize theme manager to load saved preference
  final themeManager = ThemeManager();
  await themeManager.initialize();
  
  // Initialize courses - loads from cache immediately, then fetches from Firebase in background
  // This ensures instant loading while keeping data fresh
  initializeCourses().catchError((error) {
    print('Failed to initialize courses: $error');
    // App will continue with empty courses list
  });
  
  runApp(const GamebridgeApp());
}

class GamebridgeApp extends StatefulWidget {
  const GamebridgeApp({super.key});

  @override
  State<GamebridgeApp> createState() => _GamebridgeAppState();
}

class _GamebridgeAppState extends State<GamebridgeApp> {
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamebridge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFBA1E4D),
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFFBA1E4D),
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthWrapper(),
      routes: {
        '/course-detail': (context) {
          final course = ModalRoute.of(context)!.settings.arguments as Course;
          return CourseDetailScreen(course: course);
        },
      },
    );
  }
}

