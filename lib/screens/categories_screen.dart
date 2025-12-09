import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../data/courses_data.dart';
import 'course_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? selectedCategory;
  String? selectedDifficulty;
  String? selectedDuration;
  bool showPremiumOnly = false;

  List<String> get difficulties => ['All', 'Beginner', 'Intermediate', 'Advanced'];

  List<String> get durations => ['All', '< 3 hours', '3-6 hours', '6-10 hours', '> 10 hours'];

  List<Course> getFilteredCourses() {
    List<Course> filtered = List.from(allCourses);

    if (selectedCategory != null && selectedCategory != 'All') {
      filtered = filtered.where((course) => course.category == selectedCategory).toList();
    }

    if (showPremiumOnly) {
      filtered = filtered.where((course) => course.isPremium).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = getFilteredCourses();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filters Section
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filters Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filters',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Premium Only Toggle
                          Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.workspace_premium,
                                      color: const Color(0xFFFFC107),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Premium Only',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: showPremiumOnly,
                                  onChanged: (value) {
                                    setState(() {
                                      showPremiumOnly = value;
                                    });
                                  },
                                  activeColor: const Color(0xFFBA1E4D),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Results Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Results (${filteredCourses.length})',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (selectedCategory != null || showPremiumOnly)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedCategory = null;
                                  showPremiumOnly = false;
                                });
                              },
                              child: Text(
                                'Clear Filters',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFBA1E4D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Course List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: filteredCourses.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No courses found',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your filters',
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
                                return _CourseCard(course: course);
                              },
                            ),
                    ),

                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

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
                      const SizedBox(width: 4),
                      Text(
                        '(${course.students})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
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

