import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utilities/haptic_service.dart';
import '../widgets/animated_theme_switch.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnimatedThemeSwitch();
  }
}
