// 卡片组件：通用玻璃卡片与数字统计卡片。
import 'package:flutter/material.dart';

import '../style/index.dart';

import 'surface.dart';

/// 文件作用：
/// - 圆角玻璃卡片壳；密集列表默认关 blur
///
/// 圆角玻璃卡片壳。密集列表默认关闭 blur。
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.enableBlur = false,
    this.blurSigma = AppGlass.blurLight,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final bool enableBlur;
  final double blurSigma;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.card);

    final surface = GlassSurface(
      borderRadius: radius,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      color: AppGlass.cardFillOf(context),
      borderColor: context.appBorder,
      boxShadow: AppGlass.softShadowOf(context),
      clipBehavior: clipBehavior,
      // 点击反馈位于玻璃绘制层之上，与背景和裁剪共用圆角。
      child: onTap == null
          ? Padding(padding: padding ?? EdgeInsets.zero, child: child)
          : InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
            ),
    );

    return surface;
  }
}

/// 文件作用：
/// - Profile 已读 / 收藏数字统计卡片
///
/// 数字统计卡片（对应原型 `.stat-card`），用于 Profile 的已读/收藏计数展示。
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      enableBlur: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.sectionTitle.copyWith(
              color: context.appCardFg,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.captionOn(context)),
        ],
      ),
    );
  }
}
