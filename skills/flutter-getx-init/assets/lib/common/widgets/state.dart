// 反馈组件：空状态与加载、成功、错误结果状态。
import 'package:flutter/material.dart';

import '../i18n/index.dart';
import '../style/index.dart';

import 'button.dart';
import 'surface.dart';

/// 文件作用：
/// - 空态：装饰背景 + 玻璃文案面板
///
/// 空态：装饰背景 + 玻璃文案面板。
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = context.appPrimary;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 40,
          left: 32,
          child: _Blob(size: 120, color: accent.withValues(alpha: 0.12)),
        ),
        Positioned(
          bottom: 48,
          right: 28,
          child: _Blob(size: 96, color: accent.withValues(alpha: 0.08)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GlassSurface(
            borderRadius: BorderRadius.circular(AppRadius.card),
            blurSigma: AppGlass.blurLight,
            enableBlur: true,
            color: AppGlass.cardFillOf(context),
            borderColor: AppGlass.borderOf(context),
            boxShadow: AppGlass.softShadowOf(context),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 36, color: context.appMutedFg),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.secondaryOn(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// 文件作用：
/// - 结果状态卡片（支付中 / 成功 / 警告 / 危险）
///
/// 结果反馈语气（对应组件抽取规范 `ResultStateCard` 的 `tone`）。
/// 状态与语气独立：错误可带警告语气，加载不假冒成功。
enum ResultStatus { idle, loading, success, error }

enum ResultTone { neutral, success, warning, danger }

/// 结果状态卡片（对应组件抽取规范 `ResultStateCard`）。
///
/// 承载支付处理中、支付成功、删除确认等具有明确状态反馈的场景，统一图标、
/// 标题、说明和按钮布局，页面只需要按场景切换 `tone` 与文案。
class ResultStateCard extends StatelessWidget {
  const ResultStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.desc,
    this.tone = ResultTone.success,
    this.actions,
    this.status = ResultStatus.idle,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String? desc;
  final ResultTone tone;
  final ResultStatus status;
  final VoidCallback? onRetry;
  final List<Widget>? actions;

  Color _toneColor(BuildContext context) => switch (tone) {
    ResultTone.neutral => context.appPrimary,
    ResultTone.success => AppColors.success,
    ResultTone.warning => AppColors.warning,
    ResultTone.danger => context.appDestructive,
  };

  @override
  Widget build(BuildContext context) {
    final color = _toneColor(context);
    final onColor = tone == ResultTone.danger
        ? context.appDestructiveFg
        : context.appPrimaryFg;
    final actionList = [
      ...?actions,
      if (status == ResultStatus.error && onRetry != null)
        PrimaryButton(label: trOr(TrKeys.retry, '重试'), onPressed: onRetry),
    ];

    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: status == ResultStatus.loading
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: onColor,
                    ),
                  )
                : Icon(icon, color: onColor, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.pageTitleOn(context),
          ),
          if (desc case final String text) ...[
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyOn(context),
            ),
          ],
          if (actionList.isNotEmpty) ...[
            const SizedBox(height: 24),
            for (var i = 0; i < actionList.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              actionList[i],
            ],
          ],
        ],
      ),
    );
  }
}
