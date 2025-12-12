import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../data/firebase_service.dart';

class WebViewModal extends StatefulWidget {
  final String? url;
  final String? htmlContent;
  final String title;
  final Function(Map<String, dynamic>)? onMessageReceived;
  final String? courseId;
  final String? moduleId;

  const WebViewModal({
    super.key,
    this.url,
    this.htmlContent,
    required this.title,
    this.onMessageReceived,
    this.courseId,
    this.moduleId,
  }) : assert(url != null || htmlContent != null, 'Either url or htmlContent must be provided');

  @override
  State<WebViewModal> createState() => _WebViewModalState();
}

class _WebViewModalState extends State<WebViewModal> {
  WebViewController? _controller;
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // Wait a bit to ensure platform is ready
      await Future.delayed(const Duration(milliseconds: 200));
      
      final PlatformWebViewControllerCreationParams params;
      if (Platform.isAndroid) {
        params = AndroidWebViewControllerCreationParams();
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final controller = WebViewController.fromPlatformCreationParams(params)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'FlutterMessageHandler',
          onMessageReceived: (JavaScriptMessage message) {
            _handleMessageFromWebView(message.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
              // Inject JavaScript to intercept postMessage calls
              _injectMessageInterceptor();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
            },
          ),
        );

      // Load either URL or HTML content
      if (widget.htmlContent != null && widget.htmlContent!.isNotEmpty) {
        // Load HTML content directly with base URL to enable localStorage
        await controller.loadHtmlString(
          widget.htmlContent!,
          baseUrl: 'https://gametibe2025-default-rtdb.firebaseio.com',
        );
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        // Load URL
        await controller.loadRequest(Uri.parse(widget.url!));
      }

      if (Platform.isAndroid) {
        final androidController = controller.platform as AndroidWebViewController;
        await androidController.setMediaPlaybackRequiresUserGesture(false);
      }

      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Injects JavaScript code to intercept window.postMessage calls
  /// and forward them to Flutter via the JavaScript channel
  Future<void> _injectMessageInterceptor() async {
    if (_controller == null) return;

    const String jsCode = '''
      (function() {
        // Store original postMessage
        const originalPostMessage = window.postMessage;
        
        // Override postMessage to also send to Flutter
        window.postMessage = function(message, targetOrigin) {
          // Call original postMessage (for iframe communication)
          originalPostMessage.call(this, message, targetOrigin);
          
          // Also send to Flutter via JavaScript channel
          if (window.FlutterMessageHandler) {
            // If message is an object, stringify it
            const messageStr = typeof message === 'object' 
              ? JSON.stringify(message) 
              : message;
            window.FlutterMessageHandler.postMessage(messageStr);
          }
        };
        
        // Also listen for messages sent via addEventListener
        window.addEventListener('message', function(event) {
          // Forward to Flutter if needed
          if (window.FlutterMessageHandler) {
            const messageStr = typeof event.data === 'object' 
              ? JSON.stringify(event.data) 
              : event.data;
            window.FlutterMessageHandler.postMessage(messageStr);
          }
        });
      })();
    ''';

    try {
      await _controller!.runJavaScript(jsCode);
      debugPrint('✅ Message interceptor injected successfully');
    } catch (e) {
      debugPrint('❌ Error injecting message interceptor: $e');
    }
  }

  /// Handles messages received from the WebView
  Future<void> _handleMessageFromWebView(String message) async {
    try {
      // Try to parse as JSON
      final Map<String, dynamic> data = jsonDecode(message);
      
      debugPrint('📨 Message received from WebView: $data');
      
      // Check if it's a score or other activity data
      if (data.containsKey('score')) {
        final score = data['score'] is int 
            ? data['score'] as int 
            : int.tryParse(data['score'].toString()) ?? 0;
        
        debugPrint('✅ Activity completed! Score: $score');
        
        // Save to Firebase if courseId and moduleId are provided
        // Save ALL scores, including 0 (zero scores are valid)
        if (widget.courseId != null && widget.moduleId != null && !_isSaving) {
          _isSaving = true;
          
          try {
            final pointsAwarded = await _firebaseService.saveActivityScore(
              courseId: widget.courseId!,
              moduleId: widget.moduleId!,
              score: score,
              additionalData: {
                'correctAnswers': data['correctAnswers'],
                'totalQuestions': data['totalQuestions'],
                'passed': data['passed'] ?? (score >= 70),
                'type': data['type'] ?? 'activity',
              },
            );
            
            // Show success message with points
            if (mounted) {
              final passed = score >= 70;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passed 
                            ? '✅ Activity completed! Score: $score%' 
                            : '⚠️ Activity completed! Score: $score% (Need 70% to pass)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (pointsAwarded > 0)
                        Text(
                          '🎉 You earned $pointsAwarded points!',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  backgroundColor: passed ? Colors.green : Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } catch (e) {
            debugPrint('❌ Error saving score to Firebase: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Activity completed! Score: $score (Error saving to cloud)'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } finally {
            _isSaving = false;
          }
        } else {
          // Just show notification if not saving to Firebase
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Activity completed! Score: $score'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
      
      // Call the optional callback if provided
      if (widget.onMessageReceived != null) {
        widget.onMessageReceived!(data);
      }
    } catch (e) {
      // If not JSON, treat as plain string
      debugPrint('📨 Message received (string): $message');
      
      if (widget.onMessageReceived != null) {
        widget.onMessageReceived!({'message': message});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: false,
      ),
      body: _controller == null
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading)
                  Container(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
