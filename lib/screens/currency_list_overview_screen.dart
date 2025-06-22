import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/localization_provider.dart';
import '../components/theme_toggle.dart';
import '../widgets/currency_item.dart';
import '../widgets/shimmer_loading.dart';
import '../utilities/haptic_service.dart';
import '../utilities/localization_helper.dart';
import 'currency_list_screen.dart';

class CurrencyListOverviewScreen extends StatefulWidget {
  const CurrencyListOverviewScreen({super.key});

  @override
  State<CurrencyListOverviewScreen> createState() =>
      _CurrencyListOverviewScreenState();
}

class _CurrencyListOverviewScreenState extends State<CurrencyListOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hapticService = HapticService();

    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(L.tr('currency_list_screen.title')),
            actions: [
              // Theme toggle button
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ThemeToggle(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: L.tr('currency_list_screen.favorites')),
                Tab(text: L.tr('currency_list_screen.all_currencies')),
              ],
              onTap: (_) {
                hapticService.selectionClick();
              },
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Favorites tab
              _buildFavoritesTab(),

              // All currencies tab
              _buildAllCurrenciesTab(),
            ],
          ),
        );
      },
    );
  }

  // Build favorites tab
  Widget _buildFavoritesTab() {
    return Consumer2<CurrencyProvider, LocalizationProvider>(
      builder: (context, currencyProvider, localizationProvider, child) {
        if (currencyProvider.isLoadingCurrencies) {
          return const ShimmerList(itemCount: 5, itemHeight: 70);
        }

        if (currencyProvider.favoriteCurrencies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  L.tr('currency_list_screen.no_favorites'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  L.tr('currency_list_screen.add_from_all'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Get favorite currencies
        final favoriteCurrencies = currencyProvider.favoriteCurrencies;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteCurrencies.length,
          itemBuilder: (context, index) {
            final currencyCode = favoriteCurrencies[index];
            final currencyName =
                currencyProvider.currencies[currencyCode] ?? currencyCode;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CurrencyItem(
                code: currencyCode,
                name: currencyName.toString(),
                isFavorite: true,
                onTap: () {
                  _showCurrencyDetails(context, currencyCode);
                },
                onFavoriteToggle: () {
                  final hapticService = HapticService();
                  hapticService.mediumImpact();
                  currencyProvider.toggleFavorite(currencyCode);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Build all currencies tab
  Widget _buildAllCurrenciesTab() {
    return Consumer2<CurrencyProvider, LocalizationProvider>(
      builder: (context, currencyProvider, localizationProvider, child) {
        if (currencyProvider.isLoadingCurrencies) {
          return const ShimmerList(itemCount: 10, itemHeight: 70);
        }

        if (currencyProvider.currenciesError != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  L.tr('common.error'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  currencyProvider.currenciesError!,
                  style: TextStyle(color: Colors.red[400], fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => currencyProvider.fetchCurrencies(),
                  child: Text(L.tr('common.try_again')),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Currency list section header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      L.tr('currency_list_screen.all_available'),
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.search, size: 18),
                    label: Text(
                      L.tr('common.search'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    onPressed: () {
                      _navigateToCurrencyList(context);
                    },
                  ),
                ],
              ),
            ),

            // Currency list preview
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: currencyProvider.currencies.entries.length.clamp(
                  0,
                  15,
                ),
                itemBuilder: (context, index) {
                  final entries = currencyProvider.currencies.entries.toList();
                  if (index >= entries.length) return const SizedBox();

                  final entry = entries[index];
                  final currencyCode = entry.key;
                  final currencyName = entry.value.toString();
                  final isFavorite = currencyProvider.favoriteCurrencies
                      .contains(currencyCode);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CurrencyItem(
                      code: currencyCode,
                      name: currencyName,
                      isFavorite: isFavorite,
                      onTap: () {
                        _showCurrencyDetails(context, currencyCode);
                      },
                      onFavoriteToggle: () {
                        final hapticService = HapticService();
                        hapticService.mediumImpact();
                        currencyProvider.toggleFavorite(currencyCode);
                      },
                    ),
                  );
                },
              ),
            ),

            // View all button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToCurrencyList(context);
                  },
                  child: Text(L.tr('currency_list_screen.view_all')),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Navigate to currency list
  void _navigateToCurrencyList(BuildContext context) {
    final hapticService = HapticService();
    hapticService.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrencyListScreen(isFromCurrency: true),
      ),
    );
  }

  // Show currency details
  void _showCurrencyDetails(BuildContext context, String currencyCode) {
    final hapticService = HapticService();
    hapticService.lightImpact();

    // In a real app, this would navigate to a detailed view for the currency

    final theme = Theme.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(
      context,
      listen: false,
    );
    final currencyName =
        currencyProvider.currencies[currencyCode] ?? currencyCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Currency details
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currencyCode.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        currencyName.toString(),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Set as From currency
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.arrow_upward),
                        label: Text(L.tr('currency_list_screen.set_as_from')),
                        onPressed: () {
                          hapticService.mediumImpact();
                          currencyProvider.setFromCurrency(currencyCode);
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Set as To currency
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.arrow_downward),
                        label: Text(L.tr('currency_list_screen.set_as_to')),
                        onPressed: () {
                          hapticService.mediumImpact();
                          currencyProvider.setToCurrency(currencyCode);
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
