---
name: flutter-rename
description: 在当前 Flutter 项目中，根据用户给定的单个值设置 Android/iOS Bundle ID（包标识符）或 App Name（应用显示名称）。用户要求修改包名、应用名称、Bundle ID、App Name 或使用 flutter-rename 时调用。
---

# Flutter Rename

接收用户给定的单个参数，自动选择并执行 `rename` 命令，修改当前 Flutter 项目的 Bundle ID 或 App Name。

## 执行流程

在包含 `pubspec.yaml` 的 Flutter 项目根目录执行以下步骤。

1. **安装工具**

   ```bash
   flutter pub global activate rename
   ```

   安装失败时停止，报告错误，不继续执行修改。

2. **获取用户参数**

   从用户消息中提取一个明确的参数，保留值本身的大小写、空格和中文等字符；去掉仅用于包裹参数的成对引号。缺少参数、参数为空或无法确定唯一值时，询问用户，不猜测。

3. **自动判断并执行**

   统计参数中的英文句点 `.` 数量，无需用户另外指定类型。

   - 包含至少两个 `.`：执行 Bundle ID 修改。

     ```bash
     flutter pub global run rename setBundleId --value "参数"
     ```

   - 少于两个 `.`：执行 App Name 修改。

     ```bash
     flutter pub global run rename setAppName --value "参数"
     ```

   将示例中的 `参数` 替换为实际用户值，并确保它作为 `--value` 后的单个命令行参数传入。优先使用参数数组；使用 Shell 时正确转义，不使用 `eval`，不让用户值中的引号、反引号或 `$()` 被解释为命令。不额外添加 Bundle ID 正则限制，也不在命令失败后切换另一种操作。

4. **检查结果**

   - 检查修改命令的退出码与输出；失败时报告错误及可能已修改的文件，不宣称成功。
   - 修改 Bundle ID 后执行：

     ```bash
     flutter pub global run rename getBundleId
     ```

   - 修改 App Name 后执行：

     ```bash
     flutter pub global run rename getAppName
     ```

   - 将命令返回的各平台实际值与用户参数逐一比较，并核对 `git diff` 和相关原生配置文件。默认检查 Android 的 `android/app/build.gradle` 或 `build.gradle.kts`、`AndroidManifest.xml` 及其引用的字符串资源，以及 iOS 的 `ios/Runner.xcodeproj/project.pbxproj`、`ios/Runner/Info.plist`；以实际存在且被构建配置引用的文件为准，解析其中的变量引用。
   - 返回值不一致、读取失败或仅部分平台修改成功时，明确报告具体平台和未验证项，不把命令退出成功等同于验证通过。
   - 汇报识别出的类型、目标值、实际修改的平台和验证结果。只修改与此次改名相关的配置，保留用户已有改动。

## 调用示例

- `flutter-rename com.ducafecat.demo` → `setBundleId`
- `flutter-rename com.ducafecat.demo.dev` → `setBundleId`
- `flutter-rename DucaFeCat Academy` → `setAppName`
- `flutter-rename 猫咪时钟` → `setAppName`
