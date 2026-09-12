# flutter-getx-init

把已有 Flutter 项目初始化成可运行的 GetX 脚手架：go_router、Dio、Freezed、SharedPreferences、Logger、AdaptiveTheme。

## When to use

- 初始化 Flutter GetX 工程结构
- 生成 `lib/common/*`、`lib/pages/*`、`global.dart`、路由、存储、网络、主题
- Splash 展示应用名，固定 0.5 秒后分流
- Welcome 三页 `PageView`，最后一页点「开始」
- Login 预填 `AppConfig.demoEmail` / `demoPassword`（`ducafecat@gmail.com` / `123456`）
- Home 单页，右上角两个按钮通过 `showModalBottomSheet` 切主题（浅色 / 深色 / 跟随系统）和语言（en / zh-CN / zh-TW）；不含 Tab 壳，禁止 `Get.back`

## Not suitable for

- 非 Flutter 项目
- 明确使用其他状态管理的项目
- 只要讲解、不要落地文件

## Environment

- 需要 `pubspec.yaml` 和 `lib/main.dart`
- 需要 Flutter SDK 与 Dart SDK
- 装包需要网络

## File and command behavior

- 先读再合并
- 用 `flutter pub add` 加依赖
- 创建或合并 `lib/` 下文件，包含完整 DucafeUI 通用组件库
- 生成 `docs/组件说明.html`，浏览器标题与页面主标题为 `DucafeUI`
- 生成 `docs/样式规范.html`，保留离线阅读与交互，并按目标源码调整规范和链接
- 跑 `build_runner`、`dart format`、`flutter analyze`、`flutter test`
- 不部署、不发布、不故意删用户代码

## References

- Agent 入口：[`SKILL.md`](./SKILL.md)
- 文件模板：[`references/file-templates.md`](./references/file-templates.md)
- 组件源码：[`assets/lib/common/widgets/`](./assets/lib/common/widgets/)
- 离线组件说明：[`assets/docs/组件说明.html`](./assets/docs/组件说明.html)
- 离线样式规范：[`assets/docs/样式规范.html`](./assets/docs/样式规范.html)
- 架构说明：[`references/architecture.md`](./references/architecture.md)

## Installation

```bash
gh skill install ducafecat/ducafe-skills flutter-getx-init@v1.0.0
```
