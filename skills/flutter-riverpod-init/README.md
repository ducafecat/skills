# flutter-riverpod-init

Initialize an existing Flutter project as a runnable Riverpod scaffold with go_router, Dio, Freezed/JSON generation, SharedPreferences, Logger, and AdaptiveTheme.

## When to use

- Bootstrap a Flutter Riverpod app structure.
- Add core providers, router, storage, network, UI theme, and starter pages.
- Update `main.dart` for a Splash -> Welcome/Login -> Home minimum flow.

## Not suitable for

- Non-Flutter projects.
- Projects that intentionally use another state-management architecture.
- Explanation-only requests where no scaffold should be created.

## Environment

- Requires `pubspec.yaml` and `lib/main.dart`.
- Requires Flutter SDK and Dart SDK.
- Package installation needs network access.

## File and command behavior

- Reads existing project files before merging.
- Adds dependencies with `flutter pub add`.
- Creates or merges files under `lib/`.
- Runs `build_runner`, `dart format`, `flutter analyze`, and `flutter test`.
- Does not deploy, publish, or intentionally delete user code.

## References

- Agent entrypoint: [`SKILL.md`](./SKILL.md)
- File templates: [`references/file-templates.md`](./references/file-templates.md)
- Architecture notes: [`references/architecture.md`](./references/architecture.md)

## Installation

```bash
gh skill install ducafecat/ducafe-skills flutter-riverpod-init@v1.0.0
```
