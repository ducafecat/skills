// 头像组件：图片、SVG、首字符头像与项目文字头像。
import 'package:flutter/material.dart';

import '../style/index.dart';

import 'image.dart';
import 'text.dart';

/// 头像类型
enum AvatarWidgetType { img, svg, text }

/// 头像组件
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.type,
    this.path,
    this.size,
    this.onTap,
    this.borderWidth,
    this.elevation,
    this.backgroundColor,
    this.padding,
    this.firstChar,
  });

  /// 类型
  final AvatarWidgetType type;

  /// 头像地址
  final String? path;

  /// 头像尺寸
  final double? size;

  /// padding 边框间距
  final EdgeInsetsGeometry? padding;

  /// 点击事件
  final GestureTapCallback? onTap;

  /// 边框
  final double? borderWidth;

  /// 阴影
  final double? elevation;

  /// 背景色
  final Color? backgroundColor;

  /// 首字符
  final String? firstChar;

  const AvatarWidget.img(
    this.path, {
    super.key,
    this.size,
    this.onTap,
    this.borderWidth,
    this.elevation,
    this.backgroundColor,
    this.padding,
    this.firstChar,
  }) : type = AvatarWidgetType.img;

  const AvatarWidget.svg(
    this.path, {
    super.key,
    this.size,
    this.onTap,
    this.borderWidth,
    this.elevation,
    this.backgroundColor,
    this.padding,
    this.firstChar,
  }) : type = AvatarWidgetType.svg;

  const AvatarWidget.text(
    this.firstChar, {
    super.key,
    this.path,
    this.size,
    this.onTap,
    this.borderWidth,
    this.elevation,
    this.backgroundColor,
    this.padding,
  }) : type = AvatarWidgetType.text;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? AppSpacing.touch;
    final value = firstChar?.trim() ?? '';
    final fallback = Center(
      child: TextWidget.body(
        value.isEmpty ? '?' : value.characters.first.toUpperCase(),
      ),
    );
    final imagePath = path?.trim() ?? '';
    final child = type == AvatarWidgetType.text || imagePath.isEmpty
        ? fallback
        : ImageWidget(
            path: imagePath,
            type: type == AvatarWidgetType.svg
                ? ImageWidgetType.svg
                : ImageWidgetType.img,
            width: dimension,
            height: dimension,
            fit: BoxFit.cover,
            radius: 0,
            errorWidget: fallback,
          );
    // 圆形 Material 同时负责裁切、边框、阴影及点击反馈。
    return SizedBox.square(
      dimension: dimension,
      child: Material(
        color: backgroundColor ?? context.appMuted,
        elevation: elevation ?? 0,
        shape: CircleBorder(
          side: BorderSide(color: context.appBorder, width: borderWidth ?? 0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

/// 文件作用：
/// - 圆形文字头像兜底（无图或加载失败时用）
///
/// 圆形文字头像（对应原型 `.avatar` / `.avatar-primary` / `.avatar-muted`）。
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.text,
    this.size = 40,
    this.background,
    this.foreground,
  });

  final String text;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? context.appMuted,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: foreground ?? context.appMutedFg,
        ),
      ),
    );
  }
}
