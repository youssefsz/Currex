import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utilities/theme_animation_overlay.dart';
import '../utilities/screen_capture_provider.dart';
import '../utilities/haptic_service.dart';

class AnimatedThemeSwitch extends StatefulWidget {
  const AnimatedThemeSwitch({super.key});

  @override
  _AnimatedThemeSwitchState createState() => _AnimatedThemeSwitchState();
}

class _AnimatedThemeSwitchState extends State<AnimatedThemeSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Duration _animationDuration = const Duration(milliseconds: 1200);

  // Store the position of the button for the animation origin
  Offset? _buttonPosition;
  Size? _screenSize;

  // For capturing the screen
  ui.Image? _capturedImage;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Listen to animation completion
    _animationController.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Animation completed
      setState(() {
        _isAnimating = false;
        _capturedImage = null; // Release the captured image
      });

      // Hide the overlay when animation completes
      context.hideThemeOverlay();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(_handleAnimationStatus);
    _animationController.dispose();
    super.dispose();
  }

  void _updatePositionAndSize(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    _buttonPosition =
        box.localToGlobal(Offset.zero) +
        Offset(box.size.width / 2, box.size.height / 2);
    _screenSize = MediaQuery.of(context).size;
  }

  void _toggleTheme() async {
    if (_isAnimating) return;

    // Get current theme mode before toggling
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // Provide haptic feedback
    final hapticService = HapticService();
    hapticService.mediumImpact();

    // Update button position for animation origin
    _updatePositionAndSize(context);

    setState(() {
      _isAnimating = true;
    });

    // Use the screen capture provider to capture the current screen
    final captureState = ScreenCaptureProvider.of(context);
    if (captureState != null) {
      _capturedImage = await captureState.captureScreen();
    }

    if (_capturedImage != null &&
        _buttonPosition != null &&
        _screenSize != null) {
      // Create and show the overlay with animation
      context.showThemeOverlay(_buildThemeAnimation(isDarkMode: isDarkMode));

      // Toggle the theme immediately so new theme renders underneath
      themeProvider.toggleTheme();

      // Start the animation to reveal the new theme
      _animationController.forward(from: 0.0);
    } else {
      // Fallback to direct toggle without animation if screen capture failed
      themeProvider.toggleTheme();
      setState(() {
        _isAnimating = false;
      });
    }
  }

  Widget _buildThemeAnimation({required bool isDarkMode}) {
    // Calculate the maximum radius needed to cover the entire screen
    final double maxRadius = _calculateMaxRadius();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: CircularRevealPainter(
            image: _capturedImage!,
            radius: maxRadius * _animation.value,
            center: _buttonPosition!,
            progress: _animation.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  double _calculateMaxRadius() {
    if (_screenSize == null || _buttonPosition == null) return 0;

    // Calculate distances to the four corners of the screen
    final double topLeft = _buttonPosition!.distance;
    final double topRight =
        Offset(
          _screenSize!.width - _buttonPosition!.dx,
          _buttonPosition!.dy,
        ).distance;
    final double bottomLeft =
        Offset(
          _buttonPosition!.dx,
          _screenSize!.height - _buttonPosition!.dy,
        ).distance;
    final double bottomRight =
        Offset(
          _screenSize!.width - _buttonPosition!.dx,
          _screenSize!.height - _buttonPosition!.dy,
        ).distance;

    // Return the maximum distance to ensure the circle covers the entire screen
    return [topLeft, topRight, bottomLeft, bottomRight].reduce(max) *
        1.1; // Add 10% for safety
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child:
            isDarkMode
                ? const Icon(
                  Icons.dark_mode_rounded,
                  key: ValueKey('dark'),
                  color: Colors.white,
                )
                : const Icon(
                  Icons.light_mode_rounded,
                  key: ValueKey('light'),
                  color: Colors.amber,
                ),
      ),
      onPressed: _isAnimating ? null : _toggleTheme,
      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}

class CircularRevealPainter extends CustomPainter {
  final ui.Image image;
  final double radius;
  final Offset center;
  final double progress;

  CircularRevealPainter({
    required this.image,
    required this.radius,
    required this.center,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a path for the expanding/contracting circle
    final Path path =
        Path()..addOval(Rect.fromCircle(center: center, radius: radius));

    // Create a path for the entire screen
    final Path screenPath =
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate the difference - this will be the mask that shows the old theme
    final Path clipPath = Path.combine(
      PathOperation.difference,
      screenPath,
      path,
    );

    // Save the canvas state
    canvas.save();

    // Clip to show only the old theme outside the circle
    canvas.clipPath(clipPath);

    // Calculate the correct scale to prevent zooming
    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;

    // Use the canvas transform to ensure the image is drawn at the exact size of the screen
    // without any scaling that could cause zooming
    canvas.scale(scaleX, scaleY);

    // Draw the captured image (old theme) on the outside of the circle
    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    // Restore the canvas to remove the clip and transforms
    canvas.restore();
  }

  @override
  bool shouldRepaint(CircularRevealPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.image != image ||
        oldDelegate.center != center ||
        oldDelegate.progress != progress;
  }
}
