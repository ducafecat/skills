# Changelog

## 1.4.0 — 2026-10-27

- 所有偏好选项默认「无限制自由发挥」，移除科技蓝、抽象几何、无文字等预设。
- 新增分组风格目录，询问时展示全部选项，支持单选、多选、混搭、自定义。
- 开放 3D、玻璃、金属、霓虹、插画等表现，保留可编辑 SVG、授权与安全要求。
- 自由发挥六稿至少覆盖四种视觉家族，同步调整画廊文案与再生成反馈。
- 更新 brief 示例与验收规范，保留用户明确约束优先。

## 1.3.0 — 2026-10-27

- 增加真实 Logo 品牌案例研究（至少四例、至少两个站点）：Logosystem、LogoArchive、Dribbble、Behance、LogoLounge、Brand New。
- 新增 `references/design-research.md`，区分「设计案例」与「可分析源 SVG 的开源图标」。
- 在 `research.json` 中新增 `designReferences[]`；在 `candidates.json` 增加 `designReferenceIds[]`。
- HTML 画廊增加「品牌 Logo 案例研究」，每份候选稿展示关联设计原则与来源链接；未授权案例图片不自动复制或内嵌。
- 为 SVG 素材卡片增加许可证原文链接，保持图片与著作权信息可追溯。
- 对外部改造 SVG 强制核对候选的源 URL 与 license 和研究记录相符。
- 支持将 Iconify 作为搜索入口，同时追溯上游集合许可；不将 Iconify API 的 MIT 当作素材许可证。
- 加强网站导航横版 Logo 和 Favicon 16/32 px 的交付要求。
- 保留 6 款可编辑 SVG、交互选稿、下载、确认、反馈重画、演示预览与离线 HTML 能力。
- **兼容性提醒：** 旧 v1.2.1 `research.json` 须重新补充真正核查过的设计案例；`--demo` 仅作预览，不能替代正式来源核查。
