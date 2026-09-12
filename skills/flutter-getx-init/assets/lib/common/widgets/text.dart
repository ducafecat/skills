import 'package:flutter/material.dart';

import '../style/index.dart';
import 'widget_scale.dart';

// 排版类型
enum TextWidgetType { h1, h2, h3, h4, body, label, muted }

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    this.type,
    this.size,
    this.scale,
    this.textStyle,
    this.color,
    this.weight,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.fontStyle,
  });

  /// 文字
  final String text;

  /// 排版类型
  final TextWidgetType? type;

  /// 缩放 large medium small
  final WidgetScale? scale;

  /// 组件样式
  final TextStyle? textStyle;

  /// 字体样式
  final FontStyle? fontStyle;

  /// 颜色
  final Color? color;

  /// 大小
  final double? size;

  /// 重量
  final FontWeight? weight;

  /// 行数
  final int? maxLines;

  /// 自动换行
  final bool? softWrap;

  /// 溢出
  final TextOverflow? overflow;

  /// 对齐方式
  final TextAlign? textAlign;

  /// h1
  const TextWidget.h1(
    this.text, {
    super.key,
    this.scale,
    this.size,
    this.color,
    this.weight = FontWeight.w800,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.textStyle,
    this.fontStyle,
  }) : type = TextWidgetType.h1;

  /// h2
  const TextWidget.h2(
    this.text, {
    super.key,
    this.scale,
    this.size,
    this.color,
    this.weight = FontWeight.w600,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.textStyle,
    this.fontStyle,
  }) : type = TextWidgetType.h2;

  /// h3
  const TextWidget.h3(
    this.text, {
    super.key,
    this.scale,
    this.size,
    this.color,
    this.weight = FontWeight.w600,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.textStyle,
    this.fontStyle,
  }) : type = TextWidgetType.h3;

  /// h4
  const TextWidget.h4(
    this.text, {
    super.key,
    this.scale,
    this.size,
    this.color,
    this.weight = FontWeight.w600,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.textStyle,
    this.fontStyle,
  }) : type = TextWidgetType.h4;

  /// body
  const TextWidget.body(
    this.text, {
    super.key,
    this.scale,
    this.size,
    this.color,
    this.weight = FontWeight.w400,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.textStyle,
    this.fontStyle,
  }) : type = TextWidgetType.body;

  /// label
  const TextWidget.label(
    this.text, {
    super.key,
    this.scale,
    this.size,
    this.color,
    this.weight = FontWeight.w400,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.textStyle,
    this.fontStyle,
  }) : type = TextWidgetType.label;

  /// muted
  const TextWidget.muted(
    this.text, {
    super.key,
    this.scale,
    this.size,
    this.color,
    this.weight = FontWeight.w400,
    this.maxLines,
    this.softWrap,
    this.overflow,
    this.textAlign,
    this.textStyle,
    this.fontStyle,
  }) : type = TextWidgetType.muted;

  /// 先应用项目排版，再合并调用方样式，显式参数优先。
  @override
  Widget build(BuildContext context) {
    final base = switch (type) {
      TextWidgetType.h1 => AppTextStyles.display,
      TextWidgetType.h2 => AppTextStyles.pageTitle,
      TextWidgetType.h3 => AppTextStyles.sectionTitle,
      TextWidgetType.h4 => AppTextStyles.cardTitle,
      TextWidgetType.label => AppTextStyles.label,
      TextWidgetType.muted => AppTextStyles.secondary,
      _ => AppTextStyles.body,
    };
    final merged = base
        .copyWith(
          color: type == TextWidgetType.muted
              ? context.appMutedFg
              : context.appForeground,
          fontWeight: weight,
        )
        .merge(textStyle);
    final factor = switch (scale) {
      WidgetScale.small => 0.8,
      WidgetScale.large => 1.3,
      _ => 1.0,
    };
    return Text(
      text,
      style: merged.copyWith(
        color: color,
        fontSize: (size ?? merged.fontSize!) * factor,
        fontStyle: fontStyle,
      ),
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
