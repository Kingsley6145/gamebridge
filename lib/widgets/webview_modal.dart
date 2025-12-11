import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewModal extends StatefulWidget {
  final String? url;
  final String? htmlContent;
  final String title;

  const WebViewModal({
    super.key,
    this.url,
    this.htmlContent,
    required this.title,
  }) : assert(url != null || htmlContent != null, 'Either url or htmlContent must be provided');

  @override
  State<WebViewModal> createState() => _WebViewModalState();
}

class _WebViewModalState extends State<WebViewModal> {
  WebViewController? _controller;
  bool _isLoading = true;

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
