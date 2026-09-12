// 按钮组件：基础按钮、项目主次按钮、玻璃图标按钮和顶部动作按钮统一在此维护。
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../style/index.dart';

import 'surface.dart';
import 'widget_scale.dart';

/// 按钮样式
enum ButtonWidgetVariant {
  primary,
  secondary,
  destructive,
  outline,
  ghost,
  link,
  icon,
}

/// 按钮
class ButtonWidget extends StatefulWidget {
  /// 按钮样式
  final ButtonWidgetVariant variant;

  /// 按钮尺寸
  final WidgetScale scale;

  /// tap 事件
  final Function()? onTap;

  /// 文字字符串
  final String? text;

  /// 文字颜色
  final Color? textColor;

  /// 子组件
  final Widget? child;

  /// 图标
  final Widget? icon;

  /// 圆角
  final double? borderRadius;

  /// 背景色
  final Color? backgroundColor;

  /// 边框色
  final Color? borderColor;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 启用
  final bool enabled;

  /// 图标和文字的间距
  final double? iconSpace;

  /// 是否loading
  final bool? loading;

  /// 是否反转
  final bool? reverse;

  /// 主轴对齐方式
  final MainAxisAlignment? mainAxisAlignment;

  /// 主轴尺寸
  final MainAxisSize? mainAxisSize;

  /// 阴影
  final double? elevation;

  const ButtonWidget({
    super.key,
    this.variant = ButtonWidgetVariant.primary,
    this.scale = WidgetScale.medium,
    this.onTap,
    this.text,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.width,
    this.height,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  });

  /// raw
  const ButtonWidget.raw({
    super.key,
    required this.variant,
    required this.scale,
    this.onTap,
    this.text,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.width,
    this.height,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  });

  /// 主要
  const ButtonWidget.primary(
    this.text, {
    super.key,
    this.scale = WidgetScale.medium,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  }) : variant = ButtonWidgetVariant.primary;

  /// 次要
  const ButtonWidget.secondary(
    this.text, {
    super.key,
    this.scale = WidgetScale.medium,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  }) : variant = ButtonWidgetVariant.secondary;

  // destructive 警告
  const ButtonWidget.destructive(
    this.text, {
    super.key,
    this.scale = WidgetScale.medium,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  }) : variant = ButtonWidgetVariant.destructive;

  // outline
  const ButtonWidget.outline(
    this.text, {
    super.key,
    this.scale = WidgetScale.medium,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  }) : variant = ButtonWidgetVariant.outline;

  // ghost
  const ButtonWidget.ghost(
    this.text, {
    super.key,
    this.scale = WidgetScale.medium,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  }) : variant = ButtonWidgetVariant.ghost;

  // link
  const ButtonWidget.link(
    this.text, {
    super.key,
    this.scale = WidgetScale.medium,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  }) : variant = ButtonWidgetVariant.link;

  // icon
  const ButtonWidget.icon(
    this.icon, {
    super.key,
    this.scale = WidgetScale.medium,
    this.text,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.child,
    this.backgroundColor,
    this.borderColor,
    this.enabled = true,
    this.iconSpace,
    this.loading,
    this.textColor,
    this.reverse,
    this.mainAxisAlignment,
    this.mainAxisSize,
    this.elevation,
  }) : variant = ButtonWidgetVariant.icon;

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final factor = switch (widget.scale) {
      WidgetScale.small => 0.8,
      WidgetScale.medium => 1.0,
      WidgetScale.large => 1.3,
    };
    final foreground =
        widget.textColor ??
        switch (widget.variant) {
          ButtonWidgetVariant.primary => context.appPrimaryFg,
          ButtonWidgetVariant.destructive => context.appDestructiveFg,
          ButtonWidgetVariant.secondary => context.appForeground,
          _ => context.appPrimary,
        };
    final background =
        widget.backgroundColor ??
        switch (widget.variant) {
          ButtonWidgetVariant.primary => context.appPrimary,
          ButtonWidgetVariant.destructive => context.appDestructive,
          ButtonWidgetVariant.secondary => context.appMuted,
          _ => Colors.transparent,
        };
    final enabled =
        widget.enabled && widget.onTap != null && widget.loading != true;
    final children = <Widget>[
      ?widget.icon,
      ?widget.child,
      if (widget.text?.isNotEmpty == true)
        Text(widget.text!, textAlign: TextAlign.center),
      if (widget.loading == true)
        SizedBox.square(
          dimension: 16 * factor,
          child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
        ),
    ];
    final ordered = widget.reverse == true
        ? children.reversed.toList()
        : children;
    // 用原生按钮统一禁用、键盘激活、涟漪及无障碍语义。
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextButton(
        onPressed: enabled ? widget.onTap : null,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          disabledForegroundColor: foreground.withValues(alpha: 0.5),
          backgroundColor: background,
          minimumSize: Size(AppSpacing.touch, AppSpacing.touch),
          padding: EdgeInsets.symmetric(
            horizontal: widget.variant == ButtonWidgetVariant.icon
                ? 0
                : AppSpacing.md * factor,
            vertical: AppSpacing.xs * factor,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: widget.elevation ?? 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.button,
            ),
            side:
                widget.variant == ButtonWidgetVariant.outline ||
                    widget.borderColor != null
                ? BorderSide(color: widget.borderColor ?? context.appBorder)
                : BorderSide.none,
          ),
          textStyle: AppTextStyles.body.copyWith(
            fontSize: AppTextStyles.body.fontSize! * factor,
          ),
        ),
        child: Row(
          mainAxisSize: widget.mainAxisSize ?? MainAxisSize.min,
          mainAxisAlignment:
              widget.mainAxisAlignment ?? MainAxisAlignment.center,
          spacing: widget.iconSpace ?? AppSpacing.xs * factor,
          children: ordered,
        ),
      ),
    );
  }
}

enum AppButtonVariant { primary, ghost, destructive }

enum AppButtonSize { normal, prominent }

/// 按钮统一入口：加载时保留标签布局但隐藏绘制，避免替换为spinner后宽度跳动。
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.loading = false,
    this.enabled = true,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool loading;
  final bool enabled;
  final AppButtonVariant variant;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;
    final fg = variant == AppButtonVariant.ghost
        ? context.appForeground
        : variant == AppButtonVariant.destructive
        ? context.appDestructiveFg
        : context.appPrimaryFg;
    final bg = variant == AppButtonVariant.ghost
        ? context.appSurface
        : variant == AppButtonVariant.destructive
        ? context.appDestructive
        : context.appPrimary;
    final style =
        FilledButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: bg,
          // 加载用原色及原文案占位；真正disabled由Material提供不可用反馈。
          disabledForegroundColor: loading ? fg : null,
          disabledBackgroundColor: loading ? bg : null,
          minimumSize: Size(48, size == AppButtonSize.prominent ? 48 : 42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          // 按钮使用紧凑行高并均分上下留白，避免正文行高使文字视觉偏下。
          textStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
            leadingDistribution: TextLeadingDistribution.even,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          side: variant == AppButtonVariant.ghost
              ? BorderSide(color: context.appFocus)
              : null,
        ).copyWith(
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? BorderSide(color: context.appFocus, width: 2)
                : variant == AppButtonVariant.ghost
                ? BorderSide(color: context.appFocus)
                : BorderSide.none,
          ),
        );
    final button = Semantics(
      button: true,
      enabled: active,
      liveRegion: loading,
      onTap: active ? onPressed : null,
      label: loading ? '${trOr(TrKeys.processing, '处理中')}: $label' : label,
      child: ExcludeSemantics(
        child: FilledButton(
          onPressed: active ? onPressed : null,
          style: style,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: loading ? 0 : 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(child: Text(label, textAlign: TextAlign.center)),
                  ],
                ),
              ),
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                ),
            ],
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// 旧调用名称作为薄入口，主次按钮复用同一状态与视觉实现。
class PrimaryButton extends AppButton {
  const PrimaryButton({
    super.key,
    required super.label,
    super.onPressed,
    super.icon,
    super.expanded,
    super.loading,
    super.enabled,
    super.size,
    super.variant,
  });
}

class GhostButton extends AppButton {
  const GhostButton({
    super.key,
    required super.label,
    super.onPressed,
    super.icon,
    super.expanded,
    super.loading,
    super.enabled,
    super.size,
  }) : super(variant: AppButtonVariant.ghost);
}

/// 圆形玻璃是32逻辑像素，外围48触控区域不缩小，确保键盘及触屏均可操作。
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.color,
    this.onMedia = false,
    this.size = 32,
    this.iconSize = 20,
  });
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color? color;
  final bool onMedia;
  final double size;
  final double iconSize;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: semanticLabel,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size(48, 48),
      padding: EdgeInsets.zero,
    ),
    // 图片上的返回按钮固定深底，亮色主题也保持可见。
    icon: onMedia
        ? Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppMediaColors.scrim,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: AppMediaColors.foreground),
          )
        : GlassSurface(
            width: size,
            height: size,
            borderRadius: BorderRadius.circular(size / 2),
            blurSigma: AppGlass.blurLight,
            color: AppGlass.iconFillOf(context),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: onPressed == null
                    ? context.appMutedFg
                    : color ?? context.appForeground,
              ),
            ),
          ),
  );
}

/// 顶部文字动作：视觉高32，外层触控区至少48，不复用正文按钮的42/48视觉高度。
class TopBarAction extends StatelessWidget {
  const TopBarAction({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  static const double visualHeight = 32;
  static const double touchExtent = 48;

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;
    final foreground = active || loading
        ? context.appPrimaryFg
        : context.appMutedFg;
    final background = active || loading
        ? context.appPrimary
        : context.appMuted;
    final scaledVisualHeight = math.max(
      visualHeight,
      10 + MediaQuery.textScalerOf(context).scale(13) * 1.5,
    );

    return Semantics(
      button: true,
      enabled: active,
      liveRegion: loading,
      label: loading ? '$label，处理中' : label,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: touchExtent),
          child: SizedBox(
            height: scaledVisualHeight + 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: active ? onPressed : null,
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: Padding(
                  // 透明留白属于触控区，不绘制成橙色按钮。
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    height: scaledVisualHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: loading ? 0 : 1,
                          child: Text(
                            label,
                            style: AppTextStyles.secondary.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (loading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foreground,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
