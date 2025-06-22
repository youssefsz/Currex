import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/localization_provider.dart';
import '../utilities/haptic_service.dart';
import '../utilities/localization_helper.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final hapticService = HapticService();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Consumer2<SettingsProvider, LocalizationProvider>(
      builder: (context, settingsProvider, localizationProvider, child) {
        final currentLanguage = localizationProvider.currentLanguage;
        final languages = localizationProvider.availableLanguages;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L.tr('settings_screen.language'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Language options
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: languages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final languageCode = languages.keys.elementAt(index);
                final languageName = languages[languageCode]!;
                final isSelected = currentLanguage == languageCode;

                return InkWell(
                  onTap: () {
                    if (!isSelected) {
                      hapticService.lightImpact();
                      localizationProvider.changeLanguage(languageCode);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : isDarkMode
                              ? Colors.grey[850]!.withOpacity(0.3)
                              : Colors.grey[100]!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isSelected
                              ? Border.all(color: theme.colorScheme.primary)
                              : null,
                    ),
                    child: Row(
                      children: [
                        // Language emoji flag (simple representation)
                        Text(
                          languageCode == 'en' ? '🇬🇧' : '🇫🇷',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 16),

                        // Language name
                        Expanded(
                          child: Text(
                            languageName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),

                        // Selected indicator
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
