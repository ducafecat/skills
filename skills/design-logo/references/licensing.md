# SVG 素材许可 / 品牌案例版权 / 商标风险

## A. 开源 SVG（用于学习 SVG 结构，使用前逐项核查）

| 来源 | 官网 / 官方许可 | 默认检查方式 |
|---|---|---|
| Tabler Icons | https://tabler.io/icons · https://tabler.io/license | MIT；保留许可及版权声明 |
| Lucide | https://lucide.dev/icons · https://lucide.dev/license | ISC；部分由 Feather 派生的图标涉及 MIT 署名/许可义务，逐项查证 |
| SVG Repo | https://www.svgrepo.com/ · https://www.svgrepo.com/page/licensing | **逐个图标页面**查看其许可证，不能全站一刀切；可能存在 CC BY / CC BY-SA / CC BY-NC / 商标类限制 |
| Iconify | https://iconify.design/ · https://iconify.design/docs/api/ | 聚合站点；API 程序的 MIT 不适用于所有托管图标。检查每个图标所属集合、上游来源与集合许可 |

对于每个候选图形：

1. 记录来源详情页 URL 和许可证 URL，并实际读取许可条款。
2. 确认商业用途、修改权、著作权提示、署名、相同方式共享与其他义务。
3. 排除品牌商标、非商业许可、无法判断许可范围的素材。
4. 如果使用 Iconify 找到了某个 SVG，必须记录原始图标集或上游项目，不得将 Iconify 搜索结果等同于该图标的著作权声明。
5. 实际取得原始 SVG，用独立方法检查 SVG 文件是否存在和可解析。构建器只能审计本地文件及元数据格式，不能替代理解许可条款。
6. 作为最终品牌 Logo 时，优先完整原创路径，不应直接换色/换圆角复用通用 UI 图标。若派生自第三方 SVG，必须在交付记录中真实披露，且评估其商标独占性风险。

Iconify 的检索例子（联网可用时）：

- 搜索：`https://api.iconify.design/search?query=cat&prefix=lucide`
- 获取 SVG：`https://api.iconify.design/lucide/cat.svg`
- 查看集合：`https://api.iconify.design/collection?prefix=lucide`

上面只是 API 使用示例，**不能因为有这个 URL 就称其已经下载/审查过**。

## B. 品牌 Logo 案例（仅用于设计方法学习）

Logosystem / LogoArchive / Dribbble / Behance / LogoLounge / Brand New 的 Logo 案例通常归各自品牌和设计师所有。即便网页能看到图片、能下载，也**不能推定允许复制、改色、描摹或用作商业商标**。

- 记录具体案例链接、观察到的设计法则、与本品牌的相关性、避免复制的具体特征。
- HTML 画廊只展示案例的文字研究摘要和原始链接；不自动盗链或打包他人的 Logo 图像。
- 不把案例链接放到 SVG `researchIds`；仅用于 `designReferenceIds`。

## C. 原创性与商标

1. 许可、版权、商标权分别判断；开源图标许可不代表拥有独占商标权。
2. 自绘原创几何可记 `sourceType=original`、`license=original`；但若有参考案例，也要在研究备注中说明。
3. 对改编 SVG 使用 `sourceType=modified-open-source`，真实写入上游来源、许可与改造内容。
4. 正式商业发布前，建议人工检索相似商标与 App 图标；Skill 不能保证商标可注册。
5. 未联网或未取证的内容只能标记待验证或演示状态，不能伪造 `verified: true`。
