import 'package:flutter/material.dart';

import '../style/index.dart';
import 'image.dart';
import 'text.dart';

enum IconWidgetType { icon, svg, img }

/// 图标组件
class IconWidget extends StatelessWidget {
  const IconWidget({
    super.key,
    required this.type,
    this.iconData,
    this.path,
    this.size,
    this.width,
    this.height,
    this.color,
    this.isDot,
    this.badgeString,
    this.fit,
    this.text,
    this.isVertical,
    this.onTap,
    this.isExpanded,
  });

  /// 图标类型
  final IconWidgetType type;

  /// 图标数据
  final IconData? iconData;

  /// 路径, asset , url
  final String? path;

  /// 尺寸
  final double? size;

  /// 宽
  final double? width;

  /// 高
  final double? height;

  /// 颜色
  final Color? color;

  /// 是否小圆点
  final bool? isDot;

  /// Badge 文字
  final String? badgeString;

  /// 图片 fit
  final BoxFit? fit;

  /// 图标文字
  final String? text;

  // 是否垂直
  final bool? isVertical;

  /// 是否扩展
  final bool? isExpanded;

  /// 点击事件
  final GestureTapCallback? onTap;

  const IconWidget.icon(
    this.iconData, {
    super.key,
    this.path,
    this.size,
    this.isExpanded = false,
    this.width,
    this.height,
    this.color,
    this.isDot,
    this.badgeString,
    this.fit,
    this.text,
    this.isVertical,
    this.onTap,
  }) : type = IconWidgetType.icon;

  const IconWidget.img(
    this.path, {
    super.key,
    this.iconData,
    this.size,
    this.width,
    this.height,
    this.color,
    this.isDot,
    this.badgeString,
    this.fit,
    this.text,
    this.isVertical,
    this.onTap,
    this.isExpanded,
  }) : type = IconWidgetType.img;

  const IconWidget.svg(
    this.path, {
    super.key,
    this.iconData,
    this.size,
    this.width,
    this.height,
    this.color,
    this.isDot,
    this.badgeString,
    this.fit,
    this.text,
    this.isVertical,
    this.onTap,
    this.isExpanded,
  }) : type = IconWidgetType.svg;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 24;
    Widget icon = switch (type) {
      IconWidgetType.icon => SizedBox(
        width: width,
        height: height,
        child: Icon(
          iconData,
          size: dimension,
          color: color ?? context.appForeground,
        ),
      ),
      _ => ImageWidget(
        path: path ?? '',
        type: type == IconWidgetType.svg
            ? ImageWidgetType.svg
            : ImageWidgetType.img,
        width: width ?? dimension,
        height: height ?? dimension,
        color: color,
        fit: fit,
        radius: 0,
      ),
    };
    if (isDot == true || badgeString != null) {
      icon = Badge(
        backgroundColor: context.appPrimary,
        textColor: context.appPrimaryFg,
        label: isDot == true ? null : Text(badgeString!),
        child: icon,
      );
    }
    // 仅水平方向扩展文字，避免无界高度下的 Expanded 断言。
    final label = text == null ? null : TextWidget.muted(text!);
    Widget child = icon;
    if (label != null) {
      child = isVertical == true
          ? Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xs,
              children: [icon, label],
            )
          : Row(
              mainAxisSize: isExpanded == true
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              spacing: AppSpacing.xs,
              children: [
                icon,
                isExpanded == true ? Expanded(child: label) : label,
              ],
            );
    }
    return onTap == null ? child : InkWell(onTap: onTap, child: child);
  }
}
