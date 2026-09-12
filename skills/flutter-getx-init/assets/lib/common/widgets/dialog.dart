// 对话框组件：通用内容弹窗与支持异步确认、失败重试的操作弹窗。
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../network/index.dart';
import '../style/index.dart';

import 'button.dart';
import 'text.dart';

/// dialog 对话框
class DialogWidget extends StatelessWidget {
  const DialogWidget({
    super.key,
    this.onCancel,
    this.onConfirm,
    this.title,
    this.description,
    this.content,
    this.footer,
    this.titleString,
    this.descriptionString,
    this.padding,
    this.backgroundColor,
    this.radius,
    this.border,
    this.width,
    this.height,
    this.elevation,
    this.cancel,
    this.confirm,
  });

  final Widget? title;
  final Widget? description;
  final Widget? content;
  final Widget? footer;

  final String? titleString;
  final String? descriptionString;

  final double? padding;
  final Color? backgroundColor;
  final double? radius;
  final double? border;
  final double? width;
  final double? height;
  final double? elevation;

  final Widget? cancel;
  final Widget? confirm;
  final void Function()? onCancel;
  final void Function()? onConfirm;

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Widget? description,
    Widget? content,
    Widget? footer,
    String? titleString,
    String? descriptionString,
    double? padding,
    Color? backgroundColor,
    double? radius,
    double? border,
    double? width,
    double? height,
    double? elevation,
    Widget? confirm,
    Widget? cancel,
    void Function()? onConfirm,
    void Function()? onCancel,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.7),
      builder: (context) => DialogWidget(
        title: title,
        description: description,
        content: content,
        footer: footer,
        titleString: titleString,
        descriptionString: descriptionString,
        padding: padding,
        backgroundColor: backgroundColor,
        radius: radius,
        border: border,
        width: width,
        height: height,
        elevation: elevation,
        confirm: confirm,
        cancel: cancel,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = MaterialLocalizations.of(context);
    // 自定义操作优先，避免同时传入回调时重复生成按钮。
    final actions = <Widget>[
      if (cancel != null)
        cancel!
      else if (onCancel != null)
        ButtonWidget.ghost(strings.cancelButtonLabel, onTap: onCancel),
      if (confirm != null)
        confirm!
      else if (onConfirm != null)
        ButtonWidget.primary(strings.okButtonLabel, onTap: onConfirm),
    ];
    return Dialog(
      backgroundColor: backgroundColor ?? context.appSurface,
      elevation: elevation ?? 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius ?? AppRadius.modal),
        side: BorderSide(color: context.appBorder, width: border ?? 1),
      ),
      child: SizedBox(
        width: width,
        height: height,
        // 小屏与大字体时滚动内容，避免对话框越界。
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding ?? AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md,
            children: [
              if (title != null)
                title!
              else if (titleString != null)
                TextWidget.h4(titleString!),
              if (description != null)
                description!
              else if (descriptionString != null)
                TextWidget.muted(descriptionString!),
              ?content,
              if (actions.isNotEmpty)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: actions,
                  ),
                ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

/// 危险操作统一居中确认：执行中锁定返回、遮罩和按钮，失败留在原处重试。
class AppConfirmDialog extends StatefulWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });
  final String title;
  final String message;
  final Future<void> Function() onConfirm;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) {
    // 遮罩始终不关闭；取消按钮与系统返回在空闲时可关闭，执行中全部锁定。
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AppConfirmDialog> createState() => _AppConfirmDialogState();
}

class _AppConfirmDialogState extends State<AppConfirmDialog> {
  bool _busy = false;
  bool _completed = false;
  String? _error;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onConfirm();
      if (!mounted) return;
      // 只解锁返回，不重新启用按钮；下一帧关闭前也不能再次提交。
      setState(() => _completed = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = userFacingErrorMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy || _completed,
    child: Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: context.appStyle.dialogShadow,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: AppTextStyles.pageTitleOn(context)),
              const SizedBox(height: 12),
              Text(widget.message, style: AppTextStyles.bodyOn(context)),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      style: TextStyle(color: context.appErrorText),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GhostButton(
                      label: trOr(TrKeys.cancel, '取消'),
                      enabled: !_busy,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: trOr(TrKeys.delete, '删除'),
                      variant: AppButtonVariant.destructive,
                      loading: _busy,
                      onPressed: _confirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
