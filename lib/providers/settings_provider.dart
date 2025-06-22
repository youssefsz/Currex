import 'package:flutter/material.dart';
import '../utilities/storage_service.dart';
import '../utilities/haptic_service.dart';
import '../utilities/language_service.dart';
import '../utilities/theme_service.dart';
import 'localization_provider.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final HapticService _hapticService = HapticService();
  late LocalizationProvider _localizationProvider;
  final ThemeService _themeService = ThemeService();

  // Getters
  bool get isHapticEnabled => _hapticService.isEnabled;
  bool get isDarkMode => _themeService.isDarkMode;
  String get currentLanguage => _localizationProvider.currentLanguage;
  Map<String, String> get availableLanguages => LanguageService.languages;

  // Set localization provider only if it hasn't been set before
  void setLocalizationProvider(LocalizationProvider provider) {
    if (!_isLocalizationProviderInitialized) {
      _localizationProvider = provider;
    }
  }

  // Check if localization provider is initialized
  bool get _isLocalizationProviderInitialized {
    try {
      // Access the provider to check if it's initialized
      _localizationProvider.currentLanguage;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Initialize provider
  Future<void> init() async {
    // Nothing to initialize here as individual services handle their own initialization
  }

  // Toggle haptic feedback
  Future<void> toggleHaptic() async {
    _hapticService.isEnabled = !_hapticService.isEnabled;
    await _storageService.setBool('hapticEnabled', _hapticService.isEnabled);

    // Provide feedback if enabled
    if (_hapticService.isEnabled) {
      _hapticService.mediumImpact();
    }

    notifyListeners();
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    await _themeService.toggleTheme();
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    await _localizationProvider.changeLanguage(languageCode);
    notifyListeners();
  }
}
