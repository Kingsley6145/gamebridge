import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_content.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import '../data/favorites_manager.dart';
import '../data/auth_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isBottomNavBarVisible = true;
  final FavoritesManager _favoritesManager = FavoritesManager();
  final AuthService _authService = AuthService();

  // Cache all screens to prevent rebuilding when switching tabs
  // These screens are created once and kept in memory using IndexedStack
  late final List<Widget> _screens = [
    const HomeContent(),
    const FavoritesScreen(),
    const CategoriesScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  Widget _getScreen(int index) {
    return _screens[index];
  }

  void _handleScrollNotification(ScrollNotification notification) {
    // Disabled nav bar hide/show feature to prevent build during frame errors
    // The overscroll indicator was triggering setState during layout
    // This can be re-enabled later with a more robust implementation
    return;
  }

  @override
  void initState() {
    super.initState();
    // Initialize favorites when user logs in
    _initializeFavorites();
    
    // Listen to auth state changes to reload favorites
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        // User logged in - reload favorites
        _favoritesManager.reload().catchError((error) {
          print('Error reloading favorites after login: $error');
        });
      } else {
        // User logged out - clear favorites (optional, since we check auth in FirebaseService)
        if (_favoritesManager.isInitialized) {
          _favoritesManager.reload().catchError((error) {
            print('Error clearing favorites after logout: $error');
          });
        }
      }
    });
  }
  
  Future<void> _initializeFavorites() async {
    try {
      if (!_favoritesManager.isInitialized) {
        await _favoritesManager.initialize();
      }
    } catch (e) {
      print('Error initializing favorites in MainNavigationScreen: $e');
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      // Reset nav bar visibility when switching tabs
      _isBottomNavBarVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          // Consume all scroll-related notifications to prevent overscroll indicator errors
          // This prevents the _StretchController from triggering setState during layout
          if (notification is OverscrollNotification) {
            return true; // Consume overscroll notifications
          }
          // Don't process scroll notifications for nav bar hide/show to avoid errors
          return false; // Allow notifications to continue but don't process them
        },
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isBottomNavBarVisible ? 70 : 0,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _isBottomNavBarVisible
              ? _buildBottomNavBar(context)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(context, Icons.home, 'Home', 0),
            _buildNavItem(context, Icons.favorite_outline, 'Favorites', 1),
            _buildNavItem(context, Icons.filter_list, '', 2, isCenter: true),
            _buildNavItem(context, Icons.search, 'Search', 3),
            _buildNavItem(context, Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, {bool isCenter = false}) {
    final isActive = _currentIndex == index;
    final theme = Theme.of(context);
    final activeColor = const Color(0xFFBA1E4D);
    final inactiveColor = theme.brightness == Brightness.dark ? Colors.grey[600] : Colors.grey[400];
    
    if (isCenter) {
      return GestureDetector(
        onTap: () => _onTabChanged(2),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFBA1E4D), Color(0xFF9A1A3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBA1E4D).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.filter_list, color: Colors.white, size: 28),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ClipRect(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isActive ? activeColor : inactiveColor,
                    size: 20,
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: isActive ? activeColor : inactiveColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBA1E4D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

