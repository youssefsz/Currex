import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utilities/haptic_service.dart';
import '../utilities/responsive_helper.dart';
import '../utilities/localization_helper.dart';
import 'package:shimmer/shimmer.dart';

class CurrencyCard extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double convertedAmount;
  final double exchangeRate;
  final VoidCallback onSwap;
  final Function(String) onFromCurrencyTap;
  final Function(String) onToCurrencyTap;
  final Function(double) onAmountChanged;
  final bool isLoading;
  final String? errorMessage;

  const CurrencyCard({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.amount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.onSwap,
    required this.onFromCurrencyTap,
    required this.onToCurrencyTap,
    required this.onAmountChanged,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends State<CurrencyCard>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _amountController;

  // Copy animation state
  bool _isCopied = false;
  late AnimationController _copyAnimationController;
  late Animation<double> _copyScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize copy animation controller
    _copyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _copyScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _copyAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _amountController = TextEditingController(
      text: _formatAmount(widget.amount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _copyAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CurrencyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _amountController.text = _formatAmount(widget.amount);
    }
  }

  String _formatAmount(double amount) {
    // Only show decimal if it's not a whole number
    return amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
  }

  /// Handles the copy action with a subtle animation feedback
  void _handleCopy(HapticService hapticService) {
    // Copy to clipboard
    Clipboard.setData(
      ClipboardData(text: widget.convertedAmount.toStringAsFixed(6)),
    );

    // Trigger haptic feedback
    hapticService.lightImpact();

    // Play the scale animation
    _copyAnimationController.forward().then((_) {
      _copyAnimationController.reverse();
    });

    // Update state to show checkmark
    setState(() {
      _isCopied = true;
    });

    // Reset back to copy icon after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hapticService = HapticService();
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getAdaptiveValue(
            context: context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        ),
      ),
      child: Padding(
        padding: ResponsiveHelper.getPadding(
          context,
          mobile: const EdgeInsets.all(16.0),
          tablet: const EdgeInsets.all(24.0),
          desktop: const EdgeInsets.all(32.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount input field
            TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: ResponsiveHelper.getFontSize(context, 24),
              ),
              controller: _amountController,
              onChanged: (value) {
                if (value.isEmpty) {
                  widget.onAmountChanged(1.0);
                } else {
                  try {
                    // Allow both integer and decimal input
                    final newAmount = double.parse(value);
                    if (newAmount >= 0) {
                      // Only allow positive numbers
                      widget.onAmountChanged(newAmount);
                    }
                  } catch (_) {
                    // Invalid input - ignore
                  }
                }
              },
              decoration: InputDecoration(
                labelText: L.tr('currency_card.amount'),
                labelStyle: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getAdaptiveValue(
                      context: context,
                      mobile: 12.0,
                      tablet: 16.0,
                      desktop: 20.0,
                    ),
                  ),
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                  size: ResponsiveHelper.getAdaptiveValue(
                    context: context,
                    mobile: 24.0,
                    tablet: 28.0,
                    desktop: 32.0,
                  ),
                ),
                suffixText: widget.fromCurrency.toUpperCase(),
                suffixStyle: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                ),
              ),
            ),

            SizedBox(
              height: ResponsiveHelper.getAdaptiveValue(
                context: context,
                mobile: 24.0,
                tablet: 32.0,
                desktop: 40.0,
              ),
            ),

            // Currency selectors and swap button
            _buildCurrencySelectors(context, hapticService, isDarkMode, theme),

            SizedBox(
              height: ResponsiveHelper.getAdaptiveValue(
                context: context,
                mobile: 24.0,
                tablet: 32.0,
                desktop: 40.0,
              ),
            ),

            // Result section
            if (widget.isLoading)
              _buildLoadingShimmer(context, theme, isDarkMode)
            else if (widget.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(
                      color: Colors.red[400],
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                    ),
                  ),
                ),
              )
            else
              _buildResultSection(context, theme, isDarkMode, hapticService),
          ],
        ),
      ),
    );
  }

  // Helper to build currency selectors section
  Widget _buildCurrencySelectors(
    BuildContext context,
    HapticService hapticService,
    bool isDarkMode,
    ThemeData theme,
  ) {
    // For tablet and desktop, use horizontal layout with more space
    if (ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context)) {
      return Row(
        children: [
          // From currency selector
          Expanded(
            child: _buildCurrencySelector(
              context,
              'From',
              widget.fromCurrency,
              () {
                hapticService.lightImpact();
                widget.onFromCurrencyTap(widget.fromCurrency);
              },
            ),
          ),

          // Swap button
          Container(
            width: ResponsiveHelper.getAdaptiveValue(
              context: context,
              mobile: 48.0,
              tablet: 60.0,
              desktop: 72.0,
            ),
            height: ResponsiveHelper.getAdaptiveValue(
              context: context,
              mobile: 48.0,
              tablet: 60.0,
              desktop: 72.0,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getAdaptiveValue(
                context: context,
                mobile: 16.0,
                tablet: 24.0,
                desktop: 32.0,
              ),
            ),

            child: _buildSwapButton(hapticService, theme),
          ),

          // To currency selector
          Expanded(
            child: _buildCurrencySelector(context, 'To', widget.toCurrency, () {
              hapticService.lightImpact();
              widget.onToCurrencyTap(widget.toCurrency);
            }),
          ),
        ],
      );
    } else {
      // For mobile, use default layout
      return Row(
        children: [
          // From currency selector
          Expanded(
            child: _buildCurrencySelector(
              context,
              'From',
              widget.fromCurrency,
              () {
                hapticService.lightImpact();
                widget.onFromCurrencyTap(widget.fromCurrency);
              },
            ),
          ),

          // Swap button
          GestureDetector(
            onTap: () {
              hapticService.mediumImpact();
              HapticFeedback.mediumImpact();
              widget.onSwap();
            },
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),

              child: _buildSwapButton(hapticService, theme),
            ),
          ),

          // To currency selector
          Expanded(
            child: _buildCurrencySelector(context, 'To', widget.toCurrency, () {
              hapticService.lightImpact();
              widget.onToCurrencyTap(widget.toCurrency);
            }),
          ),
        ],
      );
    }
  }

  // Helper to build swap button
  Widget _buildSwapButton(HapticService hapticService, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        hapticService.mediumImpact();
        HapticFeedback.mediumImpact();
        widget.onSwap();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 0),
        key: ValueKey<String>('${widget.fromCurrency}-${widget.toCurrency}'),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 3.14159,
            child: Icon(
              Icons.swap_horiz,
              color: theme.colorScheme.primary,
              size: ResponsiveHelper.getAdaptiveValue(
                context: context,
                mobile: 32.0,
                tablet: 40.0,
                desktop: 48.0,
              ),
            ),
          );
        },
        onEnd: () {},
      ),
    );
  }

  // Helper to build result section
  Widget _buildResultSection(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    HapticService hapticService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Exchange rate
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                L.tr('currency_card.exchange_rate'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                ),
              ),
              Text(
                '1 ${widget.fromCurrency.toUpperCase()} = ${widget.exchangeRate.toStringAsFixed(6)} ${widget.toCurrency.toUpperCase()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: ResponsiveHelper.getAdaptiveValue(
            context: context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        ),

        // Converted amount
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                L.tr('currency_card.converted_amount'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: widget.convertedAmount.toStringAsFixed(6),
                    ),
                  );
                  hapticService.lightImpact();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.convertedAmount.toStringAsFixed(4),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: ResponsiveHelper.getFontSize(context, 20),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.toCurrency.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[700],
                          fontSize: ResponsiveHelper.getFontSize(context, 16),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    ScaleTransition(
                      scale: _copyScaleAnimation,
                      child: OutlinedButton.icon(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            _isCopied ? Icons.check : Icons.content_copy,
                            key: ValueKey<bool>(_isCopied),
                            size: 16,
                            color:
                                _isCopied
                                    ? Colors.green
                                    : theme.colorScheme.primary,
                          ),
                        ),
                        label: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isCopied
                                ? L.tr('currency_card.copied')
                                : L.tr('currency_card.copy'),
                            key: ValueKey<bool>(_isCopied),
                            style: TextStyle(
                              color: _isCopied ? Colors.green : null,
                            ),
                          ),
                        ),
                        onPressed: () => _handleCopy(hapticService),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: Container(
        padding: ResponsiveHelper.getPadding(
          context,
          mobile: const EdgeInsets.all(12),
          tablet: const EdgeInsets.all(16),
          desktop: const EdgeInsets.all(20),
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getAdaptiveValue(
              context: context,
              mobile: 12.0,
              tablet: 16.0,
              desktop: 20.0,
            ),
          ),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label == 'From'
                  ? L.tr('currency_card.from')
                  : L.tr('currency_card.to'),
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: ResponsiveHelper.getFontSize(context, 14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    currencyCode.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.primary,
                  size: ResponsiveHelper.getAdaptiveValue(
                    context: context,
                    mobile: 24.0,
                    tablet: 28.0,
                    desktop: 32.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build loading shimmer
  Widget _buildLoadingShimmer(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Exchange rate shimmer
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Exchange rate label shimmer
                Container(
                  width: ResponsiveHelper.getAdaptiveValue(
                    context: context,
                    mobile: 100,
                    tablet: 120,
                    desktop: 140,
                  ),
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Rate value shimmer
                Container(
                  width: ResponsiveHelper.getAdaptiveValue(
                    context: context,
                    mobile: 160,
                    tablet: 180,
                    desktop: 200,
                  ),
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(
          height: ResponsiveHelper.getAdaptiveValue(
            context: context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        ),

        // Converted amount shimmer
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            child: Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Converted amount label shimmer
                Container(
                  width: ResponsiveHelper.getAdaptiveValue(
                    context: context,
                    mobile: 120,
                    tablet: 140,
                    desktop: 160,
                  ),
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Amount value shimmer
                Container(
                  width: ResponsiveHelper.getAdaptiveValue(
                    context: context,
                    mobile: 140,
                    tablet: 160,
                    desktop: 180,
                  ),
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
