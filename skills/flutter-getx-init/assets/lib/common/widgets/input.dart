// 输入组件：基础输入、带说明和错误提示的输入框及搜索框。
import 'package:flutter/material.dart';

import '../style/index.dart';

/// 遵循项目输入框主题，支持清空、密码显隐和外部控制器。
class InputWidget extends StatefulWidget {
  const InputWidget({
    super.key,
    this.controller,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.cleanable = true,
    this.readOnly = false,
    this.onChanged,
    this.keyboardType,
    this.autofocus,
    this.onTap,
  });

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

  /// 是否只读
  final bool? readOnly;

  /// 输入变化回调
  final Function(String)? onChanged;

  /// 输入法类型
  final TextInputType? keyboardType;

  /// 自动焦点
  final bool? autofocus;

  /// 点击事件
  final Function()? onTap;

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  late TextEditingController _controller;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void didUpdateWidget(covariant InputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    final value = _controller.value;
    _controller.removeListener(_onTextChanged);
    if (oldWidget.controller == null) _controller.dispose();
    _controller = widget.controller ?? TextEditingController.fromValue(value);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    // 外部控制器由调用方释放，组件只释放自己创建的控制器。
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final actions = <Widget>[
      if (widget.cleanable != false &&
          widget.readOnly != true &&
          _controller.text.isNotEmpty)
        IconButton(
          tooltip: localizations.deleteButtonTooltip,
          icon: const Icon(Icons.cancel, size: 20),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
        ),
      if (widget.obscureText == true)
        IconButton(
          isSelected: _showPassword,
          icon: const Icon(Icons.visibility_off, size: 20),
          selectedIcon: const Icon(Icons.visibility, size: 20),
          onPressed: () => setState(() => _showPassword = !_showPassword),
        ),
      ?widget.suffix,
    ];
    // 复用项目 InputDecorationTheme，避免手绘边框与主题不一致。
    return TextField(
      controller: _controller,
      readOnly: widget.readOnly ?? false,
      obscureText: widget.obscureText == true && !_showPassword,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus ?? false,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: AppTextStyles.bodyOn(context),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        prefixIcon: widget.prefix,
        suffixIcon: actions.isEmpty
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: actions),
      ),
    );
  }
}

/// 文件作用：
/// - 表单输入（label + 输入框 + helper / error）
///
/// 表单输入组件（对应组件抽取规范 `FormField`）。
///
/// 统一 URL 输入、分类名称输入和只读信息块的结构：label + 输入框 + helper/error，
/// 减少页面各自拼装输入框风格。
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    this.label,
    this.controller,
    this.hint,
    this.helper,
    this.errorText,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.readOnly = false,
  });

  final String? label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label case final String text) ...[
          Text(text, style: AppTextStyles.captionOn(context)),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
        if (helper case final String text) ...[
          const SizedBox(height: 6),
          Text(text, style: AppTextStyles.captionOn(context)),
        ],
      ],
    );
  }
}

/// 搜索与普通输入共用主题边框和焦点状态，避免玻璃外壳遮掉焦点反馈。
class GlassSearchField extends StatelessWidget {
  const GlassSearchField({
    super.key,
    this.controller,
    this.hintText = '搜索',
    this.onChanged,
    this.onSubmitted,
  });
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    style: AppTextStyles.bodyOn(context),
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(Icons.search_rounded, color: context.appMutedFg),
    ),
  );
}
