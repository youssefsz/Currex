import 'package:flutter/material.dart';
import 'dart:io' show exit;
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'chart_screen.dart';
import 'currency_list_overview_screen.dart';
import 'settings_screen.dart';
import '../utilities/haptic_service.dart';
import '../utilities/responsive_helper.dart';
import '../utilities/theme_animation_overlay.dart';
import '../utilities/localization_helper.dart';
import '../providers/localization_provider.dart';
import '../providers/settings_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isLocalizationInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isLocalizationInitialized) {
      // Initialize localization helper
      L.init(context);

      // Connect providers
      final localizationProvider = Provider.of<LocalizationProvider>(
        context,
        listen: false,
      );
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );
      settingsProvider.setLocalizationProvider(localizationProvider);

      _isLocalizationInitialized = true;
    }
  }

  // List of screens to display
  final List<Widget> _screens = const [
    HomeScreen(),
    ChartScreen(),
    CurrencyListOverviewScreen(),
    SettingsScreen(),
  ];

  // Change selected tab
  void _onItemTapped(int index) {
    HapticService().selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  // Show exit confirmation dialog
  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    final hapticService = HapticService();
    hapticService.mediumImpact();

    final shouldExit = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: theme.colorScheme.surfaceTint,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              L.tr('common.exit_app'),
              style: theme.textTheme.titleLarge,
            ),
            content: Text(
              L.tr('common.exit_confirmation'),
              style: theme.textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  hapticService.lightImpact();
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  L.tr('common.stay'),
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              FilledButton(
                onPressed: () {
                  hapticService.mediumImpact();
                  Navigator.of(context).pop(true);
                },
                child: Text(L.tr('common.exit')),
              ),
            ],
          ),
    );

    if (shouldExit ?? false) {
      exit(0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should use a different layout for desktop/tablet
    final bool isWideScreen =
        ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context);

    // Wrap the layout with a Stack to include the ThemeAnimationOverlay
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          // Main content
          isWideScreen ? _buildWideScreenLayout() : _buildMobileLayout(),

          // Theme animation overlay
          ThemeAnimationOverlay(key: ThemeAnimationOverlay.overlayKey),
        ],
      ),
    );
  }

  // Build layout for mobile screens
  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Build layout for wider screens (tablet/desktop)
  Widget _buildWideScreenLayout() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;

        return Scaffold(
          body: Row(
            children: [
              // Navigation rail on the left
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                labelType: NavigationRailLabelType.selected,
                destinations: [
                  NavigationRailDestination(
                    icon: Image.asset(
                      isDarkMode
                          ? 'assets/icons/not_selected_convert.png'
                          : 'assets/icons/selected_convert.png',
                      width: _calculateRailIconSize(context),
                      height: _calculateRailIconSize(context),
                    ),
                    selectedIcon: Image.asset(
                      'assets/icons/selected_convert.png',
                      width: _calculateRailIconSize(context),
                      height: _calculateRailIconSize(context),
                    ),
                    label: Text(L.tr('navigation.convert')),
                  ),
                  NavigationRailDestination(
                    icon: Image.asset(
                      isDarkMode
                          ? 'assets/icons/not_selected_chart.png'
                          : 'assets/icons/selected_chart.png',
                      width: _calculateRailIconSize(context),
                      height: _calculateRailIconSize(context),
                    ),
                    selectedIcon: Image.asset(
                      'assets/icons/selected_chart.png',
                      width: _calculateRailIconSize(context),
                      height: _calculateRailIconSize(context),
                    ),
                    label: Text(L.tr('navigation.charts')),
                  ),
                  NavigationRailDestination(
                    icon: Image.asset(
                      isDarkMode
                          ? 'assets/icons/not_selected_currency.png'
                          : 'assets/icons/selected_currency.png',
                      width: _calculateRailIconSize(context),
                      height: _calculateRailIconSize(context),
                    ),
                    selectedIcon: Image.asset(
                      'assets/icons/selected_currency.png',
                      width: _calculateRailIconSize(context),
                      height: _calculateRailIconSize(context),
                    ),
                    label: Text(L.tr('navigation.currencies')),
                  ),
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.settings,
                      size: _calculateRailIconSize(context),
                    ),
                    label: Text(L.tr('navigation.settings')),
                  ),
                ],
              ),

              // Vertical divider
              const VerticalDivider(thickness: 1, width: 1),

              // Screen content
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: _screens),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        // Calculate responsive dimensions
        final double navBarHeight = _calculateNavBarHeight(
          screenHeight,
          screenWidth,
        );
        final double iconSize = _calculateIconSize(screenHeight, screenWidth);

        return Container(
          height: navBarHeight,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            height: navBarHeight,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              NavigationDestination(
                icon: Image.asset(
                  isDarkMode
                      ? 'assets/icons/not_selected_convert.png'
                      : 'assets/icons/selected_convert.png',
                  width: iconSize,
                  height: iconSize,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/selected_convert.png',
                  width: iconSize,
                  height: iconSize,
                ),
                label: L.tr('navigation.convert'),
              ),
              NavigationDestination(
                icon: Image.asset(
                  isDarkMode
                      ? 'assets/icons/not_selected_chart.png'
                      : 'assets/icons/selected_chart.png',
                  width: iconSize,
                  height: iconSize,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/selected_chart.png',
                  width: iconSize,
                  height: iconSize,
                ),
                label: L.tr('navigation.charts'),
              ),
              NavigationDestination(
                icon: Image.asset(
                  isDarkMode
                      ? 'assets/icons/not_selected_currency.png'
                      : 'assets/icons/selected_currency.png',
                  width: iconSize,
                  height: iconSize,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/selected_currency.png',
                  width: iconSize,
                  height: iconSize,
                ),
                label: L.tr('navigation.currencies'),
              ),
              NavigationDestination(
                icon: Icon(Icons.settings, size: iconSize),
                label: L.tr('navigation.settings'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Calculate responsive navigation bar height
  double _calculateNavBarHeight(double screenHeight, double screenWidth) {
    // Base height for small screens
    double baseHeight = 60.0;

    // Scale based on screen height, with reasonable limits
    if (screenHeight > 800) {
      baseHeight = 70.0;
    }
    if (screenHeight > 900) {
      baseHeight = 80.0;
    }

    // Additional scaling for very wide screens (like foldable phones in landscape)
    if (screenWidth > 600) {
      baseHeight += 5.0;
    }

    // Ensure minimum and maximum heights
    return baseHeight.clamp(60.0, 90.0);
  }

  // Calculate responsive icon size
  double _calculateIconSize(double screenHeight, double screenWidth) {
    // Base icon size for small screens
    double baseSize = 24.0;

    // Scale based on screen dimensions
    if (screenHeight > 800) {
      baseSize = 26.0;
    }
    if (screenHeight > 900) {
      baseSize = 28.0;
    }

    // Additional scaling for wide screens
    if (screenWidth > 600) {
      baseSize += 2.0;
    }

    // Ensure reasonable limits
    return baseSize.clamp(24.0, 32.0);
  }

  // Calculate responsive icon size for navigation rail
  double _calculateRailIconSize(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Base icon size for rail (slightly larger than bottom nav)
    double baseSize = 26.0;

    // Scale based on screen dimensions
    if (screenHeight > 800) {
      baseSize = 28.0;
    }
    if (screenHeight > 900) {
      baseSize = 30.0;
    }

    // Additional scaling for very wide screens
    if (screenWidth > 1000) {
      baseSize += 2.0;
    }

    // Ensure reasonable limits
    return baseSize.clamp(26.0, 34.0);
  }
}
