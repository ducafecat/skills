import 'package:flutter/material.dart';

import 'text.dart';

/// 复选框
class CheckboxWidget extends StatelessWidget {
  const CheckboxWidget({
    super.key,
    this.checked,
    this.title,
    this.description,
    this.onChanged,
  });

  final bool? checked;
  final String? title;
  final String? description;

  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    if (title == null && description == null) {
      return Checkbox(value: checked ?? false, onChanged: onChanged);
    }
    // 原生复选框提供选中语义、键盘交互和整行点击能力。
    return CheckboxListTile(
      value: checked ?? false,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: title == null ? null : TextWidget.label(title!),
      subtitle: description == null ? null : TextWidget.muted(description!),
    );
  }
}
