# Workout Tracker App

A Flutter-based workout tracking application for recording workouts, exercises, sets, repetitions, weights, reminders, and progress history.

## Live Application

[Open the Workout Tracker App](https://gnanenderchinnu.github.io/workout-tracker-app/)

## Project Documentation PDF

[Download Project Documentation](./Workout%20Tracker%20App%20Documentation.pdf)

## Index

1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Getting Started](#getting-started)
6. [How to Use the App](#how-to-use-the-app)
7. [Testing and Quality Checks](#testing-and-quality-checks)
8. [Deployment](#deployment)
9. [Data Storage](#data-storage)
10. [Security Notes](#security-notes)
11. [Future Enhancements](#future-enhancements)

## Project Overview

The Workout Tracker App helps users maintain a simple digital record of their training sessions. Users can add body-part-based workouts, save multiple exercises, track sets with weight and repetitions, review previous exercise history, and monitor overall progress through dashboard statistics.

The app is designed as a lightweight personal fitness tracker with local data persistence, a clean mobile-first interface, and support for web deployment through GitHub Pages.

## Key Features

- Add and save workouts by body part.
- Add multiple exercises under each workout.
- Record weight and repetition details for every set.
- View total workouts, exercises, sets, and strongest lift.
- Search workout history by body part, date, or exercise name.
- View exercise-specific history across previous workouts.
- Edit, rename, and delete exercises and sets.
- Use a calendar-style workout history view.
- Set workout reminder notifications.
- Toggle between light mode and dark mode.
- Store data locally using shared preferences.
- Access the deployed web version through GitHub Pages.

## Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Flutter Stateful Widgets
- **Local Storage:** `shared_preferences`
- **Notifications:** `flutter_local_notifications`
- **Time Zone Support:** `timezone`
- **Icons:** Material Icons and Cupertino Icons
- **Deployment:** GitHub Pages
- **Automation:** GitHub Actions

## Project Structure

```text
first_flutter_app/
├── android/                 # Android platform files
├── ios/                     # iOS platform files
├── lib/                     # Main application source code
│   ├── main.dart            # App entry point, dashboard, navigation, settings
│   ├── add_workout_screen.dart
│   └── workout_details_screen.dart
├── test/                    # Widget tests
│   └── widget_test.dart
├── web/                     # Web platform files
├── .github/workflows/       # GitHub Pages deployment workflow
├── pubspec.yaml             # Project metadata and dependencies
└── README.md                # Project documentation
```

## Getting Started

### Prerequisites

Install the following tools before running the project locally:

- Flutter SDK
- Dart SDK
- Git
- Android Studio or Visual Studio Code with Flutter extensions
- Chrome, Edge, Android Emulator, or a connected mobile device

### Clone the Repository

```bash
git clone https://github.com/GnanenderChinnu/workout-tracker-app.git
cd workout-tracker-app
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

Run on a connected device or emulator:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run as a local web server:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 57575
```

## How to Use the App

1. Open the app.
2. Use the dashboard to view workout statistics.
3. Tap the add button to create a new workout.
4. Enter the body part, exercise name, weight, and repetitions.
5. Add one or more sets to an exercise.
6. Save the exercise, then save the full workout.
7. Open the workout history screen to view saved workouts.
8. Tap a workout to view, edit, rename, or delete exercises and sets.
9. Use the history button to review previous records for the same exercise.
10. Open settings to enable dark mode or set a workout reminder.

## Testing and Quality Checks

Run static analysis:

```bash
flutter analyze
```

Run widget tests:

```bash
flutter test
```

Build the web version:

```bash
flutter build web --base-href /workout-tracker-app/
```

Current verified status:

- `flutter analyze` passes.
- `flutter test` passes.
- `flutter build web --base-href /workout-tracker-app/` succeeds.

## Deployment

The app is deployed using GitHub Pages.

Live URL:

[https://gnanenderchinnu.github.io/workout-tracker-app/](https://gnanenderchinnu.github.io/workout-tracker-app/)

Deployment is handled through the workflow file:

```text
.github/workflows/deploy-pages.yml
```

Whenever changes are pushed to the `main` branch, GitHub Actions can build and deploy the Flutter web app.

## Data Storage

The app stores workout data locally on the user's device using `shared_preferences`.

Stored data includes:

- Workout list
- Exercises
- Sets
- Weight and repetition values
- Reminder time
- Dark mode preference

Because the current version uses local storage, data is not synced across multiple devices.

## Security Notes

Android signing files such as `key.properties` and `upload-keystore.jks` are ignored by Git and should remain private.

These files are required only for signing Android release builds and should not be committed to a public repository.

## Future Enhancements

- Add charts for weekly and monthly workout progress.
- Add personal records by exercise.
- Add body-weight tracking.
- Add workout categories and templates.
- Add cloud backup and login support.
- Improve dark mode styling across all screens.
- Add export options for workout history.
- Add more detailed test coverage for add, edit, delete, and search workflows.
