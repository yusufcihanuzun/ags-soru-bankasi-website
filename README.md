# AGS App

A Flutter application built with Clean Architecture and Feature-first organization.

## Architecture

This project follows Clean Architecture principles with a Feature-first organization:

```
lib/
├── core/                          # Shared/common code
│   ├── database/                  # Database services
│   ├── di/                        # Dependency injection
│   ├── error/                     # Error handling
│   ├── network/                   # Network utilities
│   ├── utils/                     # Utility functions
│   └── widgets/                   # Reusable widgets
├── features/                      # All app features
│   └── onboarding/                # Onboarding feature
│       └── presentation/          # Presentation layer
│           ├── pages/             # Screen widgets
│           └── widgets/           # Feature-specific widgets
└── main.dart                      # Entry point
```

## Dependencies

- **flutter_bloc**: State management
- **freezed**: Code generation for immutable classes
- **equatable**: Value equality
- **get_it**: Dependency injection
- **dartz**: Functional programming utilities
- **sqflite**: SQLite database
- **path**: Path manipulation utilities

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Features

### Onboarding
- Welcome screen with custom illustration
- Turkish language support
- Modern UI design with Material 3

## Development

This project uses:
- Clean Architecture principles
- Feature-first organization
- flutter_bloc for state management
- GetIt for dependency injection
- SQLite for local storage 