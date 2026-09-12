// 列表组件：基础列表项、卡片列表行及设置项分组。
import 'package:flutter/material.dart';

import '../style/index.dart';

import 'card.dart';

/// 列表项
class ListTileWidget extends StatelessWidget {
  const ListTileWidget({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.leadingSpace,
    this.trailing,
    this.trailingSpace,
    this.padding,
    this.crossAxisAlignment,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.borderWidth,
    this.elevation,
    this.backgroundColor,
  });

  /// 标题
  final Widget? title;

  /// 子标题
  final Widget? subtitle;

  /// 左侧图标
  final Widget? leading;

  /// 左侧图标间距
  final double? leadingSpace;

  /// 右侧图标
  final List<Widget>? trailing;

  /// 右侧图标间距
  final double? trailingSpace;

  /// padding 边框间距
  final EdgeInsetsGeometry? padding;

  /// cross 对齐方式
  final CrossAxisAlignment? crossAxisAlignment;

  /// 点击事件
  final GestureTapCallback? onTap;

  /// 长按事件
  final GestureLongPressCallback? onLongPress;

  /// 圆角
  final double? borderRadius;

  /// 边框
  final double? borderWidth;

  /// 阴影
  final double? elevation;

  /// 背景色
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    // 直接保留 EdgeInsetsGeometry，避免左右/上下总和被重复应用。
    return Material(
      color: backgroundColor ?? context.appSurface,
      elevation: elevation ?? 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.card),
        side: borderWidth != null && borderWidth! > 0
            ? BorderSide(color: context.appBorder, width: borderWidth!)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.card),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: leadingSpace ?? AppSpacing.sm),
              ],
              if (title != null || subtitle != null)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        crossAxisAlignment ?? CrossAxisAlignment.start,
                    children: [?title, ?subtitle],
                  ),
                ),
              if (trailing?.isNotEmpty == true) ...[
                SizedBox(width: trailingSpace ?? AppSpacing.sm),
                Row(mainAxisSize: MainAxisSize.min, children: trailing!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 文件作用：
/// - 通用列表行卡片（订阅频道 / Profile 入口共用）
///
/// 通用列表行卡片（对应原型 `.list-card`）。
///
/// 订阅频道列表、Profile 功能入口共用：leading + 标题/副标题 + trailing。
class ListRowCard extends StatelessWidget {
  const ListRowCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.footer,
    this.padding,
    this.subtitleSpacing = 2,
    this.titleMaxLines,
    this.titleOverflow,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? footer;

  /// 特殊密集列表可收紧卡片留白，默认保持全局 16px 节奏。
  final EdgeInsetsGeometry? padding;

  /// 标题与副标题的垂直间距；默认值维持现有列表视觉。
  final double subtitleSpacing;

  /// 紧凑列表可限制标题行数，给操作按钮保留稳定空间。
  final int? titleMaxLines;

  /// 与 [titleMaxLines] 搭配使用时的标题溢出策略。
  final TextOverflow? titleOverflow;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      enableBlur: false,
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(AppSpacing.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leading case final Widget widget) ...[
                widget,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: context.appCardFg,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: titleMaxLines,
                      overflow: titleOverflow,
                    ),
                    if (subtitle case final String text) ...[
                      SizedBox(height: subtitleSpacing),
                      Text(text, style: AppTextStyles.captionOn(context)),
                    ],
                  ],
                ),
              ),
              if (trailing case final Widget widget) widget,
            ],
          ),
          if (footer case final Widget widget) ...[
            const SizedBox(height: 8),
            widget,
          ],
        ],
      ),
    );
  }
}

/// 文件作用：
/// - 设置项行 + 分组容器
///
/// 设置项行组件。
///
/// 职责：
/// - 提供统一的左右布局：leading / label / trailing。
/// - 通过 InkWell 保留 Material 点击反馈。
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    this.trailing,
    this.leading,
    this.onTap,
  });

  final String label;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // pattern matching 写法可避免先判空再强转。
            if (leading case final Widget widget) ...[
              widget,
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(label, style: AppTextStyles.bodyOn(context))),
            if (trailing case final Widget widget) widget,
          ],
        ),
      ),
    );
  }
}

/// 设置分组容器。
///
/// 职责：
/// - 把多个 SettingsTile 组合成带边框、圆角和分隔线的组。
/// - 统一处理首尾裁剪，保证涟漪和内容不会溢出圆角。
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    // 在子项之间插入分隔线，避免调用方手动维护 Divider。
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(height: 1, color: context.appBorder));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: context.appBorder),
        boxShadow: context.appStyle.cardShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: items),
    );
  }
}
