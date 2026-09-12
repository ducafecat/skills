// 表面组件：统一玻璃背景、模糊、边框、裁切和阴影。
import 'dart:ui';

import 'package:flutter/material.dart';

import '../style/index.dart';

/// 文件作用：
/// - 磨砂玻璃表面：ClipRRect + BackdropFilter + 半透明 / 渐变 + 细边框
///
/// 磨砂玻璃表面：ClipRRect + BackdropFilter + 半透明/渐变 + 细边框。
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma = AppGlass.blurHeader,
    this.enableBlur = true,
    this.gradient,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
    this.width,
    this.height,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final bool enableBlur;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final glassEnabled = context.appStyle.glassEnabled;
    final fill = glassEnabled
        ? color ?? AppGlass.cardFillOf(context)
        : context.appSurface;
    final border = borderColor ?? AppGlass.borderOf(context);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: glassEnabled ? gradient : null,
        color: glassEnabled && gradient != null ? null : fill,
        borderRadius: radius,
        border: borderWidth > 0
            ? Border.all(color: border, width: borderWidth)
            : null,
      ),
      // 让ListTile和InkWell在表面上方绘制交互反馈，不被玻璃背景盖住。
      child: Material(type: MaterialType.transparency, child: child),
    );

    if (enableBlur && glassEnabled) {
      content = ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    } else if (radius != BorderRadius.zero) {
      // 关 blur 时仍裁圆角，避免子组件画出圆角外。
      content = ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    if (boxShadow case final List<BoxShadow> shadows when shadows.isNotEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
        child: content,
      );
    }

    return content;
  }
}
