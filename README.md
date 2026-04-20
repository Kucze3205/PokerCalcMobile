# PokerCalcMobile

Mobile app for calculating and simulating poker scenarios. This tool is intended for poker players who want to analyze win probabilities, compute equity, and simulate card outcomes.

## 📋 Features

- **Poker simulator** - Real-time analysis of poker scenarios
- **Equity calculator** - Win probability calculations for different card combinations
- **Card graphics** - High-quality card assets
- **Multi-platform support** - Runs on Android, iOS, Windows, Linux, macOS, and Web
- **Responsive UI** - Optimized interface for different screen sizes

## 🛠️ Technology

- **Framework**: Flutter (^3.9.0)
- **State management**: Riverpod 2.0
- **Graphics**: Flutter SVG
- **IDE**: Visual Studio Code with CMake (Windows, Linux)

## 📦 Requirements

- Flutter SDK ^3.9.0
- Dart 3.9 or newer
- Android SDK (for Android)
- Xcode (for iOS/macOS)
- Visual Studio Build Tools (for Windows)

## 🚀 Quick Start

### Clone and Install
```bash
# Clone the repository
git clone <URL>

# Install dependencies
flutter pub get

# Run the app on the default device
flutter run
```

### Run on a specific platform
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# Web
flutter run -d chrome
```

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── views/                 # UI layer
│   └── Mainview.dart      # Main view
├── viewmodels/            # Presentation logic
│   └── Mainviewmodel.dart # ViewModel for the main view
├── models/                # Data models
│   ├── CardModel.dart     # Poker card model definition
│   └── Simulator.dart     # Poker simulation logic
└── converter/             # Conversion helpers
    └── imagepathconverter.dart

assets/
├── cards_hierarhy/        # Card hierarchy and related data
├── Graphics/              # Standard-resolution graphics
├── Graphics_svg/          # Vector SVG card assets
├── GraphicsMicro/         # Small-resolution graphics
├── GraphicsMid/           # Medium-resolution graphics
├── GraphicsMini/          # Compact graphics
└── GraphicsNano/          # Minimal graphics
```

## 📚 Main Dependencies

- **flutter_riverpod** (^2.0.0) - State management
- **flutter_svg** (^2.0.10) - SVG rendering support
- **flutter_lints** (^5.0.0) - Code analysis rules

## 🔧 Available Commands

```bash
# Analyze code
flutter analyze

# Format code
dart format lib/

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios

# Build for Windows
flutter build windows

# Run tests
flutter test
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Windows (via CMake)
- ✅ Linux (via CMake)
- ✅ macOS
- ✅ Web

## 📝 Configuration

Main configuration files:
- `pubspec.yaml` - Flutter dependencies and app configuration
- `analysis_options.yaml` - Static analysis and lint rules
- `CMakeLists.txt` - Native build configuration

## 🤝 Contributing

Please report issues and suggestions via the issue tracker.

## 📄 License

See the LICENSE file in the repository.

## 📞 Contact

For more information, check the project documentation or contact the development team.
