// 选项卡组件：分段、下划线和底部导航选项卡。
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../style/index.dart';

import 'surface.dart';

/// 两/多段分段控件：可见外框与48px触控区域分离。
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const double visualHeight = 40;
  static const double selectedVisualHeight = 32;
  static const double touchHeight = 48;

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textHeight = MediaQuery.textScalerOf(context).scale(13) * 1.5;
    final selectedHeight = math.max(selectedVisualHeight, textHeight + 12);
    final backgroundHeight = selectedHeight + 8;
    final totalHeight = math.max(touchHeight, backgroundHeight + 8);

    return SizedBox(
      height: totalHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            child: Container(
              height: backgroundHeight,
              decoration: BoxDecoration(
                color: context.appMuted,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == selectedIndex,
                    button: true,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onChanged(i),
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        child: Padding(
                          // 上下透明区域只扩展点击范围，不增加可见控件体积。
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Center(
                            child: AnimatedContainer(
                              width: double.infinity,
                              height: selectedHeight,
                              duration: const Duration(milliseconds: 180),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == selectedIndex
                                    ? context.appCard
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: i == selectedIndex
                                    ? Border.all(color: context.appBorder)
                                    : null,
                              ),
                              child: Text(
                                labels[i],
                                textAlign: TextAlign.center,
                                style: AppTextStyles.secondary.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: i == selectedIndex
                                      ? context.appForeground
                                      : context.appMutedFg,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 文件作用：
/// - 下划线 Tab（时间线「未读 / 收藏 / 稍后观看」）
///
/// 下划线 Tab（对齐时间线「未读 / 收藏 / 稍后观看」交互）。
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Semantics(
              selected: i == selectedIndex,
              button: true,
              child: InkWell(
                onTap: () => onChanged(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondary.copyWith(
                          fontWeight: FontWeight.w600,
                          color: i == selectedIndex
                              ? context.appForeground
                              : context.appMutedFg,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: i == selectedIndex
                            ? context.appPrimary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 文件作用：
/// - 底部玻璃 Tab 容器（Home 四 Tab）
///
/// 底部 Tab 导航项。
class AppBottomTabBarItem {
  const AppBottomTabBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// 底部玻璃 Tab 容器（对应组件抽取规范 `BottomTabBar`）。
class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    super.key,
    required this.items,
    required this.activeIndex,
    required this.onChanged,
  });

  /// 内容区需预留的底栏占位（含 Home Indicator）。
  ///
  /// ⚠️ 只加 `height` 会挡住 Home Indicator，必须叠 `padding.bottom`。
  static double contentInsetOf(BuildContext context) {
    return contentHeightOf(context) + bottomInsetOf(context);
  }

  /// 嵌套Scaffold会消费MediaQuery.viewPadding；回读FlutterView原始安全区，
  /// 避免有Home Indicator的设备丢失安全区。两者取最大，不重复相加；
  /// 无系统安全区时只保留12px视觉呼吸空间，避免底栏底部过厚。
  static double bottomInsetOf(BuildContext context) {
    final view = View.of(context);
    final systemBottom = view.viewPadding.bottom / view.devicePixelRatio;
    return math.max(
      minimumBottomInset,
      math.max(systemBottom, MediaQuery.viewPaddingOf(context).bottom),
    );
  }

  static const double height = 52;
  static const double minimumBottomInset = 12;

  /// 基准内容高52；文字放大只增长内容区，占位和实际高度必须同步。
  static double contentHeightOf(BuildContext context) =>
      math.max(height, 30 + MediaQuery.textScalerOf(context).scale(12) * 1.5);

  final List<AppBottomTabBarItem> items;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bottom = bottomInsetOf(context);

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
          border: Border(top: BorderSide(color: AppGlass.borderOf(context))),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: SizedBox(
            height: contentHeightOf(context),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _TabItem(
                      item: items[i],
                      selected: i == activeIndex,
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomTabBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.appPrimary : context.appMutedFg;

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? context.appForeground : context.appMutedFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
