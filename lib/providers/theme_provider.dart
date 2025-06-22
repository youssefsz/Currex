import 'package:flutter/material.dart';
import '../utilities/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();

  // Getters
  ThemeData get theme => _themeService.getTheme();
  ThemeMode get themeMode => _themeService.getThemeMode();
  bool get isDarkMode => _themeService.isDarkMode;
  bool get isSystemTheme => _themeService.isSystemTheme;
  ValueNotifier<ThemeMode> get themeNotifier => _themeService.themeNotifier;

  // Initialize provider
  Future<void> init() async {
    await _themeService.init();
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    // Update theme immediately
    _themeService.toggleThemeImmediate();
    notifyListeners();

    // Save preference in background
    _themeService.saveThemePreference();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    // Update theme immediately
    _themeService.setThemeModeImmediate(mode);
    notifyListeners();

    // Save preference in background
    _themeService.saveThemePreference();
  }

  // Toggle system theme
  Future<void> toggleSystemTheme() async {
    ThemeMode newMode;
    if (isSystemTheme) {
      // If already using system theme, switch to appropriate manual theme based on platform brightness
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      newMode =
          platformBrightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light;
    } else {
      // If using manual theme, switch to system theme
      newMode = ThemeMode.system;
    }

    await setThemeMode(newMode);
  }
}
