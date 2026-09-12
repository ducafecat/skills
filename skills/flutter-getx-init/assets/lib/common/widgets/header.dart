// 标题组件：页面顶部导航与内容分区标题；动作按钮见 button.dart。
import 'package:flutter/material.dart';

import '../style/index.dart';

import 'button.dart';
import 'surface.dart';

/// 文件作用：
/// - 页面顶部导航行（标题 / 返回 / 右侧动作）
///
/// 页面顶部导航行（对应组件抽取规范 `TopBar`）。
///
/// 统一标题、返回、右侧动作的布局。`transparent` 用于播放器悬浮态、详情页
/// 无背景态等不需要底部分割线的场景；`onBack` 未传 `leading` 时会自动生成
/// 一个返回按钮，减少页面重复写 `IconButton(onPressed: () => context.pop())`。
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    this.leading,
    this.onBack,
    this.title,
    this.trailing,
    this.centered = true,
    this.transparent = false,
    this.foregroundColor,
  });

  final Widget? leading;
  final VoidCallback? onBack;
  final String? title;
  final List<Widget>? trailing;
  final bool centered;
  final bool transparent;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? context.appCardFg;
    final resolvedLeading =
        leading ??
        (onBack == null
            ? null
            : GlassIconButton(
                semanticLabel: '返回',
                onPressed: onBack,
                icon: Icons.arrow_back_rounded,
                color: fg,
              ));

    final titleWidget = title == null
        ? null
        : Text(title!, style: AppTextStyles.pageTitle.copyWith(color: fg));

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: 8,
      ),
      child: Row(
        children: [
          if (resolvedLeading != null || centered)
            SizedBox(
              width: 48,
              child: resolvedLeading ?? const SizedBox.shrink(),
            ),
          Expanded(
            child: titleWidget == null
                ? const SizedBox.shrink()
                : Align(
                    alignment: centered
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: titleWidget,
                  ),
          ),
          trailing == null
              ? SizedBox(width: centered ? 48 : 0)
              : Row(mainAxisSize: MainAxisSize.min, children: trailing!),
        ],
      ),
    );

    if (transparent) return row;

    return GlassSurface(
      enableBlur: true,
      blurSigma: AppGlass.blurHeader,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: AppGlass.headerGradientOf(context),
      ),
      borderColor: AppGlass.borderOf(context),
      borderWidth: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppGlass.borderOf(context))),
        ),
        child: row,
      ),
    );
  }
}

/// 文件作用：
/// - 分区标题（label 样式 + 可选 trailing）
///
/// 分区标题组件。
///
/// 职责：
/// - 用统一的 label 样式展示 section 标题。
/// - 支持右侧 trailing 操作，例如“查看全部”按钮或筛选入口。
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelOn(context),
          ),
        ),
        // Dart pattern matching：仅在 trailing 非空时渲染右侧组件。
        if (trailing case final Widget widget) widget,
      ],
    );
  }
}
