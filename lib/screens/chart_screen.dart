import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../surfaces/chart_surface.dart';
import '../components/theme_toggle.dart';
import '../utilities/haptic_service.dart';
import '../utilities/localization_helper.dart';
import '../providers/localization_provider.dart';
import 'currency_list_screen.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hapticService = HapticService();

    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(L.tr('chart_screen.title')),
            actions: [
              // Theme toggle button
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ThemeToggle(),
              ),
            ],
          ),
          body: ChartSurface(
            onFromCurrencyTap: (currency) {
              hapticService.lightImpact();
              _navigateToCurrencyList(context, true);
            },
            onToCurrencyTap: (currency) {
              hapticService.lightImpact();
              _navigateToCurrencyList(context, false);
            },
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
