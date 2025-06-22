import 'package:flutter/services.dart';

/// Provides haptic feedback throughout the app with modern, Apple-like patterns
class HapticService {
  /// Singleton instance
  static final HapticService _instance = HapticService._internal();

  /// Whether haptic feedback is enabled
  bool _isEnabled = true;

  /// Factory constructor
  factory HapticService() {
    return _instance;
  }

  /// Internal constructor
  HapticService._internal();

  /// Get current haptic feedback state
  bool get isEnabled => _isEnabled;

  /// Set haptic feedback state
  set isEnabled(bool value) {
    _isEnabled = value;
  }

  /// Light impact feedback for subtle UI interactions
  void lightImpact() {
    if (_isEnabled) {
      HapticFeedback.lightImpact();
      // Double tap for stronger effect
      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.lightImpact();
      });
    }
  }

  /// Medium impact feedback for selections with a modern feel
  void mediumImpact() {
    if (_isEnabled) {
      HapticFeedback.mediumImpact();
      // Follow-up light tap for depth
      Future.delayed(const Duration(milliseconds: 30), () {
        HapticFeedback.lightImpact();
      });
    }
  }

  /// Heavy impact feedback for major interactions
  void heavyImpact() {
    if (_isEnabled) {
      HapticFeedback.heavyImpact();
      // Double heavy impact for stronger effect
      Future.delayed(const Duration(milliseconds: 40), () {
        HapticFeedback.heavyImpact();
      });
    }
  }

  /// Vibration feedback for alerts with a modern pattern
  void vibrate() {
    if (_isEnabled) {
      HapticFeedback.vibrate();
      // Follow-up medium impact for depth
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.mediumImpact();
      });
    }
  }

  /// Selection feedback for tapping with enhanced feel
  void selectionClick() {
    if (_isEnabled) {
      HapticFeedback.selectionClick();
      // Quick follow-up light impact
      Future.delayed(const Duration(milliseconds: 20), () {
        HapticFeedback.lightImpact();
      });
    }
  }

  /// Success feedback pattern (like Apple's success haptic)
  void success() {
    if (_isEnabled) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 60), () {
        HapticFeedback.lightImpact();
      });
      Future.delayed(const Duration(milliseconds: 120), () {
        HapticFeedback.lightImpact();
      });
    }
  }

  /// Error feedback pattern (like Apple's error haptic)
  void error() {
    if (_isEnabled) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 70), () {
        HapticFeedback.mediumImpact();
      });
      Future.delayed(const Duration(milliseconds: 140), () {
        HapticFeedback.lightImpact();
      });
    }
  }

  /// Warning feedback pattern
  void warning() {
    if (_isEnabled) {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.mediumImpact();
      });
    }
  }
}
