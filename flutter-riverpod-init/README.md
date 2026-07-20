# flutter-riverpod-init

将现有 Flutter 项目初始化为可运行的 Riverpod 脚手架（Riverpod、go_router、Dio、Freezed/JSON、SharedPreferences、Logger、AdaptiveTheme）。完整文件模板与细节见 [`SKILL.md`](./SKILL.md)；工程思想见 [`技术说明.md`](./技术说明.md)。

## 何时使用

- Cursor Agent：触发本 skill 后按 `SKILL.md` 全流程执行。
- 人工：按下列步骤与 `SKILL.md` 中的「文件模板」落盘代码。

## 前置条件

项目根目录存在 `pubspec.yaml` 与 `lib/main.dart`。

## 执行步骤

### 1. 安装依赖

```sh
flutter pub add flutter_riverpod riverpod_annotation go_router dio freezed_annotation json_annotation shared_preferences logger adaptive_theme
flutter pub add --dev riverpod_lint build_runner riverpod_generator freezed json_serializable shared_preferences_platform_interface
```

### 2. `analysis_options.yaml`

无则新建；`riverpod_lint` 版本与 `pubspec.yaml` 中 `dev_dependencies` 一致。

```yaml
plugins:
  riverpod_lint: <version number>
```

### 3. 目录结构

```sh
mkdir -p lib/core/config lib/core/network lib/core/providers lib/core/router lib/core/storage lib/core/ui lib/features/auth/pages lib/features/home/pages lib/features/splash/pages lib/features/welcome/pages lib/shared/extensions lib/shared/widgets
```

### 4. 源码

按 `SKILL.md`「文件模板」创建或合并；已有同名文件先阅读再合并，勿盲目覆盖。

### 5. 生成与检查

```sh
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
```

无测试或仅默认 widget 测试时，`flutter test` 可能较薄；按需补测试或说明原因。

本地运行：`flutter run`。验收：`build_runner` 通过，且 **Splash → Welcome/Login → Home** 最小流程可跑通。

## 依赖一览

| 类型 | 包名 |
|------|------|
| dependencies | flutter_riverpod, riverpod_annotation, go_router, dio, freezed_annotation, json_annotation, shared_preferences, logger, adaptive_theme |
| dev_dependencies | riverpod_lint, build_runner, riverpod_generator, freezed, json_serializable, shared_preferences_platform_interface |
