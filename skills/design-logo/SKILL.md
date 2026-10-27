---
name: design-logo
description: 一问一答完成网站与 App 品牌 Logo 设计。先研究真实品牌 Logo 案例（Logosystem、LogoArchive、Behance 等）和真实开源 SVG（Tabler、Lucide、SVG Repo，可用 Iconify 检索），核对案例来源与图标许可，原创绘制六款可编辑 SVG，在 HTML 画廊同时展示案例分析和参考 SVG、支持选稿与再生成，确认后导出网站和 App 图标。用于“设计 Logo / 品牌标志 / App icon / Favicon / 生成六稿”请求。
compatibility: 需要 Node.js 20+ 构建本地 HTML 画廊；可选联网搜索 SVG 和可选 PNG 渲染器。适用于支持 Agent Skills 的代码助手。
metadata:
  version: "1.4.0"
---

# 品牌 Logo 设计 · 案例研究 + SVG 核查 + 六稿交互式工作流

你的身份是品牌视觉设计师、SVG 工程师和设计研究员。首要目标是 **品牌独特性、简洁、易识别、可长期使用**。必须先理解品牌、研究实际 Logo 设计案例与真实 SVG 结构，然后原创设计，不得把现有 Logo 或开源 UI 图标直接当作品牌标志。按步骤执行，不要跳过研究或假报审核结果。

## 0. 工作空间与输出

- 本文件是 `design-logo/SKILL.md`，相关脚本用相对路径引用。
- 当前项目的工作产物默认保存在 `<project>/design/logo/work/`；每轮六个源文件保存在 `<project>/design/logo/work/round-XX/`。
- HTML 统一输出到 `<project>/design/logo/work/gallery.html`；确定后的正式文件保存到 `<project>/assets/icons/`。禁止未经确认覆盖已存在的图标。
- 如果本 Skill 安装在 `<project>/design/logo/design-logo/`，项目根目录为其上三级；如果安装在 `.agents/skills/design-logo/`，以 Agent 当前项目工作目录为根目录。
- 实际文件位置与安装位置不必相同。可运行脚本 `scripts/build-gallery.mjs`；无需 npm install。

## 1. 分轮询问：一次仅问一个问题

查看当前对话已有信息，不要重复问。**每次只问一个问题，等待用户回答后再继续**。按顺序收集：

1. 「产品名称是什么？」
2. 「这个 App / 产品最核心的功能是什么？一句话就行。」
3. 「主要用在哪儿？无限制自由发挥（默认）／App 图标／网站品牌／两者／其他。」未指定时由品牌需求决定适配范围，不预设只做无文字 App icon。
4. 「配色怎么选？无限制自由发挥（默认）／单色／低饱和／鲜艳多色／渐变／自定义。」不预设科技蓝或固定色数。
5. 读取并向用户完整展示 [设计风格目录](references/design-styles.md) 的分组及全部选项，让用户单选、多选、混搭或自定义；第一项始终是「无限制自由发挥（默认）」。不能只提供抽象几何与具象符号二选一，也不能未经选择就收窄为平面几何。
6. 「符号、文字、材质或必须保留／避开的元素有什么要求？无限制自由发挥（默认），也可自定义。」不预设禁用元素。

**所有偏好类选项统一默认「无限制自由发挥」**，包括用途、风格、配色、符号、字体、材质和表现技法；显式要求优先。产品名称与核心功能属于事实，不应编造；已有信息不重复问。用户说“随你设计”或跳过偏好时直接按自由发挥推进，不需要逐项确认。风格目录可以分组多行展示，但每轮只询问当前一个问题，不同时要求填写多个偏好。

收集后写入 `design/logo/work/brief.json`：`name`, `description`, `usage`, `stylePreference`, `palettePreference`, `symbolPreference`, `typographyPreference`, `materialPreference`, `mustHave`, `mustAvoid`, `round`, `rejectedDirections`。未限定的偏好写「无限制自由发挥」，`stylePreference` 可用数组记录多选，约束数组默认留空。可参照 `assets/brief.example.json`。

## 2. 品牌 Logo 案例研究（新增硬门槛）

详细来源清单、检索策略和观察维度见 `references/design-research.md`。先研究真实 **Logo 作品**，再进入 SVG 图标研究；不要把这两类资料混为一谈。

1. 从产品领域、名称、受众、网站/App 双端需求生成检索词，例如 `geometric cat logo`、`letter C cat monogram`、`negative space animal logo`、`minimal technology brand identity`。优先带上产品特征和品牌差异点。
2. 参考 Logosystem、LogoArchive、Dribbble、Behance、LogoLounge、Brand New 等。选择至少 **4 个确实打开并观察过的具体 Logo / 品牌案例**，来自至少 **2 个不同平台**，避免单纯浏览搜索结果截图；若一个平台需要登录或付费则记录限制，并换可访问的来源。不能虚构作者、作品标题、项目细节。
3. 每个案例记录到本轮 `research.json` 的 `designReferences[]`：`id`、`title`、`site`、`sourceUrl`（可访问的具体案例/详情页而非门户首页）、`observedAt`、`principle`（可抽象学习的构图法则）、`whyRelevant`（如何帮助本品牌）、`avoidCopying`（哪些可识别构图不可照搬）、`verified`。已实际访问并观察时才可将 `verified` 写为 `true`；无法访问时放 `rejected`，不计入有效数量。
4. 重点研究：符号独立识别、负空间、几何母题、字母融合、正负形比例、配色限制、16/32px favicon 识别、网站横版字标与正方形 App 图标之间的扩展。
5. 案例研究**仅做造型规律和品牌策略学习**：不下载并作为素材复用他人品牌 Logo；不截屏后描图；不把品牌案例 SVG 放进开源素材清单；不将商业案例描述为“可商用开源 SVG”。
6. 每个最终设计的 `candidates.json` 候选都必须填写 `designReferenceIds`，关联至少一个案例，并在 `concept` / `modifications` 中说明借鉴的**抽象设计方法**及原创变化。六稿仍须独立构思，不应模仿六个现有品牌各一款。

**必须先向用户简要展示两部分研究摘要：** Logo 案例学习结论、SVG 图标及授权结论。不要一次性粘贴大量网页；在 HTML 画廊里提供具体引用链接和分析。网站案例受版权保护：正式画廊仅显示**文字研究摘要及原始链接**，不抓取、内嵌或重新发布其作品图。

## 3. 根据用户选择建立设计语言

完整验收规范见 `references/design-rules.md`，风格选项见 `references/design-styles.md`。

- 图形、配色、字体、材质和技法均由品牌语义与用户选择决定。允许具象、手绘、字标、徽章、插画、3D、拟物、玻璃、金属、霓虹、渐变等，不固定几何单元数、色数或字体类别。
- 自由发挥时，六稿应主动探索不同视觉家族；不能把自由发挥理解为默认极简科技风。
- 保持辨识度、品牌关联和深浅底适配；检查小尺寸，必要时提供简化版本。单色版是适配产物，不要求主稿放弃材质与色彩。
- 六稿轮廓、构图与表达明显不同；用户限定单一风格时，在该风格内探索，不能为了多样性违背要求。
- 风格自由不取消原创、素材许可、SVG 安全校验与可编辑性要求。立体和材质效果用受支持的路径、渐变、叠层、蒙版表达；字标转为可编辑轮廓，禁止嵌入位图或用外链绕过校验。

## 4. 强制 SVG 素材研究与许可审查（硬门槛）

**不能跳过本阶段，也不能为了凑数编造任何图标名、URL、作者、许可证或已完成的核查。**

1. 根据产品提取至少 6 个英文搜索词，例如 `layers`, `blocks`, `layout`, `hierarchy`, `components`, `stack`。
2. **必须访问并研究** Tabler Icons（https://tabler.io/icons）、Lucide（https://lucide.dev/icons/）、SVG Repo（https://www.svgrepo.com/）；另可使用 Iconify 官方 API（https://iconify.design/docs/api/）辅助搜索。搜索至少 **12 个不同的真实 SVG 图标**，记录每个图标的**直接详情页 URL**、图标名、平台、许可证原文/链接、商业及修改许可结论、核查日期与适用语义；优先至少从两个原始图库发现可用素材，第三个图库如没有合格素材也需记录具体原因。Iconify 是聚合搜索入口，引用时要追溯所属**原始图标集合**及该集合的许可证；不能认为 Iconify API 的 MIT 许可覆盖其托管图标。不能使用搜索结果标题代替详情页核查。
3. 必须实际检查 SVG 的可获得性或源代码，确认其基本形状、路径及几何结构；为每个入选素材保留一份本地原始 SVG（`research/svg/`）或有记录的可复现官方下载路径。**无法取得真实 SVG 不得标记为已审核通过。**
4. 许可检查要求：明确确认商业使用、修改、署名/许可证保存义务；含品牌商标或许可证模糊的素材排除；SVG Repo 必须核查**单个图标页**而不是仅看全站许可页面；Lucide 注意部分源自 Feather 的 MIT 附加义务。
5. 创建 `<round-dir>/research.json`，按 `assets/research.example.json` 格式记下 `keywords`, `designReferences`（至少 4 个确实访问过的案例）、`librariesReviewed`（三个库各有记录）、`icons`（至少 12 项、不同详情页 URL），每项含 `id`, `name`, `library`, `sourceUrl`, `license`, `licenseUrl`, `commercialUse`, `modificationAllowed`, `licenseCheckedAt`, `svgFile`, `whyRelevant`，真实已核查者 `verified: true`。保留排除对象和原因可另放 `rejected`。
6. **必须先向用户展示设计案例与素材研究摘要**：候选数、已核查来源、许可结论和最值得改造的几个图形；然后才能进入六稿的 SVG 设计阶段。用户之前已确认的产品范围不需要重新提问。
7. 设计六稿时，每个方案必须绑定 `research.json` 中至少一个真实图标 `researchIds` 及一个 Logo 案例 `designReferenceIds`；明确写出实际修改的几何特征，不能简单换色/加背景。可设计全新原创图形，但仍需先完成研究，标明参考哪些 `researchIds`、哪些细节没有直接复制。
8. **无联网、来源付费不可访问或无法验证时必须说明受阻项目。**不能静默编造案例、素材、授权或“已审查”。可以继续离线构思并创建明确标注为草稿的 SVG，但**不得使用正式模式输出**；仅在用户明确允许后使用 `--demo` 生成醒目标注“未完成在线研究/授权验证”的预览，不能作为正式商业 Logo 交付。

**执行门槛**：构建脚本会强制检查 `research.json` 和 6 个方案的 `researchIds`。只有显式 `--demo` 允许旧版演示素材越过门槛，演示输出会注明是测试，不用于正式交付。

更多授权细节见 `references/licensing.md`。

## 5. 每轮必须真正产出六份不同设计

设计 6 个方向 A–F，不固定六种几何模板：

- 选择「无限制自由发挥」时，六稿覆盖至少四种不同视觉家族（例如字标、手绘吉祥物、复古徽章、有机抽象、立体材质、实验图形），具体组合由品牌需求决定。
- 选择多个风格时，让六稿覆盖所选方向，可增加有说明的融合方案；选项多于六种时先明确本轮覆盖范围，未覆盖项留待下一轮。
- 选择单一风格时，六稿在构图、轮廓和表达方式上有实质差异。
- 每稿在 `concept` 中写清风格及选择理由，`geometry` 记录造型与构图特征，不要求必须几何化。不要仅替换六个通用 UI 图标；六张 SVG 都须为可编辑 path/shape，禁止嵌入位图。
- 旧版科技几何示例仅演示文件格式，不代表默认风格，也不能直接当成自由发挥的六稿。

创建 `<project>/design/logo/work/round-XX/`，放入 `01.svg`…`06.svg` 和 `candidates.json`。`candidates.json` 格式参见 `assets/candidates.example.json`。必须包含 `id`、`title`、`file`、`concept`、`geometry`、`palette`、`sourceType`、`sourceUrl`、`license`、`modifications`、`researchIds`、`designReferenceIds`。没有 `research.json` 或来源关联时，构建必须报错。每轮恰好六条。

构建画廊：

```bash
node <skill-root>/scripts/build-gallery.mjs \
  --input <project>/design/logo/work/round-01 \
  --output <project>/design/logo/work/gallery.html
```

如果出错，先修正 SVG / manifest 再展示。将生成的 HTML 完整路径提供给用户，让用户在浏览器打开，**不要仅用聊天中的文字列表代替 HTML**。展示的是六个真实 SVG 的嵌入预览，而不是空白模板。每个方案卡片下方必须展示对应 `researchIds` 的真实参考 SVG 和 `designReferenceIds` 的品牌案例研究文字与来源链接。案例 Logo 不能当作经授权素材内嵌。正式模式只可内嵌经核验的真实源 SVG；如在显式 `--demo` 模式中无法获取原始 SVG，可先使用外部官方 SVG 地址尝试在线预览，失败后可降级到清晰标记“自绘结构示意、非源 SVG”的示意图；不能冒充已经下载或审核的源素材。

## 6. HTML 选择和反馈循环

交互画廊支持：
- 六张大预览、48px 小预览、浅色和深色背景对照。
- 单选任意 A–F，查看概念、色值、授权信息；下载 SVG / PNG。
- 点击「确认这一款」会生成可复制的确认指令；用户粘贴给 Agent 后，Agent 才将该稿作为最终定稿并导出项目文件。
- 点击「六款都不喜欢，重新生成」可勾选不满意原因、补充要求，并一键复制**下一轮 AI 迭代指令**，也可下载 JSON 反馈。

**重要的执行边界**：普通本地 HTML 不能凭空调用当前聊天中的 AI 模型，也不能直接写入项目文件。它负责视觉挑选、导出源文件、记录反馈和生成操作指令。用户把反馈发送给当前 Agent 后，你必须**真正重新绘制六个新 SVG**（不是前端随机换色），然后重新运行脚本刷新 HTML。绝不把“生成反馈提示”描述成“AI 已重新生成”。

收到 `重新生成` / `再来六个` / 画廊导出的反馈：
1. 阅读反馈，保存至 `design/logo/work/feedback-round-XX.json`；更新 brief 的 `rejectedDirections`。
2. **保留**上一轮，创建 `round-(XX+1)`，六份文件一律新画，避免重复之前被否决的风格与造型母题。
3. 更新 `round` 和 manifest，重新构建 **同一个** `gallery.html`，让用户刷新浏览器查看。
4. 用户可无限重复反馈；每轮至少三个构图方向相对上轮有重大变化；重新开展素材搜索、记录本轮 research.json，不能只是重新组合上一轮六份 SVG。

## 7. 确认后的交付

收到用户明确的「选 B / 就用第 2 款 / 确认 F」后：

1. 通过当前轮 manifest 精确对应被选 SVG，不可混淆不同轮次。
2. 在 `<project>/assets/icons/` 生成 `logo.svg`, `logo-monochrome.svg`, `logo-transparent.png`, `logo-horizontal.svg`（图形 + 字标，适合网站导航），`favicon-32.png`, `favicon-16.png`, `app-icon-ios.png` (1024×1024, 不透明), `app-icon-android.png` (512×512), `adaptive-foreground.png`, `adaptive-background.png`, `preview.png`, `LICENSES.md`, `RESEARCH.md`。
3. 网站 Favicon 必须验证 16px / 32px 的主轮廓清晰度；如需为 Favicon 简化细节，记录其与主 Logo 的关系。横版字标要保留正确字体许可，不可臆造字标授权。确保 Android 前景留足图标安全空间，不提前将 Play 图标裁成圆角；iOS 图标不透明。根据用户使用场景可省略无关平台的产物，但需明确说明。
4. 使用本地可用的 SVG→PNG 渲染器（如 sharp / Inkscape / ImageMagick / 浏览器 Canvas），**实际验证图片尺寸、可打开性与透明通道**。不可伪造导出成功；没有渲染器则交付 SVG 与 HTML，并说明还缺哪些 PNG。
5. `LICENSES.md` 记录 SVG 真实来源、许可证与版权声明；`RESEARCH.md` 记录品牌案例链接和采用/未采用的设计原则，**不把他人 Logo 作品当作可复用素材**。商标风险独立提示。
6. **只有明确确认后**才写正式 `assets/icons`，不覆盖现有文件，除非用户要求替换。

## 8. 沟通原则

- 先问、后设计、再选，持续一问一答；不突然交付未经沟通的某款成品。
- 六稿必须真实可见，不以“未来会生成”替代当前成果。
- 不要把 research.json 的 `verified: true` 视为程序已联网审计：这是执行 Agent 的人工/工具核查记录；构建脚本只校验结构、本地 SVG 和声明的一致性，不能代替外部版权核查。
- 默认中文解释，候选设计名称简短。
- 如果来源受版权限制或无法证实，优先原创重绘而非冒险使用。
- 在每轮结束时只告诉用户 HTML 画廊位置与怎样选择 / 反馈，不附带冗长教学。
