// 标签组件：分类胶囊与横向筛选标签组。
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../style/index.dart';

/// 分类胶囊的唯一视觉实现；点击区域由外层筛选控件负责扩展到至少48像素。
class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    super.key,
    required this.label,
    this.color,
    this.selected = false,
    this.showDot = true,
  }) : _onTap = null;

  /// 交互胶囊在背景上方创建独立 ink 层，尺寸直接由内容撑开。
  const AppCategoryChip._interactive(
    this._onTap, {
    required this.label,
    required this.color,
    required this.selected,
    required this.showDot,
  });

  final VoidCallback? _onTap;
  final String label;
  final Color? color;
  final bool selected;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.appPrimary;
    final background = selected
        ? context.appPrimary
        : color?.withValues(alpha: 0.14) ?? context.appMuted;
    final border = selected
        ? context.appPrimary
        : color?.withValues(alpha: 0.40) ?? context.appBorder;

    final decoration = BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      border: Border.all(color: border),
    );
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDot) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: AppTextStyles.secondary.copyWith(
            color: selected ? context.appPrimaryFg : context.appForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
    const padding = EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    if (_onTap == null) {
      return Container(padding: padding, decoration: decoration, child: child);
    }
    // 先绘制背景，再绘制透明 Material 中的水波纹，最后绘制文字。
    return DecoratedBox(
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: _onTap,
          // 补上 Container 原本自动计算的 1px 边框留白，保持尺寸不变。
          child: Padding(
            padding: padding.add(decoration.padding),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 文件作用：
/// - 横向可滚动筛选 Chip 行（状态筛选 / 分类筛选共用）
/// - 半透明底 + 细边框，不做逐 Chip BackdropFilter

/// 筛选项。
class FilterChipItem {
  const FilterChipItem({required this.value, required this.label, this.color});

  final String value;
  final String label;

  /// 可选强调色（如分类名 HSL 哈希色）；为 null 时走主题默认 Chip 样式。
  final Color? color;
}

/// 横向可滚动筛选 Chip 行。
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<FilterChipItem> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final visualHeight = 12 + MediaQuery.textScalerOf(context).scale(13) * 1.5;
    return SizedBox(
      // 胶囊约32高，但外层点击区至少48；文字放大时同步增高，不能裁切。
      height: math.max(48, visualHeight + 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = item.value == selectedValue;
          final color = item.color;
          return Semantics(
            selected: selected,
            button: true,
            child: GestureDetector(
              // 外层透明留白仅扩大命中范围，不承载任何 ink 绘制。
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: () => onSelected(item.value),
              child: Center(
                widthFactor: 1,
                child: AppCategoryChip._interactive(
                  () => onSelected(item.value),
                  label: item.label,
                  color: color,
                  selected: selected,
                  showDot: color != null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
