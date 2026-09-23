<p align="center">
  <img src="docs/banner.png" alt="猫哥 ducafecat — Flutter Agent Skills for Codex, Claude Code &amp; Cursor" />
</p>

[English](./README.md) | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md)

# Flutter Agent Skills for Codex, Claude Code & Cursor

Reusable Flutter Agent Skills by **猫哥 (ducafecat)** for AI coding workflows: Riverpod and GetX scaffolding, asset automation, and deep code review.

Bootstrap existing Flutter apps with go_router, Dio, Freezed, storage, and themes, or automate image assets and review code changes with repository-aware instructions.

Website: [ducafecat.com](https://ducafecat.com)

## Quick Start

Run in your project directory:

```bash
npx skills@latest add ducafecat/skills
```

Select the skills and target AI coding agents in the installer. Skills are installed as ordinary files that you can inspect and customize.

To update installed skills:

```bash
npx skills update
```

The initialization skills require an existing Flutter project with `pubspec.yaml` and `lib/main.dart`. The image asset skill requires source images in `assets/images/3.0x/`. Running project commands requires the Flutter or Dart SDK; dependency installation may require network access.

## Why Flutter Agent Skills?

- **Repeatable app setup:** apply documented Riverpod or GetX architecture, file templates, and starter page flows.
- **Automated asset workflows:** generate density variants and maintain an `AppImages` index with pure Dart.
- **Code review grounded in your repository:** inspect changes against repository standards and review rules.
- **Editable workflows:** each skill keeps its instructions, references, and supporting files in the repository.

## Available Flutter Skills

| Skill | What it does | Documentation |
| --- | --- | --- |
| [`flutter-riverpod-init`](./skills/flutter-riverpod-init/SKILL.md) | Adds Riverpod, go_router, Dio, Freezed/JSON, SharedPreferences, Logger, AdaptiveTheme, and starter pages to an existing Flutter project. | [Guide](./skills/flutter-riverpod-init/README.md) |
| [`flutter-getx-init`](./skills/flutter-getx-init/SKILL.md) | Adds GetX app infrastructure, routing, networking, storage, themes, English/Simplified Chinese/Traditional Chinese translations, and DucafeUI components with offline docs. | [Guide](./skills/flutter-getx-init/README.md) |
| [`flutter-assets-compress`](./skills/flutter-assets-compress/SKILL.md) | Generates Flutter 1x and 2x image assets from `assets/images/3.0x/`, compresses supported outputs, and updates the `AppImages` index using pure Dart. | [Guide](./skills/flutter-assets-compress/README.md) |
| [`deep-code-review`](./skills/deep-code-review/SKILL.md) | Reviews branch, PR, fixed-base, or workspace code changes using repository standards and review rules; automatically selects review depth by change size and risk. | [Skill instructions](./skills/deep-code-review/SKILL.md) |

## Supported AI Coding Agents

Install with the skills CLI for **OpenAI Codex**, **Claude Code**, or **Cursor**, selecting the target agents offered by the installer. Invocation and automatic discovery depend on the agent you use.

The examples below use Codex-style `$skill-name` invocation. In other agents, use their skill selection mechanism or ask explicitly to use the skill by name. Individual workflows may require agent capabilities such as command execution or sub-agents; check the corresponding `SKILL.md` before use.

## Flutter Tech Stack

| Area | Libraries and tools |
| --- | --- |
| Language and framework | Dart, Flutter |
| State management | Riverpod or GetX |
| Routing and networking | go_router, Dio |
| Models and code generation | Freezed, JSON serialization, build_runner |
| Storage, logging, and themes | SharedPreferences, Logger, AdaptiveTheme |
| GetX UI and localization | DucafeUI, GetX translations (en / zh-CN / zh-TW) |
| Image asset automation | Pure Dart image processing, `AppImages` index |

## Usage Examples

### Flutter Riverpod app scaffolding

```text
$flutter-riverpod-init
```

See the [architecture](./skills/flutter-riverpod-init/references/architecture.md) and [file templates](./skills/flutter-riverpod-init/references/file-templates.md).

### Flutter GetX app scaffolding

```text
$flutter-getx-init
```

See the [architecture](./skills/flutter-getx-init/references/architecture.md) and [file templates](./skills/flutter-getx-init/references/file-templates.md). The workflow includes splash, welcome, login, and home pages, plus offline component and style documentation.

### Flutter image asset generation

```text
$flutter-assets-compress
```

See the [asset generation guide](./skills/flutter-assets-compress/README.md).

### Deep code review

```text
$deep-code-review
```

You can also specify a branch or fixed base such as `main`. See the [review standards](./skills/deep-code-review/references/standards.md). This skill excludes Markdown and documentation paths from review.

## How Agent Skills Work

Each directory under [`skills/`](./skills/) contains a `SKILL.md` with its purpose, trigger conditions, and workflow. Skills may also include references, templates, assets, or helper scripts. The coding agent reads these instructions and applies them to your project; agents with automatic discovery can select a matching skill from the task context.

Read the selected skill's instructions before use. Workflows may edit project files and run local commands such as `flutter pub add`, `dart run`, `flutter analyze`, `flutter test`, or `build_runner`.

## Repository Structure

```text
.
├── skills/
│   ├── flutter-riverpod-init/   # SKILL.md, README.md, references/
│   ├── flutter-getx-init/       # SKILL.md, README.md, assets/, references/
│   ├── flutter-assets-compress/ # SKILL.md, README.md
│   └── deep-code-review/        # SKILL.md, agents/, references/, scripts/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md                   # English
├── README.zh-CN.md              # Simplified Chinese
└── README.zh-TW.md              # Traditional Chinese
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for skill structure and validation requirements. Before publishing skill changes, validate front matter, match directory names to skill names, check reference links, and synchronize skill versions with [CHANGELOG.md](./CHANGELOG.md).

When updating these READMEs, keep the English, Simplified Chinese, and Traditional Chinese versions aligned. Linked skill documentation remains in its original language.

## License

Released under the [MIT License](./LICENSE).
