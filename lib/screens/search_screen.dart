import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../data/courses_data.dart';
import 'course_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();
  String? selectedCategory;
  bool showPremiumOnly = false;

  List<Course> get filteredCourses {
    List<Course> filtered = List.from(allCourses);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((course) {
        return course.title.toLowerCase().contains(query) ||
            course.category.toLowerCase().contains(query) ||
            course.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    if (selectedCategory != null && selectedCategory != 'All') {
      filtered = filtered.where((course) => course.category == selectedCategory).toList();
    }

    // Apply premium filter
    if (showPremiumOnly) {
      filtered = filtered.where((course) => course.isPremium).toList();
    }

    return filtered;
  }

  List<String> get uniqueCategories {
    final categories = allCourses.map((course) => course.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                              hintText: 'Search for courses...',
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
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _showCategoriesBottomSheet(context, theme, isDark, textColor, cardColor),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (selectedCategory != null || showPremiumOnly)
                                  ? const Color(0xFFBA1E4D).withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.filter_list,
                              color: (selectedCategory != null || showPremiumOnly)
                                  ? const Color(0xFFBA1E4D)
                                  : Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Show active filters
                  if (selectedCategory != null || showPremiumOnly) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (selectedCategory != null)
                          _buildFilterChip(
                            label: selectedCategory!,
                            onRemove: () {
                              setState(() {
                                selectedCategory = null;
                              });
                            },
                            isDark: isDark,
                            textColor: textColor,
                          ),
                        if (showPremiumOnly)
                          _buildFilterChip(
                            label: 'Premium Only',
                            onRemove: () {
                              setState(() {
                                showPremiumOnly = false;
                              });
                            },
                            isDark: isDark,
                            textColor: textColor,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: filteredCourses.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: isDark ? Colors.grey[600] : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term or adjust filters',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_searchController.text.isNotEmpty || selectedCategory != null || showPremiumOnly) ...[
                            Text(
                              'Results (${filteredCourses.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredCourses.length,
                            itemBuilder: (context, index) {
                              final course = filteredCourses[index];
                              return _CourseCard(
                                course: course,
                                getIconColor: _getIconColor,
                                getCourseImagePath: _getCourseImagePath,
                              );
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
    required bool isDark,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFBA1E4D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBA1E4D).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFBA1E4D),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: const Color(0xFFBA1E4D),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoriesBottomSheet(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: textColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Premium Only Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
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
                  const SizedBox(height: 24),
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: uniqueCategories.map((category) {
                      final isSelected = selectedCategory == category || (category == 'All' && selectedCategory == null);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category == 'All' ? null : category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFBA1E4D) : cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFBA1E4D) : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Colors.white : textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = null;
                              showPremiumOnly = false;
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: const Color(0xFFBA1E4D)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFBA1E4D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFFBA1E4D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Apply',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
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
  final Color Function(String) getIconColor;
  final String? Function(String) getCourseImagePath;

  const _CourseCard({
    required this.course,
    required this.getIconColor,
    required this.getCourseImagePath,
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

