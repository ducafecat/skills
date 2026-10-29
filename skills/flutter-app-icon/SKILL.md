---
name: flutter-app-icon
description: 使用 assets/icons 现有资源，配置并执行 flutter_launcher_icons，更新 Flutter 项目的 Android、iOS、macOS、Windows 和 Web 应用图标。用于接入已有图标、更换 App Icon 或生成 launcher icon，不负责图标设计。
---

# Flutter App Icon

使用 `assets/icons/` 中的现有资源配置并实际执行 `flutter_launcher_icons`。不设计图标、不调用图片生成工具、不重新选稿或修改品牌构图。

## 用户输入

用户可指定目标平台；未指定时处理项目中已存在且生成器支持的平台。先查看项目协作约定、技术说明、README、pubspec.yaml 和现有图标配置。

## 优先复用 assets/icons

先阅读 `assets/icons/README.md`，按需核对 `RESEARCH.md`、`LICENSES.md` 和 `export-manifest.json`，识别正式资源、导出关系、许可和验证边界。目录中的旧稿和中间文件不自动成为正式输入。必需素材缺失时停止依赖该素材的平台步骤，说明问题并继续其他可用平台，不自行设计替代图片。

本项目现有素材对应关系如下；其他项目以实际文件为准：

| 素材 | 用途 |
| --- | --- |
| `logo.svg` | 保留原样的确认稿，不作为生成器 PNG 输入 |
| `app-icon-ios.png` | 1024×1024、RGB、不透明，作为 iOS 和高分辨率通用母图 |
| `app-icon-android.png` | 512×512、RGB、不透明，作为 Android 常规图标 |
| `adaptive-foreground.svg / .png` | 1080×1080、透明自适应前景 |
| `adaptive-background.svg / .png` | 1080×1080、不透明自适应背景 |
| `logo-transparent.svg / .png` | 透明品牌图形，供平台专用适配，不直接视为自适应前景 |
| `logo-monochrome.svg / .png` | 单色负形图形，适配画布后可用于 Android 主题图标 |
| `preview.png` | 深浅底及遮罩验收预览，不作为生成输入 |

- 自适应双层保留相同全画布坐标系，不单独裁切透明边缘；缩放时两层同比例处理。本项目采用中央直径 66/108 的安全圆，修改构图后重新检查像素边界和遮罩，不沿用旧验证值。
- 单色图保留提示符、光标等透明负形，不能把整张图染成实心方块；接入前重新核对其画布、安全边距与生成器处理方式。
- 核对实际文件尺寸、色彩模式、alpha 范围和清单中的 SHA-256；清单不代替当前文件验证，发现差异先查明原因。
- 直接使用现有 PNG，不新建 `assets/icon/` 或改动原始素材。
- 素材导出与 launcher 接入分别报告。当前素材说明中的“未替换 launcher”是历史交付边界；用户要求接入时继续配置目标平台，仅要求导出素材时不修改平台文件。

### 已有素材的配置与验收

执行下方配置流程时，将示例母图路径替换为实际素材路径。按解析版本核对 `image_path_android` 支持后，分别指定 iOS 母图和 Android 常规图标。自适应配置优先使用现有前景、背景 PNG；核对 `adaptive_icon_background` 的图片路径支持，不无故改成纯色。检查生成器的默认前景 inset 是否使已留安全边距的素材再次缩小，使用该版本支持的配置调整并复核实际输出。未经画布适配的 `logo-monochrome.png` 不直接配置为主题图标。

派生素材变化时维护现有 README、导出关系和 manifest：记录源文件与输出 SHA-256、实际尺寸、色彩模式、alpha 范围及实际完成的验证；保留确认稿来源与许可记录。接入平台后更新说明中的接入状态。检查 16/32/48px、深浅底、单色负形和模拟遮罩；App 缩略预览不等于交付 favicon，未安装验证时保持设备验证状态为未验证。

## 执行步骤

1. **检查项目**：确认当前目录是 Flutter 项目（存在 `pubspec.yaml`），识别 `ios/`、`android/`、`macos/`、`windows/`、`web/` 和 `linux/`。用户指定平台时只处理指定范围，否则默认处理所有已存在的平台。不存在的平台不要擅自创建，完成时列出跳过项。检查既有图标配置、原生资源引用及 Linux 打包方式。
2. **检查输入**：按上表核对现有 PNG。Web maskable 图标需检查安全区域，不能只修改 manifest 的 `purpose`。素材缺失或不合格时说明具体平台限制，不新增设计流程。
3. **配置 Flutter**：使用 `flutter_launcher_icons`，如果项目尚未依赖，执行：
   ```bash
   flutter pub add --dev flutter_launcher_icons
   ```
   在项目根目录创建或最小修改 `flutter_launcher_icons.yaml`。以下为五个平台均存在且在处理范围内的示例；实际配置仅启用目标平台，其他平台关闭或移除相应块。先按项目解析版本核对[官方配置](https://pub.dev/packages/flutter_launcher_icons)，不要编造配置键：
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icons/app-icon-ios.png"
     image_path_android: "assets/icons/app-icon-android.png"
     remove_alpha_ios: true
     adaptive_icon_background: "assets/icons/adaptive-background.png"
     adaptive_icon_foreground: "assets/icons/adaptive-foreground.png"
     macos:
       generate: true
       image_path: "assets/icons/app-icon-ios.png"
     windows:
       generate: true
       image_path: "assets/icons/app-icon-ios.png"
       icon_size: 256
     web:
       generate: true
       image_path: "assets/icons/app-icon-ios.png"
   ```
   保留已有自适应背景图，不替换为纯色。单色素材通过画布及安全区检查后才加入 `adaptive_icon_monochrome`。如项目有既有配置或 flavors，先检查并兼容，避免重复定义或覆盖其他环境；自定义配置使用当前版本支持的参数执行。
4. **生成平台资源**：实际执行：
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```
   当前 `flutter_launcher_icons` 的配置覆盖 Android、iOS、macOS、Windows 和 Web；不能因为包可在 Linux 运行，就认为它支持 Linux 图标生成。若只处理 Linux，无需为此安装该包。
5. **跳过 Linux**：本技能只执行生成器支持的平台，不添加无效的 `linux: generate: true`，不扩展原生打包流程。存在 Linux 时明确报告跳过原因。
6. **检查结果**：逐平台核对实际生成文件及引用，路径以当前项目为准：

   | 平台 | 主要检查项 |
   | --- | --- |
   | iOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset/`、`Contents.json`、常规图标无 alpha |
   | Android | `android/app/src/main/res/mipmap-*`、Manifest 图标引用、自适应前景与背景、安全区域 |
   | macOS | `macos/Runner/Assets.xcassets/AppIcon.appiconset/`、`Contents.json` 与各尺寸图标 |
   | Windows | `windows/runner/resources/app_icon.ico` 为有效 ICO，`Runner.rc` 引用正确 |
   | Web | `web/favicon.png`、`web/icons/`、`web/index.html` favicon 引用、`web/manifest.json` 的路径、尺寸及 purpose |

   检查主要图标尺寸、背景透明度和缩小后的辨识度。资源生成成功与平台构建、安装后显示是不同验证层次；有对应宿主工具链时执行相关构建或运行检查，否则明确列出未验证项，不要宣称未经验证的平台成功。浏览器、桌面或系统缓存导致旧图标时，优先重新构建、重新安装或刷新缓存后复核。

## 约束

- 完成实际配置并执行生成命令，不要只回答教程。执行失败时根据报错修复本次配置并重试；工具链或依赖不可用时明确报告阻塞，不声称生成成功。
- 不改变 App 名称、Bundle ID、签名、版本号或其他无关设置。
- 对用户提供的品牌素材保持一致性；不要擅自改动或删除原始素材。
- 按项目约定运行相关检查；修改 Flutter 代码时运行格式检查、`flutter analyze` 和相关测试。
- 完成时告知：使用的资源、配置文件、执行命令及结果、生成文件路径、目标平台的配置结果、跳过原因和未验证事项。

## 调用示例

- `$flutter-app-icon 按 assets/icons 现有资源执行 flutter_launcher_icons。`
- `$flutter-app-icon 使用 assets/icons 配置并生成 iOS 和 Android 图标。`
- `$flutter-app-icon 只更新 Windows 和 Web 图标。`
