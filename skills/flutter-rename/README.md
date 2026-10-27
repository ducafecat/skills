# flutter-rename

在当前 Flutter 项目中，根据单个参数自动设置 Android/iOS Bundle ID 或 App Name。

## 何时使用

- 修改包名 / Bundle ID
- 修改应用显示名称 / App Name
- 使用 `flutter-rename` 完成改名

## 不适用

- 非 Flutter 项目（无 `pubspec.yaml`）
- 需同时指定多种改名类型或批量多值
- 不安装 `rename` 工具的纯手工改配置流程

## 环境

- 需要 Flutter SDK
- 在含 `pubspec.yaml` 的项目根目录执行
- 会全局安装：`flutter pub global activate rename`

## 判定规则

统计参数中英文句点 `.` 的数量：

| 条件 | 操作 |
| --- | --- |
| 至少两个 `.` | `setBundleId` |
| 少于两个 `.` | `setAppName` |

## 命令

```bash
flutter pub global activate rename
flutter pub global run rename setBundleId --value "参数"
flutter pub global run rename setAppName --value "参数"
flutter pub global run rename getBundleId
flutter pub global run rename getAppName
```

## 调用示例

```text
$flutter-rename com.ducafecat.demo
$flutter-rename com.ducafecat.demo.dev
$flutter-rename DucaFeCat Academy
$flutter-rename 猫咪时钟
```

完整流程与校验规则见 [SKILL.md](./SKILL.md)。

## 安装

```bash
npx skills@latest add ducafecat/skills
```
