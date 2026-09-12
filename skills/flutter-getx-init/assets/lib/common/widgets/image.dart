import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../style/index.dart';

/// 图片类型
enum ImageWidgetType { img, svg, svgRaw }

/// 图片组件
class ImageWidget extends StatefulWidget {
  const ImageWidget({
    super.key,
    required this.path,
    required this.type,
    this.radius,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.elevation,
    this.color,
  });

  /// 文件路径
  final String path;

  /// 类型
  final ImageWidgetType type;

  /// 圆角
  final double? radius;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 自适应方式
  final BoxFit? fit;

  /// 占位图
  final Widget? placeholder;

  /// 错误图
  final Widget? errorWidget;

  /// 阴影
  final double? elevation;

  /// 颜色
  final Color? color;

  const ImageWidget.img(
    this.path, {
    super.key,
    this.radius,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.elevation,
    this.color,
  }) : type = ImageWidgetType.img;

  const ImageWidget.svg(
    this.path, {
    super.key,
    this.radius,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.elevation,
    this.color,
  }) : type = ImageWidgetType.svg;

  const ImageWidget.svgRaw(
    String raw, {
    super.key,
    this.radius,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.elevation,
    this.color,
  }) : type = ImageWidgetType.svgRaw,
       path = raw;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  Widget _placeholder(BuildContext context) =>
      widget.placeholder ??
      const Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );

  Widget _error(BuildContext context, Object error, StackTrace? stack) =>
      widget.errorWidget ??
      Icon(Icons.broken_image_outlined, color: context.appMutedFg);

  @override
  Widget build(BuildContext context) {
    // 协议相对地址统一补齐 HTTPS，URL 本身作为稳定缓存键。
    final path = widget.path.startsWith('//')
        ? 'https:${widget.path}'
        : widget.path;
    final uri = Uri.tryParse(path);
    final network = uri?.scheme == 'http' || uri?.scheme == 'https';
    final filter = widget.color == null
        ? null
        : ColorFilter.mode(widget.color!, BlendMode.srcIn);
    final Widget child;
    if (path.trim().isEmpty) {
      child = _error(context, const FormatException('图片地址为空'), null);
    } else {
      child = switch (widget.type) {
        ImageWidgetType.img when network => CachedNetworkImage(
          imageUrl: path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          color: widget.color,
          placeholder: (context, _) => _placeholder(context),
          errorWidget: (context, _, error) => _error(context, error, null),
        ),
        ImageWidgetType.img => Image.asset(
          path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          color: widget.color,
          errorBuilder: _error,
          frameBuilder: (context, child, frame, synchronous) =>
              frame == null && !synchronous ? _placeholder(context) : child,
        ),
        ImageWidgetType.svg when network => SvgPicture.network(
          path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.contain,
          colorFilter: filter,
          placeholderBuilder: _placeholder,
          errorBuilder: _error,
        ),
        ImageWidgetType.svg => SvgPicture.asset(
          path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.contain,
          colorFilter: filter,
          placeholderBuilder: _placeholder,
          errorBuilder: _error,
        ),
        ImageWidgetType.svgRaw => SvgPicture.string(
          path,
          width: widget.width,
          height: widget.height,
          fit: widget.fit ?? BoxFit.contain,
          colorFilter: filter,
          placeholderBuilder: _placeholder,
          errorBuilder: _error,
        ),
      };
    }
    // 裁切和阴影使用同一个圆角，错误占位也保留指定尺寸。
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: Colors.transparent,
        elevation: widget.elevation ?? 0,
        borderRadius: BorderRadius.circular(widget.radius ?? AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
