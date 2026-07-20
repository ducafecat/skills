---
name: flutter-assets-compress
description: Generate 1x and 2x images from existing 3x Flutter assets using pure Dart (no external tools), compress them, and update asset index files.
---

# 🎯 目标
在 Flutter 项目中：
- 从 `@3x` 图片生成 `2x`、`1x`
- 自动压缩图片（纯 Dart 实现）
- 按 Flutter 规范整理目录
- 更新资源索引文件

---

# 📦 前提
- 项目为 Flutter 项目
- 图片位于：assets/images
- 已存在 `@3x` 图片，例如：
  - assets/images/3.0x/default.png
  - assets/images/3.0x/banner@3x.jpg

---

# 📁 输出结构（必须符合）
例如：
assets/images/icon.png
assets/images/2.0x/icon.png

---

# ⚙️ 执行逻辑

## 1️⃣ 创建脚本（如果不存在）
创建文件：
tool/image_assets.dart

写入完整 Dart 脚本（必须生成完整代码）

---

## 2️⃣ Dart 脚本实现要求

必须使用依赖：
```yaml
dependencies:
  image: ^4.8.0
  path: ^1.9.1
````

---

## 3️⃣ 核心功能

### 扫描图片

* 遍历 assets/images/3.0x/
* 找出所有图片文件

---

### 生成尺寸

对每个图片：

* 读取原图
* 生成：

  * 2x：宽高 * 2/3
  * 1x：宽高 * 1/3

---

### 输出路径

```dart
assets/images/name.png
assets/images/2.0x/name.png
```

---

### 压缩策略（纯 Dart）

* PNG：encodePng(level: 6)
* JPG：encodeJpg(quality: 85)
* WebP（如果支持）：quality: 80

---

### 文件处理

* 自动创建目录

---

## 4️⃣ 更新资源索引

生成或更新：
lib/core/assets/app_images.dart

示例：

```dart
abstract final class AppImages {
  AppImages._();

  static const defaultPng = 'assets/images/default.png';
  static const homePlaceholderPng = 'assets/images/home_placeholder.png';
  static const loginBgJpg = 'assets/images/login_bg.jpg';
  static const logoPng = 'assets/images/logo.png';
}
```

命名规则：

* 路径转驼峰

---

## 5️⃣ 执行方式

输出命令：

```bash
dart run tool/image_assets.dart
```

---

# 📌 输出要求

执行完后必须输出：

## 目录结构

（列出变更）

## 处理统计

* 总图片数
* 成功数量

## 示例代码

（assets.dart）

---

# ⚠️ 错误处理

* 图片读取失败 → 跳过 + 提示
* 重复文件 → 覆盖
* 非图片 → 忽略

---

# 🧠 约束（非常重要）

* 不允许依赖外部 CLI 工具
* 不允许调用系统命令
* 必须纯 Dart 实现
* 必须生成完整可运行脚本
