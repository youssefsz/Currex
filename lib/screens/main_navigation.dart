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
                      width: 24,
                      height: 24,
                    ),
                    selectedIcon: Image.asset(
                      'assets/icons/selected_convert.png',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(L.tr('navigation.convert')),
                  ),
                  NavigationRailDestination(
                    icon: Image.asset(
                      isDarkMode
                          ? 'assets/icons/not_selected_chart.png'
                          : 'assets/icons/selected_chart.png',
                      width: 24,
                      height: 24,
                    ),
                    selectedIcon: Image.asset(
                      'assets/icons/selected_chart.png',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(L.tr('navigation.charts')),
                  ),
                  NavigationRailDestination(
                    icon: Image.asset(
                      isDarkMode
                          ? 'assets/icons/not_selected_currency.png'
                          : 'assets/icons/selected_currency.png',
                      width: 24,
                      height: 24,
                    ),
                    selectedIcon: Image.asset(
                      'assets/icons/selected_currency.png',
                      width: 24,
                      height: 24,
                    ),
                    label: Text(L.tr('navigation.currencies')),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings),
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

        return Container(
          height: 60, // Reduced from default height
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
            height: 60, // Reduced from default height
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: [
              NavigationDestination(
                icon: Image.asset(
                  isDarkMode
                      ? 'assets/icons/not_selected_convert.png'
                      : 'assets/icons/selected_convert.png',
                  width: 24,
                  height: 24,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/selected_convert.png',
                  width: 24,
                  height: 24,
                ),
                label: L.tr('navigation.convert'),
              ),
              NavigationDestination(
                icon: Image.asset(
                  isDarkMode
                      ? 'assets/icons/not_selected_chart.png'
                      : 'assets/icons/selected_chart.png',
                  width: 24,
                  height: 24,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/selected_chart.png',
                  width: 24,
                  height: 24,
                ),
                label: L.tr('navigation.charts'),
              ),
              NavigationDestination(
                icon: Image.asset(
                  isDarkMode
                      ? 'assets/icons/not_selected_currency.png'
                      : 'assets/icons/selected_currency.png',
                  width: 24,
                  height: 24,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/selected_currency.png',
                  width: 24,
                  height: 24,
                ),
                label: L.tr('navigation.currencies'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings),
                label: L.tr('navigation.settings'),
              ),
            ],
          ),
        );
      },
    );
  }
}
