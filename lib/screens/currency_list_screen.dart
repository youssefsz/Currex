import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/currency_item.dart';
import '../widgets/shimmer_loading.dart';
import '../utilities/haptic_service.dart';
import '../utilities/localization_helper.dart';

class CurrencyListScreen extends StatefulWidget {
  final bool isFromCurrency;

  const CurrencyListScreen({super.key, required this.isFromCurrency});

  @override
  State<CurrencyListScreen> createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hapticService = HapticService();
    final theme = Theme.of(context);

    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isFromCurrency
                  ? '${L.tr('home_screen.from')} ${L.tr('currency_list_screen.title_currency')}'
                  : '${L.tr('home_screen.to')} ${L.tr('currency_list_screen.title_currency')}',
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: L.tr('currency_list_screen.all')),
                Tab(text: L.tr('currency_list_screen.favorites')),
                Tab(text: L.tr('currency_list_screen.fiat')),
                Tab(text: L.tr('currency_list_screen.crypto')),
              ],
              onTap: (_) {
                hapticService.selectionClick();
              },
            ),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: L.tr('currency_list_screen.search'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                hapticService.lightImpact();
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              // Currency list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All currencies tab
                    _buildCurrencyList(context, _CurrencyType.all),

                    // Favorites tab
                    _buildCurrencyList(context, _CurrencyType.favorites),

                    // Fiat currencies tab
                    _buildCurrencyList(context, _CurrencyType.fiat),

                    // Crypto currencies tab
                    _buildCurrencyList(context, _CurrencyType.crypto),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build currency list
  Widget _buildCurrencyList(BuildContext context, _CurrencyType type) {
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

        // Filter currencies based on search query and type
        final allCurrencies = currencyProvider.currencies.entries.toList();
        final filteredCurrencies = _filterCurrencies(allCurrencies, type);

        if (filteredCurrencies.isEmpty) {
          return Center(
            child:
                type == _CurrencyType.favorites
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
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
                    )
                    : Text(
                      _searchQuery.isNotEmpty
                          ? L.tr(
                            'currency_list_screen.no_matching',
                            args: {'query': _searchController.text},
                          )
                          : L.tr('currency_list_screen.no_available'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredCurrencies.length,
          itemBuilder: (context, index) {
            final entry = filteredCurrencies[index];
            final currencyCode = entry.key;
            final currencyName = entry.value.toString();
            final isFavorite = currencyProvider.favoriteCurrencies.contains(
              currencyCode,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CurrencyItem(
                code: currencyCode,
                name: currencyName,
                isFavorite: isFavorite,
                onTap: () {
                  _selectCurrency(context, currencyProvider, currencyCode);
                },
                onFavoriteToggle: () {
                  currencyProvider.toggleFavorite(currencyCode);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Filter currencies based on type and search query
  List<MapEntry<String, dynamic>> _filterCurrencies(
    List<MapEntry<String, dynamic>> currencies,
    _CurrencyType type,
  ) {
    // First filter by currency type
    var filteredList =
        currencies.where((entry) {
          final currencyCode = entry.key.toLowerCase();

          switch (type) {
            case _CurrencyType.fiat:
              // Simple heuristic: crypto usually has 3+ chars and starts with a letter
              return currencyCode.length <= 3;
            case _CurrencyType.crypto:
              return currencyCode.length > 3 ||
                  currencyCode == 'btc' ||
                  currencyCode == 'eth' ||
                  currencyCode == 'xrp';
            case _CurrencyType.favorites:
              return Provider.of<CurrencyProvider>(
                context,
                listen: false,
              ).favoriteCurrencies.contains(currencyCode);
            case _CurrencyType.all:
              return true;
          }
        }).toList();

    // Then filter by search query if any
    if (_searchQuery.isNotEmpty) {
      filteredList =
          filteredList.where((entry) {
            final currencyCode = entry.key.toLowerCase();
            final currencyName = entry.value.toString().toLowerCase();

            return currencyCode.contains(_searchQuery) ||
                currencyName.contains(_searchQuery);
          }).toList();
    }

    return filteredList;
  }

  // Select currency and return to previous screen
  void _selectCurrency(
    BuildContext context,
    CurrencyProvider currencyProvider,
    String currencyCode,
  ) {
    final hapticService = HapticService();
    hapticService.mediumImpact();

    if (widget.isFromCurrency) {
      currencyProvider.setFromCurrency(currencyCode);
    } else {
      currencyProvider.setToCurrency(currencyCode);
    }

    Navigator.of(context).pop();
  }
}

// Enum for currency types
enum _CurrencyType { all, favorites, fiat, crypto }
