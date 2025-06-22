import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../components/language_selector.dart';
import '../components/theme_toggle.dart';
import '../widgets/animated_switch.dart';
import '../utilities/haptic_service.dart';
import '../utilities/localization_helper.dart';

class SettingsSurface extends StatelessWidget {
  const SettingsSurface({super.key});

  // URLs for external links
  final String _aboutUrl = 'https://youssef.tn/Currex/';
  final String _privacyPolicyUrl = 'https://youssef.tn/Currex/privacy-policy';
  final String _termsOfServiceUrl =
      'https://youssef.tn/Currex/terms-of-service';

  @override
  Widget build(BuildContext context) {
    final hapticService = HapticService();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App appearance section
              Text(
                L.tr('settings_screen.appearance'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16.0),

              // Dark mode toggle
              _buildSettingItem(
                context,
                L.tr('settings_screen.dark_mode'),
                Icons.dark_mode,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isDarkMode ? L.tr('common.on') : L.tr('common.off'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ThemeToggle(),
                  ],
                ),
              ),

              const Divider(height: 32.0),

              // Preferences section
              Text(
                L.tr('settings_screen.preferences'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16.0),

              // Haptic feedback toggle
              _buildSettingItem(
                context,
                L.tr('settings_screen.haptic_feedback'),
                Icons.vibration,
                trailing: AnimatedSwitch(
                  value: settingsProvider.isHapticEnabled,
                  onChanged: (value) {
                    if (value) {
                      hapticService.mediumImpact();
                    }
                    settingsProvider.toggleHaptic();
                  },
                ),
              ),

              const SizedBox(height: 16.0),

              // Language selector
              const LanguageSelector(),

              const Divider(height: 32.0),

              // About section
              Text(
                L.tr('settings_screen.about'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16.0),

              // About app
              _buildNavigationItem(
                context,
                L.tr('settings_screen.about'),
                Icons.info_outline,
                onTap: () {
                  hapticService.lightImpact();
                  _launchUrl(_aboutUrl);
                },
              ),

              const SizedBox(height: 16.0),

              // Privacy policy
              _buildNavigationItem(
                context,
                L.tr('settings_screen.privacy_policy'),
                Icons.privacy_tip_outlined,
                onTap: () {
                  hapticService.lightImpact();
                  _launchUrl(_privacyPolicyUrl);
                },
              ),

              const SizedBox(height: 16.0),

              // Terms of service
              _buildNavigationItem(
                context,
                L.tr('settings_screen.terms_of_service'),
                Icons.description_outlined,
                onTap: () {
                  hapticService.lightImpact();
                  _launchUrl(_termsOfServiceUrl);
                },
              ),

              const SizedBox(height: 16.0),

              // App version (moved to last position)
              _buildSettingItem(
                context,
                L.tr('settings_screen.version'),
                Icons.build_outlined,
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String url) async {
    if (!await launchUrlString(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Helper to build a settings item
  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.grey[850]!.withOpacity(0.3)
                : Colors.grey[200]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20.0),
          ),
          const SizedBox(width: 16.0),

          // Title
          Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),

          // Trailing widget
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // Helper to build a navigation item
  Widget _buildNavigationItem(
    BuildContext context,
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.grey[850]!.withOpacity(0.3)
                  : Colors.grey[200]!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20.0),
            ),
            const SizedBox(width: 16.0),

            // Title
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.0,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to show coming soon dialog
  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(L.tr('common.coming_soon')),
            content: Text(
              L.tr('common.feature_coming_soon', args: {'feature': feature}),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(L.tr('common.ok')),
              ),
            ],
          ),
    );
  }
}
