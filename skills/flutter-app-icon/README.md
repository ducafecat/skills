# flutter-app-icon

使用 `assets/icons/` 现有资源，配置并执行 `flutter_launcher_icons`，更新 Flutter 项目的 Android、iOS、macOS、Windows、Web 应用图标。

## 何时使用

- 接入已有图标素材
- 更换 App Icon / launcher icon
- 按平台生成图标资源

## 不适用

- 非 Flutter 项目（无 `pubspec.yaml`）
- 图标设计、选稿、品牌构图调整
- Linux 图标生成（生成器不支持）

## 环境

- 需要 Flutter SDK
- 在含 `pubspec.yaml` 的项目根目录执行
- 依赖：`flutter_launcher_icons`（dev）
- 输入优先来自 `assets/icons/`

## 常用素材

| 素材 | 用途 |
| --- | --- |
| `app-icon-ios.png` | iOS / 高分辨率通用母图 |
| `app-icon-android.png` | Android 常规图标 |
| `adaptive-foreground.png` | Android 自适应前景 |
| `adaptive-background.png` | Android 自适应背景 |

## 命令

```bash
flutter pub add --dev flutter_launcher_icons
flutter pub get
dart run flutter_launcher_icons
```

## 调用示例

```text
$flutter-app-icon 按 assets/icons 现有资源执行 flutter_launcher_icons。
$flutter-app-icon 使用 assets/icons 配置并生成 iOS 和 Android 图标。
$flutter-app-icon 只更新 Windows 和 Web 图标。
```

完整流程与校验规则见 [SKILL.md](./SKILL.md)。

## 安装

```bash
npx skills@latest add ducafecat/skills
```
