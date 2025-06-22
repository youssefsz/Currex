import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  // Singleton instance
  static final LanguageService _instance = LanguageService._internal();

  // Available languages
  static const Map<String, String> languages = {
    'en': 'English',
    'fr': 'Français',
  };

  // Current language
  String _currentLanguage = 'en';

  // Translation data
  Map<String, dynamic> _translations = {};

  // Factory constructor
  factory LanguageService() {
    return _instance;
  }

  // Internal constructor
  LanguageService._internal();

  // Getter for current language
  String get currentLanguage => _currentLanguage;

  // Initialize language service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
    await loadTranslations();
  }

  // Load translations for current language
  Future<void> loadTranslations() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/lang/$_currentLanguage.json',
      );
      _translations = json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading translations: $e');
      // Fallback to English
      final jsonString = await rootBundle.loadString('assets/lang/en.json');
      _translations = json.decode(jsonString);
    }
  }

  // Change current language
  Future<void> changeLanguage(String languageCode) async {
    if (languages.containsKey(languageCode)) {
      _currentLanguage = languageCode;

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);

      // Reload translations
      await loadTranslations();
    }
  }

  // Get translation by key
  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }

    if (value is String) {
      return value;
    }

    return key; // Return key if translation is not a string
  }

  // Get the appropriate locale
  Locale getLocale() {
    return Locale(_currentLanguage);
  }
}
