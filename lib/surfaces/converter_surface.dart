import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../components/currency_card.dart';
import '../widgets/shimmer_loading.dart';
import '../utilities/responsive_helper.dart';
import '../utilities/localization_helper.dart';

class ConverterSurface extends StatelessWidget {
  final Function(String) onFromCurrencyTap;
  final Function(String) onToCurrencyTap;

  const ConverterSurface({
    super.key,
    required this.onFromCurrencyTap,
    required this.onToCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.getAdaptiveContainerWidth(context),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Currency converter card
                      Padding(
                        padding: ResponsiveHelper.getPadding(
                          context,
                          mobile: const EdgeInsets.all(16.0),
                          tablet: const EdgeInsets.all(20.0),
                          desktop: const EdgeInsets.all(24.0),
                        ),
                        child:
                            currencyProvider.isLoadingCurrencies
                                ? ShimmerCard(
                                  height: 300,
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                )
                                : CurrencyCard(
                                  fromCurrency: currencyProvider.fromCurrency,
                                  toCurrency: currencyProvider.toCurrency,
                                  amount: currencyProvider.amount,
                                  convertedAmount:
                                      currencyProvider.convertedAmount,
                                  exchangeRate: currencyProvider.exchangeRate,
                                  onSwap:
                                      () => currencyProvider.swapCurrencies(),
                                  onFromCurrencyTap: onFromCurrencyTap,
                                  onToCurrencyTap: onToCurrencyTap,
                                  onAmountChanged:
                                      (amount) =>
                                          currencyProvider.setAmount(amount),
                                  isLoading: currencyProvider.isLoadingRate,
                                  errorMessage: currencyProvider.rateError,
                                ),
                      ),

                      // Recent conversions section
                      Padding(
                        padding: ResponsiveHelper.getPadding(
                          context,
                          mobile: const EdgeInsets.symmetric(horizontal: 16.0),
                          tablet: const EdgeInsets.symmetric(horizontal: 20.0),
                          desktop: const EdgeInsets.symmetric(horizontal: 24.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              L.tr('converter.recent_conversions'),
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontSize: ResponsiveHelper.getFontSize(
                                  context,
                                  18,
                                ),
                              ),
                            ),
                            if (currencyProvider.recentConversions.isNotEmpty)
                              TextButton(
                                onPressed:
                                    () =>
                                        currencyProvider
                                            .clearRecentConversions(),
                                child: Text(
                                  L.tr('converter.clear_all'),
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Recent conversions list
                      SizedBox(
                        height: 300, // Fixed height for the list
                        child:
                            currencyProvider.isLoadingCurrencies
                                ? ShimmerList(itemCount: 3, itemHeight: 80)
                                : currencyProvider.recentConversions.isEmpty
                                ? Center(
                                  child: Text(
                                    L.tr('converter.no_recent_conversions'),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      fontSize: ResponsiveHelper.getFontSize(
                                        context,
                                        16,
                                      ),
                                    ),
                                  ),
                                )
                                : _buildResponsiveConversionsList(
                                  context,
                                  currencyProvider.recentConversions,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper to build responsive recent conversions list
  Widget _buildResponsiveConversionsList(
    BuildContext context,
    List<Map<String, dynamic>> conversions,
  ) {
    if (ResponsiveHelper.isDesktop(context) ||
        ResponsiveHelper.isTablet(context)) {
      // Grid layout for tablet and desktop
      return GridView.builder(
        padding: ResponsiveHelper.getPadding(context),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.getAdaptiveGridCount(context),
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: conversions.length,
        itemBuilder: (context, index) {
          return _buildRecentConversionItem(context, conversions[index]);
        },
      );
    } else {
      // List layout for mobile
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: conversions.length,
        itemBuilder: (context, index) {
          return _buildRecentConversionItem(context, conversions[index]);
        },
      );
    }
  }

  // Helper to build recent conversion item
  Widget _buildRecentConversionItem(
    BuildContext context,
    Map<String, dynamic> conversion,
  ) {
    final fromCurrency = conversion['fromCurrency'] as String;
    final toCurrency = conversion['toCurrency'] as String;
    final amount = conversion['amount'] as double;
    final convertedAmount = conversion['convertedAmount'] as double;
    final date = conversion['date'] as String;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conversion summary
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // From amount
                Flexible(
                  child: Text(
                    '${amount.toStringAsFixed(2)} ${fromCurrency.toUpperCase()}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Arrow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_forward,
                    size: ResponsiveHelper.getAdaptiveValue(
                      context: context,
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),

                // To amount
                Flexible(
                  child: Text(
                    '${convertedAmount.toStringAsFixed(2)} ${toCurrency.toUpperCase()}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8.0),

            // Date
            Text(
              'Date: $date',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 12),
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
