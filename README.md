# skills

面向 Flutter 开发与资源处理工作流的可复用 Codex Agent Skills 集合。

官网：[https://ducafecat.com](https://ducafecat.com)

## 可用技能

| 技能                                                                   | 说明                                                                                                                                   | 文档                                                 |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| [`flutter-riverpod-init`](./skills/flutter-riverpod-init/SKILL.md)     | 为已有 Flutter 项目初始化 Riverpod、go_router、Dio、Freezed/JSON、SharedPreferences、Logger、AdaptiveTheme，以及可运行的基础页面流程。 | [README](./skills/flutter-riverpod-init/README.md)   |
| [`flutter-assets-compress`](./skills/flutter-assets-compress/SKILL.md) | 基于 `assets/images/3.0x/` 的源图，用纯 Dart 生成 Flutter 1x、2x 图片资源，并更新资源索引。                                            | [README](./skills/flutter-assets-compress/README.md) |

## 安装

### Codex Skill Installer

安装指定版本：

```bash
gh skill install ducafecat/skills flutter-riverpod-init@v1.0.0
gh skill install ducafecat/skills flutter-assets-compress@v1.0.0
```

安装并固定版本：

```bash
gh skill install ducafecat/skills flutter-riverpod-init --pin v1.0.0
```

### Cursor

如果你的 Cursor 版本支持 Skills，可以安装到项目级或全局目录。

项目级安装：

```bash
mkdir -p .cursor/skills
cp -R skills/flutter-riverpod-init .cursor/skills/
cp -R skills/flutter-assets-compress .cursor/skills/
```

全局安装：

```bash
mkdir -p ~/.cursor/skills
cp -R skills/flutter-riverpod-init ~/.cursor/skills/
cp -R skills/flutter-assets-compress ~/.cursor/skills/
```

安装后重新打开项目或重启 Cursor Agent。

### Codex

Codex 可读取项目级 `.agents/skills` 与用户级 `~/.agents/skills`。

项目级安装：

```bash
mkdir -p .agents/skills
cp -R skills/flutter-riverpod-init .agents/skills/
cp -R skills/flutter-assets-compress .agents/skills/
```

全局安装：

```bash
mkdir -p ~/.agents/skills
cp -R skills/flutter-riverpod-init ~/.agents/skills/
cp -R skills/flutter-assets-compress ~/.agents/skills/
```

安装后在 Codex 中输入 `/skills` 或使用 `$flutter-riverpod-init`、`$flutter-assets-compress` 显式调用。

### Claude Code（CC）

Claude Code 可读取项目级 `.claude/skills` 与用户级 `~/.claude/skills`。

项目级安装：

```bash
mkdir -p .claude/skills
cp -R skills/flutter-riverpod-init .claude/skills/
cp -R skills/flutter-assets-compress .claude/skills/
```

全局安装：

```bash
mkdir -p ~/.claude/skills
cp -R skills/flutter-riverpod-init ~/.claude/skills/
cp -R skills/flutter-assets-compress ~/.claude/skills/
```

如果当前会话没有自动发现新技能，重启 Claude Code 后再试。

### 参考链接

- [Cursor CLI / Agent 文档](https://docs.cursor.com/en/cli/overview)
- [Codex Build Skills 文档](https://learn.chatgpt.com/docs/build-skills)
- [Claude Code Skills 文档](https://code.claude.com/docs/zh-CN/skills)

## 使用场景

### Flutter Riverpod 项目初始化

使用 [`flutter-riverpod-init`](./skills/flutter-riverpod-init/README.md) 快速为已有 Flutter 项目加入常见应用基础设施，包括路由、网络、存储、主题、启动页、登录页和首页流程。

更多细节：

- [技能入口](./skills/flutter-riverpod-init/SKILL.md)
- [架构说明](./skills/flutter-riverpod-init/references/architecture.md)
- [文件模板](./skills/flutter-riverpod-init/references/file-templates.md)

### Flutter 图片资源生成

使用 [`flutter-assets-compress`](./skills/flutter-assets-compress/README.md) 从 3.0x 图片资源生成 2.0x 与 1x 版本，并维护 `AppImages` 资源索引。

更多细节：

- [技能入口](./skills/flutter-assets-compress/SKILL.md)

## 仓库结构

```text
skills/
├── skills/
│   ├── flutter-riverpod-init/
│   │   ├── SKILL.md
│   │   ├── README.md
│   │   └── references/
│   └── flutter-assets-compress/
│       ├── SKILL.md
│       └── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## 贡献

新增或修改技能时，请参考 [CONTRIBUTING.md](./CONTRIBUTING.md)。发布前建议检查：

- `SKILL.md` front matter 是否能正确解析。
- 技能目录名与 `name` 是否一致。
- 参考文档链接是否有效。
- 版本号与 [CHANGELOG.md](./CHANGELOG.md) 是否同步更新。

## 安全说明

使用前建议先阅读对应技能的 `SKILL.md` 与 README，可以从 [skills 目录](./skills/) 进入。当前技能不包含凭据，也不会主动执行部署、发布或删除用户代码等破坏性操作。

部分流程会执行项目本地命令，例如 `flutter pub add`、`dart run`、`flutter analyze`、`flutter test` 或 `build_runner`。安装依赖时可能需要网络访问。

## 许可证

本仓库基于 [MIT License](./LICENSE) 开源。
