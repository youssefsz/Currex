import 'package:flutter/material.dart';
import '../utilities/responsive_helper.dart';
import '../utilities/localization_helper.dart';

class ConnectionErrorPopup extends StatelessWidget {
  final VoidCallback? onRetry;

  const ConnectionErrorPopup({super.key, this.onRetry});

  // Show the popup as an overlay
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConnectionErrorPopup(onRetry: onRetry);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor:
          isDarkMode ? theme.colorScheme.surface : theme.colorScheme.surface,
      title: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: theme.colorScheme.error,
            size: ResponsiveHelper.getAdaptiveValue(
              context: context,
              mobile: 24.0,
              tablet: 28.0,
              desktop: 32.0,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            L.tr('connection_error.title'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
            ),
          ),
        ],
      ),
      content: Text(
        L.tr('connection_error.message'),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: ResponsiveHelper.getFontSize(context, 16),
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text(
              L.tr('common.try_again'),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: ResponsiveHelper.getFontSize(context, 16),
              ),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            L.tr('common.ok'),
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
            ),
          ),
        ),
      ],
    );
  }
}
