
# Water-Up

**Water-Up** is a cross-platform hydration tracking app built with Flutter. It helps users monitor their daily water intake, set goals, view progress, and celebrate achievements.

## Features

- **Daily Tracking:** Log water and other drinks with customizable volumes.
- **Smart Insights:** Get motivational tips and hydration reminders.
- **Progress Visualization:** Beautiful animated progress ring and charts.
- **History:** View and manage your hydration history for up to 14 days.
- **Achievements:** Unlock awards for meeting hydration goals and streaks.
- **Undo & Reset:** Easily undo the last entry or reset your daily counter.
- **Contextual Quick Add:** Fast-add common drink volumes based on time of day.
- **Multi-Platform:** Runs on Android, iOS, Web, Windows, macOS, and Linux.

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable)
- Dart SDK (comes with Flutter)
- Android/iOS/Web/Windows/macOS/Linux device or emulator

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/JusttMohammed/Water-Up.git
   cd Water-Up
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   - For Android/iOS:
     ```sh
     flutter run
     ```
   - For Web:
     ```sh
     flutter run -d chrome
     ```
   - For Desktop:
     ```sh
     flutter run -d windows
     ```


- **lib/screens/**: Main UI screens (dashboard, history, progress, achievements, etc.)
- **lib/services/**: Data and logic (water tracking, user settings)
- **lib/models/**: Data models (DrinkEntry, etc.)
- **lib/widgets/**: Reusable UI components

## Contributing

Contributions are welcome, Please open issues or submit pull requests.

## License

MIT License

---

