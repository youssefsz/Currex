import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/localization_provider.dart';

class L {
  // Private constructor to prevent instantiation
  L._();

  // Context to access the provider
  static late BuildContext _context;

  // Initialize with context
  static void init(BuildContext context) {
    _context = context;
  }

  // Translation lookup
  static String tr(String key, {Map<String, String>? args}) {
    try {
      return Provider.of<LocalizationProvider>(
        _context,
        listen: false,
      ).tr(key, args: args);
    } catch (e) {
      debugPrint('Error translating $key: $e');
      return key;
    }
  }

  // Get the current locale
  static Locale get locale {
    try {
      return Provider.of<LocalizationProvider>(_context, listen: false).locale;
    } catch (e) {
      debugPrint('Error getting locale: $e');
      return const Locale('en');
    }
  }

  // Get the current language code
  static String get currentLanguage {
    try {
      return Provider.of<LocalizationProvider>(
        _context,
        listen: false,
      ).currentLanguage;
    } catch (e) {
      debugPrint('Error getting current language: $e');
      return 'en';
    }
  }

  // Check if the current language is the specified one
  static bool isLang(String code) {
    return currentLanguage == code;
  }

  // Change the app language
  static Future<void> changeLanguage(String code) async {
    try {
      await Provider.of<LocalizationProvider>(
        _context,
        listen: false,
      ).changeLanguage(code);
    } catch (e) {
      debugPrint('Error changing language to $code: $e');
    }
  }
}
