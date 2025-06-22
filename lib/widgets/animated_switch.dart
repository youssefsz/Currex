import 'package:flutter/material.dart';
import '../utilities/haptic_service.dart';

class AnimatedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final double width;
  final double height;
  final Widget? activeIcon;
  final Widget? inactiveIcon;

  const AnimatedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.width = 60.0,
    this.height = 30.0,
    this.activeIcon,
    this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hapticService = HapticService();

    final actualActiveColor = activeColor ?? theme.colorScheme.primary;
    final actualInactiveColor =
        inactiveColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey[700]
            : Colors.grey[300]);
    final actualActiveThumbColor = activeThumbColor ?? Colors.white;
    final actualInactiveThumbColor = inactiveThumbColor ?? Colors.white;

    return GestureDetector(
      onTap: () {
        hapticService.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: value ? actualActiveColor : actualInactiveColor,
        ),
        child: Stack(
          children: [
            // Thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: value ? width - height + 2 : 2,
              top: 2,
              bottom: 2,
              child: Container(
                width: height - 4,
                height: height - 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      value ? actualActiveThumbColor : actualInactiveThumbColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: value ? activeIcon : inactiveIcon,
                  ),
                ),
              ),
            ),

            // Ripple effect
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    hapticService.selectionClick();
                    onChanged(!value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
