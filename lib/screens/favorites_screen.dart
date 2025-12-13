import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../data/courses_data.dart';
import '../data/favorites_manager.dart';
import 'course_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final FavoritesManager _favoritesManager = FavoritesManager();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  List<Course> get favoriteCourses => _favoritesManager.getFavoriteCourses(allCourses);

  List<Course> get filteredCourses {
    if (_searchController.text.isEmpty) {
      return favoriteCourses;
    }
    final query = _searchController.text.toLowerCase();
    return favoriteCourses.where((course) {
      return course.title.toLowerCase().contains(query) ||
          course.category.toLowerCase().contains(query) ||
          course.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    
    // Initialize favorites from Firebase
    _initializeFavorites();
    
    // Listen to favorite changes
    _favoritesManager.favoritesStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  Future<void> _initializeFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (!_favoritesManager.isInitialized) {
        await _favoritesManager.initialize();
      }
    } catch (e) {
      print('Error initializing favorites: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshFavorites() {
    setState(() {});
  }

  Color _getIconColor(String color) {
    switch (color.toLowerCase()) {
      case 'purple':
        return const Color(0xFFBA1E4D);
      case 'orange':
        return const Color(0xFFFF6B35);
      case 'blue':
        return const Color(0xFF4A90E2);
      case 'yellow':
        return const Color(0xFFFFC107);
      case 'green':
        return const Color(0xFF4CAF50);
      case 'teal':
        return const Color(0xFF26A69A);
      case 'indigo':
        return const Color(0xFF3F51B5);
      case 'red':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFFFFC107);
    }
  }

  String? _getCourseImagePath(String courseTitle) {
    // Normalize title for matching (case-insensitive, trim whitespace)
    final normalizedTitle = courseTitle.trim().toLowerCase();
    
    // Map course titles to image paths (flexible matching)
    if (normalizedTitle.contains('ux master') || normalizedTitle.contains('ux course') || normalizedTitle == 'ux master course') {
      return 'assets/images/ux.png';
    } else if (normalizedTitle.contains('ui master') || normalizedTitle.contains('ui course') || normalizedTitle == 'ui master course') {
      return 'assets/images/ui.png';
    } else if (normalizedTitle.contains('unity') && normalizedTitle.contains('game')) {
      return 'assets/images/unity.png';
    } else if (normalizedTitle.contains('3d') || normalizedTitle.contains('grow your 3d')) {
      return 'assets/images/grow you 3d skills.png';
    } else if (normalizedTitle.contains('ai') || normalizedTitle.contains('machine learning')) {
      return 'assets/images/AI and machine learning basics.png';
    } else if (normalizedTitle.contains('react') || (normalizedTitle.contains('web') && normalizedTitle.contains('development'))) {
      return 'assets/images/react web development.png';
    } else if (normalizedTitle.contains('python')) {
      return 'assets/images/Python Programming Mastery.png';
    } else if (normalizedTitle.contains('unreal') || normalizedTitle.contains('ue5')) {
      return 'assets/images/Unreal Engine 5 basics.png';
    }
    
    // Exact matches (for backward compatibility)
    switch (courseTitle) {
      case 'UX Master Course':
        return 'assets/images/ux.png';
      case 'UI Master Course':
        return 'assets/images/ui.png';
      case 'Unity Game Development':
        return 'assets/images/unity.png';
      case 'Grow Your 3D Skills':
        return 'assets/images/grow you 3d skills.png';
      case 'AI & Machine Learning Basics':
        return 'assets/images/AI and machine learning basics.png';
      case 'React Web Development':
        return 'assets/images/react web development.png';
      case 'Python Programming Mastery':
        return 'assets/images/Python Programming Mastery.png';
      case 'Unreal Engine 5 Basics':
        return 'assets/images/Unreal Engine 5 basics.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // Refresh when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[400], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search favorites...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400], size: 18),
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : filteredCourses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                favoriteCourses.isEmpty
                                    ? Icons.favorite_border
                                    : Icons.search_off,
                                size: 80,
                                color: isDark ? Colors.grey[600] : Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                favoriteCourses.isEmpty
                                    ? 'No favorites yet'
                                    : 'No results found',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                favoriteCourses.isEmpty
                                    ? 'Start adding courses to your favorites'
                                    : 'Try a different search term',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        return _FavoriteCourseCard(
                          course: course,
                          getIconColor: _getIconColor,
                          getCourseImagePath: _getCourseImagePath,
                          onRemove: () async {
                            try {
                              await _favoritesManager.removeFavorite(course.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Removed ${course.title} from favorites'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteCourseCard extends StatelessWidget {
  final Course course;
  final Color Function(String) getIconColor;
  final String? Function(String) getCourseImagePath;
  final VoidCallback onRemove;

  const _FavoriteCourseCard({
    required this.course,
    required this.getIconColor,
    required this.getCourseImagePath,
    required this.onRemove,
  });

  Color _getIconColor(String color) {
    switch (color.toLowerCase()) {
      case 'purple':
        return const Color(0xFFBA1E4D);
      case 'orange':
        return const Color(0xFFFF6B35);
      case 'blue':
        return const Color(0xFF4A90E2);
      case 'yellow':
        return const Color(0xFFFFC107);
      case 'green':
        return const Color(0xFF4CAF50);
      case 'teal':
        return const Color(0xFF26A69A);
      case 'indigo':
        return const Color(0xFF3F51B5);
      case 'red':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFFFFC107);
    }
  }

  Widget _buildCourseImage(String imagePath, {required double width, required double height}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: _getIconColor(course.imageColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.play_circle_filled,
              color: _getIconColor(course.imageColor),
              size: 30,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: _getIconColor(course.imageColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.play_circle_filled,
              color: _getIconColor(course.imageColor),
              size: 30,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Course Icon/Image
            (course.coverImagePath ?? getCourseImagePath(course.title)) != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildCourseImage(
                      course.coverImagePath ?? getCourseImagePath(course.title)!,
                      width: 60,
                      height: 60,
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: getIconColor(course.imageColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: getIconColor(course.imageColor),
                      size: 30,
                    ),
                  ),
            const SizedBox(width: 16),
            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      if (course.isPremium)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Premium',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFC107),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.category,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFBA1E4D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        course.duration,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.star,
                              size: 14,
                              color: index < course.rating.floor()
                                  ? Colors.red
                                  : (isDark ? Colors.grey[600] : Colors.grey[300]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 24,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

