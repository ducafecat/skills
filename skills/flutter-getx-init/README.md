# flutter-getx-init

把已有 Flutter 项目初始化为可运行的 GetX 基础脚手架：Splash → Welcome → Login → Home。包含 go_router、Dio、Freezed、SharedPreferences、Logger、AdaptiveTheme 和三语翻译。Home 右上角保留主题与语言按钮，页面保留退出登录；不附带组件展示页。

源码模板见 [file-templates.md](references/file-templates.md)，架构说明见 [architecture.md](references/architecture.md)。共享组件仅保留 [PrimaryButton 与 PageScaffold](assets/lib/common/widgets/)。完整 UI 组件库和设计文档由 `flutter-getx-ui-kit` 维护。

使用前需要目标项目已有 `pubspec.yaml` 和 `lib/main.dart`。运行此 skill 时先读后合并，并在生成后运行代码生成、格式化、静态分析和测试。
