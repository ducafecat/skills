规范发布自己写的 **AI Skills**，可以把它当成发布一个“小型开源软件包”：

> **Agent Skills 标准格式 + GitHub 仓库 + 自动校验 + SemVer 版本 + Release + 安全说明。**

OpenAI Codex、ChatGPT Skills、Claude Code、Cursor、GitHub Copilot 等正在采用或兼容开放的 Agent Skills 格式。核心就是一个包含 `SKILL.md` 的目录，可选附带脚本、参考资料和模板。([OpenAI Developers][1])

---

## 一、推荐的 GitHub 仓库结构

一个仓库可以发布多个 Skills：

```text
my-ai-skills/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
│
├── skills/
│   ├── nuxt4-code-review/
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   │   └── check-project.sh
│   │   ├── references/
│   │   │   ├── security-checklist.md
│   │   │   └── nuxt4-conventions.md
│   │   └── assets/
│   │       └── review-template.md
│   │
│   └── caddyfile-review/
│       └── SKILL.md
│
└── .github/
    └── workflows/
        └── validate-skills.yml
```

每个 Skill 的实际根目录必须包含：

```text
skill-name/
└── SKILL.md
```

标准目录包括：

- `scripts/`：可执行脚本
- `references/`：详细文档、规则、规范
- `assets/`：模板、配置、示例文件

`SKILL.md` 不宜塞入所有知识。官方建议主文件控制在 500 行以内，将长文档拆到 `references/`，Agent 会按需加载。([Agent Skills][2])

---

## 二、规范的 `SKILL.md`

下面是一个适合你 Nuxt 4 开发场景的模板：

````markdown
---
name: nuxt4-code-review
description: Reviews Nuxt 4, Nitro, Vue 3 and TypeScript projects for correctness, security, performance and maintainability. Use when reviewing pull requests, checking Nuxt server routes, composables, middleware, runtime configuration or deployment code.
license: MIT
compatibility: Requires access to the project source code. Optional scripts require Node.js 22+, pnpm and git.
metadata:
  author: your-github-name
  version: "1.0.0"
---

# Nuxt 4 Code Review

## Purpose

Review Nuxt 4 projects and produce actionable, prioritized findings.

## Use this skill when

- The user requests a Nuxt 4 code review.
- The user provides a pull request, diff or source directory.
- The user wants to inspect Nitro server routes.
- The user asks about security, performance or maintainability.

## Do not use this skill when

- The project is not based on Nuxt or Vue.
- The user only asks for general JavaScript syntax explanations.
- The required source files are unavailable.

## Required inputs

Collect or identify:

1. Project source directory or Git diff.
2. Nuxt version.
3. Deployment environment.
4. Package manager.
5. The scope of the review.

Do not repeatedly ask for information that can be discovered from project files.

## Workflow

### 1. Inspect project configuration

Review:

- `package.json`
- `nuxt.config.ts`
- `tsconfig.json`
- Runtime environment configuration
- Deployment configuration

### 2. Review server code

Inspect:

- `server/api/`
- `server/routes/`
- `server/middleware/`
- Authentication and authorization
- Input validation
- Error handling
- Sensitive information exposure

### 3. Review client code

Inspect:

- Pages and layouts
- Components
- Composables
- State management
- SSR hydration risks
- Duplicate network requests

### 4. Run automated checks

When dependencies are available, run:

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```
````

Do not install packages or modify project files without permission.

### 5. Produce the report

Group findings by severity:

- Critical
- High
- Medium
- Low
- Recommendation

Each finding must include:

1. File and approximate location.
2. Description of the problem.
3. Why it matters.
4. Recommended correction.
5. A code example when useful.

## Safety rules

- Never print secrets or complete environment-variable values.
- Do not deploy or publish code.
- Do not delete or overwrite project files.
- Ask for explicit confirmation before destructive operations.
- Prefer read-only inspection.

## Definition of done

The review is complete when:

- Relevant configuration and source files have been inspected.
- Security and correctness risks are prioritized.
- Findings contain concrete remediation steps.
- Automated check results are recorded.
- Unverified assumptions are clearly identified.

## Additional references

- [Nuxt conventions](references/nuxt4-conventions.md)
- [Security checklist](references/security-checklist.md)

````

### 字段限制

`name` 必须：

- 最长 64 个字符
- 只能使用小写字母、数字和连字符
- 不能以连字符开头或结尾
- 不能包含连续的 `--`
- 必须和 Skill 目录名称一致

`description` 最长 1024 个字符，应同时说明“做什么”和“什么时候触发”。它是 Agent 判断是否加载 Skill 的主要依据，因此不要只写成 `Helps with Nuxt`。:contentReference[oaicite:2]{index=2}

---

## 三、README 应该写什么

仓库根目录的 `README.md` 至少包含：

```markdown
# My AI Skills

Reusable Agent Skills for software development and infrastructure operations.

## Available skills

| Skill | Description |
|---|---|
| nuxt4-code-review | Reviews Nuxt 4 and Nitro projects |
| caddyfile-review | Reviews and improves Caddy configurations |

## Installation

Install a specific version:

```bash
gh skill install your-name/my-ai-skills nuxt4-code-review@v1.0.0
````

Install and pin the version:

```bash
gh skill install your-name/my-ai-skills nuxt4-code-review \
  --pin v1.0.0
```

## Security

Review all scripts before execution.

The skills do not contain credentials and do not perform destructive
operations without explicit confirmation.

## License

MIT

````

每个 Skill 最好同时写明：

- 使用场景
- 不适用场景
- 依赖环境
- 是否访问网络
- 是否执行命令
- 是否修改文件
- 安装方式
- 示例输入和输出
- 已知限制

---

## 四、发布前校验

Agent Skills 官方提供了格式校验方式：

```bash
skills-ref validate ./skills/nuxt4-code-review
````

它主要检查：

- YAML Frontmatter 是否正确
- `name` 是否合法
- 目录名与 Skill 名是否一致
- 必填字段是否存在

([Agent Skills][2])

现在 GitHub CLI 也支持 Skills 发布校验。GitHub CLI 2.90.0 或更高版本可以使用：

```bash
gh skill publish
```

自动修复部分元数据问题：

```bash
gh skill publish --fix
```

这个命令还会检查仓库的 secret scanning、code scanning、标签保护和不可变 Release 等供应链安全配置。([The GitHub Blog][3])

---

## 五、规范的版本发布流程

推荐使用语义化版本：

```text
v1.0.0
│ │ │
│ │ └─ 修复：描述优化、错误处理改进
│ └─── 功能：增加新的检查流程
└───── 破坏性变化：输出格式或行为发生重大变化
```

首次发布：

```bash
git add .
git commit -m "feat: add nuxt4 code review skill"

git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main
git push origin v1.0.0

gh release create v1.0.0 \
  --title "v1.0.0" \
  --generate-notes
```

用户安装时应尽量固定版本：

```bash
gh skill install your-name/my-ai-skills \
  nuxt4-code-review@v1.0.0 \
  --pin v1.0.0
```

不要只让用户安装永远变化的 `main` 分支。Skill 中的指令和脚本可以影响 Agent 行为，版本固定、Git 标签和不可变 Release 能降低内容被静默替换的风险。([The GitHub Blog][3])

---

## 六、测试不能只测试“能不能运行”

一个规范的 Skill 至少要测试四方面：

| 测试类型 | 检查内容                   |
| -------- | -------------------------- |
| 触发测试 | 应该触发时是否加载 Skill   |
| 反向测试 | 不相关任务是否错误触发     |
| 流程测试 | 是否按照规定步骤执行       |
| 结果测试 | 输出格式和结果是否符合要求 |

例如：

```text
应该触发：
- 帮我检查这个 Nuxt 4 项目的安全问题
- Review this Nitro server route
- 检查这个 PR 是否存在 SSR 问题

不应该触发：
- 帮我写一个 Flutter 页面
- MongoDB 怎么创建索引
- 翻译这段英文
```

OpenAI 建议像测试应用程序一样测试 Skills：记录提示词、运行轨迹和产物，然后检查是否调用了正确 Skill、是否执行了预期命令以及输出是否符合约定。([OpenAI Developers][4])

可以在仓库中增加：

```text
skills/nuxt4-code-review/
└── tests/
    ├── trigger-cases.json
    ├── non-trigger-cases.json
    ├── expected-output.md
    └── fixtures/
```

---

## 七、安全发布清单

发布前重点检查：

```text
[ ] 不包含 API Key、Token、Cookie、SSH 私钥
[ ] 不包含公司内部域名和客户数据
[ ] 脚本不会默认执行 rm、git push、部署或数据库写入
[ ] 修改文件前要求用户确认
[ ] 网络访问范围已经说明
[ ] 外部依赖有固定版本
[ ] Shell 参数经过安全转义
[ ] 输出不会打印完整环境变量
[ ] 包含 LICENSE
[ ] 包含 CHANGELOG
[ ] 已创建版本标签和 Release
[ ] 已执行 skills-ref validate
[ ] 已执行 secret scanning
```

`allowed-tools` 可以声明预批准工具，例如：

```yaml
allowed-tools: Bash(git:*) Bash(pnpm:*) Read
```

但这个字段目前仍属于实验性字段，不同 Agent 的支持程度可能不同，因此不能只依赖它控制安全权限。([Agent Skills][2])

---

## 八、发布到哪里

### 1. GitHub：最推荐

适合公开、跨平台发布：

```text
GitHub Repository
    ↓
Git Tag / Release
    ↓
gh skill install
    ↓
Codex / Claude Code / Cursor / Copilot
```

这是目前最容易维护版本、审查代码和追踪来源的方式。

### 2. ChatGPT Workspace

ChatGPT Skills 支持从电脑上传 Skill，也可以分享给指定成员、群组或整个 Workspace。上传的 Skill 会经过扫描，但官方仍要求使用者自行检查来源、代码和风险。([OpenAI Help Center][5])

目前 ChatGPT Personal Skills 主要面向 Business、Enterprise、Healthcare 和 Edu；Codex 与 OpenAI API 也支持 Skills。因此你的界面暂时没有 Skills 页面时，仍可以优先采用 GitHub、Codex 或 API 发布方式。([OpenAI Help Center][5])

### 3. OpenAI API

API 可以上传目录，或者上传包含单一顶层目录的 ZIP：

```bash
zip -r nuxt4-code-review.zip nuxt4-code-review/
```

然后作为版本化 Skill 上传并挂载到 hosted shell 环境。([OpenAI Developers][6])

---

## 最推荐的落地标准

你的 Skills 仓库可以按这个标准执行：

```text
格式：Agent Skills 开放标准
托管：GitHub
目录：skills/<skill-name>/SKILL.md
许可证：MIT 或 Apache-2.0
版本：SemVer
发布：Git Tag + GitHub Release
校验：skills-ref validate + gh skill publish
安装：固定 tag，并启用 --pin
测试：触发、误触发、流程、结果四类测试
安全：只读优先，危险操作必须确认
维护：CHANGELOG + 弃用说明 + 迁移指南
```

对于你经常处理的内容，可以先整理成这些独立 Skills：

```text
nuxt4-code-review
nuxt4-api-generator
caddyfile-review
docker-compose-review
mongodb-query-optimizer
rocketmq-troubleshooter
cloudflare-worker-review
technical-design-document
```

不要做成一个巨大的 `fullstack-expert` Skill。范围越明确，`description` 越容易准确触发，测试、版本维护和跨 Agent 复用也会更可靠。

[1]: https://developers.openai.com/codex/build-skills "
Build skills | ChatGPT Learn
"
[2]: https://agentskills.io/specification "Specification - Agent Skills"
[3]: https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/ "Manage agent skills with GitHub CLI - GitHub Changelog"
[4]: https://developers.openai.com/blog/eval-skills "
Testing Agent Skills Systematically with Evals | OpenAI Developers
"
[5]: https://help.openai.com/en/articles/20001066-skills-in-chatgpt "Skills in ChatGPT | OpenAI Help Center"
[6]: https://developers.openai.com/api/docs/guides/tools-skills "
Skills | OpenAI API
"
