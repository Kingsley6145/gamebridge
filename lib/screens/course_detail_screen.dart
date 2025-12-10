import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../data/favorites_manager.dart';
import 'quiz_screen.dart';
import 'module_detail_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final FavoritesManager _favoritesManager = FavoritesManager();

  bool get isFavorite => _favoritesManager.isFavorite(widget.course.id);

  Color _getColorFromString(String color) {
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
        return const Color(0xFFBA1E4D);
    }
  }

  Color _getModuleIconColor(String color) {
    switch (color.toLowerCase()) {
      case 'orange':
        return const Color(0xFFFF6B35);
      case 'lightorange':
        return const Color(0xFFFFA07A);
      default:
        return const Color(0xFFFF6B35);
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

  Widget _buildCourseImage(String imagePath, {required double width, required double height}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getColorFromString(widget.course.imageColor),
                  _getColorFromString(widget.course.imageColor).withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 80,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getColorFromString(widget.course.imageColor),
                  _getColorFromString(widget.course.imageColor).withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 80,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseColor = _getColorFromString(widget.course.imageColor);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and menu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : const Color(0xFF1A1A1A),
                          size: 18,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : const Color(0xFF1A1A1A),
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == 'favorite') {
                          setState(() {
                            _favoritesManager.toggleFavorite(widget.course.id);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? 'Added to favorites'
                                    : 'Removed from favorites',
                              ),
                              backgroundColor: courseColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else if (value == 'share') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Share functionality coming soon'),
                              backgroundColor: courseColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A)),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Share',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Course Image Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: (widget.course.coverImagePath ?? _getCourseImagePath(widget.course.title)) != null
                        ? _buildCourseImage(
                            widget.course.coverImagePath ?? _getCourseImagePath(widget.course.title)!,
                            width: double.infinity,
                            height: 400,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getColorFromString(widget.course.imageColor),
                                  _getColorFromString(widget.course.imageColor).withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Course Title and Premium Badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      widget.course.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (widget.course.isPremium) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Color(0xFFFFC107),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Premium Content',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Course Modules
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Modules',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.course.modules.map((module) => _ModuleItem(
                      module: module,
                      course: widget.course,
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quiz Button (if questions available)
              if (widget.course.questions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: courseColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(course: widget.course),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.quiz,
                                color: courseColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Take Quiz (${widget.course.questions.length} questions)',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: courseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleItem extends StatelessWidget {
  final CourseModule module;
  final Course course;

  const _ModuleItem({
    required this.module,
    required this.course,
  });

  Color _getIconColor(String color) {
    switch (color.toLowerCase()) {
      case 'orange':
        return const Color(0xFFFF6B35);
      case 'lightorange':
        return const Color(0xFFFFA07A);
      default:
        return const Color(0xFFFF6B35);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor(module.iconColor);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ModuleDetailScreen(
              module: module,
              course: course,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Play Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.play_circle_filled,
                color: iconColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Module Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.duration,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    module.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
