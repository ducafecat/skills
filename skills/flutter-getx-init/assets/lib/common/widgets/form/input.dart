import 'package:flutter/material.dart';

import '../../style/index.dart';
import '../index.dart';

/// Form 字段组件
class InputFormFieldWidget extends FormField<String> {
  InputFormFieldWidget({
    super.key,
    required this.labelText,
    this.tipText,
    this.initValue,
    this.onChanged,
    this.controller,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.obscureText,
    this.cleanable,
    this.keyboardType,
    this.autofocus,
    this.readOnly,
    super.validator,
    this.onTap,
  }) : super(
         initialValue: controller?.text ?? initValue ?? '',
         builder: (field) => (field as InputFormWidgetFieldState)._buildField(),
       );

  /// 字段文字
  final String labelText;

  /// 提示词
  final String? tipText;

  /// 初始值
  final String? initValue;

  /// 输入框控制器
  final TextEditingController? controller;

  /// 占位符
  final String? placeholder;

  /// 前缀
  final Widget? prefix;

  /// 后缀
  final Widget? suffix;

  /// 是否隐藏文本
  final bool? obscureText;

  /// 是否可清空
  final bool? cleanable;

  /// 值被改变时的回调
  final void Function(String?)? onChanged;

  /// 输入法类型
  final TextInputType? keyboardType;

  /// 自动焦点
  final bool? autofocus;

  /// 是否只读
  final bool? readOnly;

  /// 点击事件
  final void Function()? onTap;

  @override
  InputFormWidgetFieldState createState() => InputFormWidgetFieldState();
}

/// 管理表单值与编辑控制器，确保程序赋值和 reset 同步到屏幕。
class InputFormWidgetFieldState extends FormFieldState<String> {
  late TextEditingController _controller;

  @override
  InputFormFieldWidget get widget => super.widget as InputFormFieldWidget;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_syncValue);
  }

  void _syncValue() {
    if (_controller.text != value) super.didChange(_controller.text);
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (_controller.text != (value ?? '')) _controller.text = value ?? '';
  }

  @override
  void didUpdateWidget(covariant InputFormFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    final previous = _controller.value;
    _controller.removeListener(_syncValue);
    if (oldWidget.controller == null) _controller.dispose();
    _controller =
        widget.controller ?? TextEditingController.fromValue(previous);
    _controller.addListener(_syncValue);
    setValue(_controller.text);
  }

  @override
  void reset() {
    // 先移除监听再重置，避免 reset 被程序赋值重新标记为用户编辑。
    _controller.removeListener(_syncValue);
    _controller.text = widget.initialValue ?? '';
    super.reset();
    _controller.addListener(_syncValue);
    widget.onChanged?.call(value);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncValue);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  Widget _buildField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: AppSpacing.xs,
    children: [
      TextWidget.label(widget.labelText),
      InputWidget(
        controller: _controller,
        placeholder: widget.placeholder,
        prefix: widget.prefix,
        suffix: widget.suffix,
        obscureText: widget.obscureText,
        cleanable: widget.cleanable,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        autofocus: widget.autofocus,
        onTap: widget.onTap,
        onChanged: (value) {
          didChange(value);
          widget.onChanged?.call(value);
        },
      ),
      if (widget.tipText != null) TextWidget.muted(widget.tipText!),
      if (errorText != null)
        TextWidget.muted(errorText!, color: context.appErrorText),
    ],
  );
}
