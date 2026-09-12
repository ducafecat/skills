// 底部面板组件：通用内容面板与带页头、页脚的项目面板。
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../style/index.dart';

import 'button.dart';
import 'surface.dart';
import 'text.dart';

/// 底部弹出框
class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    super.key,
    required this.content,
    this.title,
    this.cancel,
    this.confirm,
    this.onCancel,
    this.onConfirm,
    this.minimum,
    this.titleString,
    this.padding,
    this.backgroundColor,
    this.radius,
    this.border,
    this.width,
    this.height,
    this.elevation,
  });

  final Widget content;
  final Widget? title;
  final Widget? cancel;
  final Widget? confirm;

  final String? titleString;
  final double? padding;
  final Color? backgroundColor;
  final double? radius;
  final double? border;
  final double? width;
  final double? height;
  final double? elevation;

  final void Function()? onCancel;
  final void Function()? onConfirm;
  final EdgeInsets? minimum;

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget content,
    Widget? title,
    Widget? confirm,
    Widget? cancel,
    String? titleString,

    // 样式
    double? padding,
    Color? backgroundColor,
    double? radius,
    double? border,
    double? width,
    double? height,
    double? elevation,

    // 回调
    void Function()? onConfirm,
    void Function()? onCancel,
    EdgeInsets? minimum,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.7),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          title: title,
          confirm: confirm,
          cancel: cancel,
          titleString: titleString,
          padding: padding,
          backgroundColor: backgroundColor,
          radius: radius,
          border: border,
          width: width,
          height: height,
          elevation: elevation,
          onConfirm: onConfirm,
          onCancel: onCancel,
          minimum: minimum,
          content: content,
        );
      },
    );
  }

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    final strings = MaterialLocalizations.of(context);
    final actions = <Widget>[
      if (widget.cancel != null)
        widget.cancel!
      else if (widget.onCancel != null)
        ButtonWidget.ghost(strings.cancelButtonLabel, onTap: widget.onCancel),
      if (widget.confirm != null)
        widget.confirm!
      else if (widget.onConfirm != null)
        ButtonWidget.primary(strings.okButtonLabel, onTap: widget.onConfirm),
    ];
    // 路由负责动画与拖动，面板仅处理键盘、安全区和可滚动内容。
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: widget.backgroundColor ?? context.appSurface,
        elevation: widget.elevation ?? 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.radius ?? AppRadius.sheet),
          ),
          side: BorderSide(color: context.appBorder, width: widget.border ?? 1),
        ),
        child: SafeArea(
          top: false,
          minimum: widget.minimum ?? EdgeInsets.zero,
          child: SizedBox(
            width: widget.width ?? double.infinity,
            height: widget.height,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(widget.padding ?? AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.md,
                children: [
                  if (widget.title != null)
                    widget.title!
                  else if (widget.titleString != null)
                    TextWidget.h4(widget.titleString!),
                  widget.content,
                  if (actions.isNotEmpty)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: actions,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 底部弹层：顶部安全区交给路由；底部留白与键盘分别只计算一次。
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.title,
    this.description,
    this.trailing,
    required this.body,
    this.footer,
  });
  final String? title;
  final String? description;
  final Widget? trailing;
  final Widget body;
  final Widget? footer;
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool dismissible = true,
    bool enableDrag = true,
  }) => showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    isDismissible: dismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: builder,
  );

  @override
  Widget build(BuildContext context) {
    final bottom = math.max(
      AppSpacing.sheetBottom,
      MediaQuery.viewPaddingOf(context).bottom,
    );
    final header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.appMutedFg,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        if (title != null || trailing != null)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppTextStyles.sectionTitleOn(context),
                      ),
                    if (description != null)
                      Text(
                        description!,
                        style: AppTextStyles.captionOn(context),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        const SizedBox(height: 8),
      ],
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sheetTop,
            AppSpacing.page,
            bottom,
          );
          // 键盘/大字令可用高度过小时，整个内容滚动，确保末尾操作仍可到达。
          final compact =
              constraints.maxHeight < 420 ||
              MediaQuery.textScalerOf(context).scale(14) > 21;
          final content = compact
              ? SingleChildScrollView(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      header,
                      body,
                      if (footer != null) ...[
                        const SizedBox(height: 12),
                        footer!,
                      ],
                    ],
                  ),
                )
              : Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      Flexible(child: SingleChildScrollView(child: body)),
                      if (footer != null) ...[
                        const SizedBox(height: 12),
                        footer!,
                      ],
                    ],
                  ),
                );
          return GlassSurface(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.sheet),
            ),
            enableBlur: false,
            color: context.appSurface,
            borderColor: context.appBorder,
            boxShadow: AppGlass.sheetShadowOf(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight),
              child: content,
            ),
          );
        },
      ),
    );
  }
}
