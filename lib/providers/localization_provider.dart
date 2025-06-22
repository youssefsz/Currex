import 'package:flutter/material.dart';
import '../utilities/language_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();

  // Get translation instance
  LanguageService get languageService => _languageService;

  // Get current locale
  Locale get locale => _languageService.getLocale();

  // Get current language code
  String get currentLanguage => _languageService.currentLanguage;

  // Get available languages
  Map<String, String> get availableLanguages => LanguageService.languages;

  // Initialize provider
  Future<void> init() async {
    await _languageService.init();
  }

  // Change language and notify listeners
  Future<void> changeLanguage(String languageCode) async {
    await _languageService.changeLanguage(languageCode);
    notifyListeners();
  }

  // Get translation by key
  String tr(String key, {Map<String, String>? args}) {
    String value = _languageService.translate(key);

    // Replace arguments if provided
    if (args != null) {
      args.forEach((argKey, argValue) {
        value = value.replaceAll('{$argKey}', argValue);
      });
    }

    return value;
  }
}
