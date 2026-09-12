---
name: flutter-getx-init
description: Initialize an existing Flutter project into a runnable GetX scaffold with go_router, Dio, Freezed/JSON generation, SharedPreferences, Logger, and AdaptiveTheme. Use when the user asks to bootstrap a Flutter GetX app structure, create common/pages, Global.init, router, storage, network, or update main.dart for a Splash to Welcome/Login to Home flow.
license: MIT
metadata:
  author: ducafecat
  version: "1.0.0"
  compatibility: Requires an existing Flutter project with pubspec.yaml and lib/main.dart. Optional checks require Flutter SDK, Dart SDK, network access for package installation, and writable project files.
---

# Flutter GetX Init

## Purpose

把已有 Flutter 项目初始化成可运行的 GetX 脚手架。

生成的应用应支持：

- `AppBootstrap` 先渲染，再异步执行 `Global.init`
- GetX 依赖装配（`Get.put` / `putAsync` / `lazyPut`）
- go_router：Splash（0.5 秒）→ Welcome 三页 / Login（预填演示账号）→ Home
- Home 右上角两个按钮，通过底部菜单切换 theme / i18n
- Dio 网络客户端（鉴权 / 日志 / 错误拦截器）
- SharedPreferences 凭证与欢迎页标记
- AdaptiveTheme 亮暗主题
- GetX translations（en / zh-CN / zh-TW）
- Freezed 模型与 `build_runner` 生成
- DucafeUI 通用组件库及离线文档 `docs/组件说明.html`、`docs/样式规范.html`

## Use this skill when

- 用户要求初始化 Flutter GetX 项目。
- 用户要 `lib/common/*` + `lib/pages/*` 脚手架，栈为 GetX、go_router、Dio、Freezed。
- 用户要按 TubeFlow 约束搭启动、路由、存储、网络、主题和四页流。
- 用户要改 `main.dart` / `global.dart` 以适配这套架构。

## Do not use this skill when

- 目标目录不是 Flutter 项目。
- 用户只要讲解、不要改文件。
- 用户要另一套状态管理（例如 Riverpod）。
- 必要项目文件不存在。

## Required inputs

从目标项目自行识别，不要反复问用户：

1. 项目根目录
2. 现有 `pubspec.yaml`
3. 现有 `lib/main.dart`
4. 现有 `analysis_options.yaml`（如有）
5. 包管理器与 Flutter SDK 是否可用

## Bundled references

- 创建或合并源码时读 `references/file-templates.md`
- 组件源码使用 `assets/lib/common/widgets/`，包含 `form/` 和入口文件
- 离线组件说明使用 `assets/docs/组件说明.html`
- 离线样式规范使用 `assets/docs/样式规范.html`
- 用户问架构原因、分层或教学说明时读 `references/architecture.md`

## Workflow

### 1. Inspect the project

确认当前目录包含：

- `pubspec.yaml`
- `lib/main.dart`

先读再改。已有文件要合并，保留无关代码。

### 2. Add dependencies

运行时依赖：

```sh
flutter pub add get go_router dio native_dio_adapter freezed_annotation json_annotation shared_preferences logger adaptive_theme flutter_cache_manager cached_network_image flutter_svg
```

开发依赖：

```sh
flutter pub add --dev build_runner freezed json_serializable shared_preferences_platform_interface
```

`pubspec.yaml` 的 `dependencies` 必须包含 SDK 包（没有就补上）：

```yaml
flutter_localizations:
  sdk: flutter
```

按目标项目的 `name` 改所有 `package:<name>/...` 导入，并把 `test/widget_test.dart` 里的 `{{package_name}}` 换成该 `name`。

### 3. Create baseline directories

```sh
mkdir -p \
  lib/common/api \
  lib/common/cache \
  lib/common/components \
  lib/common/extension/animated \
  lib/common/extension/screen \
  lib/common/i18n/translations \
  lib/common/models \
  lib/common/network \
  lib/common/routers \
  lib/common/services \
  lib/common/style \
  lib/common/utils \
  lib/common/values \
  lib/common/widgets \
  lib/pages/splash \
  lib/pages/welcome \
  lib/pages/login \
  lib/pages/home
```

### 4. Create or merge source files

基础脚手架以 `references/file-templates.md` 为准；`lib/common/widgets/**` 以 `assets/lib/common/widgets/` 为唯一源码模板。递归复制或合并全部组件，同时落地模板中的样式 token、三语文案和入口导出。组件使用空感知集合元素等语法，确认目标 Dart SDK 支持后再落地。

必出目录：

- `lib/common/**`（13 个子目录 + `index.dart`）
- `lib/pages/splash|welcome|login|home`
- `lib/pages/index.dart`
- `lib/global.dart`
- `lib/main.dart`

导包：

- `lib/common/index.dart` 只导出各子目录 `index.dart`
- common 跨子目录导入目标子目录 `index.dart`；同目录直接导入
- 页面、`main.dart`、`global.dart` 用 `lib/common/index.dart`
- 页面跨模块导入目标页面子目录 `index.dart`
- `lib/pages/index.dart` 只汇总页面入口；页面入口只导出页面与控制器
- 新增公共能力、页面、控制器必须同步维护对应 `index.dart`

约束：

- GetX 不管路由；禁止 `Get.to` / `Get.off` / `Get.back`
- 页面状态用 `GetxController` + `GetBuilder` + `update([id])`
- 页面 Controller 在 `initState` `Get.put`，`dispose` `Get.delete`
- 生成代码加中文注释

`extension` / `network` / `cache` 按模板全文落地。`BASE_URL`、refresh 白名单、代理路径在 `lib/common/values/app_config.dart`。未配 `BASE_URL` 时本地假登录，不发 refresh / 代理请求。

页面行为必须落实到源码模板：

- Splash 展示 `AppConfig.appName`，首帧后固定停留 0.5 秒再 `context.go` 分流；销毁时取消计时器，router 对 Splash 放行。
- Welcome 使用三页 `PageView`；最后一页点「开始」，成功写入 `AppLaunchService` 后再进 login。
- Login 预填 `AppConfig.demoEmail` / `AppConfig.demoPassword`，值为 `ducafecat@gmail.com` / `123456`。登录成功走 `SessionService.establish`，由 revision 变化触发 redirect 进 Home。
- Home 是单页，不是 `StatefulShellRoute`。Tab 壳属于业务，不进本脚手架。
- Home 右上角两个按钮分别使用 `showModalBottomSheet`：主题提供浅色 / 深色 / 跟随系统，语言提供 en / zh-CN / zh-TW。主题使用 AdaptiveTheme，语言使用 LocaleService 持久化；底部菜单用自身 context 的 Navigator 关闭，禁止 `Get.back`。

模板可运行，但导入和包名必须改成目标项目的。

### 5. Write DucafeUI documentation

执行完成前，必须将 `assets/docs/组件说明.html` 写入目标项目 `docs/组件说明.html`，目录不存在时创建。浏览器 `<title>` 和页面 `<h1>` 均为 `DucafeUI`，侧栏品牌与页脚保持同名。

- 将示例中的 `{{package_name}}` 替换为目标项目 `pubspec.yaml` 的 `name`。
- 保留离线样式、搜索、筛选、主题切换和示例复制功能，源码链接继续指向 `../lib/common/widgets/`。
- 已有文档先读再合并，保留用户补充；组件 API 若在合并时调整，同步更新参数、示例与组件统计。

样式规范同样是必出文档：将 `assets/docs/样式规范.html` 写入目标项目 `docs/样式规范.html`。浏览器标题为 `DucafeUI · 样式规范`，页面主标题为 `DucafeUI 样式规范`。

- 替换示例中的 `{{package_name}}`，保留目录锚点、颜色预览、亮暗切换、代码复制、打印样式与移动端表格滚动；保持离线可读。
- 对照最终生成的样式源码核对 token、组件 API、适配工具和导包说明；目标项目与模板不同的部分同步调整文档，不能把未生成的能力描述为已有实现。
- 检查文档内所有相对链接。目标项目不存在 `docs/样式规范.md`、`docs/2-设计/*` 或引用的测试文件时，将对应链接改为普通说明，并调整依赖这些文件的原文、页脚说明；不为补链接额外生成无关文件。保留有效的组件说明和源码链接。
- 已有样式规范先读再合并，保留用户补充；完成后确认两份 HTML 均已实际写入目标项目，而非仅保留在技能资源目录。

### 6. Generate and verify

```sh
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test
```

没有测试或默认 widget 测试对不上脚手架时，按模板更新 `test/widget_test.dart`，或写明为什么没跑。

## Safety rules

- 不要盲覆盖用户已有文件
- 合并时不要删用户代码
- 不要打印密钥或完整环境变量值
- 破坏性操作先问
- 不要部署或发布应用

## Definition of done

同时满足：

- 依赖已加入（含 `flutter_localizations`）
- 基线目录和脚手架文件存在
- `lib/common/widgets/` 完整落地，包含 `form/` 和入口导出，组件依赖已补齐
- `docs/组件说明.html` 已生成，浏览器标题及主标题均为 `DucafeUI`，无未替换包名占位符，源码链接有效
- `docs/样式规范.html` 已生成，标题正确，无未替换包名占位符，规范与最终源码一致，目录锚点及相对链接有效
- 代码生成成功，或阻塞已写明
- `flutter analyze` 与 `flutter test` 结果已记录
- 应用能走 Splash（0.5 秒）→ Welcome 三页 / Login（预填演示账号）→ Home（右上角底部菜单切主题/语言），或剩余阻塞已写明
