import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/chart_widget.dart';
import '../providers/currency_provider.dart';
import '../widgets/shimmer_loading.dart';
import '../utilities/api_service.dart';
import '../utilities/localization_helper.dart';

class ChartSurface extends StatefulWidget {
  final Function(String) onFromCurrencyTap;
  final Function(String) onToCurrencyTap;

  const ChartSurface({
    super.key,
    required this.onFromCurrencyTap,
    required this.onToCurrencyTap,
  });

  @override
  State<ChartSurface> createState() => _ChartSurfaceState();
}

class _ChartSurfaceState extends State<ChartSurface> {
  final ApiService _apiService = ApiService();

  String _period = '1m';
  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refetch data when currency changes
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    if (currencyProvider.fromCurrency.isNotEmpty &&
        currencyProvider.toCurrency.isNotEmpty) {
      _fetchChartData();
    }
  }

  Future<void> _fetchChartData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );
      final data = await _apiService.getMockHistoricalData(
        currencyProvider.fromCurrency,
        currencyProvider.toCurrency,
        _period,
      );

      if (!mounted) return;

      setState(() {
        _chartData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changePeriod(String period) {
    setState(() {
      _period = period;
    });
    _fetchChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Currency selector column with flip switch
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 250, // Fixed width for consistency
                  child: Column(
                    children: [
                      _buildCurrencySelector(
                        context,
                        'From Currency',
                        currencyProvider.fromCurrency,
                        () => widget.onFromCurrencyTap(
                          currencyProvider.fromCurrency,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Flip switch button
                      IconButton(
                        onPressed: () {
                          final temp = currencyProvider.fromCurrency;
                          currencyProvider.setFromCurrency(
                            currencyProvider.toCurrency,
                          );
                          currencyProvider.setToCurrency(temp);
                        },
                        icon: const Icon(Icons.swap_vert),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCurrencySelector(
                        context,
                        'To Currency',
                        currencyProvider.toCurrency,
                        () =>
                            widget.onToCurrencyTap(currencyProvider.toCurrency),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Chart widget
            Expanded(
              child:
                  _error != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              L.tr('chart.error_loading'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchChartData,
                              child: Text(L.tr('chart.try_again')),
                            ),
                          ],
                        ),
                      )
                      : _isLoading
                      ? const ShimmerChart()
                      : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ChartWidget(
                          data: _chartData,
                          period: _period,
                          onPeriodChanged: _changePeriod,
                          fromCurrency: currencyProvider.fromCurrency,
                          toCurrency: currencyProvider.toCurrency,
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }

  // Helper to build currency selector
  Widget _buildCurrencySelector(
    BuildContext context,
    String label,
    String currencyCode,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.grey[850]!.withOpacity(0.3)
                  : Colors.grey[100]!,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currencyCode.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label == 'From Currency'
                        ? L.tr('chart.from_currency')
                        : L.tr('chart.to_currency'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Row(
      children: [
        _buildPeriodOption(context, '1d', L.tr('chart.day')),
        _buildPeriodOption(context, '1w', L.tr('chart.week')),
        _buildPeriodOption(context, '1m', L.tr('chart.month')),
        _buildPeriodOption(context, '3m', L.tr('chart.three_months')),
        _buildPeriodOption(context, '1y', L.tr('chart.year')),
      ],
    );
  }

  Widget _buildPeriodOption(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    final isSelected = _period == value;

    return InkWell(
      onTap: () => _changePeriod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
