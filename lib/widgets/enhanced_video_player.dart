import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class EnhancedVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Color accentColor;
  final bool showControls;

  const EnhancedVideoPlayer({
    super.key,
    required this.controller,
    required this.accentColor,
    this.showControls = true,
  });

  @override
  State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
}

class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer> {
  bool _showControls = true;
  bool _isDragging = false;
  Timer? _hideControlsTimer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _showSkipIndicator = false;
  bool _isSkipForward = true;
  Offset? _skipIndicatorPosition;
  Timer? _skipIndicatorTimer;

  @override
  void initState() {
    super.initState();
    if (widget.controller.value.isInitialized) {
      widget.controller.addListener(_updatePosition);
      _updatePosition();
      _startHideControlsTimer();
    } else {
      widget.controller.addListener(_onControllerInitialized);
    }
  }

  void _onControllerInitialized() {
    if (widget.controller.value.isInitialized) {
      widget.controller.removeListener(_onControllerInitialized);
      widget.controller.addListener(_updatePosition);
      _updatePosition();
      _startHideControlsTimer();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    widget.controller.removeListener(_updatePosition);
    widget.controller.removeListener(_onControllerInitialized);
    super.dispose();
  }

  void _updatePosition() {
    if (mounted && !_isDragging) {
      setState(() {
        _currentPosition = widget.controller.value.position;
        _totalDuration = widget.controller.value.duration;
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    // Only start timer if playing - when paused, controls should stay visible
    if (widget.showControls && widget.controller.value.isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    _startHideControlsTimer();
  }

  void _skipForward(Offset tapPosition) {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    final maxPosition = _totalDuration;
    widget.controller.seekTo(
      newPosition > maxPosition ? maxPosition : newPosition,
    );
    _showSkipIndicatorAtPosition(true, tapPosition);
  }

  void _skipBackward(Offset tapPosition) {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    widget.controller.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
    _showSkipIndicatorAtPosition(false, tapPosition);
  }

  void _showSkipIndicatorAtPosition(bool forward, Offset position) {
    setState(() {
      _showSkipIndicator = true;
      _isSkipForward = forward;
      _skipIndicatorPosition = position;
    });
    
    _skipIndicatorTimer?.cancel();
    _skipIndicatorTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showSkipIndicator = false;
          _skipIndicatorPosition = null;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _onSliderChanged(double value) {
    setState(() {
      _isDragging = true;
      _currentPosition = Duration(milliseconds: value.toInt());
    });
  }

  void _onSliderChangeEnd(double value) {
    widget.controller.seekTo(Duration(milliseconds: value.toInt()));
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),

          // Double tap areas for skip/rewind
          Row(
            children: [
              // Left side - rewind (double tap)
              Expanded(
                child: GestureDetector(
                  onDoubleTapDown: (details) {
                    // Get the position relative to the Stack
                    final RenderBox? gestureBox = context.findRenderObject() as RenderBox?;
                    if (gestureBox != null) {
                      final globalPos = gestureBox.localToGlobal(details.localPosition);
                      final stackBox = context.findAncestorRenderObjectOfType<RenderBox>();
                      if (stackBox != null) {
                        final localPos = stackBox.globalToLocal(globalPos);
                        _skipBackward(localPos);
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),

              // Center - play/pause (single tap)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                      // When pausing, show controls and keep them visible
                      setState(() {
                        _showControls = true;
                      });
                      _hideControlsTimer?.cancel();
                    } else {
                      widget.controller.play();
                      // When playing, show controls and start auto-hide timer
                      setState(() {
                        _showControls = true;
                      });
                      _startHideControlsTimer();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.transparent,
                    child: _showControls && widget.showControls
                        ? Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
              ),

              // Right side - skip forward (double tap)
              Expanded(
                child: GestureDetector(
                  onDoubleTapDown: (details) {
                    // Get the position relative to the Stack
                    final RenderBox? gestureBox = context.findRenderObject() as RenderBox?;
                    if (gestureBox != null) {
                      final globalPos = gestureBox.localToGlobal(details.localPosition);
                      final stackBox = context.findAncestorRenderObjectOfType<RenderBox>();
                      if (stackBox != null) {
                        final localPos = stackBox.globalToLocal(globalPos);
                        _skipForward(localPos);
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),

          // Skip indicator overlay
          if (_showSkipIndicator && _skipIndicatorPosition != null)
            Positioned(
              left: _skipIndicatorPosition!.dx - 30,
              top: _skipIndicatorPosition!.dy - 30,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSkipForward ? Icons.forward_10 : Icons.replay_10,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isSkipForward ? '+10s' : '-10s',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Controls overlay
          if (_showControls && widget.showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress slider
                    Row(
                      children: [
                        // Current time
                        Text(
                          _formatDuration(_currentPosition),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Slider
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: widget.accentColor,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: widget.accentColor,
                              overlayColor: widget.accentColor.withOpacity(0.2),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: _currentPosition.inMilliseconds.toDouble(),
                              min: 0,
                              max: _totalDuration.inMilliseconds > 0
                                  ? _totalDuration.inMilliseconds.toDouble()
                                  : 1,
                              onChanged: _onSliderChanged,
                              onChangeEnd: _onSliderChangeEnd,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Total time
                        Text(
                          _formatDuration(_totalDuration),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Fullscreen button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _FullScreenVideoPlayer(
                                  controller: widget.controller,
                                  accentColor: widget.accentColor,
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Color accentColor;

  const _FullScreenVideoPlayer({
    required this.controller,
    required this.accentColor,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _showControls = true;
  bool _isDragging = false;
  Timer? _hideControlsTimer;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _showSkipIndicator = false;
  bool _isSkipForward = true;
  Offset? _skipIndicatorPosition;
  Timer? _skipIndicatorTimer;

  @override
  void initState() {
    super.initState();
    if (widget.controller.value.isInitialized) {
      widget.controller.addListener(_updatePosition);
      _updatePosition();
      _startHideControlsTimer();
    } else {
      widget.controller.addListener(_onControllerInitialized);
    }
  }

  void _onControllerInitialized() {
    if (widget.controller.value.isInitialized) {
      widget.controller.removeListener(_onControllerInitialized);
      widget.controller.addListener(_updatePosition);
      _updatePosition();
      _startHideControlsTimer();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _skipIndicatorTimer?.cancel();
    widget.controller.removeListener(_updatePosition);
    widget.controller.removeListener(_onControllerInitialized);
    super.dispose();
  }

  void _updatePosition() {
    if (mounted && !_isDragging) {
      setState(() {
        _currentPosition = widget.controller.value.position;
        _totalDuration = widget.controller.value.duration;
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    // Only start timer if playing - when paused, controls should stay visible
    if (widget.controller.value.isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    _startHideControlsTimer();
  }

  void _skipForward(Offset tapPosition) {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    final maxPosition = _totalDuration;
    widget.controller.seekTo(
      newPosition > maxPosition ? maxPosition : newPosition,
    );
    _showSkipIndicatorAtPosition(true, tapPosition);
  }

  void _skipBackward(Offset tapPosition) {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    widget.controller.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
    _showSkipIndicatorAtPosition(false, tapPosition);
  }

  void _showSkipIndicatorAtPosition(bool forward, Offset position) {
    setState(() {
      _showSkipIndicator = true;
      _isSkipForward = forward;
      _skipIndicatorPosition = position;
    });
    
    _skipIndicatorTimer?.cancel();
    _skipIndicatorTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showSkipIndicator = false;
          _skipIndicatorPosition = null;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _onSliderChanged(double value) {
    setState(() {
      _isDragging = true;
      _currentPosition = Duration(milliseconds: value.toInt());
    });
  }

  void _onSliderChangeEnd(double value) {
    widget.controller.seekTo(Duration(milliseconds: value.toInt()));
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            // Back button
            if (_showControls)
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            // Double tap areas
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleControls,
                    onDoubleTapDown: (details) {
                      final RenderBox? box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final globalPosition = box.localToGlobal(details.localPosition);
                        final stackBox = context.findAncestorRenderObjectOfType<RenderBox>();
                        if (stackBox != null) {
                          final localPosition = stackBox.globalToLocal(globalPosition);
                          _skipBackward(localPosition);
                        }
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.controller.value.isPlaying) {
                        widget.controller.pause();
                        // When pausing, show controls and keep them visible
                        setState(() {
                          _showControls = true;
                        });
                        _hideControlsTimer?.cancel();
                      } else {
                        widget.controller.play();
                        // When playing, show controls and start auto-hide timer
                        setState(() {
                          _showControls = true;
                        });
                        _startHideControlsTimer();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.transparent,
                      child: _showControls
                          ? Center(
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _toggleControls,
                    onDoubleTapDown: (details) {
                      final RenderBox? box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final globalPosition = box.localToGlobal(details.localPosition);
                        final stackBox = context.findAncestorRenderObjectOfType<RenderBox>();
                        if (stackBox != null) {
                          final localPosition = stackBox.globalToLocal(globalPosition);
                          _skipForward(localPosition);
                        }
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),

            // Skip indicator overlay
            if (_showSkipIndicator && _skipIndicatorPosition != null)
              Positioned(
                left: _skipIndicatorPosition!.dx - 30,
                top: _skipIndicatorPosition!.dy - 30,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isSkipForward ? Icons.forward_10 : Icons.replay_10,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isSkipForward ? '+10s' : '-10s',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Controls overlay
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: widget.accentColor,
                                inactiveTrackColor: Colors.white.withOpacity(0.3),
                                thumbColor: widget.accentColor,
                                overlayColor: widget.accentColor.withOpacity(0.2),
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                              ),
                              child: Slider(
                                value: _currentPosition.inMilliseconds.toDouble(),
                                min: 0,
                                max: _totalDuration.inMilliseconds > 0
                                    ? _totalDuration.inMilliseconds.toDouble()
                                    : 1,
                                onChanged: _onSliderChanged,
                                onChangeEnd: _onSliderChangeEnd,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDuration(_totalDuration),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.fullscreen_exit,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
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

