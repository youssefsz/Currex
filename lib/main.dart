import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'screens/main_navigation.dart';

import 'providers/currency_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/localization_provider.dart';

import 'utilities/language_service.dart';
import 'utilities/storage_service.dart';
import 'utilities/theme_service.dart';
import 'utilities/responsive_helper.dart';
import 'utilities/screen_capture_provider.dart';
import 'utilities/theme_animation_overlay.dart';
import 'theme/app_theme.dart';

void main() async {
  // This is needed to preserve the splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final themeService = ThemeService();
  await themeService.init();

  final languageService = LanguageService();
  await languageService.init();

  runApp(MyApp(themeService: themeService, languageService: languageService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;
  final LanguageService languageService;

  const MyApp({
    super.key,
    required this.themeService,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()..init()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // Set context for responsive theme
          themeService.setContext(context);

          // Set system UI overlay style based on theme using scheduleMicrotask to avoid crashes
          final isDark = themeProvider.isDarkMode;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor:
                    isDark ? const Color(0xFF121622) : const Color(0xFFF8F9FD),
                systemNavigationBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
              ),
            );
          });

          return Consumer2<SettingsProvider, LocalizationProvider>(
            builder: (context, settingsProvider, localizationProvider, _) {
              // Determine if we should lock orientation
              final shouldLockOrientation =
                  !ResponsiveHelper.isDesktop(context);

              if (shouldLockOrientation) {
                // Lock orientation to portrait for smaller screens
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                ]);
              } else {
                // Allow all orientations on larger screens
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]);
              }

              // Remove the splash screen once the app is fully loaded
              FlutterNativeSplash.remove();

              return ScreenCaptureProvider(
                child: MaterialApp(
                  title: localizationProvider.tr('app_name'),
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: localizationProvider.locale,
                  supportedLocales: const [Locale('en'), Locale('fr')],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  home: const MainNavigation(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
