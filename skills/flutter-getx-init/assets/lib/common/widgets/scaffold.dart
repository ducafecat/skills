// 页面容器：统一背景、安全区、内容留白与页脚布局。
import 'package:flutter/material.dart';

import '../style/index.dart';

/// 页面外壳统一纯色背景及安全区；自行拥有滚动padding的列表显式选择fullBleed。
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    this.topBar,
    required this.body,
    this.footer,
    this.backgroundColor,
    this.padding,
    this.scrollable = false,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.fullBleed = false,
  });
  final Widget? topBar;
  final Widget body;
  final Widget? footer;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool fullBleed;
  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding:
          padding ??
          (fullBleed
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: AppSpacing.page)),
      child: body,
    );
    if (scrollable) content = SingleChildScrollView(child: content);
    return Scaffold(
      backgroundColor: backgroundColor ?? context.appBackground,
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 极小可用高度时让页脚也能滚动到达，内部列表仍保留有界视口。
            if (footer != null && constraints.maxHeight < 420) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ?topBar,
                    SizedBox(height: 200, child: content),
                    footer!,
                  ],
                ),
              );
            }
            return Column(
              children: [
                ?topBar,
                Expanded(child: content),
                ?footer,
              ],
            );
          },
        ),
      ),
    );
  }
}
