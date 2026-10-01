# TaskBoard

TaskBoard is a simple shared task board built with Flutter and Dart, using Firebase as its remote backend. Sign in with Google, add tasks, and see saved tasks again after a refresh. The app has a minimal dark UI and supports signing out.

Tasks are read from and created at `/boards/shared/tasks` in Cloud Firestore. Firebase Authentication identifies signed-in users. **Task claiming and completion are unfinished:** tasks have no claimant identity, and the current Firestore rules deny task updates, so moving a task between columns does not persist.

## Prerequisites

- Flutter and Dart compatible with the SDK constraint in `pubspec.yaml`.
- Google Chrome to run the web app.
- Access to the configured Firebase project `prog4swsys`, with Google sign-in enabled in Firebase Authentication and Cloud Firestore provisioned with the repository's rules.

## Run and Verify

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
flutter build apk --debug
```

The app uses the configured live Firebase project by default, including in debug builds. Local Auth, Firestore, and Functions emulators are opt-in:

```sh
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

Start the Firebase emulators separately before using that option. For Android emulator clients the app uses `10.0.2.2`; browser clients use `localhost`.

## Important Files

- `lib/main.dart` initializes Firebase and contains the task model, Firestore repository, and board UI.
- `lib/screens/auth_gate.dart` routes users based on Firebase Auth state and displays auth loading/errors.
- `lib/screens/login_screen.dart` provides the Google sign-in UI.
- `lib/services/auth_service.dart` implements Google sign-in and sign-out through Firebase Authentication.
- `lib/firebase_options.dart` contains generated client configuration for supported platforms.
- `firestore.rules` controls access to board documents and tasks.
- `firebase.json` points Firebase CLI to the rules and configures local emulators and Hosting.
- `.github/workflows/test-and-build.yml` runs dependency setup, analysis, tests, and a debug Android APK build.
- `test/widget_test.dart` tests authentication routing and emulator host selection; it does not test Firestore operations.

## CI

GitHub Actions runs on pushes to `main` and `feature/**`, and on pull requests targeting `main`. Its checks are `flutter analyze`, `flutter test`, and `flutter build apk --debug`.

- [Repository](https://github.com/joesevv/proj4swsys)
- [GitHub Actions](https://github.com/joesevv/proj4swsys/actions)