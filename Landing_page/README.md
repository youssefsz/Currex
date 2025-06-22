# CurrEx Landing Page

A modern, professional landing page for the CurrEx currency converter app, built with 2025 best practices in mind.

## 🚀 Features

### Theme System
- **Dark Mode Default**: Starts in dark mode as requested
- **Dynamic Theme Switching**: Toggle between dark and light themes
- **Image Switching**: Screenshots automatically change based on selected theme
- **Smooth Transitions**: Animated theme changes with visual feedback

### Interactive Screenshots
- **Carousel Navigation**: Browse through all 4 main app screens (Convert, Charts, Currencies, Settings)
- **Auto-play**: Automatically cycles through screenshots every 5 seconds
- **Touch Gestures**: Swipe support on mobile devices
- **Keyboard Navigation**: Use arrow keys to navigate screenshots

### Modern Design
- **Mobile-First**: Optimized for mobile devices with responsive breakpoints
- **Glassmorphism**: Beautiful backdrop blur effects in navigation
- **Floating Cards**: Animated floating elements with exchange rate data
- **Gradient Effects**: Modern gradient text and button styling
- **Performance Optimized**: Lazy loading, smooth scrolling, and optimized animations

### Content Sections
1. **Hero Section**: Compelling headline with app screenshot and floating data cards
2. **Features Grid**: 6 key features with icons and descriptions
3. **Screenshots Showcase**: Interactive carousel of all 4 main app screens
4. **Social Proof**: User testimonials with ratings
5. **Download CTA**: App store badges and feature highlights
6. **Footer**: Links and copyright information

## 🎨 Design Features Following 2025 Trends

- **Bold Typography**: Large, impactful headlines with proper hierarchy
- **Monochromatic Aesthetic**: Consistent color scheme with accent colors
- **Minimalist Layout**: Clean, uncluttered design with plenty of white space
- **Interactive Elements**: Hover effects, animations, and micro-interactions
- **High Contrast**: Excellent readability in both dark and light modes

## 📱 Mobile Optimizations

- Touch-friendly navigation dots and buttons
- Swipe gestures for screenshot carousel
- Optimized font sizes and spacing for mobile
- Reduced animations on slower devices
- Orientation change handling

## 🖼️ Image Structure

The landing page expects the following image structure:
```
Landing_page/
├── imgs/
│   ├── dark/
│   │   ├── screenshot-dark-convert.jpg
│   │   ├── screenshot-dark-charts.jpg
│   │   ├── screenshot-dark-currencies.jpg
│   │   └── screenshot-dark-settings.jpg
│   └── light/
│       ├── screenshot-light-convert.jpg
│       ├── screenshot-light-charts.jpg
│       ├── screenshot-light-currencies.jpg
│       └── screenshot-light-settings.jpg
└── icon/
    └── logo.png
```

## 🚀 How to Test

1. **Open the landing page**: Open `index.html` in a web browser
2. **Test theme switching**: Click the theme toggle button (🌙/☀️) in the navigation
3. **Browse screenshots**: Click the dots below the screenshots or use arrow keys
4. **Test mobile**: Resize browser window or open on mobile device
5. **Check animations**: Scroll through the page to see fade-in animations

## 🎯 Features Showcase

The landing page effectively showcases your CurrEx app's key features:

- **Real-time Currency Conversion**: Instant, accurate conversions
- **Interactive Charts**: Visualize currency trends over time
- **Crypto & Fiat Support**: Comprehensive currency support
- **Favorites Management**: Save frequently used currencies
- **Dark & Light Themes**: User preference customization
- **Recent Conversions**: Track conversion history

## 📊 Performance Features

- Lazy loading for images
- Optimized animations and transitions
- Efficient DOM manipulation
- Mobile-specific optimizations
- Reduced motion support for accessibility

## 🎨 Customization

The landing page uses CSS custom properties (variables) for easy customization:
- Colors and gradients
- Spacing and typography
- Animation timings
- Responsive breakpoints

All major styling can be adjusted by modifying the CSS variables in `:root` and `.dark-mode` selectors. 