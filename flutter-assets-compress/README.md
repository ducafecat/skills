# flutter-assets-compress 使用说明

从 `assets/images/3.0x/` 下的 `@3x` 资源生成 `1x`、`2x`，纯 Dart 压缩并更新资源索引。

## 前提

- Flutter 项目
- `pubspec.yaml` 增加依赖：`image: ^4.8.0`、`path: ^1.9.1`
- 源图放在 `assets/images/3.0x/`（如 `default.png`、`banner@3x.jpg`）

## 输出目录

- `assets/images/<name>.<ext>` → 1x
- `assets/images/2.0x/<name>.<ext>` → 2x  
（3x 保留在 `3.0x/`）

## 脚本

若项目无 `tool/image_assets.dart`，按 [SKILL.md](./SKILL.md) 生成完整脚本（扫描 3.0x、缩放 2/3 与 1/3、PNG level 6 / JPG quality 85 / WebP 80、建目录、写 `lib/core/assets/app_images.dart`）。

## 运行

```bash
dart run tool/image_assets.dart
```

## 索引文件

`lib/core/assets/app_images.dart`：`AppImages` 类，常量值为 `assets/images/...` 路径，命名由路径转驼峰。

## 约束

- 仅 Dart，不调用外部 CLI
- 读失败跳过并提示；同名覆盖；非图片忽略
