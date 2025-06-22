import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../surfaces/settings_surface.dart';
import '../utilities/localization_helper.dart';
import '../providers/localization_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, _) {
        return Scaffold(
          appBar: AppBar(title: Text(L.tr('settings_screen.title'))),
          body: const SettingsSurface(),
        );
      },
    );
  }
}
