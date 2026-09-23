# Changelog

All notable changes to this repository will be documented in this file.

## [1.0.4] - 2026-09-18

feat(deep-code-review): enhance AI review rules selection and manifest generation

- Refactor AI rules handling to prevent main agent from reading rules directly, instead passing relevant paths to sub-agents.
- Update SKILL.md to clarify AI rules reading process and output structure.
- Implement logic in build-review-manifest script to dynamically select AI review rules based on file paths and content.
- Add tests to validate AI review rules selection and ensure correct manifest generation.

## [1.0.3] - 2026-09-13

- add flutter-getx-init UI 组件样式表
- add flutter-getx-init getx 脚手架
- add deep-code-review 深度代码审核

## [1.0.2] - 2026-09-07

- flutter-riverpod-init 自适应 Riverpod、GetX。

## [1.0.1] - 2026-08-20

- riverpod_lint 已从 pubspec 移除，只在 analysis_options.yaml 的 plugins 启用。

## [1.0.0] - 2026-07-20

- Standardized the repository as a publishable multi-skill package.
- Moved skills under the `skills/` directory.
- Added root publishing documents and MIT license metadata.
- Split large Flutter Riverpod templates into bundled references.
