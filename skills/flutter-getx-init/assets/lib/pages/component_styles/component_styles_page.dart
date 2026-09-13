import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';

/// 公共组件调试目录：直接渲染真实组件，所有操作仅修改页面内的演示状态。
class ComponentStylesPage extends StatefulWidget {
  const ComponentStylesPage({super.key});

  @override
  State<ComponentStylesPage> createState() => _ComponentStylesPageState();
}

class _ComponentStylesPageState extends State<ComponentStylesPage> {
  static const _groups = ['基础', '按钮', '表单', '卡片', '导航', '反馈'];
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int _group = 0;
  int _tab = 0;
  int _underline = 0;
  int _bottom = 0;
  String _filter = 'all';
  bool _checked = false;
  bool _loading = false;
  bool _failFirst = true;
  bool _blur = true;
  ResultStatus _status = ResultStatus.idle;
  String _feedback = '点击组件查看交互结果';

  @override
  void dispose() {
    // 页面拥有的输入及滚动控制器随路由一起释放。
    _name.dispose();
    _password.dispose();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _report(String message) {
    if (mounted) setState(() => _feedback = message);
  }

  /// 模拟异步等待并阻止重复触发，退出页面后不再更新状态。
  Future<void> _simulate() async {
    if (_loading) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _feedback = '模拟操作完成';
    });
  }

  /// 每次打开都重新计数，可验证首次失败、留在弹窗重试和执行中锁定。
  Future<void> _confirm() async {
    var attempts = 0;
    final failFirst = _failFirst;
    final result = await AppConfirmDialog.show(
      context: context,
      title: '模拟删除',
      message: '仅测试确认流程，不删除真实数据。',
      onConfirm: () async {
        await Future<void>.delayed(const Duration(seconds: 1));
        if (failFirst && attempts++ == 0) throw Exception('模拟失败');
      },
    );
    _report(result == true ? '确认操作成功' : '已取消确认');
  }

  Future<void> _sheet() async {
    final result = await AppBottomSheet.show<String>(
      context: context,
      builder: (sheetContext) => AppBottomSheet(
        title: 'AppBottomSheet',
        description: '测试键盘、安全区和底部操作',
        body: const InputWidget(placeholder: '点击输入以查看键盘避让'),
        footer: PrimaryButton(
          label: '完成选择',
          onPressed: () => Navigator.of(sheetContext).pop('已完成面板选择'),
        ),
      ),
    );
    _report(result ?? '已关闭底部面板');
  }

  @override
  Widget build(BuildContext context) => PageScaffold(
    topBar: TopBar(
      title: TrKeys.componentStyles.tr,
      onBack: () => context.pop(),
      trailing: [
        GlassIconButton(
          icon: Icons.contrast_rounded,
          semanticLabel: '切换主题',
          onPressed: () => showThemeModeSheet(context),
        ),
      ],
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.sm),
        const TextWidget.muted('真实组件预览 · 使用本地演示数据'),
        FilterChipRow(
          items: [
            for (var i = 0; i < _groups.length; i++)
              FilterChipItem(value: '$i', label: _groups[i]),
          ],
          selectedValue: '$_group',
          onSelected: (value) {
            FocusScope.of(context).unfocus();
            _scroll.jumpTo(0);
            setState(() => _group = int.parse(value));
          },
        ),
        Semantics(
          liveRegion: true,
          child: Text(_feedback, style: AppTextStyles.captionOn(context)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView(
            controller: _scroll,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: switch (_group) {
              0 => _basics(context),
              1 => _buttons(),
              2 => _inputs(),
              3 => _cards(),
              4 => _navigation(),
              _ => _states(),
            },
          ),
        ),
      ],
    ),
  );

  /// 示例分区保留组件名称，方便从界面定位到公共组件源码。
  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        SectionHeader(title: title),
        ...children,
      ],
    ),
  );

  List<Widget> _basics(BuildContext context) => [
    _section('主题语义色', [
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final entry in {
            'Primary': context.appPrimary,
            'Surface': context.appSurface,
            'Muted': context.appMuted,
            'Border': context.appBorder,
            'Error': context.appErrorText,
            'Success': AppColors.success,
            'Warning': AppColors.warning,
          }.entries)
            SizedBox(
              width: 96,
              child: Column(
                spacing: AppSpacing.xs,
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: entry.value,
                      border: Border.all(color: context.appBorder),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                  ),
                  TextWidget.label(entry.key),
                ],
              ),
            ),
        ],
      ),
    ]),
    _section('TextWidget · 排版与尺寸', [
      for (final type in TextWidgetType.values)
        TextWidget(text: '${type.name} · 组件样式', type: type),
      for (final scale in WidgetScale.values)
        TextWidget.body('字号档位 ${scale.name}', scale: scale),
      const TextWidget.muted('页面留白 20 · 卡片留白 16\n卡片圆角 16 · 输入/按钮圆角 12'),
    ]),
    _section('AvatarWidget / AppAvatar / IconWidget', [
      Wrap(
        spacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const AvatarWidget.text('D'),
          const AppAvatar(text: 'TF', size: 56),
          const AvatarWidget.img(''),
          IconWidget.icon(Icons.notifications_outlined, badgeString: '3'),
          const IconWidget.icon(Icons.favorite_outline, isDot: true),
        ],
      ),
    ]),
    _section('ImageWidget · 本地图像与错误兜底', [
      // 内联 SVG 与空路径让正常图、错误图预览都不依赖网络。
      const ImageWidget.svgRaw(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 90"><rect width="160" height="90" fill="#D86B34"/><path d="M65 25L105 45L65 65Z" fill="#231F1A"/></svg>',
        height: 120,
        fit: BoxFit.contain,
      ),
      const ImageWidget.img('', height: 72),
    ]),
  ];

  List<Widget> _buttons() => [
    _section('ButtonWidget · 全部变体', [
      // 不同尺寸的示例按钮按中心对齐，避免大按钮向下突出。
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final variant in ButtonWidgetVariant.values)
            ButtonWidget(
              variant: variant,
              text: variant == ButtonWidgetVariant.icon ? null : variant.name,
              icon: variant == ButtonWidgetVariant.icon
                  ? const Icon(Icons.add, semanticLabel: '添加')
                  : null,
              onTap: () => _report('点击 ${variant.name}'),
            ),
        ],
      ),
      // 不同尺寸的示例按钮按中心对齐，避免大按钮向下突出。
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final scale in WidgetScale.values)
            ButtonWidget.primary(scale.name, scale: scale, onTap: _simulate),
        ],
      ),
      const ButtonWidget.primary('禁用按钮', enabled: false),
      ButtonWidget.primary('模拟加载', loading: _loading, onTap: _simulate),
    ]),
    _section('AppButton / PrimaryButton / GhostButton', [
      for (final variant in AppButtonVariant.values)
        AppButton(label: variant.name, variant: variant, onPressed: _simulate),
      PrimaryButton(
        label: '主要操作 · 点击加载',
        size: AppButtonSize.prominent,
        loading: _loading,
        onPressed: _simulate,
      ),
      const GhostButton(label: '禁用次要操作', enabled: false),
      // 不同尺寸的示例按钮按中心对齐，避免大按钮向下突出。
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          GlassIconButton(
            icon: Icons.add,
            semanticLabel: '添加示例',
            onPressed: () => _report('点击玻璃图标按钮'),
          ),
          TopBarAction(label: '保存', onPressed: () => _report('点击顶部保存')),
        ],
      ),
    ]),
  ];

  List<Widget> _inputs() => [
    _section('InputWidget / GlassSearchField', [
      InputWidget(
        controller: _password,
        placeholder: '密码：支持显隐与清空',
        obscureText: true,
      ),
      GlassSearchField(
        controller: _search,
        hintText: '输入搜索内容',
        onChanged: (value) => _report('搜索内容：$value'),
      ),
    ]),
    _section('AppFormField / InputFormFieldWidget', [
      const AppFormField(label: '只读状态', hint: '此处不可编辑', readOnly: true),
      const AppFormField(
        label: '错误状态',
        hint: '输入内容',
        errorText: '这是错误样式示例',
        helper: '辅助说明',
      ),
      Form(
        key: _formKey,
        child: InputFormFieldWidget(
          controller: _name,
          labelText: '名称（必填）',
          placeholder: '至少输入两个字符',
          validator: (value) =>
              (value?.trim().length ?? 0) < 2 ? '名称至少需要两个字符' : null,
        ),
      ),
      PrimaryButton(
        label: '校验表单',
        onPressed: () =>
            _report(_formKey.currentState!.validate() ? '表单校验通过' : '请修正表单错误'),
      ),
      GhostButton(
        label: '重置表单',
        onPressed: () {
          _formKey.currentState!.reset();
          // 外部控制器在重建后可能成为新的初值，显式清空演示输入。
          _name.clear();
          _report('表单已重置');
        },
      ),
    ]),
    _section('CheckboxWidget', [
      CheckboxWidget(
        title: '接收提醒',
        description: '点击整行测试选中状态',
        checked: _checked,
        onChanged: (value) => setState(() => _checked = value ?? false),
      ),
      const CheckboxWidget(title: '禁用复选框', checked: true),
    ]),
  ];

  List<Widget> _cards() => [
    _section('GlassSurface / GlassCard / StatCard', [
      CheckboxWidget(
        title: '启用示例模糊',
        checked: _blur,
        onChanged: (value) => setState(() => _blur = value ?? false),
      ),
      GlassSurface(
        enableBlur: _blur,
        padding: const EdgeInsets.all(AppSpacing.card),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: const TextWidget.body('玻璃表面：跟随当前主题'),
      ),
      GlassCard(
        // 使用规范卡片留白，文字与点击反馈共用完整的卡片区域。
        padding: const EdgeInsets.all(AppSpacing.card),
        child: const TextWidget.body('可点击卡片'),
        onTap: () => _report('点击 GlassCard'),
      ),
      const StatCard(value: '128', label: '演示统计'),
    ]),
    _section('ListTileWidget / ListRowCard', [
      ListTileWidget(
        title: const TextWidget.body('基础列表项'),
        subtitle: const TextWidget.muted('支持点击和长按'),
        leading: const AppAvatar(text: 'D'),
        onTap: () => _report('点击基础列表项'),
        onLongPress: () => _report('长按基础列表项'),
      ),
      ListRowCard(
        title: '项目列表卡片',
        subtitle: '标题、说明、尾部与底部内容',
        trailing: const Icon(Icons.chevron_right),
        footer: const AppCategoryChip(label: '示例分类'),
        onTap: () => _report('点击 ListRowCard'),
      ),
      SettingsGroup(
        children: [
          SettingsTile(
            label: '设置项 A',
            leading: const Icon(Icons.settings_outlined),
            onTap: () => _report('点击设置项 A'),
          ),
          SettingsTile(
            label: '设置项 B',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _report('点击设置项 B'),
          ),
        ],
      ),
    ]),
  ];

  List<Widget> _navigation() => [
    _section('AppCategoryChip / FilterChipRow', [
      const Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          AppCategoryChip(label: '默认'),
          AppCategoryChip(label: '已选中', selected: true, showDot: false),
          AppCategoryChip(label: '成功色', color: AppColors.success),
        ],
      ),
      FilterChipRow(
        items: const [
          FilterChipItem(value: 'all', label: '全部'),
          FilterChipItem(value: 'unread', label: '未读'),
        ],
        selectedValue: _filter,
        onSelected: (value) => setState(() {
          _filter = value;
          _feedback = '筛选：$value';
        }),
      ),
    ]),
    _section('SegmentedTabs / UnderlineTabs', [
      SegmentedTabs(
        labels: const ['视频', '频道'],
        selectedIndex: _tab,
        onChanged: (value) => setState(() => _tab = value),
      ),
      TextWidget.body('当前分段：${_tab == 0 ? '视频' : '频道'}'),
      UnderlineTabs(
        labels: const ['未读', '收藏', '稍后'],
        selectedIndex: _underline,
        onChanged: (value) => setState(() => _underline = value),
      ),
      TextWidget.body('当前下划线选项：${_underline + 1}'),
    ]),
    _section('TopBar / SectionHeader / AppBottomTabBar', [
      TopBar(
        title: '示例导航栏',
        onBack: () => _report('点击示例返回'),
        trailing: [TopBarAction(label: '编辑', onPressed: () => _report('点击编辑'))],
      ),
      AppBottomTabBar(
        items: const [
          AppBottomTabBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: '首页',
          ),
          AppBottomTabBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: '我的',
          ),
        ],
        activeIndex: _bottom,
        onChanged: (value) => setState(() {
          _bottom = value;
          _feedback = '底部导航：${value + 1}';
        }),
      ),
    ]),
  ];

  List<Widget> _states() => [
    _section('DialogWidget / AppConfirmDialog', [
      PrimaryButton(
        label: '打开普通对话框',
        onPressed: () => showDialog<void>(
          context: context,
          builder: (dialogContext) => DialogWidget(
            titleString: 'DialogWidget',
            descriptionString: '检查标题、说明与操作按钮。',
            onCancel: () {
              Navigator.of(dialogContext).pop();
              _report('已取消对话框');
            },
            onConfirm: () {
              Navigator.of(dialogContext).pop();
              _report('已确认对话框');
            },
          ),
        ),
      ),
      CheckboxWidget(
        title: '确认操作首次失败（可重试）',
        checked: _failFirst,
        onChanged: (value) => setState(() => _failFirst = value ?? false),
      ),
      AppButton(
        label: '打开模拟删除确认',
        variant: AppButtonVariant.destructive,
        onPressed: _confirm,
      ),
    ]),
    _section('BottomSheetWidget / AppBottomSheet', [
      GhostButton(
        label: '打开基础底部面板',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) => BottomSheetWidget(
            titleString: 'BottomSheetWidget',
            content: const InputWidget(placeholder: '测试输入与键盘'),
            onConfirm: () {
              Navigator.of(sheetContext).pop();
              _report('已确认基础面板');
            },
          ),
        ),
      ),
      PrimaryButton(label: '打开项目底部面板', onPressed: _sheet),
    ]),
    _section('ResultStateCard', [
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final status in ResultStatus.values)
            ButtonWidget.outline(
              status.name,
              onTap: () => setState(() => _status = status),
            ),
        ],
      ),
      ResultStateCard(
        icon: _status == ResultStatus.error ? Icons.error_outline : Icons.check,
        title: '当前状态：${_status.name}',
        desc: '错误状态可点击重试，切换为成功状态。',
        status: _status,
        tone: _status == ResultStatus.error
            ? ResultTone.danger
            : ResultTone.success,
        onRetry: () => setState(() {
          _status = ResultStatus.success;
          _feedback = '重试成功';
        }),
      ),
    ]),
    _section('EmptyStateView', [const EmptyStateView(message: '暂无内容，这是空状态示例')]),
  ];
}
