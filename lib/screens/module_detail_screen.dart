import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/course.dart';
import '../widgets/enhanced_video_player.dart';
import '../widgets/webview_modal.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeVideo();
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

              // Module Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.module.title,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
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

              // Take Quiz Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Open webview modal with quiz URL
                      // You can customize this URL based on your needs
                      final quizUrl = 'https://example.com/quiz/${widget.module.id}';
                      showDialog(
                        context: context,
                        builder: (context) => WebViewModal(
                          url: quizUrl,
                          title: '${widget.module.title} - Quiz',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: courseColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Take Quiz',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

