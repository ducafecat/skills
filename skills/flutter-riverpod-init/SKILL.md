---
name: flutter-riverpod-init
description: Initialize an existing Flutter project into a runnable Riverpod scaffold with go_router, Dio, Freezed/JSON generation, SharedPreferences, Logger, and AdaptiveTheme. Use when the user asks to bootstrap a Flutter Riverpod app structure, create core providers/router/storage/network files, install baseline dependencies, or update main.dart for a Splash to Welcome/Login to Home flow.
license: MIT
metadata:
  author: ducafecat
  version: "1.0.1"
  compatibility: Requires an existing Flutter project with pubspec.yaml and lib/main.dart. Optional checks require Flutter SDK, Dart SDK, network access for package installation, and writable project files.
---

# Flutter Riverpod Init

## Purpose

Convert an existing Flutter project into a runnable Riverpod application scaffold.

The generated app should support:

- startup-time async initialization before `runApp`
- Riverpod-managed dependency graph
- go_router splash, welcome, login, and home routing
- Dio network client with auth, logging, and error interceptors
- SharedPreferences-backed token and launch-state storage
- AdaptiveTheme-based light/dark theme support
- Freezed and JSON code generation readiness

## Use this skill when

- The user asks to initialize a Flutter Riverpod project.
- The user wants a reusable Flutter app scaffold with Riverpod, go_router, Dio, and Freezed.
- The user asks to create TubeFlow-style app structure, providers, router, storage, network, UI theme, and starter pages.
- The user wants to update `main.dart` and baseline project files for this architecture.

## Do not use this skill when

- The target directory is not a Flutter project.
- The user only wants a conceptual explanation without file changes.
- The user asks for a different state-management architecture.
- Required project files are unavailable.

## Required inputs

Identify from the target project before asking the user:

1. Project root.
2. Existing `pubspec.yaml`.
3. Existing `lib/main.dart`.
4. Existing `analysis_options.yaml`, if present.
5. Package manager and Flutter SDK availability.

Do not repeatedly ask for information that can be discovered from files.

## Bundled references

- Read `references/file-templates.md` when creating or merging scaffold source files.
- Read `references/architecture.md` when the user asks about the architectural rationale, TubeFlow-style layering, or teaching notes.

## Workflow

### 1. Inspect the project

Confirm the current directory contains:

- `pubspec.yaml`
- `lib/main.dart`

Read existing files before editing. If a file already exists, merge carefully and preserve unrelated user code.

### 2. Add dependencies

Install runtime dependencies:

```sh
flutter pub add flutter_riverpod riverpod_annotation go_router dio freezed_annotation json_annotation shared_preferences logger adaptive_theme
```

Install development dependencies:

```sh
flutter pub add --dev build_runner riverpod_generator freezed json_serializable shared_preferences_platform_interface
```

Do **not** add `riverpod_lint` to `pubspec.yaml`. It is an `analysis_server_plugin`; as a pub dependency it pins an exact `riverpod` version and conflicts with `flutter_riverpod` / `analyzer`.

Enable it only in `analysis_options.yaml` (merge if the file exists). Use the latest version from https://pub.dev/packages/riverpod_lint:

```yaml
plugins:
  riverpod_lint: ^3.1.8
```

Do not put it under `analyzer.plugins` (legacy `custom_lint` format). Do not copy a version from `pubspec.yaml`.

### 3. Create baseline directories

Create the scaffold directories:

```sh
mkdir -p lib/core/config lib/core/network/interceptors lib/core/providers lib/core/router lib/core/storage lib/core/ui lib/features/auth/pages lib/features/home/pages lib/features/splash/pages lib/features/welcome/pages lib/shared/extensions lib/shared/widgets
```

### 4. Create or merge source files

Use `references/file-templates.md` as the source of truth for the scaffold files.

Required output areas:

- `lib/core/config`
- `lib/core/storage`
- `lib/core/network`
- `lib/core/providers`
- `lib/core/router`
- `lib/core/ui`
- `lib/shared/widgets`
- `lib/features/*/pages`
- `lib/main.dart`

Keep generated templates runnable, but adapt imports and package names to the actual project.

### 5. Generate and verify

Run:

```sh
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
```

If tests are absent or the default widget test no longer matches the scaffold, update the test or clearly report why it was not run.

## Safety rules

- Do not blindly overwrite existing user files.
- Do not delete user code while merging scaffold files.
- Do not print secrets or complete environment-variable values.
- Ask before destructive operations.
- Do not deploy or publish the app.

## Definition of done

The skill task is complete when:

- Required dependencies are present.
- Riverpod linting is enabled.
- Baseline directories and scaffold files exist.
- Code generation succeeds or blockers are clearly reported.
- `flutter analyze` and `flutter test` results are recorded.
- The app can start into the Splash -> Welcome/Login -> Home minimum flow, or remaining blockers are documented.
