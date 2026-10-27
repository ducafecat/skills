# design-logo Skill v1.4.0

用于网站和 App 的品牌 Logo 设计：**一问一答 → 真实 Logo 案例研究 → 开源 SVG 许可核查 → 六款原创 SVG → HTML 交互选稿 → 反馈重绘 → 确认导出**。

所有偏好选项默认 **无限制自由发挥**。询问风格时完整展示 [设计风格目录](references/design-styles.md)，支持单选、多选、混搭和自定义，包含文字、手绘、吉祥物、复古、3D、玻璃、金属、霓虹等方向。自由发挥的六稿至少覆盖四种视觉家族；用户限定风格时按其要求探索。旧版科技几何示例只演示格式，不代表默认审美。

> **v1.3.0 新增：** 不再只研究 Tabler / Lucide / SVG Repo 图标。加入 Logosystem、LogoArchive、Dribbble、Behance、LogoLounge、Brand New 的**品牌设计案例**分析；HTML 画廊同时显示每个候选引用的案例（文字+出处）与真实 SVG 参考（图形+许可证）。增加网站横版 Logo 和 16/32 px Favicon 的交付要求。

## 目录结构

```text
design-logo/
├── SKILL.md
├── scripts/
│   └── build-gallery.mjs
├── references/
│   ├── design-rules.md
│   ├── design-research.md           # v1.3.0 新增：Logo 案例检索与研究
│   └── licensing.md                # 更新：SVG / Iconify / 品牌版权
├── assets/
│   ├── brief.example.json
│   ├── candidates.example.json
│   └── research.example.json       # 更新：designReferences[]
└── examples/
    ├── round-01/
    └── gallery.html
```

安装时将整个 `design-logo/` 目录放到所用 Agent 的项目 Skill 发现目录（如 `.agents/skills/design-logo/`），或在对话中明确要求 Agent 读取 `SKILL.md`。Node.js 20+，构建 HTML 不需要 npm 安装。

## 使用命令

在支持 Agent Skills 的助手中输入：

> 执行 design-logo，为 ducafecat.com 设计网站和 App Logo，按 SKILL.md 一问一答。先参考真实品牌 Logo 案例的构图规律，再研究 Tabler、Lucide、SVG Repo 的 SVG 和授权，可用 Iconify 搜索。生成六套可编辑 SVG，给出 HTML 交互画廊供我选稿，未查证的资源一律标注未知，不要伪称已核验。

正常流程的正式构建：

```bash
node .agents/skills/design-logo/scripts/build-gallery.mjs \
  --input design/logo/work/round-01 \
  --output design/logo/work/gallery.html
```

**正式构建门槛（两个独立研究库）：**

1. `research.json.designReferences` 至少 **4 个**实际打开并观察的具体 Logo 案例，来自至少 **2 个平台**；只保留原创设计原则、具体出处和禁止照搬的特征，不擅自打包案例 Logo 图片。
2. `research.json.librariesReviewed` 包含 Tabler Icons、Lucide、SVG Repo 真实访问记录；`icons` 至少 **12 个**逐项审查的 SVG，原始 SVG 存放于本轮 `research/svg/`。Iconify 可以辅助搜索，但其 API 软件许可证不等于托管图标许可证，必须追溯源集合。
3. 六个方案均包含 `researchIds` 与 `designReferenceIds`（两者不要混用），可查到真实参考记录。
4. 脚本强制检查 JSON 结构、文件存在、受限 SVG 标签和引用 ID；**它不联网判断版权或商标是否真的许可**，真实性由执行 Agent 实际检索并留证负责。

画廊会显示六稿、深浅色预览、源 SVG、Logo 案例方法研究和授权出处。选稿后可下载草稿 SVG / PNG、复制确认指令或反馈下一轮的重新生成指令。静态 HTML 自身不会直接调用 AI 或自动改写项目。

## 演示模式（不等于已授权的正式研究）

```bash
node .agents/skills/design-logo/scripts/build-gallery.mjs \
  --input .agents/skills/design-logo/examples/round-01 \
  --output /tmp/design-logo-demo.html \
  --demo
```

演示数据没有真实完整研究，页面会明确提示“研究未完成”；正式项目严禁以 `--demo` 规避研究门槛后宣称可商用。`examples/gallery.html` 是随附的示例 HTML，可以直接浏览。

## 正式交付目录

用户确认后才写 `assets/icons/`，按平台需要输出：`logo.svg`, `logo-monochrome.svg`, `logo-horizontal.svg`, `favicon-16.png`, `favicon-32.png`, `logo-transparent.png`, `app-icon-ios.png`, `app-icon-android.png`, `adaptive-foreground.png`, `adaptive-background.png`, `preview.png`, `LICENSES.md`, `RESEARCH.md`。

没有本地 PNG 渲染器则说明限制，不伪报成功；商标近似检索和法务结论不是本 Skill 的自动保证。

## 升级注意

- 原 v1.2.1 的 `research.json` 没有 `designReferences[]` 时，**不能直接通过 v1.3.0 正式构建**；需要真正补做 Logo 案例研究，而不是填假数据。
- 每个候选新增 `designReferenceIds` 字段；旧案例库的演示数据仍可用 `--demo` 预览。
- Iconify 是可选发现工具，不会放宽原有三图库/真实 SVG 校验。
