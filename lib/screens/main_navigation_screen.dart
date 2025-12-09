import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_content.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isBottomNavBarVisible = true;
  double _lastScrollOffset = 0.0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeContent();
      case 1:
        return const FavoritesScreen();
      case 2:
        return const CategoriesScreen();
      case 3:
        return const SearchScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeContent();
    }
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final currentOffset = notification.metrics.pixels;
      final scrollDelta = currentOffset - _lastScrollOffset;
      
      // React immediately to ANY scroll movement, no matter how small
      if (scrollDelta.abs() > 0.01) { // Even tiny movement triggers
        if (scrollDelta > 0) {
          // Scrolling DOWN - hide nav bar immediately
          if (_isBottomNavBarVisible && currentOffset > 5) {
            setState(() {
              _isBottomNavBarVisible = false;
            });
          }
        } else if (scrollDelta < 0) {
          // Scrolling UP - show nav bar immediately
          if (!_isBottomNavBarVisible) {
            setState(() {
              _isBottomNavBarVisible = true;
            });
          }
        }
      }
      
      // Always show nav bar when at the very top
      if (currentOffset <= 5) {
        if (!_isBottomNavBarVisible) {
          setState(() {
            _isBottomNavBarVisible = true;
          });
        }
      }
      
      _lastScrollOffset = currentOffset;
    } else if (notification is ScrollStartNotification) {
      // Initialize scroll tracking when scroll starts
      _lastScrollOffset = notification.metrics.pixels;
    } else if (notification is ScrollEndNotification) {
      // Reset scroll tracking when scroll ends
      _lastScrollOffset = notification.metrics.pixels;
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      // Reset nav bar visibility when switching tabs
      _isBottomNavBarVisible = true;
      _lastScrollOffset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          _handleScrollNotification(notification);
          return false; // Allow the notification to continue bubbling
        },
        child: _getScreen(_currentIndex),
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

