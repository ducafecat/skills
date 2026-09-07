---
name: deep-code-review
description: "审查 branch、PR、固定点或工作区代码变更；自动审查按规模与风险选择单 Agent 轻审或双 Agent 全审，并核查仓库标准、代码异味及按需路由的本地规则。"
---

审查用户指定范围；未指定固定点时只审查当前全部未提交变更。先用 Node helper 构建统一 manifest，再让 sub-agent 直接读取其中的 patch 文件。任何 ignored 路径和文档路径都不得进入 manifest、审查上下文或 finding。

文档不审查：`*.md`、`docs/**`、`.docs/**`。自动触发时若当前任务仅变更文档，不执行本 skill。用户显式要求审查文档时仍排除这些路径。

不查找外部需求 Spec。产品契约规则只检查 diff 和仓库中能够验证的可观察行为。

## 1. 构建审查输入

在本 skill 目录执行 `node scripts/build-review-manifest.mjs [--base <fixed-point>]`。

- 仅当用户显式指定 commit、branch、tag、`main`、`HEAD~5` 等固定点时传 `--base`。
- helper 成功时 stdout 只返回 `manifest.json` 的绝对路径；读取该文件，不要把完整 patch 复制进 sub-agent 任务文本。
- helper 统一收集 fixed-point 到 `HEAD` 的已提交变更（如适用）、staged、unstaged 和 untracked 文本变更，并处理 ignore、文档、binary、rename/copy 与特殊路径。
- `textFileCount` 为 0 时（含仅文档变更），不读取规则、不启动 sub-agent；删除 manifest 中的准确 `tempDirectory` 后报告没有可审查的文本变更。
- helper 失败或固定点无效时，在启动 sub-agent 前停止并报告错误。

## 2. 选择轻审或全审

只有自动触发的审查才可轻审。必须同时满足以下条件：

1. manifest 的 `sizeEligibleForLightReview` 为 `true`，即不超过 2 个文本文件且累计增删不超过 50 行；
2. diff 不包含下列高风险变更。

高风险包括：

- 认证、授权、凭证、加密、不可信输入、文件路径或模板渲染；
- 数据库读写或迁移、事务、锁、并发、缓存、网络扇出；
- 公共接口、跨模块边界、共享 abstraction；
- 生命周期、权限可见性、兼容迁移、幂等或外部集成契约；
- CI/CD、部署、容器、环境配置或依赖锁文件。

用户显式要求 code review、指定固定点、超过规模阈值或命中任一高风险条件时，执行全审。边界不明确时按全审处理。

## 3. 按需读取规则

- Standards：读取 `references/standards.md`，并读取 manifest 的 `standardSources`。
- AI rules：始终读取 `references/ai_review_rules/reviewer.md`，再按 changed paths 和 patch 内容选择直接相关的规则：
  - 安全边界：`security.md`
  - 模块和依赖边界：`architect.md`
  - 运行时性能：`runtime_performance.md`
  - 部署运维：`devops.md`
  - API/UI 可观察行为：`product_contract.md`

不要为追求覆盖率读取无关规则。一个变更确实跨多个领域时可读取多个文件。

## 4. 启动 sub-agent

所有 sub-agent 都使用 `fork_turns: "none"`，只传递 manifest 路径、项目用途、规则路径和任务边界。Agent 自行读取 manifest、非空 patch、相关规则与必要的最终文件上下文。

### 轻审

启动 1 个独立 sub-agent，同时执行 Standards 和 AI rules 审查，输出分为 `Standards` 与 `AI Review Rules`；AI rules 部分列出实际读取的规则文件。总输出不超过 500 中文字。

### 全审

并行启动两个彼此不共享结论的 sub-agent：

- Standards：读取 `references/standards.md` 和 manifest 的 `standardSources`，输出不超过 300 中文字。
- AI rules：读取 `reviewer.md` 及按需路由的角色规则，先列出实际读取文件，输出不超过 500 中文字。

### 共同约束

- 只报告 manifest patch 中新增、修改或删除造成的问题；必要上下文可以读取，但不得报告未修改代码。
- 每个 finding 必须包含严重程度、文件、行号、关键代码、问题、触发条件和实际影响。
- 只报告最终工作区仍存在且可复现推导的问题；删除证据不足、纯推测和后续层已修复的问题。
- `Critical` 表示可造成严重安全、数据或系统可用性损害；`Major` 表示正常场景下的功能错误或显著回归；`Minor` 表示范围有限但值得修正的问题。
- 不输出评分、表扬、泛化建议、默认修复代码或时间估算。无 finding 时只输出 `NO_FINDINGS`。

## 5. 核查与汇总

主 Agent 逐项核查：

1. 文件、行号和代码确实来自 manifest patch，路径未被 ignore；
2. 问题在最终工作区仍存在；
3. 触发条件和影响符合项目技术栈、用途与部署方式；
4. 合并重复 finding 但不因多 Agent 重复而提高严重程度。

最终报告保持三个部分：

- `## Standards`：经核实的 findings；没有则写“未发现问题”。
- `## AI Review Rules`：列出启用规则和经核实的 findings；没有则写“未发现问题”。
- `## Summary`：findings 总数、最高严重程度、剔除或合并数量。

只报告问题，不修改被审查代码。汇总完成后删除 manifest 中由 helper 创建的准确 `tempDirectory`。
