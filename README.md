# CurrEx - Currency Converter App

CurrEx is a sophisticated Flutter-based currency conversion application that handles both fiat and cryptocurrency exchanges with a modern, seamless UI. The app features fluid animations, real-time currency charts, and support for multiple languages.

## Features

- **Real-time currency conversion** for both fiat and cryptocurrencies
- **Interactive currency charts** with multiple time periods (1D, 1W, 1M, 3M, 6M, 1Y)
- **Favorites system** for quick access to frequently used currencies
- **Dark/light mode** with smooth transition animations
- **Haptic feedback** throughout the app for enhanced user experience
- **Multi-language support** (English and French)
- **Offline functionality** with cached rates

## Technical Specifications

- Built with Flutter (April 2025 stable release)
- Supports Android and iOS platforms
- Integrates with [Currency API](https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@2025.4.28/)
- Custom animations without using Lottie
- Shimmer loading animations for a modern look and feel
- Provider state management
- Theme system with easy customization

## Project Structure

```
lib/
├── screens/           # Full pages of the app
│   ├── home_screen.dart
│   ├── chart_screen.dart
│   ├── currency_list_screen.dart
│   └── settings_screen.dart
├── surfaces/          # Major UI sections within screens
│   ├── converter_surface.dart
│   ├── chart_surface.dart
│   └── settings_surface.dart
├── components/        # Reusable complex UI elements
│   ├── currency_card.dart
│   ├── chart_widget.dart
│   ├── theme_toggle.dart
│   └── language_selector.dart
├── widgets/           # Simple UI elements
│   ├── custom_button.dart
│   ├── currency_item.dart
│   └── animated_switch.dart
├── utilities/         # Helper functions and services
│   ├── api_service.dart
│   ├── haptic_service.dart
│   ├── storage_service.dart
│   ├── theme_service.dart
│   └── language_service.dart
├── providers/         # State management
│   ├── currency_provider.dart
│   ├── settings_provider.dart
│   └── theme_provider.dart
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (April 2025 stable release or newer)
- Dart SDK
- Android Studio / Xcode for emulators

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/currex.git
```

2. Navigate to the project directory:
```bash
cd currex
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Screenshots

(Screenshots would be included here in a real README)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Currency conversion API by [Fawaz Ahmed](https://github.com/fawazahmed0/currency-api)
- Flutter team for the amazing framework
- All the open-source contributors whose libraries made this project possible
