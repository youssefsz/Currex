import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../surfaces/converter_surface.dart';
import '../components/theme_toggle.dart';
import '../utilities/responsive_helper.dart';
import '../utilities/localization_helper.dart';
import '../providers/localization_provider.dart';
import '../providers/currency_provider.dart';
import 'currency_list_screen.dart';
import '../utilities/haptic_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hapticService = HapticService();

    // Set context in currency provider for showing popups
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CurrencyProvider>(context, listen: false).setContext(context);
    });

    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              L.tr('home_screen.title'),
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 20),
              ),
            ),
            actions: [
              // Theme toggle button
              Padding(
                padding: ResponsiveHelper.getAdaptiveValue(
                  context: context,
                  mobile: const EdgeInsets.only(right: 16.0),
                  tablet: const EdgeInsets.only(right: 24.0),
                  desktop: const EdgeInsets.only(right: 32.0),
                ),
                child: ThemeToggle(),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ConverterSurface(
                    onFromCurrencyTap: (currency) {
                      hapticService.lightImpact();
                      _navigateToCurrencyList(context, true);
                    },
                    onToCurrencyTap: (currency) {
                      hapticService.lightImpact();
                      _navigateToCurrencyList(context, false);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Navigate to currency list screen
  void _navigateToCurrencyList(BuildContext context, bool isFrom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyListScreen(isFromCurrency: isFrom),
      ),
    );
  }
}
