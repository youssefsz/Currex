import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeService extends ChangeNotifier {
  // Singleton instance
  static final ThemeService _instance = ThemeService._internal();

  // Theme mode
  ThemeMode _themeMode = ThemeMode.system;

  // Theme controller for animations
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  // BuildContext for responsive theme
  BuildContext? _context;

  // Factory constructor
  factory ThemeService() {
    return _instance;
  }

  // Internal constructor
  ThemeService._internal();

  // Set BuildContext for responsive theming
  void setContext(BuildContext context) {
    _context = context;
  }

  // Get theme data
  ThemeData getTheme() {
    if (_context != null) {
      // Use responsive theme if context is available
      return AppTheme.getTheme(_context!, isDark: _themeMode == ThemeMode.dark);
    }

    // Fallback to static theme if no context
    return _themeMode == ThemeMode.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }

  // Get theme mode
  ThemeMode getThemeMode() {
    return _themeMode;
  }

  // Check if dark mode
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Check if using system theme
  bool get isSystemTheme => _themeMode == ThemeMode.system;

  // Initialize theme service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode');

    if (savedThemeMode != null) {
      // User has previously set a theme preference
      switch (savedThemeMode) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    } else {
      // First launch - use system theme by default
      _themeMode = ThemeMode.system;
    }

    // Update the theme notifier
    themeNotifier.value = _themeMode;
  }

  // Toggle theme immediately without waiting for storage
  void toggleThemeImmediate() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    themeNotifier.value = _themeMode;
  }

  // Set theme mode immediately without waiting for storage
  void setThemeModeImmediate(ThemeMode mode) {
    _themeMode = mode;
    themeNotifier.value = mode;
  }

  // Save theme preference in background
  Future<void> saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();

    // Store the theme mode as a string
    String themeModeString;
    switch (_themeMode) {
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await prefs.setString('themeMode', themeModeString);
  }

  // Toggle between dark and light mode (legacy method)
  Future<void> toggleTheme() async {
    toggleThemeImmediate();
    await saveThemePreference();
    notifyListeners();
  }

  // Set specific theme mode (legacy method)
  Future<void> setThemeMode(ThemeMode mode) async {
    setThemeModeImmediate(mode);
    await saveThemePreference();
    notifyListeners();
  }
}
