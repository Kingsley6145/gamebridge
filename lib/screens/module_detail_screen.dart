import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/course.dart';
import '../widgets/enhanced_video_player.dart';
import '../widgets/webview_modal.dart';
import '../data/firebase_service.dart';

class ModuleDetailScreen extends StatefulWidget {
  final CourseModule module;
  final Course course;

  const ModuleDetailScreen({
    super.key,
    required this.module,
    required this.course,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isCompleted = false;
  Map<String, dynamic>? _activityScore;
  bool _isLoadingCompletion = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    try {
      // Get the activity score first (this will exist for any score, not just passed)
      final score = await _firebaseService.getActivityScore(
        widget.course.id,
        widget.module.id,
      );
      
      // Check if completed (only true if passed)
      final isCompleted = await _firebaseService.isModuleCompleted(
        widget.course.id,
        widget.module.id,
      );
      
      if (mounted) {
        setState(() {
          _isCompleted = isCompleted;
          _activityScore = score; // Show score regardless of pass/fail
          _isLoadingCompletion = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking completion status: $e');
      if (mounted) {
        setState(() {
          _isLoadingCompletion = false;
        });
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // Use video URL from module
      final videoPath = widget.module.videoUrl.trim();
      
      debugPrint('Initializing video with path: $videoPath');
      
      // Check if video URL is empty
      if (videoPath.isEmpty) {
        debugPrint('Video URL is empty');
        if (mounted) {
          setState(() {
            _isVideoError = true;
          });
        }
        return;
      }
      
      // Check if it's a URL (http/https) or an asset path
      if (videoPath.startsWith('http://') || videoPath.startsWith('https://')) {
        debugPrint('Loading video from network URL: $videoPath');
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
      } else {
        debugPrint('Loading video from asset: $videoPath');
        _controller = VideoPlayerController.asset(videoPath);
      }

      await _controller!.initialize();
      debugPrint('Video initialized successfully');
      
      // Add listener to update UI when playback state changes
      _controller!.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Video initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Video URL was: ${widget.module.videoUrl}');
      if (mounted) {
        setState(() {
          _isVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _getMarkdownDescription() {
    try {
      final description = widget.module.markdownDescription;
      if (description.isNotEmpty) {
        return description;
      }
    } catch (e) {
      // Handle case where markdownDescription might not be available
    }
    return '## ${widget.module.title}\n\nDescription coming soon...';
  }

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

  @override
  Widget build(BuildContext context) {
    final courseColor = _getColorFromString(widget.course.imageColor);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Module Title with Completion Badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.module.title,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    if (_isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Video Player Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child                          : _isVideoError
                          ? Container(
                              color: Colors.black,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Video not available',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'Please ensure the video file is included in assets/videos/',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _isVideoInitialized && _controller != null
                              ? EnhancedVideoPlayer(
                                  controller: _controller!,
                                  accentColor: courseColor,
                                )
                              : Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: courseColor,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Description Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: MarkdownBody(
                        data: _getMarkdownDescription(),
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.poppins(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark ? Colors.grey[300] : const Color(0xFF1A1A1A),
                          ),
                          h1: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          h2: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          h3: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          strong: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          code: GoogleFonts.robotoMono(
                            fontSize: 14,
                            color: courseColor,
                            backgroundColor: isDark
                                ? Colors.grey[900]!
                                : Colors.grey[200]!,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquote: GoogleFonts.poppins(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                          listBullet: GoogleFonts.poppins(
                            fontSize: 15,
                            color: courseColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Practical Activity Button
              if (widget.module.htmlContent.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Open webview full screen with HTML content from Firebase
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WebViewModal(
                                  htmlContent: widget.module.htmlContent,
                                  title: '${widget.module.title} - Practical Activity',
                                  courseId: widget.course.id,
                                  moduleId: widget.module.id,
                                  onMessageReceived: (data) {
                                    // Refresh completion status immediately when message is received
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      _checkCompletionStatus();
                                    });
                                  },
                                ),
                              ),
                            );
                            
                            // Always refresh completion status when returning from activity
                            // Add a small delay to ensure Firebase has saved the data
                            await Future.delayed(const Duration(milliseconds: 300));
                            _checkCompletionStatus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCompleted 
                                ? Colors.green 
                                : courseColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(
                            _isCompleted ? Icons.check_circle : Icons.play_arrow,
                            size: 20,
                          ),
                          label: Text(
                            _isCompleted 
                                ? 'Practical Activity (Completed)' 
                                : 'Practical Activity',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (_activityScore != null && _activityScore!['score'] < 100)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'You can retake this activity to improve your score',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Show score if any score exists (regardless of pass/fail)
              if (_activityScore != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCompleted 
                          ? (isDark ? Colors.green[900]?.withOpacity(0.2) : Colors.green[50])
                          : (isDark ? Colors.orange[900]?.withOpacity(0.2) : Colors.orange[50]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCompleted 
                            ? Colors.green.withOpacity(0.3)
                            : Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isCompleted ? Icons.emoji_events : Icons.assessment,
                          color: _isCompleted 
                              ? Colors.green[700]
                              : Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Score',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: _isCompleted
                                      ? (isDark ? Colors.green[300] : Colors.green[700])
                                      : (isDark ? Colors.orange[300] : Colors.orange[700]),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${_activityScore!['score']}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _isCompleted
                                      ? (isDark ? Colors.green[300] : Colors.green[700])
                                      : (isDark ? Colors.orange[300] : Colors.orange[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_activityScore!['pointsAwarded'] != null && _activityScore!['pointsAwarded'] > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: courseColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${_activityScore!['pointsAwarded']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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

