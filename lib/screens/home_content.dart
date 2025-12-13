import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../data/courses_data.dart' show allCourses, streamCourses;
import '../data/firebase_service.dart';
import 'course_detail_screen.dart';
import 'notifications_screen.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    final theme = Theme.of(context);
    return SafeArea(
      child: StreamBuilder<List<Course>>(
        stream: streamCourses(),
        builder: (context, snapshot) {
          // Get courses from stream or fallback to cached
          final courses = snapshot.hasData && snapshot.data!.isNotEmpty 
              ? snapshot.data! 
              : allCourses;
          
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Gamebridge',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: FirebaseService().streamUnreadNotificationCount(),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      final hasUnread = unreadCount > 0;
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: theme.brightness == Brightness.dark 
                                      ? Colors.white 
                                      : const Color(0xFF1A1A1A),
                                  size: 24,
                                ),
                              ),
                              if (hasUnread)
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Trending Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:                   Text(
                    'Trending',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 400,
                  child: courses.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Loading courses...',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            // Filter only trendy courses from Firebase
                            final trendyCourses = courses.where((course) => course.isTrendy).toList();
                            
                            if (trendyCourses.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(
                                    'No trending courses available',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              itemCount: trendyCourses.length > 5 ? 5 : trendyCourses.length,
                              itemBuilder: (context, index) {
                                final course = trendyCourses[index];
                                // Try coverImagePath from Firebase first, then fallback to title-based mapping
                                final imagePath = course.coverImagePath ?? _getCourseImagePath(course.title);
                                return Transform.translate(
                                  offset: Offset(index > 0 ? -30.0 * index : 0, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CourseDetailScreen(course: course),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: SizedBox(
                                        height: 400,
                                        width: 320,
                                        child: imagePath != null
                                            ? imagePath.startsWith('http://') || imagePath.startsWith('https://')
                                                ? Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Image.network(
                                                      imagePath,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        // Fallback to gradient if network image fails
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                              colors: [
                                                                _getIconColor(course.imageColor),
                                                                _getIconColor(course.imageColor).withOpacity(0.7),
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
                                                    ),
                                                  )
                                                : Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Image.asset(
                                                      imagePath,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        // Fallback to gradient if asset image fails
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                              colors: [
                                                                _getIconColor(course.imageColor),
                                                                _getIconColor(course.imageColor).withOpacity(0.7),
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
                                                    ),
                                                  )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      _getIconColor(course.imageColor),
                                                      _getIconColor(course.imageColor).withOpacity(0.7),
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
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Best Of The Week Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Of The Week',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gamebridge',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...courses.take(5).map((course) => _CourseListItem(course: course)),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourseListItem extends StatelessWidget {
  final Course course;

  const _CourseListItem({required this.course});

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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/course-detail',
          arguments: course,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Course Icon/Image
            (course.coverImagePath ?? _getCourseImagePath(course.title)) != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildCourseImage(
                      course.coverImagePath ?? _getCourseImagePath(course.title)!,
                      width: 60,
                      height: 60,
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getIconColor(course.imageColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: _getIconColor(course.imageColor),
                      size: 30,
                    ),
                  ),
            const SizedBox(width: 16),
            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${course.duration}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 14,
                        color: index < course.rating.floor()
                            ? Colors.red
                            : Colors.grey[300],
                      ),
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

extension PaddingExtension on Widget {
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}

