import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utilities/haptic_service.dart';
import '../utilities/localization_helper.dart';

class ChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String period;
  final Function(String) onPeriodChanged;
  final String fromCurrency;
  final String toCurrency;
  final bool isLoading;

  const ChartWidget({
    super.key,
    required this.data,
    required this.period,
    required this.onPeriodChanged,
    required this.fromCurrency,
    required this.toCurrency,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hapticService = HapticService();
    final isDarkMode = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return Center(
        child: Text(
          L.tr('chart_widget.no_data'),
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    // Get min and max values for the y-axis
    final List<double> rates = data.map((e) => e['rate'] as double).toList();
    final double minY = (rates.reduce((a, b) => a < b ? a : b) * 0.995);
    final double maxY = (rates.reduce((a, b) => a > b ? a : b) * 1.005);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart title
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.titleMedium,
              children: [
                TextSpan(
                  text:
                      '${fromCurrency.toUpperCase()}/${toCurrency.toUpperCase()} ',
                ),
                TextSpan(
                  text: _getPeriodLabel(period),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Chart
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _getInterval(),
                    getTitlesWidget: (value, meta) {
                      if (value < 0 || value >= data.length) {
                        return const SizedBox();
                      }

                      final date = data[value.toInt()]['date'] as String;
                      final parts = date.split('-');

                      // Simplified date formatting based on period
                      String label;
                      if (period == '1d') {
                        // Show hours for 1 day
                        label = '${value.toInt() * 2}h';
                      } else if (period == '1w') {
                        // Show day of week for 1 week
                        label = parts[2];
                      } else {
                        // Show month/day for longer periods
                        label = '${parts[1]}/${parts[2]}';
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          label,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxY - minY) / 5,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toStringAsFixed(4),
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                  left: BorderSide(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                ),
              ),
              minX: 0,
              maxX: data.length.toDouble() - 1,
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (LineBarSpot touchedSpot) {
                    final value = touchedSpot.y;
                    if (value < 30) {
                      return Colors.red.withOpacity(0.8);
                    } else if (value < 70) {
                      return Colors.orange.withOpacity(0.8);
                    } else {
                      return Colors.green.withOpacity(0.8);
                    }
                  },
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = data[spot.x.toInt()]['date'] as String;
                      return LineTooltipItem(
                        '$date\n',
                        TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${spot.y.toStringAsFixed(6)} ${toCurrency.toUpperCase()}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                touchCallback: (
                  FlTouchEvent event,
                  LineTouchResponse? touchResponse,
                ) {
                  if (event is FlTapUpEvent) {
                    hapticService.lightImpact();
                  }
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(data.length, (index) {
                    return FlSpot(
                      index.toDouble(),
                      data[index]['rate'] as double,
                    );
                  }),
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.3),
                        theme.colorScheme.primary.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Time period selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPeriodButton(context, '1d', hapticService),
            _buildPeriodButton(context, '1w', hapticService),
            _buildPeriodButton(context, '1m', hapticService),
            _buildPeriodButton(context, '3m', hapticService),
            _buildPeriodButton(context, '6m', hapticService),
            _buildPeriodButton(context, '1y', hapticService),
          ],
        ),
      ],
    );
  }

  // Helper to build period selector buttons
  Widget _buildPeriodButton(
    BuildContext context,
    String periodValue,
    HapticService hapticService,
  ) {
    final theme = Theme.of(context);
    final isSelected = period == periodValue;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          hapticService.selectionClick();
          onPeriodChanged(periodValue);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          _getPeriodButtonLabel(periodValue),
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Helper to get the chart interval based on period
  double _getInterval() {
    switch (period) {
      case '1d':
        return 4;
      case '1w':
        return 1;
      case '1m':
        return 5;
      case '3m':
        return 15;
      case '6m':
        return 30;
      case '1y':
        return 60;
      default:
        return 5;
    }
  }

  // Helper to get the period button label
  String _getPeriodButtonLabel(String periodValue) {
    switch (periodValue) {
      case '1d':
        return '1D';
      case '1w':
        return '1W';
      case '1m':
        return '1M';
      case '3m':
        return '3M';
      case '6m':
        return '6M';
      case '1y':
        return '1Y';
      default:
        return periodValue;
    }
  }

  // Helper to get the period description
  String _getPeriodLabel(String period) {
    switch (period) {
      case '1d':
        return L.tr('chart_widget.day');
      case '1w':
        return L.tr('chart_widget.week');
      case '1m':
        return L.tr('chart_widget.month');
      case '3m':
        return L.tr('chart_widget.three_months');
      case '1y':
        return L.tr('chart_widget.year');
      default:
        return 'Custom Period';
    }
  }
}
