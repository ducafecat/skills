## 文件模板
## Contents
- `lib/common/values` `style` `extension` `models` `services`
- `lib/common/network` `cache` `api` `i18n` `routers` `widgets`
- splash / welcome / login / home、`global.dart`、`main.dart`
- 把 `{{package_name}}` 换成目标项目 `pubspec.yaml` 的 `name`

### `lib/common/values/app_config.dart`

```dart
/// 文件作用：
/// - App 名称、设计稿、网络占位配置
///
/// 通过 `--dart-define` 覆盖 BASE_URL / APP_NAME / ENABLE_HTTP_LOG。
abstract final class AppConfig {
  /// 演示登录预填值，供初始化脚手架体验使用。
  static const demoEmail = 'ducafecat@gmail.com';
  static const demoPassword = '123456';

  /// 应用标题，供 MaterialApp 等位置复用。
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'GetX App',
  );

  /// 主业务后端。默认空：登录走本地假 token，不发 refresh / 代理。
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

  /// 正式构建可用 dart-define 关闭正文日志。
  static const enableHttpLog = bool.fromEnvironment(
    'ENABLE_HTTP_LOG',
    defaultValue: true,
  );

  /// 登录接口路径，同时是鉴权白名单。
  static const authLoginPath = '/api/auth/login';

  /// 刷新接口路径，同时是鉴权白名单。
  static const authRefreshPath = '/api/auth/refresh';

  /// 图片代理路径；[ApiClient.getImageStream] 只允许该 path。
  static const proxyImagePath = '/api/files/img';

  /// AuthInterceptor 不挂 Bearer、不参与 401 刷新的路径。
  static const authWhitelist = <String>[authLoginPath, authRefreshPath];

  /// UI 适配基准尺寸，通常取设计稿宽高。
  static const ui = UiConfig(designWidth: 390, designHeight: 844);

  /// 是否已配置可访问的后端。
  static bool get hasBaseUrl => baseUrl.trim().isNotEmpty;
}

/// UI 适配参数，供 ScreenUtil.init 使用。
class UiConfig {
  const UiConfig({required this.designWidth, required this.designHeight});

  final double designWidth;
  final double designHeight;
}
```

### `lib/common/values/index.dart`

```dart
// 配置与常量入口。
export 'app_config.dart';
export 'adaptive_spacing.dart';
```

### `lib/common/style/app_style.dart`

```dart
import 'package:flutter/material.dart';

/// 唯一主题数据：Material和自定义控件共享，主题动画通过lerp同步插值。
@immutable
class AppStyle extends ThemeExtension<AppStyle> {
  const AppStyle({
    required this.background,
    required this.foreground,
    required this.card,
    required this.primary,
    required this.onPrimary,
    required this.muted,
    required this.mutedForeground,
    required this.dangerAction,
    required this.onDanger,
    required this.border,
    required this.surface,
    required this.inputBorder,
    required this.errorText,
    required this.glassBorder,
    required this.headerGradient,
    required this.cardShadow,
    required this.sheetShadow,
    required this.dialogShadow,
    this.glassEnabled = true,
  });
  final Color background;
  final Color foreground;
  final Color card;
  final Color primary;
  final Color onPrimary;
  final Color muted;
  final Color mutedForeground;
  final Color dangerAction;
  final Color onDanger;
  final Color border;
  final Color surface;
  final Color inputBorder;
  final Color errorText;
  final Color glassBorder;
  final List<Color> headerGradient;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> sheetShadow;
  final List<BoxShadow> dialogShadow;

  /// 低性能场景可在根主题关闭玻璃，表面回退为不透明surface。
  final bool glassEnabled;
  static const light = AppStyle(
    background: Color(0xFFF5F1EA),
    foreground: Color(0xFF231F1A),
    card: Color(0xD1FFFFFF),
    primary: Color(0xFFD86B34),
    onPrimary: Color(0xFF231F1A),
    muted: Color(0xFFEDE8DF),
    mutedForeground: Color(0xFF736B61),
    dangerAction: Color(0xFFB91C1C),
    onDanger: Color(0xFFFFFFFF),
    border: Color(0x14322818),
    surface: Color(0xFFFFFFFF),
    inputBorder: Color(0xFF736B61),
    errorText: Color(0xFFB91C1C),
    glassBorder: Color(0x24FFFFFF),
    headerGradient: [Color(0x9EFFFFFF), Color(0x52FFFFFF), Color(0x0AFFFFFF)],
    cardShadow: [
      BoxShadow(
        color: Color(0x142C2216),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
    sheetShadow: [
      BoxShadow(
        color: Color(0x29352314),
        blurRadius: 40,
        offset: Offset(0, -18),
      ),
    ],
    dialogShadow: [
      BoxShadow(
        color: Color(0x29000000),
        blurRadius: 40,
        offset: Offset(0, 18),
      ),
    ],
  );
  static const dark = AppStyle(
    background: Color(0xFF141310),
    foreground: Color(0xFFF4EFE7),
    card: Color(0xE01C1B18),
    primary: Color(0xFFEF8A4E),
    onPrimary: Color(0xFF231F1A),
    muted: Color(0xFF282724),
    mutedForeground: Color(0xFFB0A89C),
    dangerAction: Color(0xFFB91C1C),
    onDanger: Color(0xFFFFFFFF),
    border: Color(0x14FFFFFF),
    surface: Color(0xFF1D1C18),
    inputBorder: Color(0xFFB0A89C),
    errorText: Color(0xFFFCA5A5),
    glassBorder: Color(0x08FFFFFF),
    headerGradient: [Color(0xC2121212), Color(0x61121212), Color(0x0A121212)],
    cardShadow: [
      BoxShadow(
        color: Color(0x47000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
    sheetShadow: [
      BoxShadow(
        color: Color(0x57000000),
        blurRadius: 48,
        offset: Offset(0, -24),
      ),
    ],
    dialogShadow: [
      BoxShadow(
        color: Color(0x57000000),
        blurRadius: 40,
        offset: Offset(0, 18),
      ),
    ],
  );

  @override
  AppStyle copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? primary,
    Color? onPrimary,
    Color? muted,
    Color? mutedForeground,
    Color? dangerAction,
    Color? onDanger,
    Color? border,
    Color? surface,
    Color? inputBorder,
    Color? errorText,
    Color? glassBorder,
    List<Color>? headerGradient,
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? sheetShadow,
    List<BoxShadow>? dialogShadow,
    bool? glassEnabled,
  }) => AppStyle(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    card: card ?? this.card,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    muted: muted ?? this.muted,
    mutedForeground: mutedForeground ?? this.mutedForeground,
    dangerAction: dangerAction ?? this.dangerAction,
    onDanger: onDanger ?? this.onDanger,
    border: border ?? this.border,
    surface: surface ?? this.surface,
    inputBorder: inputBorder ?? this.inputBorder,
    errorText: errorText ?? this.errorText,
    glassBorder: glassBorder ?? this.glassBorder,
    headerGradient: headerGradient ?? this.headerGradient,
    cardShadow: cardShadow ?? this.cardShadow,
    sheetShadow: sheetShadow ?? this.sheetShadow,
    dialogShadow: dialogShadow ?? this.dialogShadow,
    glassEnabled: glassEnabled ?? this.glassEnabled,
  );
  @override
  AppStyle lerp(covariant AppStyle? other, double t) {
    if (other == null) return this;
    return AppStyle(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      dangerAction: Color.lerp(dangerAction, other.dangerAction, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      border: Color.lerp(border, other.border, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      headerGradient: List.generate(
        3,
        (i) => Color.lerp(headerGradient[i], other.headerGradient[i], t)!,
      ),
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t)!,
      sheetShadow: BoxShadow.lerpList(sheetShadow, other.sheetShadow, t)!,
      dialogShadow: BoxShadow.lerpList(dialogShadow, other.dialogShadow, t)!,
      glassEnabled: t < 0.5 ? glassEnabled : other.glassEnabled,
    );
  }
}
```

### `lib/common/style/app_colors.dart`

```dart
import 'package:flutter/material.dart';
import 'app_style.dart';
export 'app_style.dart';

/// 非主题变化的语义状态色；业务页通过主题扩展读取其它颜色。
abstract final class AppColors {
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}

/// 保留简短的调用接口，但不再在每个getter里维护一套亮暗色值。
extension AppColorsX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  AppStyle get appStyle =>
      Theme.of(this).extension<AppStyle>() ??
      (isDarkMode ? AppStyle.dark : AppStyle.light);
  Color get appBackground => appStyle.background;
  Color get appForeground => appStyle.foreground;
  Color get appCard => appStyle.glassEnabled ? appStyle.card : appStyle.surface;
  Color get appCardFg => appStyle.foreground;
  Color get appPrimary => appStyle.primary;
  Color get appPrimaryFg => appStyle.onPrimary;
  Color get appMuted => appStyle.muted;
  Color get appMutedFg => appStyle.mutedForeground;
  Color get appDestructive => appStyle.dangerAction;
  Color get appDestructiveFg => appStyle.onDanger;
  Color get appBorder => appStyle.border;
  Color get appSurface => appStyle.surface;
  Color get appErrorText => appStyle.errorText;
  Color get appFocus => appStyle.inputBorder;
}
```

### `lib/common/style/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 规范文字档位：所有样式支持系统文字缩放，不以固定容器高度裁剪。
abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const pageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const sectionTitle = pageTitle;
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );
  static const secondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const meta = secondary;
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const label = caption;
  static const mono = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    fontFamily: 'monospace',
  );
  static TextStyle displayOn(BuildContext c) =>
      display.copyWith(color: c.appForeground);
  static TextStyle pageTitleOn(BuildContext c) =>
      pageTitle.copyWith(color: c.appForeground);
  static TextStyle sectionTitleOn(BuildContext c) =>
      sectionTitle.copyWith(color: c.appForeground);
  static TextStyle cardTitleOn(BuildContext c) =>
      cardTitle.copyWith(color: c.appForeground);
  static TextStyle bodyOn(BuildContext c) =>
      body.copyWith(color: c.appForeground);
  static TextStyle secondaryOn(BuildContext c) =>
      secondary.copyWith(color: c.appMutedFg);
  static TextStyle metaOn(BuildContext c) => meta.copyWith(color: c.appMutedFg);
  static TextStyle captionOn(BuildContext c) =>
      caption.copyWith(color: c.appMutedFg);
  static TextStyle labelOn(BuildContext c) =>
      label.copyWith(color: c.appMutedFg);

  /// Material槽位与项目命名使用同一份样式，无重复亮暗TextTheme。
  static TextTheme theme(AppStyle s) => TextTheme(
    displaySmall: display.copyWith(color: s.foreground),
    headlineSmall: pageTitle.copyWith(color: s.foreground),
    titleLarge: sectionTitle.copyWith(color: s.foreground),
    titleMedium: cardTitle.copyWith(color: s.foreground),
    bodyLarge: body.copyWith(color: s.foreground),
    bodyMedium: secondary.copyWith(color: s.foreground),
    bodySmall: caption.copyWith(color: s.mutedForeground),
    labelSmall: label.copyWith(color: s.mutedForeground),
  );
}
```

### `lib/common/style/app_radius.dart`

```dart
import 'package:flutter/widgets.dart';

/// 文件作用：
/// - 圆角尺寸 token 与 BorderRadius 快捷值
///
/// 圆角 token。
///
/// 职责：
/// - 将常用圆角尺寸集中命名，形成一致的组件形态。
/// - 提供 BorderRadius 快捷 getter，减少页面重复 `BorderRadius.circular(...)`。
abstract final class AppRadius {
  // 语义名不会随其它控件改版一起变化；旧尺寸仅供特殊小元素使用。
  static const double card = 16;
  static const double button = 12;
  static const double input = 12;
  static const double sheet = 28;
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double modal = 28;
  static const double pill = 999;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(card);
  static BorderRadius get modalBorderRadius => BorderRadius.circular(sheet);
  static BorderRadius get chipBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get pillBorderRadius => BorderRadius.circular(pill);
}
```

### `lib/common/style/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

/// Material与自定义控件共享AppStyle，关闭玻璃可使用build(brightness, glassEnabled: false)。
abstract final class AppTheme {
  static ThemeData get lightTheme => build(Brightness.light);
  static ThemeData get darkTheme => build(Brightness.dark);
  static ThemeData build(Brightness brightness, {bool glassEnabled = true}) {
    final s = (brightness == Brightness.dark ? AppStyle.dark : AppStyle.light)
        .copyWith(glassEnabled: glassEnabled);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(color: s.inputBorder),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [s],
      scaffoldBackgroundColor: s.background,
      canvasColor: s.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: s.primary,
        onPrimary: s.onPrimary,
        secondary: s.muted,
        onSecondary: s.foreground,
        surface: s.surface,
        onSurface: s.foreground,
        error: s.errorText,
        onError: brightness == Brightness.dark ? s.background : s.onDanger,
        outline: s.inputBorder,
        outlineVariant: s.border,
        surfaceContainerHighest: s.muted,
        onSurfaceVariant: s.mutedForeground,
      ),
      textTheme: AppTextStyles.theme(s),
      dividerTheme: DividerThemeData(color: s.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: s.background,
        foregroundColor: s.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.pageTitle.copyWith(color: s.foreground),
      ),
      cardTheme: CardThemeData(
        color: s.glassEnabled ? s.card : s.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: s.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: buttonShape,
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.primary,
          foregroundColor: s.onPrimary,
          elevation: 0,
          minimumSize: const Size(48, 42),
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: s.foreground,
          side: BorderSide(color: s.inputBorder),
          shape: buttonShape,
          minimumSize: const Size(48, 42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: s.foreground,
          minimumSize: const Size(48, 42),
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: s.foreground,
          minimumSize: const Size(48, 48),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: s.muted,
        selectedColor: s.primary,
        labelStyle: AppTextStyles.secondary.copyWith(color: s.foreground),
        secondaryLabelStyle: AppTextStyles.secondary.copyWith(
          color: s.onPrimary,
        ),
        shape: const StadiumBorder(),
        side: BorderSide(color: s.border),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: s.inputBorder, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: s.errorText),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: s.errorText, width: 2),
        ),
        errorStyle: AppTextStyles.caption.copyWith(color: s.errorText),
        errorMaxLines: 3,
        hintStyle: AppTextStyles.body.copyWith(color: s.mutedForeground),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
  }
}
```

### `lib/common/style/index.dart`

```dart
// 样式功能入口：导出主题、玻璃效果与间距 token。
export '../values/index.dart';
export 'app_glass.dart';
export 'app_media_colors.dart';
export 'app_colors.dart';
export 'app_radius.dart';
export 'app_text_styles.dart';
export 'app_theme.dart';
```

### `lib/common/extension/animated/animated_icon.dart`

```dart
part of '../app_extensions.dart';

class _AnimatedIconContainer extends Icon {
  const _AnimatedIconContainer(
    super.icon, {
    super.key,
    super.color,
    super.semanticLabel,
    super.size,
    super.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final _AnimatedModel? animation = _StyledInheritedAnimation.of(
      context,
    )?.animation;
    if (animation == null) {
      return super.build(context);
    }
    // assert(
    //     animation != null, 'You can`t animate without specifying an animation');
    return _AnimatedIcon(
      icon,
      duration: animation.duration,
      curve: animation.curve,
      color: color,
      semanticLabel: semanticLabel,
      size: size,
      textDirection: textDirection,
    );
  }
}

class _AnimatedIcon extends ImplicitlyAnimatedWidget {
  /// Creates a container that animates its parameters implicitly.
  ///
  /// The [curve] and [duration] arguments must not be null.
  const _AnimatedIcon(
    this.icon, {
    this.color,
    this.semanticLabel,
    this.size,
    this.textDirection,
    super.curve,
    required super.duration,
  });

  final IconData? icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  @override
  _AnimatedIconState createState() => _AnimatedIconState();
}

class _AnimatedIconState extends AnimatedWidgetBaseState<_AnimatedIcon> {
  ColorTween? _color;
  Tween<double>? _size;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _color =
        visitor(
              _color,
              widget.color,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween?;
    _size =
        visitor(
              _size,
              widget.size,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      widget.icon,
      semanticLabel: widget.semanticLabel,
      textDirection: widget.textDirection,
      color: _color?.evaluate(animation),
      size: _size?.evaluate(animation),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
  }
}
```

### `lib/common/extension/animated/animated_text.dart`

```dart
part of '../app_extensions.dart';

class _AnimatedTextContainer extends Text {
  const _AnimatedTextContainer(
    super.data, {
    super.locale,
    super.maxLines,
    super.overflow,
    super.semanticsLabel,
    super.softWrap,
    super.strutStyle,
    super.style,
    super.textAlign,
    super.textDirection,
    super.textScaler,
    super.textWidthBasis,
  });

  @override
  Widget build(BuildContext context) {
    final _AnimatedModel? animation = _StyledInheritedAnimation.of(
      context,
    )?.animation;
    if (animation == null) {
      return super.build(context);
    }
    // assert(
    //     animation != null, 'You can`t animate without specifying an animation');
    return _AnimatedText(
      data ?? '',
      duration: animation.duration,
      curve: animation.curve,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      strutStyle: strutStyle,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaler: textScaler,
      textWidthBasis: textWidthBasis,
    );
  }
}

class _AnimatedText extends ImplicitlyAnimatedWidget {
  /// Creates a container that animates its parameters implicitly.
  ///
  /// The [curve] and [duration] arguments must not be null.
  const _AnimatedText(
    this.data, {
    this.locale,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.style,
    this.textAlign,
    this.textDirection,
    this.textScaler,
    this.textWidthBasis,
    super.curve,
    required super.duration,
  });

  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends AnimatedWidgetBaseState<_AnimatedText> {
  Tween<double>? _fontSize;
  Tween<double>? _letterSpacing;
  Tween<double>? _wordSpacing;
  Tween<double>? _height;
  Tween<double>? _decorationThickness;
  IntTween? _maxLines;
  ColorTween? _color;
  ColorTween? _decorationColor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _fontSize =
        visitor(
              _fontSize,
              widget.style?.fontSize,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _letterSpacing =
        visitor(
              _letterSpacing,
              widget.style?.letterSpacing,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _wordSpacing =
        visitor(
              _wordSpacing,
              widget.style?.wordSpacing,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _height =
        visitor(
              _height,
              widget.style?.height,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _decorationThickness =
        visitor(
              _decorationThickness,
              widget.style?.decorationThickness,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _maxLines =
        visitor(
              _maxLines,
              widget.maxLines,
              (dynamic value) => IntTween(begin: value as int),
            )
            as IntTween?;
    _color =
        visitor(
              _color,
              widget.style?.color,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween?;
    _decorationColor =
        visitor(
              _decorationColor,
              widget.style?.decorationColor,
              (dynamic value) => ColorTween(begin: value as Color),
            )
            as ColorTween?;
  }

  @override
  Widget build(BuildContext context) => Text(
    widget.data,
    style: widget.style?.copyWith(
      fontSize: _fontSize?.evaluate(animation),
      letterSpacing: _letterSpacing?.evaluate(animation),
      wordSpacing: _wordSpacing?.evaluate(animation),
      height: _height?.evaluate(animation),
      decorationThickness: _decorationThickness?.evaluate(animation),
      color: _color?.evaluate(animation),
      decorationColor: _decorationColor?.evaluate(animation),
    ),
    strutStyle: widget.strutStyle,
    textAlign: widget.textAlign,
    textDirection: widget.textDirection,
    locale: widget.locale,
    softWrap: widget.softWrap,
    overflow: widget.overflow,
    // TextScaler 目前不可插值，直接应用调用方指定的缩放策略。
    textScaler: widget.textScaler,
    maxLines: _maxLines?.evaluate(animation),
    semanticsLabel: widget.semanticsLabel,
    textWidthBasis: widget.textWidthBasis,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
  }
}
```

### `lib/common/extension/animated/animated_widget.dart`

```dart
part of '../app_extensions.dart';

class _AnimatedModel {
  final Duration duration;
  final Curve curve;
  _AnimatedModel({required this.duration, this.curve = Curves.linear});
}

class _StyledInheritedAnimation extends InheritedWidget {
  final _AnimatedModel? animation;

  const _StyledInheritedAnimation({
    super.key,
    this.animation,
    required super.child,
  });

  @override
  bool updateShouldNotify(_StyledInheritedAnimation oldAnimation) =>
      !(oldAnimation.animation?.duration == animation?.duration &&
          oldAnimation.animation?.curve == animation?.curve);

  static _StyledInheritedAnimation? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StyledInheritedAnimation>();
}

class _StyledAnimatedBuilder extends StatelessWidget {
  const _StyledAnimatedBuilder({super.key, required this.builder});

  final Widget Function(_AnimatedModel) builder;

  @override
  Widget build(BuildContext context) {
    final _AnimatedModel? animation = _StyledInheritedAnimation.of(
      context,
    )?.animation;
    assert(
      animation != null,
      '[styled_widget]: Tried to animate a widget without an animation specified. Define your animation using .animate() as an ancestor of the widget you are trying to animate',
    );
    return builder(animation!);
  }
}

class _AnimatedDecorationBox extends ImplicitlyAnimatedWidget {
  /// The [curve] and [duration] arguments must not be null.
  _AnimatedDecorationBox({
    this.decoration,
    this.position = DecorationPosition.background,
    this.child,
    super.curve,
    required super.duration,
  }) : assert(decoration == null || decoration.debugAssertIsValid());

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final Decoration? decoration;

  final DecorationPosition? position;

  @override
  _AnimatedDecorationBoxState createState() => _AnimatedDecorationBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Decoration>('bg', decoration, defaultValue: null),
    );
  }
}

class _AnimatedDecorationBoxState
    extends AnimatedWidgetBaseState<_AnimatedDecorationBox> {
  DecorationTween? _decoration;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _decoration =
        visitor(
              _decoration,
              widget.decoration,
              (dynamic value) => DecorationTween(begin: value as Decoration),
            )
            as DecorationTween?;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration?.evaluate(animation) ?? const BoxDecoration(),
      position: widget.position ?? DecorationPosition.background,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<DecorationTween>(
        'bg',
        _decoration,
        defaultValue: null,
      ),
    );
  }
}

class _AnimatedConstrainedBox extends ImplicitlyAnimatedWidget {
  /// The [curve] and [duration] arguments must not be null.
  _AnimatedConstrainedBox({
    this.constraints,
    this.child,
    super.curve,
    required super.duration,
  }) : assert(constraints == null || constraints.debugAssertIsValid());

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  /// Additional constraints to apply to the child.
  ///
  /// The constructor `width` and `height` arguments are combined with the
  /// `constraints` argument to set this property.
  ///
  /// The [padding] goes inside the constraints.
  final BoxConstraints? constraints;

  @override
  _AnimatedConstrainedBoxState createState() => _AnimatedConstrainedBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<BoxConstraints>(
        'constraints',
        constraints,
        defaultValue: null,
        showName: false,
      ),
    );
  }
}

class _AnimatedConstrainedBoxState
    extends AnimatedWidgetBaseState<_AnimatedConstrainedBox> {
  BoxConstraintsTween? _constraints;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _constraints =
        visitor(
              _constraints,
              widget.constraints,
              (dynamic value) =>
                  BoxConstraintsTween(begin: value as BoxConstraints),
            )
            as BoxConstraintsTween?;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: _constraints?.evaluate(animation) ?? const BoxConstraints(),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<BoxConstraintsTween>(
        'constraints',
        _constraints,
        showName: false,
        defaultValue: null,
      ),
    );
  }
}

class _AnimatedTransform extends ImplicitlyAnimatedWidget {
  /// Creates a container that animates its parameters implicitly.
  ///
  /// The [curve] and [duration] arguments must not be null.
  const _AnimatedTransform({
    this.transform,
    this.origin,
    this.alignment,
    this.transformHitTests = true,
    this.child,
    super.curve,
    required super.duration,
  });

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  final Offset? origin;

  final AlignmentGeometry? alignment;

  final bool? transformHitTests;

  /// The transformation matrix to apply before painting the container.
  final Matrix4? transform;

  @override
  _AnimatedTransformState createState() => _AnimatedTransformState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<AlignmentGeometry>(
        'alignment',
        alignment,
        showName: false,
        defaultValue: null,
      ),
    );
    properties.add(ObjectFlagProperty<Matrix4>.has('transform', transform));
  }
}

class _AnimatedTransformState
    extends AnimatedWidgetBaseState<_AnimatedTransform> {
  AlignmentGeometryTween? _alignment;
  Matrix4Tween? _transform;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _alignment =
        visitor(
              _alignment,
              widget.alignment,
              (dynamic value) =>
                  AlignmentGeometryTween(begin: value as AlignmentGeometry?),
            )
            as AlignmentGeometryTween?;
    _transform =
        visitor(
              _transform,
              widget.transform,
              (dynamic value) => Matrix4Tween(begin: value as Matrix4?),
            )
            as Matrix4Tween?;
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: _transform?.evaluate(animation) ?? Matrix4.zero(),
      alignment: _alignment?.evaluate(animation),
      origin: widget.origin,
      transformHitTests: widget.transformHitTests ?? true,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<AlignmentGeometryTween>(
        'alignment',
        _alignment,
        showName: false,
        defaultValue: null,
      ),
    );
    description.add(
      ObjectFlagProperty<Matrix4Tween>.has('transform', _transform),
    );
  }
}

class _AnimatedClipRRect extends ImplicitlyAnimatedWidget {
  /// The [curve] and [duration] arguments must not be null.
  const _AnimatedClipRRect({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
    this.clipper,
    this.clipBehavior,
    this.child,
    super.curve,
    required super.duration,
  });

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  final double? topLeft;
  final double? topRight;
  final double? bottomLeft;
  final double? bottomRight;
  final CustomClipper<RRect>? clipper;
  final Clip? clipBehavior;

  @override
  _AnimatedClipRRectState createState() => _AnimatedClipRRectState();
}

class _AnimatedClipRRectState
    extends AnimatedWidgetBaseState<_AnimatedClipRRect> {
  Tween<double>? _topLeft;
  Tween<double>? _topRight;
  Tween<double>? _bottomLeft;
  Tween<double>? _bottomRight;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _topLeft =
        visitor(
              _topLeft,
              widget.topLeft,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _topRight =
        visitor(
              _topRight,
              widget.topRight,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _bottomLeft =
        visitor(
              _bottomLeft,
              widget.bottomLeft,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _bottomRight =
        visitor(
              _bottomRight,
              widget.bottomRight,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipper: widget.clipper,
      clipBehavior: widget.clipBehavior ?? Clip.antiAlias,
      borderRadius: BorderRadius.only(
        topLeft: _topLeft != null
            ? Radius.circular(_topLeft!.evaluate(animation))
            : Radius.zero,
        topRight: _topRight != null
            ? Radius.circular(_topRight!.evaluate(animation))
            : Radius.zero,
        bottomLeft: _bottomLeft != null
            ? Radius.circular(_bottomLeft!.evaluate(animation))
            : Radius.zero,
        bottomRight: _bottomRight != null
            ? Radius.circular(_bottomRight!.evaluate(animation))
            : Radius.zero,
      ),
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
  }
}

class _AnimatedBackgroundBlur extends ImplicitlyAnimatedWidget {
  /// Creates a widget that animates its opacity implicitly.
  ///
  /// The [opacity] argument must not be null and must be between 0.0 and 1.0,
  /// inclusive. The [curve] and [duration] arguments must not be null.
  const _AnimatedBackgroundBlur({
    this.child,
    required this.sigma,
    super.curve,
    required super.duration,
  }) : assert(sigma >= 0.0);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;

  final double sigma;

  @override
  _AnimatedBackgroundBlurState createState() => _AnimatedBackgroundBlurState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('background blur', sigma));
  }
}

// 基类监听动画帧并触发重建，使模糊半径在更新后连续变化。
class _AnimatedBackgroundBlurState
    extends AnimatedWidgetBaseState<_AnimatedBackgroundBlur> {
  Tween<double>? _sigma;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _sigma =
        visitor(
              _sigma,
              widget.sigma,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: _sigma?.evaluate(animation) ?? 0,
        sigmaY: _sigma?.evaluate(animation) ?? 0,
      ),
      child: widget.child,
    );
  }
}

class _AnimatedOverflowBox extends ImplicitlyAnimatedWidget {
  /// Creates a widget that animates its opacity implicitly.
  ///
  /// The [opacity] argument must not be null and must be between 0.0 and 1.0,
  /// inclusive. The [curve] and [duration] arguments must not be null.
  const _AnimatedOverflowBox({
    this.child,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignment,
    super.curve,
    required super.duration,
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget? child;
  final AlignmentGeometry? alignment;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  @override
  _AnimatedOverflowBoxState createState() => _AnimatedOverflowBoxState();
}

// 约束插值必须随动画逐帧重建，才能反映新的目标尺寸。
class _AnimatedOverflowBoxState
    extends AnimatedWidgetBaseState<_AnimatedOverflowBox> {
  Tween<double>? _minWidth;
  Tween<double>? _maxWidth;
  Tween<double>? _minHeight;
  Tween<double>? _maxHeight;
  AlignmentGeometryTween? _alignment;
  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _minWidth =
        visitor(
              _minWidth,
              widget.minWidth,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _maxWidth =
        visitor(
              _maxWidth,
              widget.maxWidth,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _minHeight =
        visitor(
              _minHeight,
              widget.minHeight,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _maxHeight =
        visitor(
              _maxHeight,
              widget.maxHeight,
              (dynamic value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _alignment =
        visitor(
              _alignment,
              widget.alignment,
              (dynamic value) =>
                  AlignmentGeometryTween(begin: value as AlignmentGeometry),
            )
            as AlignmentGeometryTween?;
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minWidth: _minWidth?.evaluate(animation),
      maxWidth: _maxWidth?.evaluate(animation),
      minHeight: _minHeight?.evaluate(animation),
      maxHeight: _maxHeight?.evaluate(animation),
      alignment: _alignment?.evaluate(animation) ?? Alignment.center,
      child: widget.child,
    );
  }
}
```

### `lib/common/extension/app_extensions.dart`

```dart
/// 扩展功能库：集中引入 Flutter 依赖，并组合各个 `part` 扩展实现。
library;

import 'dart:async';
import 'dart:collection';
import 'dart:developer' as devtools show log;
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'animated/animated_icon.dart';
part 'animated/animated_text.dart';
part 'animated/animated_widget.dart';
part 'colors_ext.dart';
part 'context_ext.dart';
part 'dev_tools_ext.dart';
part 'duration_ext.dart';
part 'icon_ext.dart';
part 'list_ext.dart';
part 'media_query_ext.dart';
part 'padding_ext.dart';
part 'platform_ext.dart';
part 'screen/screen_util.dart';
part 'screen/_flutter_widgets.dart';
part 'screen/screenutil_init.dart';
part 'screen/screenutil_mixin.dart';
part 'screen_util_ext.dart';
part 'sized_box_ext.dart';
part 'string_ext.dart';
part 'text_ext.dart';
part 'text_span_ext.dart';
part 'themes_ext.dart';
part 'widget_ext.dart';
```

### `lib/common/extension/colors_ext.dart`

```dart
part of 'app_extensions.dart';

/// theme 主题颜色扩展
/// `context.colors.primary` 可以这样使用
extension ThemeColorsExtensions on BuildContext {
  // ignore: library_private_types_in_public_api
  _ThemeColors get colors => _ThemeColors(
    primary: _primaryColor,
    primaryLight: _primaryColorLight,
    primaryDark: _primaryColorDark,
    canvas: _canvasColor,
    scaffoldBackground: _scaffoldBackgroundColor,
    card: _cardColor,
    divider: _dividerColor,
    focus: _focusColor,
    hover: _hoverColor,
    highlight: _highlightColor,
    splash: _splashColor,
    unselectedWidget: _unselectedWidgetColor,
    disabled: _disabledColor,
    secondaryHeader: _secondaryHeaderColor,
    dialogBackground: _dialogBackgroundColor,
    indicator: _indicatorColor,
    hint: _hintColor,
    scheme: _colorScheme,
    shadow: _shadowColor,
  );

  // 获取当前主题
  ThemeData get _theme => Theme.of(this);

  // 获取颜色方案
  ColorScheme get _colorScheme => _theme.colorScheme;

  // 主要颜色
  Color get _primaryColor => _theme.primaryColor;
  Color get _primaryColorLight => _theme.primaryColorLight;
  Color get _primaryColorDark => _theme.primaryColorDark;

  // 次要颜色
  Color get _secondaryHeaderColor => _theme.secondaryHeaderColor;

  // 其他主题颜色
  Color get _canvasColor => _theme.canvasColor;
  Color get _scaffoldBackgroundColor => _theme.scaffoldBackgroundColor;
  Color get _cardColor => _theme.cardColor;
  Color get _dividerColor => _theme.dividerColor;
  Color get _focusColor => _theme.focusColor;
  Color get _hoverColor => _theme.hoverColor;
  Color get _highlightColor => _theme.highlightColor;
  Color get _splashColor => _theme.splashColor;
  Color get _unselectedWidgetColor => _theme.unselectedWidgetColor;
  Color get _disabledColor => _theme.disabledColor;
  Color get _dialogBackgroundColor =>
      _theme.dialogTheme.backgroundColor ?? _colorScheme.surface;
  Color get _indicatorColor =>
      _theme.tabBarTheme.indicatorColor ?? _colorScheme.primary;
  Color get _hintColor => _theme.hintColor;
  Color get _shadowColor => _theme.shadowColor;
}

/// Helper class that allows to use a color like:
/// `context.colors.primary`
class _ThemeColors {
  const _ThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.canvas,
    required this.shadow,
    required this.scaffoldBackground,
    required this.card,
    required this.divider,
    required this.focus,
    required this.hover,
    required this.highlight,
    required this.splash,
    required this.unselectedWidget,
    required this.disabled,
    required this.secondaryHeader,
    required this.dialogBackground,
    required this.indicator,
    required this.hint,
    required this.scheme,
  });

  /// See [ThemeData.primaryColor].
  final Color primary;

  /// See [ThemeData.primaryColorLight].
  final Color primaryLight;

  /// See [ThemeData.primaryColorDark].
  final Color primaryDark;

  /// See [ThemeData.canvasColor].
  final Color canvas;

  /// See [ThemeData.shadowColor].
  final Color shadow;

  /// See [ThemeData.scaffoldBackgroundColor].
  final Color scaffoldBackground;

  /// See [ThemeData.cardColor].
  final Color card;

  /// See [ThemeData.dividerColor].
  final Color divider;

  /// See [ThemeData.focusColor].
  final Color focus;

  /// See [ThemeData.hoverColor].
  final Color hover;

  /// See [ThemeData.highlightColor].
  final Color highlight;

  /// See [ThemeData.splashColor].
  final Color splash;

  /// See [ThemeData.unselectedWidgetColor].
  final Color unselectedWidget;

  /// See [ThemeData.disabledColor].
  final Color disabled;

  /// See [ThemeData.secondaryHeaderColor].
  final Color secondaryHeader;

  /// See [DialogThemeData.backgroundColor].
  final Color dialogBackground;

  /// See [TabBarThemeData.indicatorColor].
  final Color indicator;

  /// See [ThemeData.hintColor].
  final Color hint;

  /// See [ThemeData.colorScheme].
  final ColorScheme scheme;
}
```

### `lib/common/extension/context_ext.dart`

```dart
part of 'app_extensions.dart';

/// 上下文扩展
extension ContextExtensions on BuildContext {
  /////////////////////////////////////////////////////////////////////
  // ScreenUtil 屏幕尺寸信息
  /////////////////////////////////////////////////////////////////////

  /// 获取屏幕宽度
  double get screenWidth => ScreenUtil().screenWidth;

  /// 获取屏幕高度
  double get screenHeight => ScreenUtil().screenHeight;

  /// 获取底部导航栏高度
  double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  /// 获取状态栏高度
  double get statusBarHeight => ScreenUtil().statusBarHeight;

  /// 获取文本缩放因子
  // double get textScaleFactor => ScreenUtil().textScaleFactor;

  /// 获取宽度的缩放因子
  double get scaleWidth => ScreenUtil().scaleWidth;

  /// 获取高度的缩放因子
  double get scaleHeight => ScreenUtil().scaleHeight;

  /////////////////////////////////////////////////////////////////////
  // 屏幕方向
  /////////////////////////////////////////////////////////////////////

  /// 获取当前屏幕方向
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// 判断是否为横屏模式
  bool get isLandscape => orientation == Orientation.landscape;

  /// 判断是否为竖屏模式
  bool get isPortrait => orientation == Orientation.portrait;

  /////////////////////////////////////////////////////////////////////
  // theme
  /////////////////////////////////////////////////////////////////////

  // ThemeData get theme => Theme.of(this);

  // TextTheme get textTheme => Theme.of(this).textTheme;

  // ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Color get primaryColor => theme.primaryColor;

  // Color get accentColor => theme.colorScheme.secondary;

  // Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;

  // Color get cardColor => theme.cardColor;

  // Color get dividerColor => theme.dividerColor;

  // Color get iconColor => theme.iconTheme.color!;

  /////////////////////////////////////////////////////////////////////
  // 其它
  /////////////////////////////////////////////////////////////////////

  /// 获取平台亮度设置
  Brightness platformBrightness() => MediaQuery.of(this).platformBrightness;

  /// 获取底部导航栏高度
  double get navigationBarHeight => MediaQuery.of(this).padding.bottom;

  /// 获取默认文本样式
  DefaultTextStyle get defaultTextStyle => DefaultTextStyle.of(this);

  /// 获取当前Form的状态
  FormState? get formState => Form.of(this);

  /// 获取当前Scaffold的状态
  ScaffoldState get scaffoldState => Scaffold.of(this);

  /// 获取当前Overlay的状态
  OverlayState? get overlayState => Overlay.of(this);

  /// 请求焦点
  void requestFocus(FocusNode focus) {
    FocusScope.of(this).requestFocus(focus);
  }

  /// 取消焦点
  void unFocus(FocusNode focus) {
    focus.unfocus();
  }

  /// 检查是否可以弹出当前路由
  bool get canPop => Navigator.canPop(this);

  /// 弹出当前路由
  // void pop<T extends Object>([T? result]) => Navigator.pop(this, result);

  /// 打开抽屉
  void openDrawer() => Scaffold.of(this).openDrawer();

  /// 打开末端抽屉
  void openEndDrawer() => Scaffold.of(this).openEndDrawer();

  /// 检查键盘是否可见
  bool get isKeyboardShowing => MediaQuery.of(this).viewInsets.bottom > 0;
}
```

### `lib/common/extension/dev_tools_ext.dart`

```dart
part of 'app_extensions.dart';

/// 开发工具
extension DevTools on Object {
  /// 打印日志
  void log() => devtools.log(toString());
}
```

### `lib/common/extension/duration_ext.dart`

```dart
part of 'app_extensions.dart';

/// 返回时间差 [Duration] 的扩展
extension DurationExtensions on num {
  /// 将数字转换为微秒的 [Duration]
  Duration get microseconds => Duration(microseconds: round());

  /// 将数字转换为毫秒的 [Duration]
  Duration get milliseconds => Duration(milliseconds: round());

  /// 将数字转换为秒的 [Duration]
  Duration get seconds => Duration(seconds: round());

  /// 将数字转换为分钟的 [Duration]
  Duration get minutes => Duration(minutes: round());

  /// 将数字转换为小时的 [Duration]
  Duration get hours => Duration(hours: round());

  /// 将数字转换为天的 [Duration]
  Duration get days => Duration(days: round());

  /// 将数字转换为月的 [Duration]（假设一个月为30天）
  Duration get months => Duration(days: 30 * round());

  /// 将数字转换为季度的 [Duration]（假设一个季度为90天）
  Duration get quarters => Duration(days: 90 * round());

  /// 将数字转换为四个月的 [Duration]（假设四个月为120天）
  Duration get quadrimesters => Duration(days: 120 * round());

  /// 将数字转换为年的 [Duration]（假设一年为365天）
  Duration get years => Duration(days: 365 * round());
}

/// Duration 扩展
extension FutureDuration on Duration {
  /// 启动一个延迟 delayed
  Future<dynamic> future([FutureOr<dynamic> Function()? computation]) {
    return Future.delayed(this, computation);
  }
}
```

### `lib/common/extension/icon_ext.dart`

```dart
part of 'app_extensions.dart';

/// Icon 扩展，提供复制和修改 Icon 属性的方法。
extension IconExtensions on Icon {
  /// 创建一个新的 Icon 实例，可选择性地修改部分或全部属性
  ///
  /// 参数:
  /// - [size]: 图标的大小，单位为逻辑像素。如果为 null，则保持原始大小。
  /// - [color]: 图标的颜色。如果为 null，则保持原始颜色。
  /// - [semanticLabel]: 图标的语义标签，用于辅助功能。如果为 null，则保持原始标签。
  /// - [textDirection]: 图标的文本方向。如果为 null，则保持原始方向。
  ///
  /// 返回:
  /// 返回新的 [Icon]；动画图标会保留其动画容器类型。
  Icon copyWith({
    double? size,
    Color? color,
    String? semanticLabel,
    TextDirection? textDirection,
  }) => (this is _AnimatedIconContainer
      ? _AnimatedIconContainer(
          icon,
          key: key,
          color: color ?? this.color,
          size: size ?? this.size,
          semanticLabel: semanticLabel ?? this.semanticLabel,
          textDirection: textDirection ?? this.textDirection,
        )
      : Icon(
          icon,
          key: key,
          color: color ?? this.color,
          size: size ?? this.size,
          semanticLabel: semanticLabel ?? this.semanticLabel,
          textDirection: textDirection ?? this.textDirection,
        ));

  /// 创建一个新的 Icon 实例，仅修改其大小
  ///
  /// 参数:
  /// - [size]: 新的图标大小，单位为逻辑像素。这个参数是必需的，不能为 null。
  ///
  /// 返回一个新的 Icon 实例，其大小被设置为指定的值，其他属性保持不变。
  Icon iconSize(double size) => copyWith(size: size);

  /// 创建一个新的 Icon 实例，仅修改其颜色
  ///
  /// 参数:
  /// - [color]: 新的图标颜色。这个参数是必需的，不能为 null。
  ///
  /// 返回一个新的 Icon 实例，其颜色被设置为指定的值，其他属性保持不变。
  Icon iconColor(Color color) => copyWith(color: color);
}
```

### `lib/common/extension/index.dart`

```dart
// 扩展功能入口：导出通用 Dart 和 Flutter 扩展。
export 'app_extensions.dart';
export 'safe_area_ext.dart';
```

### `lib/common/extension/list_ext.dart`

```dart
part of 'app_extensions.dart';

extension ListExtensions<E> on List<Widget> {
  /// 将 Widget 列表转换为 Column
  ///
  /// 参数:
  /// - [key]: 用于 Column 的可选键
  /// - [mainAxisAlignment]: 主轴对齐方式，默认为 MainAxisAlignment.start
  /// - [mainAxisSize]: 主轴尺寸，默认为 MainAxisSize.max
  /// - [crossAxisAlignment]: 交叉轴对齐方式，默认为 CrossAxisAlignment.center
  /// - [textDirection]: 文本方向，可选
  /// - [verticalDirection]: 垂直方向，默认为 VerticalDirection.down
  /// - [textBaseline]: 文本基线，可选
  /// - [separator]: 可选的分隔 Widget
  ///
  /// 返回: 包含列表中所有 Widget 的 Column
  Widget toColumn({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Widget? separator,
  }) => Column(
    key: key,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection,
    verticalDirection: verticalDirection,
    textBaseline: textBaseline,
    children: separator != null && isNotEmpty
        ? (expand((child) => [child, separator]).toList()..removeLast())
        : this,
  );

  /// 将 Widget 列表转换为带有间距的 Column
  ///
  /// 参数:
  /// - [key]: 用于 Column 的可选键
  /// - [mainAxisAlignment]: 主轴对齐方式，默认为 MainAxisAlignment.start
  /// - [mainAxisSize]: 主轴尺寸，默认为 MainAxisSize.max
  /// - [crossAxisAlignment]: 交叉轴对齐方式，默认为 CrossAxisAlignment.center
  /// - [textDirection]: 文本方向，可选
  /// - [verticalDirection]: 垂直方向，默认为 VerticalDirection.down
  /// - [textBaseline]: 文本基线，可选
  /// - [space]: Widget 之间的间距，默认为 10.0
  ///
  /// 返回: 包含列表中所有 Widget 的 Column，Widget 之间有指定的间距
  Widget toColumnSpace({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    double space = 10.0,
  }) => Column(
    key: key,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection,
    verticalDirection: verticalDirection,
    textBaseline: textBaseline,
    children: isNotEmpty
        ? (expand((child) => [child, SizedBox(height: space)]).toList()
            ..removeLast())
        : this,
  );

  /// 将 Widget 列表转换为 Row
  ///
  /// 参数:
  /// - [key]: 用于 Row 的可选键
  /// - [mainAxisAlignment]: 主轴对齐方式，默认为 MainAxisAlignment.start
  /// - [mainAxisSize]: 主轴尺寸，默认为 MainAxisSize.max
  /// - [crossAxisAlignment]: 交叉轴对齐方式，默认为 CrossAxisAlignment.center
  /// - [textDirection]: 文本方向，可选
  /// - [verticalDirection]: 垂直方向，默认为 VerticalDirection.down
  /// - [textBaseline]: 文本基线，可选
  /// - [separator]: 可选的分隔 Widget
  ///
  /// 返回: 包含列表中所有 Widget 的 Row
  Widget toRow({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Widget? separator,
  }) => Row(
    key: key,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection,
    verticalDirection: verticalDirection,
    textBaseline: textBaseline,
    children: separator != null && isNotEmpty
        ? (expand((child) => [child, separator]).toList()..removeLast())
        : this,
  );

  /// 将 Widget 列表转换为带有间距的 Row
  ///
  /// 参数:
  /// - [key]: 用于 Row 的可选键
  /// - [mainAxisAlignment]: 主轴对齐方式，默认为 MainAxisAlignment.start
  /// - [mainAxisSize]: 主轴尺寸，默认为 MainAxisSize.max
  /// - [crossAxisAlignment]: 交叉轴对齐方式，默认为 CrossAxisAlignment.center
  /// - [textDirection]: 文本方向，可选
  /// - [verticalDirection]: 垂直方向，默认为 VerticalDirection.down
  /// - [textBaseline]: 文本基线，可选
  /// - [space]: Widget 之间的间距，默认为 10.0
  ///
  /// 返回: 包含列表中所有 Widget 的 Row，Widget 之间有指定的间距
  Widget toRowSpace({
    Key? key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    double space = 10.0,
  }) => Row(
    key: key,
    mainAxisAlignment: mainAxisAlignment,
    mainAxisSize: mainAxisSize,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection,
    verticalDirection: verticalDirection,
    textBaseline: textBaseline,
    children: isNotEmpty
        ? (expand((child) => [child, SizedBox(width: space)]).toList()
            ..removeLast())
        : this,
  );

  /// 将 Widget 列表转换为 Stack
  ///
  /// 参数:
  /// - [key]: 用于 Stack 的可选键
  /// - [alignment]: 子 Widget 的对齐方式，默认为 AlignmentDirectional.topStart
  /// - [textDirection]: 文本方向，可选
  /// - [fit]: 子 Widget 如何适应 Stack 的大小，默认为 StackFit.loose
  /// - [clipBehavior]: 超出 Stack 边界的子 Widget 的裁剪行为，默认为 Clip.hardEdge
  /// - [children]: 额外的子 Widget 列表，默认为空
  ///
  /// 返回: 包含列表中所有 Widget 的 Stack
  Widget toStack({
    Key? key,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
    List<Widget> children = const <Widget>[],
  }) => Stack(
    key: key,
    alignment: alignment,
    textDirection: textDirection,
    fit: fit,
    clipBehavior: clipBehavior,
    // 保留原列表顺序，并在末尾追加调用方传入的额外子组件。
    children: [...this, ...children],
  );

  /// 将 Widget 列表转换为 ListView
  ///
  /// 参数:
  /// - [key]: 用于 ListView 的可选键
  /// - [scrollDirection]: 滚动方向，默认为 Axis.vertical
  ///
  /// 返回: 包含列表中所有 Widget 的 ListView
  Widget toListView({Key? key, Axis scrollDirection = Axis.vertical}) =>
      ListView(key: key, scrollDirection: scrollDirection, children: this);

  /// 将 Widget 列表转换为 Wrap
  ///
  /// 参数:
  /// - [key]: 用于 Wrap 的可选键
  /// - [direction]: 主轴方向，默认为 Axis.horizontal
  /// - [alignment]: 主轴对齐方式，默认为 WrapAlignment.start
  /// - [spacing]: 主轴方向上的间距，默认为 0.0
  /// - [runAlignment]: 交叉轴对齐方式，默认为 WrapAlignment.start
  /// - [runSpacing]: 交叉轴方向上的间距，默认为 0.0
  /// - [crossAxisAlignment]: 交叉轴上子 Widget 的对齐方式，默认为 WrapCrossAlignment.start
  /// - [textDirection]: 文本方向，可选
  /// - [verticalDirection]: 垂直方向，默认为 VerticalDirection.down
  /// - [clipBehavior]: 超出 Wrap 边界的子 Widget 的裁剪行为，默认为 Clip.none
  /// - [children]: 额外的子 Widget 列表，默认为空
  ///
  /// 返回: 包含列表中所有 Widget 的 Wrap
  Widget toWrap({
    Key? key,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
    List<Widget> children = const <Widget>[],
  }) => Wrap(
    key: key,
    direction: direction,
    alignment: alignment,
    spacing: spacing,
    runAlignment: runAlignment,
    runSpacing: runSpacing,
    crossAxisAlignment: crossAxisAlignment,
    textDirection: textDirection,
    verticalDirection: verticalDirection,
    clipBehavior: clipBehavior,
    // 保留原列表顺序，并在末尾追加调用方传入的额外子组件。
    children: [...this, ...children],
  );
}
```

### `lib/common/extension/media_query_ext.dart`

```dart
part of 'app_extensions.dart';

/// 媒体查询各种尺寸信息, 返回 sizes 对象
extension MediaQueryExtensions on BuildContext {
  // ignore: library_private_types_in_public_api
  _Sizes get sizes => _Sizes(
    width: _width,
    height: _height,
    padding: _padding,
    viewInsets: _viewInsets,
    systemGestureInsets: _systemGestureInsets,
    viewPadding: _viewPadding,
    devicePixelRatio: _devicePixelRatio,
    textScaler: _textScaler,
    maybeDevicePixelRatio: _maybeDevicePixelRatio,
    maybeHeight: _maybeHeight,
    maybePadding: _maybePadding,
    maybeSystemGestureInsets: _maybeSystemGestureInsets,
    maybeTextScaler: _maybeTextScaler,
    maybeViewInsets: _maybeViewInsets,
    maybeViewPadding: _maybeViewPadding,
    maybeWidth: _maybeWidth,
  );

  /// 获取屏幕宽度
  /// 返回: 当前上下文的屏幕宽度
  double get _width => MediaQuery.sizeOf(this).width;

  /// 尝试获取屏幕宽度，可能为空
  /// 返回: 当前上下文的屏幕宽度，如果无法获取则返回 null
  double? get _maybeWidth => MediaQuery.maybeSizeOf(this)?.width;

  /// 获取屏幕高度
  /// 返回: 当前上下文的屏幕高度
  double get _height => MediaQuery.sizeOf(this).height;

  /// 尝试获取屏幕高度，可能为空
  /// 返回: 当前上下文的屏幕高度，如果无法获取则返回 null
  double? get _maybeHeight => MediaQuery.maybeSizeOf(this)?.height;

  /// 获取屏幕边距
  /// 返回: 当前上下文的屏幕边距
  EdgeInsets get _padding => MediaQuery.paddingOf(this);

  /// 尝试获取屏幕边距，可能为空
  /// 返回: 当前上下文的屏幕边距，如果无法获取则返回 null
  EdgeInsets? get _maybePadding => MediaQuery.maybePaddingOf(this);

  /// 获取视图插入
  /// 返回: 当前上下文的视图插入
  EdgeInsets get _viewInsets => MediaQuery.viewInsetsOf(this);

  /// 尝试获取视图插入，可能为空
  /// 返回: 当前上下文的视图插入，如果无法获取则返回 null
  EdgeInsets? get _maybeViewInsets => MediaQuery.maybeViewInsetsOf(this);

  /// 获取系统手势插入
  /// 返回: 当前上下文的系统手势插入
  EdgeInsets get _systemGestureInsets => MediaQuery.systemGestureInsetsOf(this);

  /// 尝试获取系统手势插入，可能为空
  /// 返回: 当前上下文的系统手势插入，如果无法获取则返回 null
  EdgeInsets? get _maybeSystemGestureInsets =>
      MediaQuery.maybeSystemGestureInsetsOf(this);

  /// 获取视图边距
  /// 返回: 当前上下文的视图边距
  EdgeInsets get _viewPadding => MediaQuery.viewPaddingOf(this);

  /// 尝试获取视图边距，可能为空
  /// 返回: 当前上下文的视图边距，如果无法获取则返回 null
  EdgeInsets? get _maybeViewPadding => MediaQuery.maybeViewPaddingOf(this);

  /// 获取设备像素比
  /// 返回: 当前上下文的设备像素比
  double get _devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// 尝试获取设备像素比，可能为空
  /// 返回: 当前上下文的设备像素比，如果无法获取则返回 null
  double? get _maybeDevicePixelRatio =>
      MediaQuery.maybeDevicePixelRatioOf(this);

  /// 获取文本缩放器
  /// 返回: 当前上下文的文本缩放器
  TextScaler get _textScaler => MediaQuery.textScalerOf(this);

  /// 尝试获取文本缩放器，可能为空
  /// 返回: 当前上下文的文本缩放器，如果无法获取则返回 null
  TextScaler? get _maybeTextScaler => MediaQuery.maybeTextScalerOf(this);
}

class _Sizes {
  const _Sizes({
    required this.width,
    required this.height,
    required this.padding,
    required this.viewInsets,
    required this.systemGestureInsets,
    required this.viewPadding,
    required this.devicePixelRatio,
    required this.textScaler,
    required this.maybeWidth,
    required this.maybeHeight,
    required this.maybePadding,
    required this.maybeViewInsets,
    required this.maybeSystemGestureInsets,
    required this.maybeViewPadding,
    required this.maybeDevicePixelRatio,
    required this.maybeTextScaler,
  });

  /// 屏幕宽度
  ///
  /// 返回: 当前设备的屏幕宽度
  ///
  /// 参考 [Size.width]
  final double width;

  /// 可能为空的屏幕宽度
  ///
  /// 返回: 当前设备的屏幕宽度，如果无法获取则为 null
  ///
  /// 参考 [Size.width]
  final double? maybeWidth;

  /// 屏幕高度
  ///
  /// 返回: 当前设备的屏幕高度
  ///
  /// 参考 [Size.height]
  final double height;

  /// 可能为空的屏幕高度
  ///
  /// 返回: 当前设备的屏幕高度，如果无法获取则为 null
  ///
  /// 参考 [Size.height]
  final double? maybeHeight;

  /// 屏幕边距
  ///
  /// 返回: 当前设备的屏幕边距
  ///
  /// 参考 [MediaQueryData.padding]
  final EdgeInsets padding;

  /// 可能为空的屏幕边距
  ///
  /// 返回: 当前设备的屏幕边距，如果无法获取则为 null
  ///
  /// 参考 [MediaQueryData.padding]
  final EdgeInsets? maybePadding;

  /// 视图插入
  ///
  /// 返回: 当前设备的视图插入
  ///
  /// 参考 [MediaQueryData.viewInsets]
  final EdgeInsets viewInsets;

  /// 可能为空的视图插入
  ///
  /// 返回: 当前设备的视图插入，如果无法获取则为 null
  ///
  /// 参考 [MediaQueryData.viewInsets]
  final EdgeInsets? maybeViewInsets;

  /// 系统手势插入
  ///
  /// 返回: 当前设备的系统手势插入
  ///
  /// 参考 [MediaQueryData.systemGestureInsets]
  final EdgeInsets systemGestureInsets;

  /// 可能为空的系统手势插入
  ///
  /// 返回: 当前设备的系统手势插入，如果无法获取则为 null
  ///
  /// 参考 [MediaQueryData.systemGestureInsets]
  final EdgeInsets? maybeSystemGestureInsets;

  /// 视图边距
  ///
  /// 返回: 当前设备的视图边距
  ///
  /// 参考 [MediaQueryData.viewPadding]
  final EdgeInsets viewPadding;

  /// 可能为空的视图边距
  ///
  /// 返回: 当前设备的视图边距，如果无法获取则为 null
  ///
  /// 参考 [MediaQueryData.viewPadding]
  final EdgeInsets? maybeViewPadding;

  /// 设备像素比
  ///
  /// 返回: 当前设备的像素比
  ///
  /// 参考 [MediaQueryData.devicePixelRatio]
  final double devicePixelRatio;

  /// 可能为空的设备像素比
  ///
  /// 返回: 当前设备的像素比，如果无法获取则为 null
  ///
  /// 参考 [MediaQueryData.devicePixelRatio]
  final double? maybeDevicePixelRatio;

  /// 文本缩放器
  ///
  /// 返回: 当前设备的文本缩放器
  ///
  /// 参考 [MediaQueryData.textScaler]
  final TextScaler textScaler;

  /// 可能为空的文本缩放器
  ///
  /// 返回: 当前设备的文本缩放器，如果无法获取则为 null
  ///
  /// 参考 [MediaQueryData.textScaler]
  final TextScaler? maybeTextScaler;
}
```

### `lib/common/extension/padding_ext.dart`

```dart
part of 'app_extensions.dart';

/// 数字转 EdgeInsets 扩展
extension PaddingExtensions on num {
  /// 创建所有方向上偏移量相等的内边距
  ///
  /// 返回: 一个 EdgeInsets 对象，其所有方向的偏移量都等于当前数值
  ///
  /// 示例: 5.paddingAll() 等同于 EdgeInsets.all(5.0)
  EdgeInsets paddingAll() => EdgeInsets.all(toDouble());

  /// 创建水平方向上对称的内边距
  ///
  /// 返回: 一个 EdgeInsets 对象，其左右偏移量等于当前数值，上下偏移量为0
  ///
  /// 示例: 5.paddingHorizontal() 等同于 EdgeInsets.symmetric(horizontal: 5.0)
  EdgeInsets paddingHorizontal() =>
      EdgeInsets.symmetric(horizontal: toDouble());

  /// 创建垂直方向上对称的内边距
  ///
  /// 返回: 一个 EdgeInsets 对象，其上下偏移量等于当前数值，左右偏移量为0
  ///
  /// 示例: 5.paddingVertical() 等同于 EdgeInsets.symmetric(vertical: 5.0)
  EdgeInsets paddingVertical() => EdgeInsets.symmetric(vertical: toDouble());

  /// 创建只有顶部内边距的 EdgeInsets
  ///
  /// 返回: 一个 EdgeInsets 对象，其顶部偏移量等于当前数值，其他方向为0
  ///
  /// 示例: 5.paddingTop() 等同于 EdgeInsets.only(top: 5.0)
  EdgeInsets paddingTop() => EdgeInsets.only(top: toDouble());

  /// 创建只有左侧内边距的 EdgeInsets
  ///
  /// 返回: 一个 EdgeInsets 对象，其左侧偏移量等于当前数值，其他方向为0
  ///
  /// 示例: 5.paddingLeft() 等同于 EdgeInsets.only(left: 5.0)
  EdgeInsets paddingLeft() => EdgeInsets.only(left: toDouble());

  /// 创建只有右侧内边距的 EdgeInsets
  ///
  /// 返回: 一个 EdgeInsets 对象，其右侧偏移量等于当前数值，其他方向为0
  ///
  /// 示例: 5.paddingRight() 等同于 EdgeInsets.only(right: 5.0)
  EdgeInsets paddingRight() => EdgeInsets.only(right: toDouble());

  /// 创建只有底部内边距的 EdgeInsets
  ///
  /// 返回: 一个 EdgeInsets 对象，其底部偏移量等于当前数值，其他方向为0
  ///
  /// 示例: 5.paddingBottom() 等同于 EdgeInsets.only(bottom: 5.0)
  EdgeInsets paddingBottom() => EdgeInsets.only(bottom: toDouble());
}
```

### `lib/common/extension/platform_ext.dart`

```dart
part of 'app_extensions.dart';

/// 当前系统
extension PlatformExtensions on BuildContext {
  /// 获取当前平台
  ///
  /// 返回: 当前运行的目标平台 (TargetPlatform)
  TargetPlatform get platform => Theme.of(this).platform;

  /// 检查当前系统是否为 Android
  ///
  /// 返回: 如果当前平台是 Android，则返回 true；否则返回 false
  bool get isAndroid => platform == TargetPlatform.android;

  /// 检查当前系统是否为 iOS
  ///
  /// 返回: 如果当前平台是 iOS，则返回 true；否则返回 false
  bool get isIOS => platform == TargetPlatform.iOS;

  /// 检查当前系统是否为 MacOS
  ///
  /// 返回: 如果当前平台是 MacOS，则返回 true；否则返回 false
  bool get isMacOS => platform == TargetPlatform.macOS;

  /// 检查当前系统是否为 Windows
  ///
  /// 返回: 如果当前平台是 Windows，则返回 true；否则返回 false
  bool get isWindows => platform == TargetPlatform.windows;

  /// 检查当前系统是否为 Fuchsia
  ///
  /// 返回: 如果当前平台是 Fuchsia，则返回 true；否则返回 false
  bool get isFuchsia => platform == TargetPlatform.fuchsia;

  /// 检查当前系统是否为 Linux
  ///
  /// 返回: 如果当前平台是 Linux，则返回 true；否则返回 false
  bool get isLinux => platform == TargetPlatform.linux;
}
```

### `lib/common/extension/safe_area_ext.dart`

```dart
import 'package:flutter/widgets.dart';

/// 文件作用：
/// - 快捷读取刘海 / 手势条安全区
///
/// 适用于自定义全屏布局、底部按钮、沉浸式 AppBar。
extension SafeAreaExt on BuildContext {
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);
  double get safeTop => safeAreaPadding.top;
  double get safeBottom => safeAreaPadding.bottom;
  double get safeLeft => safeAreaPadding.left;
  double get safeRight => safeAreaPadding.right;
}
```

### `lib/common/extension/screen/_flutter_widgets.dart`

```dart
part of '../app_extensions.dart';

final flutterWidgets = HashSet<String>.from({
  'AbsorbPointer',
  'Accumulator',
  'Action',
  'ActionDispatcher',
  'ActionListener',
  'Actions',
  'ActivateAction',
  'ActivateIntent',
  'Align',
  'Alignment',
  'AlignmentDirectional',
  'AlignmentGeometry',
  'AlignmentGeometryTween',
  'AlignmentTween',
  'AlignTransition',
  'AlwaysScrollableScrollPhysics',
  'AlwaysStoppedAnimation',
  'AndroidView',
  'AndroidViewSurface',
  'Animatable',
  'AnimatedAlign',
  'AnimatedBuilder',
  'AnimatedContainer',
  'AnimatedCrossFade',
  'AnimatedDefaultTextStyle',
  'AnimatedFractionallySizedBox',
  'AnimatedGrid',
  'AnimatedGridState',
  'AnimatedList',
  'AnimatedListState',
  'AnimatedModalBarrier',
  'AnimatedOpacity',
  'AnimatedPadding',
  'AnimatedPhysicalModel',
  'AnimatedPositioned',
  'AnimatedPositionedDirectional',
  'AnimatedRotation',
  'AnimatedScale',
  'AnimatedSize',
  'AnimatedSlide',
  'AnimatedSwitcher',
  'AnimatedWidget',
  'AnimatedWidgetBaseState',
  'Animation',
  'AnimationController',
  'AnimationMax',
  'AnimationMean',
  'AnimationMin',
  'AnnotatedRegion',
  'AspectRatio',
  'AssetBundle',
  'AssetBundleImageKey',
  'AssetBundleImageProvider',
  'AssetImage',
  'AsyncSnapshot',
  'AutocompleteHighlightedOption',
  'AutocompleteNextOptionIntent',
  'AutocompletePreviousOptionIntent',
  'AutofillGroup',
  'AutofillGroupState',
  'AutofillHints',
  'AutomaticKeepAlive',
  'AutomaticNotchedShape',
  'BackButtonDispatcher',
  'BackButtonListener',
  'BackdropFilter',
  'BallisticScrollActivity',
  'Banner',
  'BannerPainter',
  'Baseline',
  'BaseTapAndDragGestureRecognizer',
  'BeveledRectangleBorder',
  'BlockSemantics',
  'Border',
  'BorderDirectional',
  'BorderRadius',
  'BorderRadiusDirectional',
  'BorderRadiusGeometry',
  'BorderRadiusTween',
  'BorderSide',
  'BorderTween',
  'BottomNavigationBarItem',
  'BouncingScrollPhysics',
  'BouncingScrollSimulation',
  'BoxBorder',
  'BoxConstraints',
  'BoxConstraintsTween',
  'BoxDecoration',
  'BoxPainter',
  'BoxScrollView',
  'BoxShadow',
  'BuildContext',
  'Builder',
  'BuildOwner',
  'ButtonActivateIntent',
  'CallbackAction',
  'CallbackShortcuts',
  'Canvas',
  'CapturedThemes',
  'CatmullRomCurve',
  'CatmullRomSpline',
  'Center',
  'ChangeNotifier',
  'CharacterActivator',
  'CharacterRange',
  'Characters',
  'CheckedModeBanner',
  'ChildBackButtonDispatcher',
  'CircleBorder',
  'CircularNotchedRectangle',
  'ClampingScrollPhysics',
  'ClampingScrollSimulation',
  'ClipboardStatusNotifier',
  'ClipContext',
  'ClipOval',
  'ClipPath',
  'ClipRect',
  'ClipRRect',
  'Color',
  'ColoredBox',
  'ColorFilter',
  'ColorFiltered',
  'ColorProperty',
  'ColorSwatch',
  'ColorTween',
  'Column',
  'ComponentElement',
  'CompositedTransformFollower',
  'CompositedTransformTarget',
  'CompoundAnimation',
  'ConstantTween',
  'ConstrainedBox',
  'ConstrainedLayoutBuilder',
  'ConstraintsTransformBox',
  'Container',
  'ContentInsertionConfiguration',
  'ContextAction',
  'ContextMenuButtonItem',
  'ContextMenuController',
  'ContinuousRectangleBorder',
  'CopySelectionTextIntent',
  'Cubic',
  'Curve',
  'Curve2D',
  'Curve2DSample',
  'CurvedAnimation',
  'Curves',
  'CurveTween',
  'CustomClipper',
  'CustomMultiChildLayout',
  'CustomPaint',
  'CustomPainter',
  'CustomPainterSemantics',
  'CustomScrollView',
  'CustomSingleChildLayout',
  'DebugCreator',
  'DecoratedBox',
  'DecoratedBoxTransition',
  'Decoration',
  'DecorationImage',
  'DecorationImagePainter',
  'DecorationTween',
  'DefaultAssetBundle',
  'DefaultPlatformMenuDelegate',
  'DefaultSelectionStyle',
  'DefaultTextEditingShortcuts',
  'DefaultTextHeightBehavior',
  'DefaultTextStyle',
  'DefaultTextStyleTransition',
  'DefaultTransitionDelegate',
  'DefaultWidgetsLocalizations',
  'DeleteCharacterIntent',
  'DeleteToLineBreakIntent',
  'DeleteToNextWordBoundaryIntent',
  'DesktopTextSelectionToolbarLayoutDelegate',
  'DevToolsDeepLinkProperty',
  'DiagnosticsNode',
  'DirectionalCaretMovementIntent',
  'DirectionalFocusAction',
  'DirectionalFocusIntent',
  'Directionality',
  'DirectionalTextEditingIntent',
  'DismissAction',
  'Dismissible',
  'DismissIntent',
  'DismissUpdateDetails',
  'DisplayFeatureSubScreen',
  'DisposableBuildContext',
  'DoNothingAction',
  'DoNothingAndStopPropagationIntent',
  'DoNothingAndStopPropagationTextIntent',
  'DoNothingIntent',
  'DragDownDetails',
  'DragEndDetails',
  'Draggable',
  'DraggableDetails',
  'DraggableScrollableActuator',
  'DraggableScrollableController',
  'DraggableScrollableNotification',
  'DraggableScrollableSheet',
  'DragScrollActivity',
  'DragStartDetails',
  'DragTarget',
  'DragTargetDetails',
  'DragUpdateDetails',
  'DrivenScrollActivity',
  'DualTransitionBuilder',
  'EdgeDraggingAutoScroller',
  'EdgeInsets',
  'EdgeInsetsDirectional',
  'EdgeInsetsGeometry',
  'EdgeInsetsGeometryTween',
  'EdgeInsetsTween',
  'EditableText',
  'EditableTextState',
  'ElasticInCurve',
  'ElasticInOutCurve',
  'ElasticOutCurve',
  'Element',
  'EmptyTextSelectionControls',
  'ErrorDescription',
  'ErrorHint',
  'ErrorSummary',
  'ErrorWidget',
  'ExactAssetImage',
  'ExcludeFocus',
  'ExcludeFocusTraversal',
  'ExcludeSemantics',
  'Expanded',
  'ExpandSelectionToDocumentBoundaryIntent',
  'ExpandSelectionToLineBreakIntent',
  'ExtendSelectionByCharacterIntent',
  'ExtendSelectionByPageIntent',
  'ExtendSelectionToDocumentBoundaryIntent',
  'ExtendSelectionToLineBreakIntent',
  'ExtendSelectionToNextParagraphBoundaryIntent',
  'ExtendSelectionToNextParagraphBoundaryOrCaretLocationIntent',
  'ExtendSelectionToNextWordBoundaryIntent',
  'ExtendSelectionToNextWordBoundaryOrCaretLocationIntent',
  'ExtendSelectionVerticallyToAdjacentLineIntent',
  'ExtendSelectionVerticallyToAdjacentPageIntent',
  'FadeInImage',
  'FadeTransition',
  'FileImage',
  'FittedBox',
  'FittedSizes',
  'FixedColumnWidth',
  'FixedExtentMetrics',
  'FixedExtentScrollController',
  'FixedExtentScrollPhysics',
  'FixedScrollMetrics',
  'Flex',
  'FlexColumnWidth',
  'Flexible',
  'FlippedCurve',
  'FlippedTweenSequence',
  'Flow',
  'FlowDelegate',
  'FlowPaintingContext',
  'FlutterErrorDetails',
  'FlutterLogoDecoration',
  'Focus',
  'FocusableActionDetector',
  'FocusAttachment',
  'FocusManager',
  'FocusNode',
  'FocusOrder',
  'FocusScope',
  'FocusScopeNode',
  'FocusTraversalGroup',
  'FocusTraversalOrder',
  'FocusTraversalPolicy',
  'FontWeight',
  'ForcePressDetails',
  'Form',
  'FormField',
  'FormFieldState',
  'FormState',
  'FractionallySizedBox',
  'FractionalOffset',
  'FractionalOffsetTween',
  'FractionalTranslation',
  'FractionColumnWidth',
  'FutureBuilder',
  'GestureDetector',
  'GestureRecognizerFactory',
  'GestureRecognizerFactoryWithHandlers',
  'GlobalKey',
  'GlobalObjectKey',
  'GlowingOverscrollIndicator',
  'Gradient',
  'GradientRotation',
  'GradientTransform',
  'GridPaper',
  'GridView',
  'Hero',
  'HeroController',
  'HeroControllerScope',
  'HeroMode',
  'HoldScrollActivity',
  'HSLColor',
  'HSVColor',
  'HtmlElementView',
  'Icon',
  'IconData',
  'IconDataProperty',
  'IconTheme',
  'IconThemeData',
  'IdleScrollActivity',
  'IgnorePointer',
  'Image',
  'ImageCache',
  'ImageCacheStatus',
  'ImageChunkEvent',
  'ImageConfiguration',
  'ImageFiltered',
  'ImageIcon',
  'ImageInfo',
  'ImageProvider',
  'ImageShader',
  'ImageSizeInfo',
  'ImageStream',
  'ImageStreamCompleter',
  'ImageStreamCompleterHandle',
  'ImageStreamListener',
  'ImageTilingInfo',
  'ImplicitlyAnimatedWidget',
  'ImplicitlyAnimatedWidgetState',
  'IndexedSemantics',
  'IndexedSlot',
  'IndexedStack',
  'InheritedElement',
  'InheritedModel',
  'InheritedModelElement',
  'InheritedNotifier',
  'InheritedTheme',
  'InheritedWidget',
  'InlineSpan',
  'InlineSpanSemanticsInformation',
  'InspectorSelection',
  'InspectorSerializationDelegate',
  'Intent',
  'InteractiveViewer',
  'Interval',
  'IntrinsicColumnWidth',
  'IntrinsicHeight',
  'IntrinsicWidth',
  'IntTween',
  'KeepAlive',
  'KeepAliveHandle',
  'KeepAliveNotification',
  'Key',
  'KeyboardInsertedContent',
  'KeyboardListener',
  'KeyedSubtree',
  'KeyEvent',
  'KeySet',
  'LabeledGlobalKey',
  'LayerLink',
  'LayoutBuilder',
  'LayoutChangedNotification',
  'LayoutId',
  'LeafRenderObjectElement',
  'LeafRenderObjectWidget',
  'LexicalFocusOrder',
  'LimitedBox',
  'LinearBorder',
  'LinearBorderEdge',
  'LinearGradient',
  'ListBody',
  'Listenable',
  'ListenableBuilder',
  'Listener',
  'ListView',
  'ListWheelChildBuilderDelegate',
  'ListWheelChildDelegate',
  'ListWheelChildListDelegate',
  'ListWheelChildLoopingListDelegate',
  'ListWheelElement',
  'ListWheelScrollView',
  'ListWheelViewport',
  'Locale',
  'LocalHistoryEntry',
  'Localizations',
  'LocalizationsDelegate',
  'LocalKey',
  'LogicalKeySet',
  'LongPressDraggable',
  'LongPressEndDetails',
  'LongPressMoveUpdateDetails',
  'LongPressStartDetails',
  'LookupBoundary',
  'MagnifierController',
  'MagnifierDecoration',
  'MagnifierInfo',
  'MaskFilter',
  'Matrix4',
  'Matrix4Tween',
  'MatrixUtils',
  'MaxColumnWidth',
  'MediaQuery',
  'MediaQueryData',
  'MemoryImage',
  'MergeSemantics',
  'MetaData',
  'MinColumnWidth',
  'ModalBarrier',
  'ModalRoute',
  'MouseCursor',
  'MouseRegion',
  'MultiChildLayoutDelegate',
  'MultiChildRenderObjectElement',
  'MultiChildRenderObjectWidget',
  'MultiFrameImageStreamCompleter',
  'MultiSelectableSelectionContainerDelegate',
  'NavigationToolbar',
  'Navigator',
  'NavigatorObserver',
  'NavigatorState',
  'NestedScrollView',
  'NestedScrollViewState',
  'NestedScrollViewViewport',
  'NetworkImage',
  'NeverScrollableScrollPhysics',
  'NextFocusAction',
  'NextFocusIntent',
  'NotchedShape',
  'Notification',
  'NotificationListener',
  'NumericFocusOrder',
  'ObjectKey',
  'Offset',
  'Offstage',
  'OneFrameImageStreamCompleter',
  'Opacity',
  'OrderedTraversalPolicy',
  'OrientationBuilder',
  'OutlinedBorder',
  'OvalBorder',
  'OverflowBar',
  'OverflowBox',
  'Overlay',
  'OverlayEntry',
  'OverlayPortal',
  'OverlayPortalController',
  'OverlayRoute',
  'OverlayState',
  'OverscrollIndicatorNotification',
  'OverscrollNotification',
  'Padding',
  'Page',
  'PageController',
  'PageMetrics',
  'PageRoute',
  'PageRouteBuilder',
  'PageScrollPhysics',
  'PageStorage',
  'PageStorageBucket',
  'PageStorageKey',
  'PageView',
  'Paint',
  'PaintingContext',
  'ParametricCurve',
  'ParentDataElement',
  'ParentDataWidget',
  'PasteTextIntent',
  'Path',
  'PerformanceOverlay',
  'PhysicalModel',
  'PhysicalShape',
  'Placeholder',
  'PlaceholderDimensions',
  'PlaceholderSpan',
  'PlatformMenu',
  'PlatformMenuBar',
  'PlatformMenuDelegate',
  'PlatformMenuItem',
  'PlatformMenuItemGroup',
  'PlatformProvidedMenuItem',
  'PlatformRouteInformationProvider',
  'PlatformSelectableRegionContextMenu',
  'PlatformViewCreationParams',
  'PlatformViewLink',
  'PlatformViewSurface',
  'PointerCancelEvent',
  'PointerDownEvent',
  'PointerEvent',
  'PointerMoveEvent',
  'PointerUpEvent',
  'PopupRoute',
  'Positioned',
  'PositionedDirectional',
  'PositionedTransition',
  'PreferredSize',
  'PreferredSizeWidget',
  'PreviousFocusAction',
  'PreviousFocusIntent',
  'PrimaryScrollController',
  'PrioritizedAction',
  'PrioritizedIntents',
  'ProxyAnimation',
  'ProxyElement',
  'ProxyWidget',
  'RadialGradient',
  'Radius',
  'RangeMaintainingScrollPhysics',
  'RawAutocomplete',
  'RawDialogRoute',
  'RawGestureDetector',
  'RawGestureDetectorState',
  'RawImage',
  'RawKeyboardListener',
  'RawKeyEvent',
  'RawMagnifier',
  'RawScrollbar',
  'RawScrollbarState',
  'ReadingOrderTraversalPolicy',
  'Rect',
  'RectTween',
  'RedoTextIntent',
  'RelativePositionedTransition',
  'RelativeRect',
  'RelativeRectTween',
  'RenderBox',
  'RenderNestedScrollViewViewport',
  'RenderObject',
  'RenderObjectElement',
  'RenderObjectToWidgetAdapter',
  'RenderObjectToWidgetElement',
  'RenderObjectWidget',
  'RenderSemanticsGestureHandler',
  'RenderSliverOverlapAbsorber',
  'RenderSliverOverlapInjector',
  'RenderTapRegion',
  'RenderTapRegionSurface',
  'ReorderableDelayedDragStartListener',
  'ReorderableDragStartListener',
  'ReorderableList',
  'ReorderableListState',
  'RepaintBoundary',
  'ReplaceTextIntent',
  'RequestFocusAction',
  'RequestFocusIntent',
  'ResizeImage',
  'ResizeImageKey',
  'RestorableBool',
  'RestorableBoolN',
  'RestorableChangeNotifier',
  'RestorableDateTime',
  'RestorableDateTimeN',
  'RestorableDouble',
  'RestorableDoubleN',
  'RestorableEnum',
  'RestorableEnumN',
  'RestorableInt',
  'RestorableIntN',
  'RestorableListenable',
  'RestorableNum',
  'RestorableNumN',
  'RestorableProperty',
  'RestorableRouteFuture',
  'RestorableString',
  'RestorableStringN',
  'RestorableTextEditingController',
  'RestorableValue',
  'RestorationBucket',
  'RestorationScope',
  'ReverseAnimation',
  'ReverseTween',
  'RichText',
  'RootBackButtonDispatcher',
  'RootRenderObjectElement',
  'RootRestorationScope',
  'RotatedBox',
  'RotationTransition',
  'RoundedRectangleBorder',
  'Route',
  'RouteAware',
  'RouteInformation',
  'RouteInformationParser',
  'RouteInformationProvider',
  'RouteObserver',
  'Router',
  'RouterConfig',
  'RouterDelegate',
  'RouteSettings',
  'RouteTransitionRecord',
  'Row',
  'RRect',
  'RSTransform',
  'SafeArea',
  'SawTooth',
  'ScaleEndDetails',
  'ScaleStartDetails',
  'ScaleTransition',
  'ScaleUpdateDetails',
  'Scrollable',
  'ScrollableDetails',
  'ScrollableState',
  'ScrollAction',
  'ScrollActivity',
  'ScrollActivityDelegate',
  'ScrollAwareImageProvider',
  'ScrollbarPainter',
  'ScrollBehavior',
  'ScrollConfiguration',
  'ScrollContext',
  'ScrollController',
  'ScrollDragController',
  'ScrollEndNotification',
  'ScrollHoldController',
  'ScrollIncrementDetails',
  'ScrollIntent',
  'ScrollMetricsNotification',
  'ScrollNotification',
  'ScrollNotificationObserver',
  'ScrollNotificationObserverState',
  'ScrollPhysics',
  'ScrollPosition',
  'ScrollPositionWithSingleContext',
  'ScrollSpringSimulation',
  'ScrollStartNotification',
  'ScrollToDocumentBoundaryIntent',
  'ScrollUpdateNotification',
  'ScrollView',
  'SelectableRegion',
  'SelectableRegionState',
  'SelectAction',
  'SelectAllTextIntent',
  'SelectIntent',
  'SelectionContainer',
  'SelectionContainerDelegate',
  'SelectionOverlay',
  'SelectionRegistrarScope',
  'Semantics',
  'SemanticsDebugger',
  'SemanticsGestureDelegate',
  'Shader',
  'ShaderMask',
  'ShaderWarmUp',
  'Shadow',
  'ShapeBorder',
  'ShapeBorderClipper',
  'ShapeDecoration',
  'SharedAppData',
  'ShortcutActivator',
  'ShortcutManager',
  'ShortcutMapProperty',
  'ShortcutRegistrar',
  'ShortcutRegistry',
  'ShortcutRegistryEntry',
  'Shortcuts',
  'ShortcutSerialization',
  'ShrinkWrappingViewport',
  'Simulation',
  'SingleActivator',
  'SingleChildLayoutDelegate',
  'SingleChildRenderObjectElement',
  'SingleChildRenderObjectWidget',
  'SingleChildScrollView',
  'Size',
  'SizeChangedLayoutNotification',
  'SizeChangedLayoutNotifier',
  'SizedBox',
  'SizedOverflowBox',
  'SizeTransition',
  'SizeTween',
  'SlideTransition',
  'SliverAnimatedGrid',
  'SliverAnimatedGridState',
  'SliverAnimatedList',
  'SliverAnimatedListState',
  'SliverAnimatedOpacity',
  'SliverChildBuilderDelegate',
  'SliverChildDelegate',
  'SliverChildListDelegate',
  'SliverFadeTransition',
  'SliverFillRemaining',
  'SliverFillViewport',
  'SliverFixedExtentList',
  'SliverGrid',
  'SliverGridDelegate',
  'SliverGridDelegateWithFixedCrossAxisCount',
  'SliverGridDelegateWithMaxCrossAxisExtent',
  'SliverIgnorePointer',
  'SliverLayoutBuilder',
  'SliverList',
  'SliverMultiBoxAdaptorElement',
  'SliverMultiBoxAdaptorWidget',
  'SliverOffstage',
  'SliverOpacity',
  'SliverOverlapAbsorber',
  'SliverOverlapAbsorberHandle',
  'SliverOverlapInjector',
  'SliverPadding',
  'SliverPersistentHeader',
  'SliverPersistentHeaderDelegate',
  'SliverPrototypeExtentList',
  'SliverReorderableList',
  'SliverReorderableListState',
  'SliverSafeArea',
  'SliverToBoxAdapter',
  'SliverVisibility',
  'SliverWithKeepAliveWidget',
  'SlottedRenderObjectElement',
  'SnapshotController',
  'SnapshotPainter',
  'SnapshotWidget',
  'Spacer',
  'SpellCheckConfiguration',
  'SpringDescription',
  'Stack',
  'StadiumBorder',
  'StarBorder',
  'State',
  'StatefulBuilder',
  'StatefulElement',
  'StatefulWidget',
  'StatelessElement',
  'StatelessWidget',
  'StatusTransitionWidget',
  'StepTween',
  'StreamBuilder',
  'StreamBuilderBase',
  'StretchingOverscrollIndicator',
  'StrutStyle',
  'SweepGradient',
  'SystemMouseCursors',
  'Table',
  'TableBorder',
  'TableCell',
  'TableColumnWidth',
  'TableRow',
  'TapAndDragGestureRecognizer',
  'TapAndHorizontalDragGestureRecognizer',
  'TapAndPanGestureRecognizer',
  'TapDownDetails',
  'TapDragDownDetails',
  'TapDragEndDetails',
  'TapDragStartDetails',
  'TapDragUpdateDetails',
  'TapDragUpDetails',
  'TapRegion',
  'TapRegionRegistry',
  'TapRegionSurface',
  'TapUpDetails',
  'Text',
  'TextAlignVertical',
  'TextBox',
  'TextDecoration',
  'TextEditingController',
  'TextEditingValue',
  'TextFieldTapRegion',
  'TextHeightBehavior',
  'TextInputType',
  'TextMagnifierConfiguration',
  'TextPainter',
  'TextPosition',
  'TextRange',
  'TextSelection',
  'TextSelectionControls',
  'TextSelectionGestureDetector',
  'TextSelectionGestureDetectorBuilder',
  'TextSelectionGestureDetectorBuilderDelegate',
  'TextSelectionOverlay',
  'TextSelectionPoint',
  'TextSelectionToolbarAnchors',
  'TextSelectionToolbarLayoutDelegate',
  'TextSpan',
  'TextStyle',
  'TextStyleTween',
  'Texture',
  'ThreePointCubic',
  'Threshold',
  'TickerFuture',
  'TickerMode',
  'TickerProvider',
  'Title',
  'Tolerance',
  'ToolbarItemsParentData',
  'ToolbarOptions',
  'TrackingScrollController',
  'TrainHoppingAnimation',
  'Transform',
  'TransformationController',
  'TransformProperty',
  'TransitionDelegate',
  'TransitionRoute',
  'TransposeCharactersIntent',
  'Tween',
  'TweenAnimationBuilder',
  'TweenSequence',
  'TweenSequenceItem',
  'UiKitView',
  'UnconstrainedBox',
  'UndoHistory',
  'UndoHistoryController',
  'UndoHistoryState',
  'UndoHistoryValue',
  'UndoTextIntent',
  'UniqueKey',
  'UniqueWidget',
  'UnmanagedRestorationScope',
  'UpdateSelectionIntent',
  'UserScrollNotification',
  'ValueKey',
  'ValueListenableBuilder',
  'ValueNotifier',
  'Velocity',
  'View',
  'Viewport',
  'Visibility',
  'VoidCallbackAction',
  'VoidCallbackIntent',
  'Widget',
  'WidgetInspector',
  'WidgetOrderTraversalPolicy',
  'WidgetsApp',
  'WidgetsBindingObserver',
  'WidgetsFlutterBinding',
  'WidgetsLocalizations',
  'WidgetSpan',
  'WidgetToRenderBoxAdapter',
  'WillPopScope',
  'WordBoundary',
  'Wrap',
});
```

### `lib/common/extension/screen/screen_util.dart`

```dart
part of '../app_extensions.dart';

typedef FontSizeResolver = double Function(num fontSize, ScreenUtil instance);

class ScreenUtil {
  /// 默认设计尺寸
  static const Size defaultSize = Size(360, 690);

  /// ScreenUtil 单例实例
  static final ScreenUtil _instance = ScreenUtil._();

  /// 控制是否启用宽高缩放的函数
  static bool Function() _enableScaleWH = () => true;

  /// 控制是否启用文本缩放的函数
  static bool Function() _enableScaleText = () => true;

  /// UI设计中手机尺寸，单位为 dp
  late Size _uiSize;

  /// 屏幕方向
  late Orientation _orientation;

  /// 是否启用最小文本自适应
  late bool _minTextAdapt;

  /// 媒体查询数据
  late MediaQueryData _data;

  /// 是否启用分屏模式
  late bool _splitScreenMode;

  /// 字体大小解析器
  FontSizeResolver? fontSizeResolver;

  /// 私有构造函数
  ScreenUtil._();

  /// 工厂构造函数，返回单例实例
  factory ScreenUtil() => _instance;

  /// 启用或禁用缩放
  ///
  /// 参数:
  /// - enableWH: 控制是否启用宽高缩放的函数
  /// - enableText: 控制是否启用文本缩放的函数
  ///
  /// 如果 enableWH 返回 false，宽度和高度的缩放比例将为 1
  /// 如果 enableText 返回 false，文本的缩放比例将为 1
  static void enableScale({
    bool Function()? enableWH,
    bool Function()? enableText,
  }) {
    _enableScaleWH = enableWH ?? () => true;
    _enableScaleText = enableText ?? () => true;
  }

  /// 手动等待窗口大小初始化
  ///
  /// 建议在需要访问窗口大小之前使用，或在自定义启动/引导屏幕的 [FutureBuilder] 中使用
  ///
  /// 参数:
  /// - window: Flutter 视图对象，默认为 null
  /// - duration: 轮询间隔，默认为 10 毫秒
  ///
  /// 返回:
  /// - `Future<void>`：当窗口大小初始化完成时完成的 Future
  ///
  /// 示例:
  /// ```dart
  /// ...
  /// ScreenUtil.init(context, ...);
  /// ...
  ///   FutureBuilder(
  ///     future: Future.wait([..., ensureScreenSize(), ...]),
  ///     builder: (context, snapshot) {
  ///       if (snapshot.hasData) return const HomeScreen();
  ///       return Material(
  ///         child: LayoutBuilder(
  ///           ...
  ///         ),
  ///       );
  ///     },
  ///   )
  /// ```
  static Future<void> ensureScreenSize([
    FlutterView? window,
    Duration duration = const Duration(milliseconds: 10),
  ]) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.deferFirstFrame();

    await Future.doWhile(() {
      window ??= binding.platformDispatcher.implicitView;

      if (window == null || window!.physicalSize.isEmpty) {
        return Future.delayed(duration, () => true);
      }

      return false;
    });

    binding.allowFirstFrame();
  }

  /// 需要重建的元素集合
  Set<Element>? _elementsToRebuild;

  /// 注册当前页面及其所有后代以进行重建
  /// 在构建 Web 和桌面应用时特别有用
  ///
  /// 参数:
  /// - context: 构建上下文
  /// - withDescendants: 是否包括后代元素，默认为 false
  ///
  /// 注意: 此方法为实验性功能
  static void registerToBuild(
    BuildContext context, [
    bool withDescendants = false,
  ]) {
    (_instance._elementsToRebuild ??= {}).add(context as Element);

    if (withDescendants) {
      context.visitChildren((element) {
        registerToBuild(element, true);
      });
    }
  }

  /// 配置 ScreenUtil 实例
  ///
  /// 参数:
  /// - data: 媒体查询数据，可选
  /// - designSize: 设计尺寸，可选
  /// - splitScreenMode: 是否启用分屏模式，可选
  /// - minTextAdapt: 是否启用最小文本自适应，可选
  /// - fontSizeResolver: 字体大小解析器，可选
  ///
  /// 抛出:
  /// - Exception: 如果在调用 ScreenUtil.init 或 ScreenUtilInit 之前使用
  static void configure({
    MediaQueryData? data,
    Size? designSize,
    bool? splitScreenMode,
    bool? minTextAdapt,
    FontSizeResolver? fontSizeResolver,
  }) {
    try {
      if (data != null) {
        _instance._data = data;
      } else {
        data = _instance._data;
      }

      if (designSize != null) {
        _instance._uiSize = designSize;
      } else {
        designSize = _instance._uiSize;
      }
    } catch (_) {
      throw Exception(
        'You must either use ScreenUtil.init or ScreenUtilInit first',
      );
    }

    final MediaQueryData? deviceData = data.nonEmptySizeOrNull();
    final Size deviceSize = deviceData?.size ?? designSize;

    final orientation =
        deviceData?.orientation ??
        (deviceSize.width > deviceSize.height
            ? Orientation.landscape
            : Orientation.portrait);

    _instance
      ..fontSizeResolver = fontSizeResolver ?? _instance.fontSizeResolver
      .._minTextAdapt = minTextAdapt ?? _instance._minTextAdapt
      .._splitScreenMode = splitScreenMode ?? _instance._splitScreenMode
      .._orientation = orientation;

    _instance._elementsToRebuild?.forEach((el) => el.markNeedsBuild());
  }

  /// 初始化 ScreenUtil 库
  ///
  /// 参数:
  /// - context: 构建上下文
  /// - designSize: 设计尺寸，默认为 defaultSize
  /// - splitScreenMode: 是否启用分屏模式，默认为 false
  /// - minTextAdapt: 是否启用最小文本自适应，默认为 false
  /// - fontSizeResolver: 字体大小解析器，可选
  static void init(
    BuildContext context, {
    Size designSize = defaultSize,
    bool splitScreenMode = false,
    bool minTextAdapt = false,
    FontSizeResolver? fontSizeResolver,
  }) {
    final view = View.maybeOf(context);
    return configure(
      data: view != null ? MediaQueryData.fromView(view) : null,
      designSize: designSize,
      splitScreenMode: splitScreenMode,
      minTextAdapt: minTextAdapt,
      fontSizeResolver: fontSizeResolver,
    );
  }

  /// 确保屏幕尺寸已初始化，然后初始化 ScreenUtil
  ///
  /// 参数:
  /// - context: 构建上下文
  /// - designSize: 设计尺寸，默认为 defaultSize
  /// - splitScreenMode: 是否启用分屏模式，默认为 false
  /// - minTextAdapt: 是否启用最小文本自适应，默认为 false
  /// - fontSizeResolver: 字体大小解析器，可选
  ///
  /// 返回:
  /// - `Future<void>`：当初始化完成时完成的 Future
  static Future<void> ensureScreenSizeAndInit(
    BuildContext context, {
    Size designSize = defaultSize,
    bool splitScreenMode = false,
    bool minTextAdapt = false,
    FontSizeResolver? fontSizeResolver,
  }) async {
    await ScreenUtil.ensureScreenSize();
    // 等待窗口就绪后，调用方页面可能已经销毁，不能再读取其上下文。
    if (!context.mounted) return;

    init(
      context,
      designSize: designSize,
      minTextAdapt: minTextAdapt,
      splitScreenMode: splitScreenMode,
      fontSizeResolver: fontSizeResolver,
    );
  }

  /// 获取屏幕方向
  ///
  /// 返回: 当前的屏幕方向 (Orientation)
  Orientation get orientation => _orientation;

  /// 获取文本缩放因子
  ///
  /// 返回: 每个逻辑像素的字体像素数，即字体的缩放比例
  // double get textScaleFactor => _data.textScaleFactor;

  /// 获取设备的像素密度
  ///
  /// 返回: 设备的像素密度 (设备物理像素和逻辑像素的比率)
  double? get pixelRatio => _data.devicePixelRatio;

  /// 获取当前设备宽度
  ///
  /// 返回: 当前设备的宽度，单位为 dp
  double get screenWidth => _data.size.width;

  /// 获取当前设备高度
  ///
  /// 返回: 当前设备的高度，单位为 dp
  double get screenHeight => _data.size.height;

  /// 获取状态栏高度
  ///
  /// 返回: 状态栏的高度，单位为 dp (刘海屏会更高)
  double get statusBarHeight => _data.padding.top;

  /// 获取底部安全区距离
  ///
  /// 返回: 底部安全区的距离，单位为 dp
  double get bottomBarHeight => _data.padding.bottom;

  /// 获取实际宽度与UI设计宽度的比例
  ///
  /// 返回: 如果启用了宽度缩放，返回实际宽度与设计宽度的比例；否则返回 1
  double get scaleWidth => !_enableScaleWH() ? 1 : screenWidth / _uiSize.width;

  /// 获取实际高度与UI设计高度的比例
  ///
  /// 返回: 如果启用了高度缩放，返回实际高度与设计高度的比例；否则返回 1
  double get scaleHeight => !_enableScaleWH()
      ? 1
      : (_splitScreenMode ? max(screenHeight, 700) : screenHeight) /
            _uiSize.height;

  /// 获取文本缩放比例
  ///
  /// 返回: 文本的缩放比例
  double get scaleText => !_enableScaleText()
      ? 1
      : (_minTextAdapt ? min(scaleWidth, scaleHeight) : scaleWidth);

  /// 根据UI设计的设备宽度适配尺寸
  ///
  /// 参数:
  /// - width: 设计稿上的宽度
  ///
  /// 返回: 适配后的宽度
  double setWidth(num width) => width * scaleWidth;

  /// 根据UI设计的设备高度适配尺寸
  ///
  /// 参数:
  /// - height: 设计稿上的高度
  ///
  /// 返回: 适配后的高度
  double setHeight(num height) => height * scaleHeight;

  /// 根据宽度或高度中的较小值进行适配
  ///
  /// 参数:
  /// - r: 设计稿上的尺寸
  ///
  /// 返回: 适配后的尺寸
  double radius(num r) => r * min(scaleWidth, scaleHeight);

  /// 根据宽度和高度同时进行适配
  ///
  /// 参数:
  /// - d: 设计稿上的尺寸
  ///
  /// 返回: 适配后的尺寸
  double diagonal(num d) => d * scaleHeight * scaleWidth;

  /// 根据宽度和高度的最大值进行适配
  ///
  /// 参数:
  /// - d: 设计稿上的尺寸
  ///
  /// 返回: 适配后的尺寸
  double diameter(num d) => d * max(scaleWidth, scaleHeight);

  /// 字体大小适配方法
  ///
  /// 参数:
  /// - fontSize: UI设计上字体的大小，单位dp
  ///
  /// 返回: 适配后的字体大小
  double setSp(num fontSize) {
    // 文本缩放开关对默认和自定义解析器都生效。
    if (!_enableScaleText()) return fontSize.toDouble();
    return fontSizeResolver?.call(fontSize, _instance) ?? fontSize * scaleText;
  }

  /// 获取设备类型
  ///
  /// 参数:
  /// - context: 构建上下文
  ///
  /// 返回: 当前设备的类型 (DeviceType)
  DeviceType deviceType(BuildContext context) {
    var deviceType = DeviceType.web;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;

    if (kIsWeb) {
      deviceType = DeviceType.web;
    } else {
      bool isMobile =
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
      bool isTablet =
          (orientation == Orientation.portrait && screenWidth >= 600) ||
          (orientation == Orientation.landscape && screenHeight >= 600);

      if (isMobile) {
        deviceType = isTablet ? DeviceType.tablet : DeviceType.mobile;
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.linux:
            deviceType = DeviceType.linux;
            break;
          case TargetPlatform.macOS:
            deviceType = DeviceType.mac;
            break;
          case TargetPlatform.windows:
            deviceType = DeviceType.windows;
            break;
          case TargetPlatform.fuchsia:
            deviceType = DeviceType.fuchsia;
            break;
          default:
            break;
        }
      }
    }

    return deviceType;
  }

  /// 创建垂直间距
  ///
  /// 参数:
  /// - height: 设计稿上的高度
  ///
  /// 返回: 一个高度经过适配的 SizedBox
  SizedBox setVerticalSpacing(num height) =>
      SizedBox(height: setHeight(height));

  /// 创建基于宽度的垂直间距
  ///
  /// 参数:
  /// - height: 设计稿上的宽度值（用作高度）
  ///
  /// 返回: 一个高度基于宽度适配的 SizedBox
  SizedBox setVerticalSpacingFromWidth(num height) =>
      SizedBox(height: setWidth(height));

  /// 创建水平间距
  ///
  /// 参数:
  /// - width: 设计稿上的宽度
  ///
  /// 返回: 一个宽度经过适配的 SizedBox
  SizedBox setHorizontalSpacing(num width) => SizedBox(width: setWidth(width));

  /// 创建基于半径的水平间距
  ///
  /// 参数:
  /// - width: 设计稿上的半径值（用作宽度）
  ///
  /// 返回: 一个宽度基于半径适配的 SizedBox
  SizedBox setHorizontalSpacingRadius(num width) =>
      SizedBox(width: radius(width));

  /// 创建基于半径的垂直间距
  ///
  /// 参数:
  /// - height: 设计稿上的半径值（用作高度）
  ///
  /// 返回: 一个高度基于半径适配的 SizedBox
  SizedBox setVerticalSpacingRadius(num height) =>
      SizedBox(height: radius(height));

  /// 创建基于直径的水平间距
  ///
  /// 参数:
  /// - width: 设计稿上的直径值（用作宽度）
  ///
  /// 返回: 一个宽度基于直径适配的 SizedBox
  SizedBox setHorizontalSpacingDiameter(num width) =>
      SizedBox(width: diameter(width));

  /// 创建基于直径的垂直间距
  ///
  /// 参数:
  /// - height: 设计稿上的直径值（用作高度）
  ///
  /// 返回: 一个高度基于直径适配的 SizedBox
  SizedBox setVerticalSpacingDiameter(num height) =>
      SizedBox(height: diameter(height));

  /// 创建基于对角线的水平间距
  ///
  /// 参数:
  /// - width: 设计稿上的对角线值（用作宽度）
  ///
  /// 返回: 一个宽度基于对角线适配的 SizedBox
  SizedBox setHorizontalSpacingDiagonal(num width) =>
      SizedBox(width: diagonal(width));

  /// 创建基于对角线的垂直间距
  ///
  /// 参数:
  /// - height: 设计稿上的对角线值（用作高度）
  ///
  /// 返回: 一个高度基于对角线适配的 SizedBox
  SizedBox setVerticalSpacingDiagonal(num height) =>
      SizedBox(height: diagonal(height));
}

extension on MediaQueryData? {
  /// 检查 MediaQueryData 是否具有非空的尺寸
  ///
  /// 此方法用于确保 MediaQueryData 对象具有有效的尺寸。
  /// 如果尺寸为空或 MediaQueryData 为 null，则返回 null。
  ///
  /// 返回:
  /// - MediaQueryData?: 如果尺寸非空，则返回原始 MediaQueryData 对象；否则返回 null
  MediaQueryData? nonEmptySizeOrNull() {
    if (this?.size.isEmpty ?? true) {
      return null;
    } else {
      return this;
    }
  }
}

enum DeviceType { mobile, tablet, web, mac, windows, linux, fuchsia }
```

### `lib/common/extension/screen/screenutil_init.dart`

```dart
part of '../app_extensions.dart';

typedef RebuildFactor = bool Function(MediaQueryData old, MediaQueryData data);

typedef ScreenUtilInitBuilder =
    Widget Function(BuildContext context, Widget? child);

abstract class RebuildFactors {
  static bool size(MediaQueryData old, MediaQueryData data) {
    return old.size != data.size;
  }

  static bool orientation(MediaQueryData old, MediaQueryData data) {
    return old.orientation != data.orientation;
  }

  static bool sizeAndViewInsets(MediaQueryData old, MediaQueryData data) {
    // 同时响应窗口调整与键盘变化，避免沿用旧尺寸。
    return old.size != data.size || old.viewInsets != data.viewInsets;
  }

  static bool change(MediaQueryData old, MediaQueryData data) {
    return old != data;
  }

  static bool always(MediaQueryData _, MediaQueryData _) {
    return true;
  }

  static bool none(MediaQueryData _, MediaQueryData _) {
    return false;
  }
}

abstract class FontSizeResolvers {
  /// 默认字体策略遵循文本缩放开关和最小比例适配设置。
  static double adaptive(num fontSize, ScreenUtil instance) {
    return fontSize * instance.scaleText;
  }

  static double width(num fontSize, ScreenUtil instance) {
    return instance.setWidth(fontSize);
  }

  static double height(num fontSize, ScreenUtil instance) {
    return instance.setHeight(fontSize);
  }

  static double radius(num fontSize, ScreenUtil instance) {
    return instance.radius(fontSize);
  }

  static double diameter(num fontSize, ScreenUtil instance) {
    return instance.diameter(fontSize);
  }

  static double diagonal(num fontSize, ScreenUtil instance) {
    return instance.diagonal(fontSize);
  }
}

class ScreenUtilInit extends StatefulWidget {
  /// A helper widget that initializes [ScreenUtil]
  const ScreenUtilInit({
    super.key,
    this.builder,
    this.child,
    this.rebuildFactor = RebuildFactors.size,
    this.designSize = ScreenUtil.defaultSize,
    this.splitScreenMode = false,
    this.minTextAdapt = false,
    this.useInheritedMediaQuery = false,
    this.ensureScreenSize = false,
    this.enableScaleWH,
    this.enableScaleText,
    this.responsiveWidgets,
    this.excludeWidgets,
    this.fontSizeResolver = FontSizeResolvers.adaptive,
  });

  final ScreenUtilInitBuilder? builder;
  final Widget? child;
  final bool splitScreenMode;
  final bool minTextAdapt;
  final bool useInheritedMediaQuery;
  final bool ensureScreenSize;
  final bool Function()? enableScaleWH;
  final bool Function()? enableScaleText;
  final RebuildFactor rebuildFactor;
  final FontSizeResolver fontSizeResolver;

  /// The [Size] of the device in the design draft, in dp
  final Size designSize;
  final Iterable<String>? responsiveWidgets;
  final Iterable<String>? excludeWidgets;

  @override
  State<ScreenUtilInit> createState() => _ScreenUtilInitState();
}

class _ScreenUtilInitState extends State<ScreenUtilInit>
    with WidgetsBindingObserver {
  final _canMarkedToBuild = HashSet<String>();
  final _excludedWidgets = HashSet<String>();
  MediaQueryData? _mediaQueryData;
  final _binding = WidgetsBinding.instance;
  final _screenSizeCompleter = Completer<void>();

  @override
  void initState() {
    if (widget.responsiveWidgets != null) {
      _canMarkedToBuild.addAll(widget.responsiveWidgets!);
    }
    if (widget.excludeWidgets != null) {
      // 保存排除名单，避免尺寸变化时重建指定组件。
      _excludedWidgets.addAll(widget.excludeWidgets!);
    }

    ScreenUtil.enableScale(
      enableWH: widget.enableScaleWH,
      enableText: widget.enableScaleText,
    );

    _validateSize().then(_screenSizeCompleter.complete);

    super.initState();
    _binding.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _revalidate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revalidate();
  }

  MediaQueryData? _newData() {
    final view = View.maybeOf(context);
    if (view != null) return MediaQueryData.fromView(view);
    return null;
  }

  Future<void> _validateSize() async {
    if (widget.ensureScreenSize) return ScreenUtil.ensureScreenSize();
  }

  void _markNeedsBuildIfAllowed(Element el) {
    final widgetName = el.widget.runtimeType.toString();
    if (_excludedWidgets.contains(widgetName)) return;
    final allowed =
        widget is SU ||
        _canMarkedToBuild.contains(widgetName) ||
        !(widgetName.startsWith('_') || flutterWidgets.contains(widgetName));

    if (allowed) el.markNeedsBuild();
  }

  void _updateTree(Element el) {
    _markNeedsBuildIfAllowed(el);
    el.visitChildren(_updateTree);
  }

  void _revalidate([void Function()? callback]) {
    final oldData = _mediaQueryData;
    final newData = _newData();

    if (newData == null) return;

    if (oldData == null || widget.rebuildFactor(oldData, newData)) {
      setState(() {
        _mediaQueryData = newData;
        _updateTree(context as Element);
        callback?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = _mediaQueryData;

    if (mq == null) return const SizedBox.shrink();

    if (!widget.ensureScreenSize) {
      ScreenUtil.configure(
        data: mq,
        designSize: widget.designSize,
        splitScreenMode: widget.splitScreenMode,
        minTextAdapt: widget.minTextAdapt,
        fontSizeResolver: widget.fontSizeResolver,
      );

      return widget.builder?.call(context, widget.child) ?? widget.child!;
    }

    return FutureBuilder<void>(
      future: _screenSizeCompleter.future,
      builder: (c, snapshot) {
        ScreenUtil.configure(
          data: mq,
          designSize: widget.designSize,
          splitScreenMode: widget.splitScreenMode,
          minTextAdapt: widget.minTextAdapt,
          fontSizeResolver: widget.fontSizeResolver,
        );

        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder?.call(context, widget.child) ?? widget.child!;
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _binding.removeObserver(this);
    super.dispose();
  }
}
```

### `lib/common/extension/screen/screenutil_mixin.dart`

```dart
part of '../app_extensions.dart';

mixin SU on Widget {}
```

### `lib/common/extension/screen_util_ext.dart`

```dart
part of 'app_extensions.dart';

/// Screen Util 工具扩展
extension ScreenUtilExtensions on num {
  /// 根据屏幕宽度适配尺寸
  ///
  /// 返回: 适配后的宽度值
  ///
  /// 参考 [ScreenUtil.setWidth]
  double get w => ScreenUtil().setWidth(this);

  /// 根据屏幕高度适配尺寸
  ///
  /// 返回: 适配后的高度值
  ///
  /// 参考 [ScreenUtil.setHeight]
  double get h => ScreenUtil().setHeight(this);

  /// 适配圆角半径
  ///
  /// 返回: 适配后的圆角半径值
  ///
  /// 参考 [ScreenUtil.radius]
  double get r => ScreenUtil().radius(this);

  /// 适配对角线尺寸
  ///
  /// 返回: 适配后的对角线尺寸值
  ///
  /// 参考 [ScreenUtil.diagonal]
  double get dg => ScreenUtil().diagonal(this);

  /// 适配直径尺寸
  ///
  /// 返回: 适配后的直径尺寸值
  ///
  /// 参考 [ScreenUtil.diameter]
  double get dm => ScreenUtil().diameter(this);

  /// 适配字体大小
  ///
  /// 返回: 适配后的字体大小值
  ///
  /// 参考 [ScreenUtil.setSp]
  double get sp => ScreenUtil().setSp(this);

  /// 智能尺寸适配：检查适配值是否大于原始，如果大于则使用原始值
  ///
  /// 返回: 适配后的尺寸值，但不会超过原始值
  ///
  /// 例如：对于 16.spMin，如果适配后的值 16.sp() 大于 16，则返回 16 而不是 16.sp()
  /// 这有助于在大屏幕上保持尺寸平衡
  double get spMin => min(toDouble(), sp);

  /// 已废弃，请使用 spMin 代替
  ///
  /// 返回: 同 spMin
  @Deprecated('use spMin instead')
  double get sm => min(toDouble(), sp);

  /// 智能尺寸适配：返回适配值和原始值中的较大者
  ///
  /// 返回: 适配后的尺寸值和原始值中的较大值
  double get spMax => max(toDouble(), sp);

  /// 屏幕宽度的倍数
  /// Multiple of screen width
  double get sw => ScreenUtil().screenWidth * this;

  /// 屏幕高度的倍数
  /// Multiple of screen height
  double get sh => ScreenUtil().screenHeight * this;

  /// 创建垂直方向的间距
  ///
  /// 返回: 一个高度为适配后的当前值的 SizedBox
  ///
  /// 参考 [ScreenUtil.setHeight]
  SizedBox get verticalSpace => ScreenUtil().setVerticalSpacing(this);

  /// 创建基于宽度的垂直方向间距
  ///
  /// 返回: 一个高度为适配后的当前值的 SizedBox，但基于屏幕宽度计算
  ///
  /// 参考 [ScreenUtil.setVerticalSpacingFromWidth]
  SizedBox get verticalSpaceFromWidth =>
      ScreenUtil().setVerticalSpacingFromWidth(this);

  /// 创建水平方向的间距
  ///
  /// 返回: 一个宽度为适配后的当前值的 SizedBox
  ///
  /// 参考 [ScreenUtil.setWidth]
  SizedBox get horizontalSpace => ScreenUtil().setHorizontalSpacing(this);

  /// 创建基于圆角半径的水平间距
  ///
  /// 返回: 一个宽度为适配后的圆角半径值的 SizedBox
  ///
  /// 参考 [ScreenUtil.radius]
  SizedBox get horizontalSpaceRadius =>
      ScreenUtil().setHorizontalSpacingRadius(this);

  /// 创建基于圆角半径的垂直间距
  ///
  /// 返回: 一个高度为适配后的圆角半径值的 SizedBox
  ///
  /// 参考 [ScreenUtil.radius]
  SizedBox get verticalSpacingRadius =>
      ScreenUtil().setVerticalSpacingRadius(this);

  /// 创建基于直径的水平间距
  ///
  /// 返回: 一个宽度为适配后的直径值的 SizedBox
  ///
  /// 参考 [ScreenUtil.diameter]
  SizedBox get horizontalSpaceDiameter =>
      ScreenUtil().setHorizontalSpacingDiameter(this);

  /// 创建基于直径的垂直间距
  ///
  /// 返回: 一个高度为适配后的直径值的 SizedBox
  ///
  /// 参考 [ScreenUtil.diameter]
  SizedBox get verticalSpacingDiameter =>
      ScreenUtil().setVerticalSpacingDiameter(this);

  /// 创建基于对角线的水平间距
  ///
  /// 返回: 一个宽度为适配后的对角线值的 SizedBox
  ///
  /// 参考 [ScreenUtil.diagonal]
  SizedBox get horizontalSpaceDiagonal =>
      ScreenUtil().setHorizontalSpacingDiagonal(this);

  /// 创建基于对角线的垂直间距
  ///
  /// 返回: 一个高度为适配后的对角线值的 SizedBox
  ///
  /// 参考 [ScreenUtil.diagonal]
  SizedBox get verticalSpacingDiagonal =>
      ScreenUtil().setVerticalSpacingDiagonal(this);
}

extension EdgeInsetsExtension on EdgeInsets {
  /// 使用 r [SizeExtensions] 创建适配后的 EdgeInsets
  ///
  /// 返回: 一个新的 EdgeInsets 对象，其所有边距都使用 r 进行了适配
  EdgeInsets get r =>
      copyWith(top: top.r, bottom: bottom.r, right: right.r, left: left.r);

  /// 使用 dm [SizeExtensions] 创建适配后的 EdgeInsets
  ///
  /// 返回: 一个新的 EdgeInsets 对象，其所有边距都使用 dm (直径) 进行了适配
  EdgeInsets get dm =>
      copyWith(top: top.dm, bottom: bottom.dm, right: right.dm, left: left.dm);

  /// 使用 dg [SizeExtensions] 创建适配后的 EdgeInsets
  ///
  /// 返回: 一个新的 EdgeInsets 对象，其所有边距都使用 dg (对角线) 进行了适配
  EdgeInsets get dg =>
      copyWith(top: top.dg, bottom: bottom.dg, right: right.dg, left: left.dg);

  /// 使用 w [SizeExtensions] 创建适配后的 EdgeInsets
  ///
  /// 返回: 一个新的 EdgeInsets 对象，其所有边距都使用 w (宽度) 进行了适配
  EdgeInsets get w =>
      copyWith(top: top.w, bottom: bottom.w, right: right.w, left: left.w);

  /// 使用 h [SizeExtensions] 创建适配后的 EdgeInsets
  ///
  /// 返回: 一个新的 EdgeInsets 对象，其所有边距都使用 h (高度) 进行了适配
  EdgeInsets get h =>
      copyWith(top: top.h, bottom: bottom.h, right: right.h, left: left.h);
}

extension BorderRadiusExtension on BorderRadius {
  /// 使用 r [SizeExtensions] 创建适配后的 BorderRadius
  ///
  /// 返回: 一个新的 BorderRadius 对象，其所有角半径都使用 r 进行了适配
  ///
  /// 参考 [SizeExtensions.r]
  BorderRadius get r => copyWith(
    bottomLeft: bottomLeft.r,
    bottomRight: bottomRight.r,
    topLeft: topLeft.r,
    topRight: topRight.r,
  );

  /// 使用 w [SizeExtensions] 创建适配后的 BorderRadius
  ///
  /// 返回: 一个新的 BorderRadius 对象，其所有角半径都使用 w (宽度) 进行了适配
  ///
  /// 参考 [SizeExtensions.w]
  BorderRadius get w => copyWith(
    bottomLeft: bottomLeft.w,
    bottomRight: bottomRight.w,
    topLeft: topLeft.w,
    topRight: topRight.w,
  );

  /// 使用 h [SizeExtensions] 创建适配后的 BorderRadius
  ///
  /// 返回: 一个新的 BorderRadius 对象，其所有角半径都使用 h (高度) 进行了适配
  ///
  /// 参考 [SizeExtensions.h]
  BorderRadius get h => copyWith(
    bottomLeft: bottomLeft.h,
    bottomRight: bottomRight.h,
    topLeft: topLeft.h,
    topRight: topRight.h,
  );
}

extension RadiusExtension on Radius {
  /// 使用 r [SizeExtensions] 创建适配后的 Radius
  ///
  /// 返回: 一个新的 Radius 对象，其 x 和 y 值都使用 r 进行了适配
  ///
  /// 参考 [SizeExtensions.r]
  Radius get r => Radius.elliptical(x.r, y.r);

  /// 使用 dm [SizeExtensions] 创建适配后的 Radius
  ///
  /// 返回: 一个新的 Radius 对象，其 x 和 y 值都使用 dm (直径) 进行了适配
  ///
  /// 参考 [SizeExtensions.dm]
  Radius get dm => Radius.elliptical(x.dm, y.dm);

  /// 使用 dg [SizeExtensions] 创建适配后的 Radius
  ///
  /// 返回: 一个新的 Radius 对象，其 x 和 y 值都使用 dg (对角线) 进行了适配
  ///
  /// 参考 [SizeExtensions.dg]
  Radius get dg => Radius.elliptical(x.dg, y.dg);

  /// 使用 w [SizeExtensions] 创建适配后的 Radius
  ///
  /// 返回: 一个新的 Radius 对象，其 x 和 y 值都使用 w (宽度) 进行了适配
  ///
  /// 参考 [SizeExtensions.w]
  Radius get w => Radius.elliptical(x.w, y.w);

  /// 使用 h [SizeExtensions] 创建适配后的 Radius
  ///
  /// 返回: 一个新的 Radius 对象，其 x 和 y 值都使用 h (高度) 进行了适配
  ///
  /// 参考 [SizeExtensions.h]
  Radius get h => Radius.elliptical(x.h, y.h);
}

extension BoxConstraintsExtension on BoxConstraints {
  /// 使用 r [SizeExtensions] 创建适配后的 BoxConstraints
  ///
  /// 返回: 一个新的 BoxConstraints 对象，其所有约束值都使用 r 进行了适配
  ///
  /// 参考 [SizeExtensions.r]
  BoxConstraints get r => copyWith(
    maxHeight: maxHeight.r,
    maxWidth: maxWidth.r,
    minHeight: minHeight.r,
    minWidth: minWidth.r,
  );

  /// 使用 h 和 w [SizeExtensions] 创建适配后的 BoxConstraints
  ///
  /// 返回: 一个新的 BoxConstraints 对象，高度约束使用 h 适配，宽度约束使用 w 适配
  ///
  /// 参考 [SizeExtensions.h] 和 [SizeExtensions.w]
  BoxConstraints get hw => copyWith(
    maxHeight: maxHeight.h,
    maxWidth: maxWidth.w,
    minHeight: minHeight.h,
    minWidth: minWidth.w,
  );

  /// 使用 w [SizeExtensions] 创建适配后的 BoxConstraints
  ///
  /// 返回: 一个新的 BoxConstraints 对象，其所有约束值都使用 w (宽度) 进行了适配
  ///
  /// 参考 [SizeExtensions.w]
  BoxConstraints get w => copyWith(
    maxHeight: maxHeight.w,
    maxWidth: maxWidth.w,
    minHeight: minHeight.w,
    minWidth: minWidth.w,
  );

  /// 使用 h [SizeExtensions] 创建适配后的 BoxConstraints
  ///
  /// 返回: 一个新的 BoxConstraints 对象，其所有约束值都使用 h (高度) 进行了适配
  ///
  /// 参考 [SizeExtensions.h]
  BoxConstraints get h => copyWith(
    maxHeight: maxHeight.h,
    maxWidth: maxWidth.h,
    minHeight: minHeight.h,
    minWidth: minWidth.h,
  );
}
```

### `lib/common/extension/sized_box_ext.dart`

```dart
part of 'app_extensions.dart';

/// 数字转 SizedBox 扩展
extension SizedBoxExtensions on num {
  /// 创建具有指定宽度的 SizedBox
  ///
  /// 返回: 一个新的 SizedBox 对象，其宽度等于当前数值
  ///
  /// 示例: 10.horizontalSpace 创建一个宽度为 10 的 SizedBox
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// 创建具有指定高度的 SizedBox
  ///
  /// 返回: 一个新的 SizedBox 对象，其高度等于当前数值
  ///
  /// 示例: 20.verticalSpace 创建一个高度为 20 的 SizedBox
  SizedBox get verticalSpace => SizedBox(height: toDouble());
}
```

### `lib/common/extension/string_ext.dart`

```dart
part of 'app_extensions.dart';

/// String 字符串扩展
extension StringExtensions on String {
  /// 每个单词都大写
  /// `hello world` becomes `Hello World`.
  String capitalize() {
    return split(' ').map((e) => e.capitalizeFirst()).join(' ');
  }

  /// 首字母大写
  /// `hello world` becomes `Hello world`.
  String capitalizeFirst() {
    if (length == 0) return '';
    if (length == 1) return toUpperCase();
    return substring(0, 1).toUpperCase() + substring(1);
  }

  /// 是否 bool
  ///
  /// If [caseSensitive] is `true`, which is the default,
  /// the only accepted inputs are the strings `"true"` and `"false"`,
  /// Example:
  /// ```dart
  /// print('true'.isBool()); // true
  /// print('false'.isBool()); // true
  /// print('TRUE'.isBool()); // false
  /// print('TRUE'.isBool(caseSensitive: false)); // true
  /// print('FALSE'.isBool(caseSensitive: false)); // true
  /// print('NO'.isBool()); // false
  /// print('YES'.isBool()); // false
  /// print('0'.isBool()); // false
  /// print('1'.isBool()); // false
  /// ```
  bool isBool({bool caseSensitive = true}) =>
      bool.tryParse(this, caseSensitive: caseSensitive) != null;

  /// 转 bool
  ///
  /// Throws if the string is not a Boolean.
  /// If [caseSensitive] is `true`, which is the default,
  /// the only accepted inputs are the strings `"true"` and `"false"`,
  bool toBool({bool caseSensitive = true}) =>
      bool.parse(this, caseSensitive: caseSensitive);

  /// 是否数字
  ///
  /// print('2021'.isNum()); // true
  /// print('3.14'.isNum()); // true
  /// print('  3.14 \xA0'.isNum()); // true
  /// print('0.'.isNum()); // true
  /// print('.0'.isNum()); // true
  /// print('-1.e3'.isNum()); // true
  /// print('1234E+7'.isNum()); // true
  /// print('+.12e-9'.isNum()); // true
  /// print('-NaN'.isNum()); // true
  /// print('0xFF'.isNum()); // true
  /// print(double.infinity.toString().isNum()); // true
  /// print('1f'.isNum()); // false
  bool isNum() => num.tryParse(this) != null;

  /// 转数字
  num toNum() => num.parse(this);

  /// 是否 double
  bool isDouble() => double.tryParse(this) != null;

  /// 转 double
  double toDouble() => double.parse(this);

  /// 是否 int
  bool isInt() => int.tryParse(this) != null;

  /// 转 int
  int toInt() => int.parse(this);

  /// 生成 Color
  Color get toColor {
    return Color(int.parse(this, radix: 16) | 0xFF000000);
  }

  /// 生成 MaterialColor
  Color get toMaterialColor {
    Color color = toColor;

    List<double> strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    // Color 分量现以 0 到 1 的浮点值暴露，转换为 RGB 整数供色板计算。
    final int r = (color.r * 255).round();
    final int g = (color.g * 255).round();
    final int b = (color.b * 255).round();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  /// 清除所有空格
  String removeAllWhitespace() => replaceAll(' ', '');

  /// 正则检查匹配
  bool hasMatch(String pattern) => RegExp(pattern).hasMatch(this);

  /// 清除 html 标签
  String get clearHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
```

### `lib/common/extension/text_ext.dart`

```dart
part of 'app_extensions.dart';

/// Text 文本扩展
extension TextExtensions<T extends Text> on T {
  T copyWith({
    String? data,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
  }) =>
      (this is _AnimatedTextContainer
              ? _AnimatedTextContainer(
                  data ?? this.data ?? "",
                  style: style ?? this.style,
                  strutStyle: strutStyle ?? this.strutStyle,
                  textAlign: textAlign ?? this.textAlign,
                  locale: locale ?? this.locale,
                  maxLines: maxLines ?? this.maxLines,
                  overflow: overflow ?? this.overflow,
                  semanticsLabel: semanticsLabel ?? this.semanticsLabel,
                  softWrap: softWrap ?? this.softWrap,
                  textDirection: textDirection ?? this.textDirection,
                  // Flutter 以 TextScaler 替代已废弃的 textScaleFactor。
                  textScaler: textScaleFactor == null
                      ? textScaler
                      : TextScaler.linear(textScaleFactor),
                  textWidthBasis: textWidthBasis ?? this.textWidthBasis,
                )
              // 富文本的 data 为空；未覆盖内容时必须保留原始 span 树。
              : data == null && textSpan != null
              ? Text.rich(
                  textSpan!,
                  key: key,
                  style: style ?? this.style,
                  strutStyle: strutStyle ?? this.strutStyle,
                  textAlign: textAlign ?? this.textAlign,
                  locale: locale ?? this.locale,
                  maxLines: maxLines ?? this.maxLines,
                  overflow: overflow ?? this.overflow,
                  semanticsLabel: semanticsLabel ?? this.semanticsLabel,
                  softWrap: softWrap ?? this.softWrap,
                  textDirection: textDirection ?? this.textDirection,
                  textScaler: textScaleFactor == null
                      ? textScaler
                      : TextScaler.linear(textScaleFactor),
                  textWidthBasis: textWidthBasis ?? this.textWidthBasis,
                  textHeightBehavior: textHeightBehavior,
                  selectionColor: selectionColor,
                  semanticsIdentifier: semanticsIdentifier,
                )
              : Text(
                  data ?? this.data ?? "",
                  style: style ?? this.style,
                  strutStyle: strutStyle ?? this.strutStyle,
                  textAlign: textAlign ?? this.textAlign,
                  locale: locale ?? this.locale,
                  maxLines: maxLines ?? this.maxLines,
                  overflow: overflow ?? this.overflow,
                  semanticsLabel: semanticsLabel ?? this.semanticsLabel,
                  softWrap: softWrap ?? this.softWrap,
                  textDirection: textDirection ?? this.textDirection,
                  // Flutter 以 TextScaler 替代已废弃的 textScaleFactor。
                  textScaler: textScaleFactor == null
                      ? textScaler
                      : TextScaler.linear(textScaleFactor),
                  textWidthBasis: textWidthBasis ?? this.textWidthBasis,
                ))
          as T;

  T textStyle(TextStyle style) => copyWith(
    style: (this.style ?? const TextStyle()).copyWith(
      background: style.background,
      backgroundColor: style.backgroundColor,
      color: style.color,
      debugLabel: style.debugLabel,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      fontFamily: style.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback,
      fontFeatures: style.fontFeatures,
      fontSize: style.fontSize,
      fontStyle: style.fontStyle,
      fontWeight: style.fontWeight,
      foreground: style.foreground,
      height: style.height,
      inherit: style.inherit,
      letterSpacing: style.letterSpacing,
      locale: style.locale,
      shadows: style.shadows,
      textBaseline: style.textBaseline,
      wordSpacing: style.wordSpacing,
    ),
  );

  /// 设置文本缩放因子
  ///
  /// 参数:
  /// - scaleFactor: 文本缩放因子
  ///
  /// 返回: 应用了新缩放因子的 Text 对象
  T textScale(double scaleFactor) => copyWith(textScaleFactor: scaleFactor);

  /// 将文本设置为粗体
  ///
  /// 返回: 应用了粗体样式的 Text 对象
  T bold() => copyWith(
    style: (style ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold),
  );

  /// 将文本设置为斜体
  ///
  /// 返回: 应用了斜体样式的 Text 对象
  T italic() => copyWith(
    style: (style ?? const TextStyle()).copyWith(fontStyle: FontStyle.italic),
  );

  /// 设置文本的字体粗细
  ///
  /// 参数:
  /// - fontWeight: 字体粗细
  ///
  /// 返回: 应用了新字体粗细的 Text 对象
  T fontWeight(FontWeight? fontWeight) => copyWith(
    style: (style ?? const TextStyle()).copyWith(fontWeight: fontWeight),
  );

  /// 设置文本的字体大小
  ///
  /// 参数:
  /// - size: 字体大小
  ///
  /// 返回: 应用了新字体大小的 Text 对象
  T fontSize(double? size) =>
      copyWith(style: (style ?? const TextStyle()).copyWith(fontSize: size));

  /// 设置文本的字体系列
  ///
  /// 参数:
  /// - font: 字体系列名称
  ///
  /// 返回: 应用了新字体系列的 Text 对象
  T fontFamily(String? font) =>
      copyWith(style: (style ?? const TextStyle()).copyWith(fontFamily: font));

  /// 设置文本的字母间距
  ///
  /// 参数:
  /// - space: 字母间距
  ///
  /// 返回: 应用了新字母间距的 Text 对象
  T letterSpacing(double? space) => copyWith(
    style: (style ?? const TextStyle()).copyWith(letterSpacing: space),
  );

  /// 设置文本的单词间距
  ///
  /// 参数:
  /// - space: 单词间距
  ///
  /// 返回: 应用了新单词间距的 Text 对象
  T wordSpacing(double? space) => copyWith(
    style: (style ?? const TextStyle()).copyWith(wordSpacing: space),
  );

  /// 为文本添加阴影效果
  ///
  /// 参数:
  /// - color: 阴影颜色，默认为半透明黑色
  /// - blurRadius: 阴影的模糊半径，默认为 0.0
  /// - offset: 阴影的偏移量，默认为 Offset.zero
  ///
  /// 返回: 应用了阴影效果的 Text 对象
  T textShadow({
    Color color = const Color(0x33000000),
    double blurRadius = 0.0,
    Offset offset = Offset.zero,
  }) => copyWith(
    style: (style ?? const TextStyle()).copyWith(
      shadows: [Shadow(color: color, blurRadius: blurRadius, offset: offset)],
    ),
  );

  /// 为文本添加立体效果
  ///
  /// 参数:
  /// - elevation: 立体效果的高度
  /// - angle: 阴影的角度，默认为 0.0
  /// - color: 阴影颜色，默认为半透明黑色
  /// - opacityRatio: 不透明度比率，默认为 1.0
  ///
  /// 返回: 应用了立体效果的 Text 对象
  T textElevation(
    double elevation, {
    double angle = 0.0,
    Color color = const Color(0x33000000),
    double opacityRatio = 1.0,
  }) {
    final double calculatedOpacity =
        _elevationOpacityCurve(elevation) * opacityRatio;

    final Shadow shadow = Shadow(
      color: color.withValues(alpha: calculatedOpacity),
      blurRadius: elevation,
      offset: Offset(sin(angle) * elevation, cos(angle) * elevation),
    );
    return copyWith(
      style: (style ?? const TextStyle()).copyWith(shadows: [shadow]),
    );
  }

  /// 设置文本颜色
  ///
  /// 参数:
  /// - color: 文本颜色
  ///
  /// 返回: 应用了新颜色的 Text 对象
  T textColor(Color? color) =>
      copyWith(style: (style ?? const TextStyle()).copyWith(color: color));

  /// 设置文本对齐方式
  ///
  /// 参数:
  /// - align: 文本对齐方式
  ///
  /// 返回: 应用了新对齐方式的 Text 对象
  T textAlignment(TextAlign? align) => copyWith(textAlign: align);

  /// 设置文本方向
  ///
  /// 参数:
  /// - direction: 文本方向
  ///
  /// 返回: 应用了新文本方向的 Text 对象
  T textDirection(TextDirection? direction) =>
      copyWith(textDirection: direction);

  /// 设置文本基线
  ///
  /// 参数:
  /// - textBaseline: 文本基线
  ///
  /// 返回: 应用了新文本基线的 Text 对象
  T textBaseline(TextBaseline? textBaseline) => copyWith(
    style: (style ?? const TextStyle()).copyWith(textBaseline: textBaseline),
  );

  /// 设置文本宽度基准
  ///
  /// 参数:
  /// - textWidthBasis: 文本宽度基准
  ///
  /// 返回: 应用了新文本宽度基准的 Text 对象
  T textWidthBasis(TextWidthBasis? textWidthBasis) =>
      copyWith(textWidthBasis: textWidthBasis);
}
```

### `lib/common/extension/text_span_ext.dart`

```dart
part of 'app_extensions.dart';

/// TextSpan 文本扩展
extension TextSpanExtensions<T extends TextSpan> on T {
  T copyWith({
    TextStyle? style,
    GestureRecognizer? recognizer,
    String? semanticsLabel,
  }) =>
      TextSpan(
            text: text,
            children: children,
            style: style ?? this.style,
            recognizer: recognizer ?? this.recognizer,
            semanticsLabel: semanticsLabel ?? this.semanticsLabel,
          )
          as T;

  T textStyle(TextStyle style) => copyWith(
    // 无初始样式时，也需要应用调用方传入的样式。
    style: (this.style ?? const TextStyle()).copyWith(
      background: style.background,
      backgroundColor: style.backgroundColor,
      color: style.color,
      debugLabel: style.debugLabel,
      decoration: style.decoration,
      decorationColor: style.decorationColor,
      decorationStyle: style.decorationStyle,
      decorationThickness: style.decorationThickness,
      fontFamily: style.fontFamily,
      fontFamilyFallback: style.fontFamilyFallback,
      fontFeatures: style.fontFeatures,
      fontSize: style.fontSize,
      fontStyle: style.fontStyle,
      fontWeight: style.fontWeight,
      foreground: style.foreground,
      height: style.height,
      inherit: style.inherit,
      letterSpacing: style.letterSpacing,
      locale: style.locale,
      shadows: style.shadows,
      textBaseline: style.textBaseline,
      wordSpacing: style.wordSpacing,
    ),
  );

  /// 将文本设置为粗体
  ///
  /// 返回: 应用了粗体样式的 TextSpan 对象
  T bold() => copyWith(
    style: (style ?? const TextStyle()).copyWith(fontWeight: FontWeight.bold),
  );

  /// 将文本设置为斜体
  ///
  /// 返回: 应用了斜体样式的 TextSpan 对象
  T italic() => copyWith(
    style: (style ?? const TextStyle()).copyWith(fontStyle: FontStyle.italic),
  );

  /// 设置文本的字体粗细
  ///
  /// 参数:
  /// - fontWeight: 字体粗细
  ///
  /// 返回: 应用了新字体粗细的 TextSpan 对象
  T fontWeight(FontWeight fontWeight) => copyWith(
    style: (style ?? const TextStyle()).copyWith(fontWeight: fontWeight),
  );

  /// 设置文本的字体大小
  ///
  /// 参数:
  /// - size: 字体大小
  ///
  /// 返回: 应用了新字体大小的 TextSpan 对象
  T fontSize(double size) =>
      copyWith(style: (style ?? const TextStyle()).copyWith(fontSize: size));

  /// 设置文本的字体系列
  ///
  /// 参数:
  /// - font: 字体系列名称
  ///
  /// 返回: 应用了新字体系列的 TextSpan 对象
  T fontFamily(String font) =>
      copyWith(style: (style ?? const TextStyle()).copyWith(fontFamily: font));

  /// 设置文本的字母间距
  ///
  /// 参数:
  /// - space: 字母间距
  ///
  /// 返回: 应用了新字母间距的 TextSpan 对象
  T letterSpacing(double space) => copyWith(
    style: (style ?? const TextStyle()).copyWith(letterSpacing: space),
  );

  /// 设置文本的单词间距
  ///
  /// 参数:
  /// - space: 单词间距
  ///
  /// 返回: 应用了新单词间距的 TextSpan 对象
  T wordSpacing(double space) => copyWith(
    style: (style ?? const TextStyle()).copyWith(wordSpacing: space),
  );

  /// 为文本添加阴影效果
  ///
  /// 参数:
  /// - color: 阴影颜色，默认为半透明黑色
  /// - blurRadius: 阴影的模糊半径，默认为 0.0
  /// - offset: 阴影的偏移量，默认为 Offset.zero
  ///
  /// 返回: 应用了阴影效果的 TextSpan 对象
  T textShadow({
    Color color = const Color(0x33000000),
    double blurRadius = 0.0,
    Offset offset = Offset.zero,
  }) => copyWith(
    style: (style ?? const TextStyle()).copyWith(
      shadows: [Shadow(color: color, blurRadius: blurRadius, offset: offset)],
    ),
  );

  /// 计算立体效果的不透明度曲线
  ///
  /// 参数:
  /// - x: 输入值
  ///
  /// 返回: 计算后的不透明度值
  double _elevationOpacityCurve(double x) =>
      pow(x, 1 / 16) / sqrt(pow(x, 2) + 2) + 0.2;

  /// 为文本添加立体效果
  ///
  /// 参数:
  /// - elevation: 立体效果的高度
  /// - angle: 阴影的角度，默认为 0.0
  /// - color: 阴影颜色，默认为半透明黑色
  /// - opacityRatio: 不透明度比率，默认为 1.0
  ///
  /// 返回: 应用了立体效果的 TextSpan 对象
  T textElevation(
    double elevation, {
    double angle = 0.0,
    Color color = const Color(0x33000000),
    double opacityRatio = 1.0,
  }) {
    final double calculatedOpacity =
        _elevationOpacityCurve(elevation) * opacityRatio;

    final Shadow shadow = Shadow(
      color: color.withValues(alpha: calculatedOpacity),
      blurRadius: elevation,
      offset: Offset(sin(angle) * elevation, cos(angle) * elevation),
    );
    return copyWith(
      style: (style ?? const TextStyle()).copyWith(shadows: [shadow]),
    );
  }

  /// 设置文本颜色
  ///
  /// 参数:
  /// - color: 文本颜色
  ///
  /// 返回: 应用了新颜色的 TextSpan 对象
  T textColor(Color color) =>
      copyWith(style: (style ?? const TextStyle()).copyWith(color: color));

  /// 设置文本基线
  ///
  /// 参数:
  /// - textBaseline: 文本基线
  ///
  /// 返回: 应用了新文本基线的 TextSpan 对象
  T textBaseline(TextBaseline textBaseline) => copyWith(
    style: (style ?? const TextStyle()).copyWith(textBaseline: textBaseline),
  );
}
```

### `lib/common/extension/themes_ext.dart`

```dart
part of 'app_extensions.dart';

// /// theme 主题访问扩展
// /// `context.themes.icon`
// extension ThemesExtensions on BuildContext {
//   // ignore: library_private_types_in_public_api
//   _Themes get themes => _Themes(
//         button: _buttonTheme,
//         toggleButtons: _toggleButtonsTheme,
//         text: _textTheme,
//         primaryText: _primaryTextTheme,
//         inputDecoration: _inputDecorationTheme,
//         icon: _iconTheme,
//         primaryIcon: _primaryIconTheme,
//         slider: _sliderTheme,
//         tabBar: _tabBarTheme,
//         tooltip: _tooltipTheme,
//         card: _cardTheme,
//         chip: _chipTheme,
//         appBar: _appBarTheme,
//         scrollbar: _scrollbarTheme,
//         bottomAppBar: _bottomAppBarTheme,
//         dialog: _dialogTheme,
//         floatingActionButton: _floatingActionButtonTheme,
//         navigationRail: _navigationRailTheme,
//         cupertinoOverride: _cupertinoOverrideTheme,
//         snackBar: _snackBarTheme,
//         bottomSheet: _bottomSheetTheme,
//         popupMenu: _popupMenuTheme,
//         banner: _bannerTheme,
//         divider: _dividerTheme,
//         buttonBar: _buttonBarTheme,
//         bottomNavigationBar: _bottomNavigationBarTheme,
//         timePicker: _timePickerTheme,
//         textButton: _textButtonTheme,
//         elevatedButton: _elevatedButtonTheme,
//         outlinedButton: _outlinedButtonTheme,
//         textSelection: _textSelectionTheme,
//         dataTable: _dataTableTheme,
//         checkbox: _checkboxTheme,
//         radio: _radioTheme,
//         switchTheme: _switchTheme,
//         badge: _badgeTheme,
//         drawer: _drawerTheme,
//         dropdownMenu: _dropdownMenuTheme,
//         expansionTile: _expansionTileTheme,
//         extensions: _extensions,
//         filledButton: _filledButtonTheme,
//         iconButton: _iconButtonTheme,
//         listTile: _listTileTheme,
//         menu: _menuTheme,
//         menuBar: _menuBarTheme,
//         menuButton: _menuButtonTheme,
//         navigationBar: _navigationBarTheme,
//         navigationDrawer: _navigationDrawerTheme,
//         pageTransitions: _pageTransitionsTheme,
//         progressIndicator: _progressIndicatorTheme,
//         segmentedButton: _segmentedButtonTheme,
//       );

//   /// 获取当前主题数据
//   ///
//   /// 返回: 当前的 ThemeData 对象
//   ThemeData get _themeData => Theme.of(this);

//   /// 获取文本主题
//   ///
//   /// 返回: 当前主题的 TextTheme 对象
//   TextTheme get _textTheme => _themeData.textTheme;

//   /// 获取按钮主题数据
//   ///
//   /// 返回: 当前主题的 ButtonThemeData 对象
//   ButtonThemeData get _buttonTheme => _themeData.buttonTheme;

//   /// 获取切换按钮主题数据
//   ///
//   /// 返回: 当前主题的 ToggleButtonsThemeData 对象
//   ToggleButtonsThemeData get _toggleButtonsTheme =>
//       _themeData.toggleButtonsTheme;

//   /// 获取主要文本主题
//   ///
//   /// 返回: 当前主题的主要 TextTheme 对象
//   TextTheme get _primaryTextTheme => _themeData.primaryTextTheme;

//   /// 获取图标主题数据
//   ///
//   /// 返回: 当前主题的 IconThemeData 对象
//   IconThemeData get _iconTheme => _themeData.iconTheme;

//   /// 获取输入装饰主题
//   ///
//   /// 返回: 当前主题的 InputDecorationTheme 对象
//   InputDecorationTheme get _inputDecorationTheme =>
//       _themeData.inputDecorationTheme;

//   /// 获取主要图标主题数据
//   ///
//   /// 返回: 当前主题的主要 IconThemeData 对象
//   IconThemeData get _primaryIconTheme => _themeData.primaryIconTheme;

//   /// 获取滑块主题数据
//   ///
//   /// 返回: 当前主题的 SliderThemeData 对象
//   SliderThemeData get _sliderTheme => _themeData.sliderTheme;

//   /// 获取标签栏主题
//   ///
//   /// 返回: 当前主题的 TabBarTheme 对象
//   TabBarTheme get _tabBarTheme => _themeData.tabBarTheme;

//   /// 获取工具提示主题数据
//   ///
//   /// 返回: 当前主题的 TooltipThemeData 对象
//   TooltipThemeData get _tooltipTheme => _themeData.tooltipTheme;

//   /// 获取卡片主题
//   ///
//   /// 返回: 当前主题的 CardTheme 对象
//   CardTheme get _cardTheme => _themeData.cardTheme;

//   /// 获取芯片主题数据
//   ///
//   /// 返回: 当前主题的 ChipThemeData 对象
//   ChipThemeData get _chipTheme => _themeData.chipTheme;

//   /// 获取应用栏主题
//   ///
//   /// 返回: 当前主题的 AppBarTheme 对象
//   AppBarTheme get _appBarTheme => _themeData.appBarTheme;

//   /// 获取滚动条主题数据
//   ///
//   /// 返回: 当前主题的 ScrollbarThemeData 对象
//   ScrollbarThemeData get _scrollbarTheme => _themeData.scrollbarTheme;

//   /// 获取底部应用栏主题
//   ///
//   /// 返回: 当前主题的 BottomAppBarTheme 对象
//   BottomAppBarTheme get _bottomAppBarTheme => _themeData.bottomAppBarTheme;

//   /// 获取对话框主题
//   ///
//   /// 返回: 当前主题的 DialogTheme 对象
//   DialogTheme get _dialogTheme => _themeData.dialogTheme;

//   /// 获取浮动操作按钮主题数据
//   ///
//   /// 返回: 当前主题的 FloatingActionButtonThemeData 对象
//   FloatingActionButtonThemeData get _floatingActionButtonTheme =>
//       _themeData.floatingActionButtonTheme;

//   /// 获取导航栏主题数据
//   ///
//   /// 返回: 当前主题的 NavigationRailThemeData 对象
//   NavigationRailThemeData get _navigationRailTheme =>
//       _themeData.navigationRailTheme;

//   /// 获取 Cupertino 覆盖主题数据
//   ///
//   /// 返回: 当前主题的 NoDefaultCupertinoThemeData 对象，可能为 null
//   NoDefaultCupertinoThemeData? get _cupertinoOverrideTheme =>
//       _themeData.cupertinoOverrideTheme;

//   /// 获取 Snackbar 主题数据
//   ///
//   /// 返回: 当前主题的 SnackBarThemeData 对象
//   SnackBarThemeData get _snackBarTheme => _themeData.snackBarTheme;

//   /// 获取底部表单主题数据
//   ///
//   /// 返回: 当前主题的 BottomSheetThemeData 对象
//   BottomSheetThemeData get _bottomSheetTheme => _themeData.bottomSheetTheme;

//   /// 获取弹出菜单主题数据
//   ///
//   /// 返回: 当前主题的 PopupMenuThemeData 对象
//   PopupMenuThemeData get _popupMenuTheme => _themeData.popupMenuTheme;

//   /// 获取横幅主题数据
//   ///
//   /// 返回: 当前主题的 MaterialBannerThemeData 对象
//   MaterialBannerThemeData get _bannerTheme => _themeData.bannerTheme;

//   /// 获取分隔线主题数据
//   ///
//   /// 返回: 当前主题的 DividerThemeData 对象
//   DividerThemeData get _dividerTheme => _themeData.dividerTheme;

//   /// 获取按钮栏主题数据
//   ///
//   /// 返回: 当前主题的 ButtonBarThemeData 对象
//   ButtonBarThemeData get _buttonBarTheme => _themeData.buttonBarTheme;

//   /// 获取底部导航栏主题数据
//   ///
//   /// 返回: 当前主题的 BottomNavigationBarThemeData 对象
//   BottomNavigationBarThemeData get _bottomNavigationBarTheme =>
//       _themeData.bottomNavigationBarTheme;

//   /// 获取时间选择器主题数据
//   ///
//   /// 返回: 当前主题的 TimePickerThemeData 对象
//   TimePickerThemeData get _timePickerTheme => _themeData.timePickerTheme;

//   /// 获取文本按钮主题数据
//   ///
//   /// 返回: 当前主题的 TextButtonThemeData 对象
//   TextButtonThemeData get _textButtonTheme => _themeData.textButtonTheme;

//   /// 获取凸起按钮主题数据
//   ///
//   /// 返回: 当前主题的 ElevatedButtonThemeData 对象
//   ElevatedButtonThemeData get _elevatedButtonTheme =>
//       _themeData.elevatedButtonTheme;

//   /// 获取轮廓按钮主题数据
//   ///
//   /// 返回: 当前主题的 OutlinedButtonThemeData 对象
//   OutlinedButtonThemeData get _outlinedButtonTheme =>
//       _themeData.outlinedButtonTheme;

//   /// 获取文本选择主题数据
//   ///
//   /// 返回: 当前主题的 TextSelectionThemeData 对象
//   TextSelectionThemeData get _textSelectionTheme =>
//       _themeData.textSelectionTheme;

//   /// 获取数据表格主题数据
//   ///
//   /// 返回: 当前主题的 DataTableThemeData 对象
//   DataTableThemeData get _dataTableTheme => _themeData.dataTableTheme;

//   /// 获取复选框主题数据
//   ///
//   /// 返回: 当前主题的 CheckboxThemeData 对象
//   CheckboxThemeData get _checkboxTheme => _themeData.checkboxTheme;

//   /// 获取单选按钮主题数据
//   ///
//   /// 返回: 当前主题的 RadioThemeData 对象
//   RadioThemeData get _radioTheme => _themeData.radioTheme;

//   /// 获取开关主题数据
//   ///
//   /// 返回: 当前主题的 SwitchThemeData 对象
//   SwitchThemeData get _switchTheme => _themeData.switchTheme;

//   /// 获取徽章主题数据
//   ///
//   /// 返回: 当前主题的 BadgeThemeData 对象
//   BadgeThemeData get _badgeTheme => _themeData.badgeTheme;

//   /// 获取抽屉主题数据
//   ///
//   /// 返回: 当前主题的 DrawerThemeData 对象
//   DrawerThemeData get _drawerTheme => _themeData.drawerTheme;

//   /// 获取下拉菜单主题数据
//   ///
//   /// 返回: 当前主题的 DropdownMenuThemeData 对象
//   DropdownMenuThemeData get _dropdownMenuTheme => _themeData.dropdownMenuTheme;

//   /// 获取展开面板主题数据
//   ///
//   /// 返回: 当前主题的 ExpansionTileThemeData 对象
//   ExpansionTileThemeData get _expansionTileTheme =>
//       _themeData.expansionTileTheme;

//   /// 获取主题扩展
//   ///
//   /// 返回: 当前主题的扩展 Map
//   Map<Object, ThemeExtension<dynamic>> get _extensions => _themeData.extensions;

//   /// 获取填充按钮主题数据
//   ///
//   /// 返回: 当前主题的 FilledButtonThemeData 对象
//   FilledButtonThemeData get _filledButtonTheme => _themeData.filledButtonTheme;

//   /// 获取图标按钮主题数据
//   ///
//   /// 返回: 当前主题的 IconButtonThemeData 对象
//   IconButtonThemeData get _iconButtonTheme => _themeData.iconButtonTheme;

//   /// 获取列表项主题数据
//   ///
//   /// 返回: 当前主题的 ListTileThemeData 对象
//   ListTileThemeData get _listTileTheme => _themeData.listTileTheme;

//   /// 获取菜单主题数据
//   ///
//   /// 返回: 当前主题的 MenuThemeData 对象
//   MenuThemeData get _menuTheme => _themeData.menuTheme;

//   /// 获取菜单栏主题数据
//   ///
//   /// 返回: 当前主题的 MenuBarThemeData 对象
//   MenuBarThemeData get _menuBarTheme => _themeData.menuBarTheme;

//   /// 获取菜单按钮主题数据
//   ///
//   /// 返回: 当前主题的 MenuButtonThemeData 对象
//   MenuButtonThemeData get _menuButtonTheme => _themeData.menuButtonTheme;

//   /// 获取导航栏主题数据
//   ///
//   /// 返回: 当前主题的 NavigationBarThemeData 对象
//   NavigationBarThemeData get _navigationBarTheme =>
//       _themeData.navigationBarTheme;

//   /// 获取导航抽屉主题数据
//   ///
//   /// 返回: 当前主题的 NavigationDrawerThemeData 对象
//   NavigationDrawerThemeData get _navigationDrawerTheme =>
//       _themeData.navigationDrawerTheme;

//   /// 获取页面转换主题
//   ///
//   /// 返回: 当前主题的 PageTransitionsTheme 对象
//   PageTransitionsTheme get _pageTransitionsTheme =>
//       _themeData.pageTransitionsTheme;

//   /// 获取进度指示器主题数据
//   ///
//   /// 返回: 当前主题的 ProgressIndicatorThemeData 对象
//   ProgressIndicatorThemeData get _progressIndicatorTheme =>
//       _themeData.progressIndicatorTheme;

//   /// 获取分段按钮主题数据
//   ///
//   /// 返回: 当前主题的 SegmentedButtonThemeData 对象
//   SegmentedButtonThemeData get _segmentedButtonTheme =>
//       _themeData.segmentedButtonTheme;
// }

// class _Themes {
//   const _Themes({
//     required this.button,
//     required this.toggleButtons,
//     required this.text,
//     required this.primaryText,
//     required this.inputDecoration,
//     required this.icon,
//     required this.primaryIcon,
//     required this.slider,
//     required this.tabBar,
//     required this.tooltip,
//     required this.card,
//     required this.chip,
//     required this.appBar,
//     required this.scrollbar,
//     required this.bottomAppBar,
//     required this.dialog,
//     required this.floatingActionButton,
//     required this.navigationRail,
//     required this.snackBar,
//     required this.bottomSheet,
//     required this.popupMenu,
//     required this.banner,
//     required this.divider,
//     required this.buttonBar,
//     required this.bottomNavigationBar,
//     required this.timePicker,
//     required this.textButton,
//     required this.elevatedButton,
//     required this.outlinedButton,
//     required this.textSelection,
//     required this.dataTable,
//     required this.checkbox,
//     required this.radio,
//     required this.switchTheme,
//     required this.cupertinoOverride,
//     required this.pageTransitions,
//     required this.extensions,
//     required this.badge,
//     required this.drawer,
//     required this.dropdownMenu,
//     required this.expansionTile,
//     required this.filledButton,
//     required this.iconButton,
//     required this.listTile,
//     required this.menuBar,
//     required this.menuButton,
//     required this.menu,
//     required this.navigationBar,
//     required this.navigationDrawer,
//     required this.progressIndicator,
//     required this.segmentedButton,
//   });

//   /// See [ThemeData.buttonTheme].
//   final ButtonThemeData button;

//   /// See [ThemeData.toggleButtonsTheme].
//   final ToggleButtonsThemeData toggleButtons;

//   /// See [ThemeData.textTheme].
//   final TextTheme text;

//   /// See [ThemeData.primaryTextTheme].
//   final TextTheme primaryText;

//   /// See [ThemeData.inputDecorationTheme].
//   final InputDecorationTheme inputDecoration;

//   /// See [ThemeData.iconTheme].
//   final IconThemeData icon;

//   /// See [ThemeData.primaryIconTheme].
//   final IconThemeData primaryIcon;

//   /// See [ThemeData.sliderTheme].
//   final SliderThemeData slider;

//   /// See [ThemeData.tabBarTheme].
//   final TabBarTheme tabBar;

//   /// See [ThemeData.tooltipTheme].
//   final TooltipThemeData tooltip;

//   /// See [ThemeData.cardTheme].
//   final CardTheme card;

//   /// See [ThemeData.chipTheme].
//   final ChipThemeData chip;

//   /// See [ThemeData.appBarTheme].
//   final AppBarTheme appBar;

//   /// See [ThemeData.scrollbarTheme].
//   final ScrollbarThemeData scrollbar;

//   /// See [ThemeData.bottomAppBarTheme].
//   final BottomAppBarTheme bottomAppBar;

//   /// See [ThemeData.dialogTheme].
//   final DialogTheme dialog;

//   /// See [ThemeData.floatingActionButtonTheme].
//   final FloatingActionButtonThemeData floatingActionButton;

//   /// See [ThemeData.navigationRailTheme].
//   final NavigationRailThemeData navigationRail;

//   /// See [ThemeData.cupertinoOverrideTheme].
//   final NoDefaultCupertinoThemeData? cupertinoOverride;

//   /// See [ThemeData.snackBarTheme].
//   final SnackBarThemeData snackBar;

//   /// See [ThemeData.bottomSheetTheme].
//   final BottomSheetThemeData bottomSheet;

//   /// See [ThemeData.popupMenuTheme].
//   final PopupMenuThemeData popupMenu;

//   /// See [ThemeData.bannerTheme].
//   final MaterialBannerThemeData banner;

//   /// See [ThemeData.dividerTheme].
//   final DividerThemeData divider;

//   /// See [ThemeData.buttonBarTheme].
//   final ButtonBarThemeData buttonBar;

//   /// See [ThemeData.bottomNavigationBarTheme].
//   final BottomNavigationBarThemeData bottomNavigationBar;

//   /// See [ThemeData.timePickerTheme].
//   final TimePickerThemeData timePicker;

//   /// See [ThemeData.textButtonTheme].
//   final TextButtonThemeData textButton;

//   /// See [ThemeData.elevatedButtonTheme].
//   final ElevatedButtonThemeData elevatedButton;

//   /// See [ThemeData.outlinedButtonTheme].
//   final OutlinedButtonThemeData outlinedButton;

//   /// See [ThemeData.textSelectionTheme].
//   final TextSelectionThemeData textSelection;

//   /// See [ThemeData.dataTableTheme].
//   final DataTableThemeData dataTable;

//   /// See [ThemeData.checkboxTheme].
//   final CheckboxThemeData checkbox;

//   /// See [ThemeData.radioTheme].
//   final RadioThemeData radio;

//   /// See [ThemeData.switchTheme].
//   final SwitchThemeData switchTheme;

//   /// See [ThemeData.pageTransitionsTheme].
//   final PageTransitionsTheme pageTransitions;

//   /// See [ThemeData.extensions].
//   final Map<Object, ThemeExtension<dynamic>> extensions;

//   /// See [ThemeData.badgeTheme].
//   final BadgeThemeData badge;

//   /// See [ThemeData.drawerTheme].
//   final DrawerThemeData drawer;

//   /// See [ThemeData.dropdownMenuTheme].
//   final DropdownMenuThemeData dropdownMenu;

//   /// See [ThemeData.expansionTileTheme].
//   final ExpansionTileThemeData expansionTile;

//   /// See [ThemeData.filledButtonTheme].
//   final FilledButtonThemeData filledButton;

//   /// See [ThemeData.iconButtonTheme].
//   final IconButtonThemeData iconButton;

//   /// See [ThemeData.listTileTheme].
//   final ListTileThemeData listTile;

//   /// See [ThemeData.menuBarTheme].
//   final MenuBarThemeData menuBar;

//   /// See [ThemeData.menuButtonTheme].
//   final MenuButtonThemeData menuButton;

//   /// See [ThemeData.menuTheme].
//   final MenuThemeData menu;

//   /// See [ThemeData.navigationBarTheme].
//   final NavigationBarThemeData navigationBar;

//   /// See [ThemeData.navigationDrawerTheme].
//   final NavigationDrawerThemeData navigationDrawer;

//   /// See [ThemeData.progressIndicatorTheme].
//   final ProgressIndicatorThemeData progressIndicator;

//   /// See [ThemeData.segmentedButtonTheme].
//   final SegmentedButtonThemeData segmentedButton;
// }

// /// Theme mode extensions
// extension ThemeModeExt on BuildContext {
//   /// Indicates wheter the app is in dark mode
//   bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

//   /// Indicates wheter the app is in light mode
//   bool get isLightMode => Theme.of(this).brightness == Brightness.light;
// }
```

### `lib/common/extension/widget_ext.dart`

```dart
part of 'app_extensions.dart';

typedef GestureOnTapChangeCallback = void Function(bool tapState);

/// Widget 扩展
extension WidgetExtensions on Widget {
  _AnimatedModel _getAnimation(BuildContext context) {
    final _AnimatedModel? animation = _StyledInheritedAnimation.of(
      context,
    )?.animation;
    assert(
      animation != null,
      '[styled_widget]: You can`t animate without defining the animation. Call the method animate() higher in your widget hierarchy to define an animation',
    );
    return animation!;
  }

  /// animated all properties before this method
  /// 动画所有属性
  Widget animate(Duration duration, Curve curve, {Key? key}) =>
      _StyledInheritedAnimation(
        key: key,
        animation: _AnimatedModel(duration: duration, curve: curve),
        child: this,
      );

  /// 对齐
  Widget align(AlignmentGeometry alignment, {Key? key}) =>
      Align(key: key, alignment: alignment, child: this);

  /// 对齐 中间
  Widget alignCenter() => align(Alignment.center);

  /// 对齐 左边
  Widget alignLeft() => align(Alignment.centerLeft);

  /// 对齐 右边
  Widget alignRight() => align(Alignment.centerRight);

  /// 对齐 顶部
  Widget alignTop() => align(Alignment.topCenter);

  /// 对齐 底部
  Widget alignBottom() => align(Alignment.bottomCenter);

  /// Applies a parent to a child
  /// ```dart
  /// final parentWidget = ({required Widget child}) => Styled.widget(child: child)
  ///   .alignment(Alignment.center)
  ///
  /// final childWidget = Text('some text')
  ///   .padding(all: 10)
  ///
  /// Widget build(BuildContext) => childWidget
  ///   .parent(parentWidget);
  /// ```
  Widget parent(Widget Function({required Widget child}) parent) =>
      parent(child: this);

  /// 内间距
  Widget padding({
    Key? key,
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool animate = false,
  }) => animate
      ? Builder(
          key: key,
          builder: (BuildContext context) {
            final _AnimatedModel animation = _getAnimation(context);
            return AnimatedPadding(
              padding: EdgeInsets.only(
                top: top ?? vertical ?? all ?? 0.0,
                bottom: bottom ?? vertical ?? all ?? 0.0,
                left: left ?? horizontal ?? all ?? 0.0,
                right: right ?? horizontal ?? all ?? 0.0,
              ),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Padding(
          key: key,
          padding: EdgeInsets.only(
            top: top ?? vertical ?? all ?? 0.0,
            bottom: bottom ?? vertical ?? all ?? 0.0,
            left: left ?? horizontal ?? all ?? 0.0,
            right: right ?? horizontal ?? all ?? 0.0,
          ),
          child: this,
        );

  /// 内间距 下
  Widget paddingBottom(double val) => padding(bottom: val);

  /// 内间距 横向
  Widget paddingHorizontal(double val) => padding(horizontal: val);

  /// 内间距 左
  Widget paddingLeft(double val) => padding(left: val);

  /// 内间距 右
  Widget paddingRight(double val) => padding(right: val);

  /// 内间距 上
  Widget paddingTop(double val) => padding(top: val);

  /// 内间距 纵向
  Widget paddingVertical(double val) => padding(vertical: val);

  /// 内间距 方向
  Widget paddingDirectional({
    Key? key,
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? start,
    double? end,
    bool animate = false,
  }) => animate
      ? Builder(
          key: key,
          builder: (BuildContext context) {
            final _AnimatedModel animation = _getAnimation(context);
            return AnimatedPadding(
              padding: EdgeInsetsDirectional.only(
                top: top ?? vertical ?? all ?? 0.0,
                bottom: bottom ?? vertical ?? all ?? 0.0,
                start: start ?? horizontal ?? all ?? 0.0,
                end: end ?? horizontal ?? all ?? 0.0,
              ),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Padding(
          key: key,
          padding: EdgeInsetsDirectional.only(
            top: top ?? vertical ?? all ?? 0.0,
            bottom: bottom ?? vertical ?? all ?? 0.0,
            start: start ?? horizontal ?? all ?? 0.0,
            end: end ?? horizontal ?? all ?? 0.0,
          ),
          child: this,
        );

  /// 内间距
  Widget sliverPadding({
    Key? key,
    EdgeInsetsGeometry? value,
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) => SliverPadding(
    key: key,
    padding:
        value ??
        EdgeInsets.only(
          top: top ?? vertical ?? all ?? 0.0,
          bottom: bottom ?? vertical ?? all ?? 0.0,
          left: left ?? horizontal ?? all ?? 0.0,
          right: right ?? horizontal ?? all ?? 0.0,
        ),
    sliver: this,
  );

  /// 内间距 下
  Widget sliverPaddingBottom(double val) => sliverPadding(bottom: val);

  /// 内间距 横向
  Widget sliverPaddingHorizontal(double val) => sliverPadding(horizontal: val);

  /// 内间距 左
  Widget sliverPaddingLeft(double val) => sliverPadding(left: val);

  /// 内间距 右
  Widget sliverPaddingRight(double val) => sliverPadding(right: val);

  /// 内间距 上
  Widget sliverPaddingTop(double val) => sliverPadding(top: val);

  /// 内间距 纵向
  Widget sliverPaddingVertical(double val) => sliverPadding(vertical: val);

  /// SliverToBoxAdapter
  Widget sliverToBoxAdapter({Key? key}) =>
      SliverToBoxAdapter(key: key, child: this);

  /// 透明度
  Widget opacity(
    double opacity, {
    Key? key,
    bool animate = false,
    bool alwaysIncludeSemantics = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return AnimatedOpacity(
              opacity: opacity,
              alwaysIncludeSemantics: alwaysIncludeSemantics,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Opacity(
          key: key,
          opacity: opacity,
          alwaysIncludeSemantics: alwaysIncludeSemantics,
          child: this,
        );

  /// 舞台
  Widget offstage({Key? key, bool offstage = true}) =>
      Offstage(key: key, offstage: offstage, child: this);

  /// 对齐
  Widget alignment(
    AlignmentGeometry alignment, {
    Key? key,
    bool animate = false,
  }) => animate
      ? Builder(
          key: key,
          builder: (BuildContext context) {
            final _AnimatedModel animation = _getAnimation(context);
            return AnimatedAlign(
              alignment: alignment,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Align(key: key, alignment: alignment, child: this);

  /// 背景颜色
  Widget backgroundColor(Color color, {Key? key, bool animate = false}) =>
      animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedDecorationBox(
              decoration: BoxDecoration(color: color),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : DecoratedBox(
          key: key,
          decoration: BoxDecoration(color: color),
          child: this,
        );

  /// 背景图片
  Widget backgroundImage(
    DecorationImage image, {
    Key? key,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedDecorationBox(
              decoration: BoxDecoration(image: image),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : DecoratedBox(
          key: key,
          decoration: BoxDecoration(image: image),
          child: this,
        );

  /// 背景渐变
  Widget backgroundGradient(
    Gradient gradient, {
    Key? key,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedDecorationBox(
              decoration: BoxDecoration(gradient: gradient),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : DecoratedBox(
          key: key,
          decoration: BoxDecoration(gradient: gradient),
          child: this,
        );

  /// 背景线性渐变
  Widget backgroundLinearGradient({
    Key? key,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    List<Color>? colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors ?? [],
        stops: stops,
        tileMode: tileMode,
        transform: transform,
      ),
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 背景径向渐变
  Widget backgroundRadialGradient({
    Key? key,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
    List<Color>? colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    AlignmentGeometry? focal,
    double focalRadius = 0.0,
    GradientTransform? transform,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      gradient: RadialGradient(
        center: center,
        radius: radius,
        colors: colors ?? [],
        stops: stops,
        tileMode: tileMode,
        focal: focal,
        focalRadius: focalRadius,
        transform: transform,
      ),
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 背景扫光渐变
  Widget backgroundSweepGradient({
    Key? key,
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0.0,
    double endAngle = pi * 2,
    List<Color>? colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      gradient: SweepGradient(
        center: center,
        startAngle: startAngle,
        endAngle: endAngle,
        colors: colors ?? [],
        stops: stops,
        tileMode: tileMode,
        transform: transform,
      ),
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 背景混合模式
  /// 使用指定颜色或渐变参与混合；默认白色，保持原有调用方式兼容。
  Widget backgroundBlendMode(
    BlendMode blendMode, {
    Key? key,
    Color color = const Color(0xFFFFFFFF),
    Gradient? gradient,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedDecorationBox(
              decoration: BoxDecoration(
                color: color,
                gradient: gradient,
                backgroundBlendMode: blendMode,
              ),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : DecoratedBox(
          key: key,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            backgroundBlendMode: blendMode,
          ),
          child: this,
        );

  /// 背景模糊
  Widget backgroundBlur(double sigma, {Key? key, bool animate = false}) =>
      animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedBackgroundBlur(
              sigma: sigma,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : BackdropFilter(
          key: key,
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: this,
        );

  /// 圆角
  Widget borderRadius({
    Key? key,
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft ?? all ?? 0.0),
        topRight: Radius.circular(topRight ?? all ?? 0.0),
        bottomLeft: Radius.circular(bottomLeft ?? all ?? 0.0),
        bottomRight: Radius.circular(bottomRight ?? all ?? 0.0),
      ),
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 圆角方向
  Widget borderRadiusDirectional({
    Key? key,
    double? all,
    double? topStart,
    double? topEnd,
    double? bottomStart,
    double? bottomEnd,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadiusDirectional.only(
        topStart: Radius.circular(topStart ?? all ?? 0.0),
        topEnd: Radius.circular(topEnd ?? all ?? 0.0),
        bottomStart: Radius.circular(bottomStart ?? all ?? 0.0),
        bottomEnd: Radius.circular(bottomEnd ?? all ?? 0.0),
      ),
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 圆角矩形
  Widget clipRRect({
    Key? key,
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedClipRRect(
              clipper: clipper,
              clipBehavior: clipBehavior,
              topLeft: topLeft ?? all ?? 0.0,
              topRight: topRight ?? all ?? 0.0,
              bottomLeft: bottomLeft ?? all ?? 0.0,
              bottomRight: bottomRight ?? all ?? 0.0,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : ClipRRect(
          key: key,
          clipper: clipper,
          clipBehavior: clipBehavior,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topLeft ?? all ?? 0.0),
            topRight: Radius.circular(topRight ?? all ?? 0.0),
            bottomLeft: Radius.circular(bottomLeft ?? all ?? 0.0),
            bottomRight: Radius.circular(bottomRight ?? all ?? 0.0),
          ),
          child: this,
        );

  /// 矩形
  Widget clipRect({
    Key? key,
    CustomClipper<Rect>? clipper,
    Clip clipBehavior = Clip.hardEdge,
  }) => ClipRect(
    key: key,
    clipper: clipper,
    clipBehavior: clipBehavior,
    child: this,
  );

  /// 椭圆
  Widget clipOval({Key? key}) => ClipOval(key: key, child: this);

  /// 边框
  Widget border({
    Key? key,
    double? all,
    double? left,
    double? right,
    double? top,
    double? bottom,
    Color color = const Color(0xFF000000),
    BorderStyle style = BorderStyle.solid,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      border: Border(
        left: (left ?? all) == null
            ? BorderSide.none
            : BorderSide(color: color, width: left ?? all ?? 0, style: style),
        right: (right ?? all) == null
            ? BorderSide.none
            : BorderSide(color: color, width: right ?? all ?? 0, style: style),
        top: (top ?? all) == null
            ? BorderSide.none
            : BorderSide(color: color, width: top ?? all ?? 0, style: style),
        bottom: (bottom ?? all) == null
            ? BorderSide.none
            : BorderSide(color: color, width: bottom ?? all ?? 0, style: style),
      ),
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 取消父级约束
  Widget unconstrained({
    Key? key,
    TextDirection? textDirection,
    AlignmentGeometry alignment = Alignment.center,
    Axis? constrainedAxis,
    Clip clipBehavior = Clip.none,
  }) => UnconstrainedBox(
    key: key,
    textDirection: textDirection,
    alignment: alignment,
    constrainedAxis: constrainedAxis,
    clipBehavior: clipBehavior,
    child: this,
  );

  /// 盒子装饰器
  Widget decorated({
    Key? key,
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape shape = BoxShape.rectangle,
    DecorationPosition position = DecorationPosition.background,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      color: color,
      image: image,
      border: border,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      gradient: gradient,
      backgroundBlendMode: backgroundBlendMode,
      shape: shape,
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                position: position,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(
            key: key,
            decoration: decoration,
            position: position,
            child: this,
          );
  }

  /// 阴影透明度曲线
  double _elevationOpacityCurve(double x) =>
      pow(x, 1 / 16) / sqrt(pow(x, 2) + 2) + 0.2;

  /// 阴影
  Widget elevation(
    double elevation, {
    Key? key,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    Color shadowColor = const Color(0xFF000000),
  }) => Material(
    key: key,
    color: Colors.transparent,
    elevation: elevation,
    borderRadius: borderRadius,
    shadowColor: shadowColor,
    child: this,
  );

  /// 新拟态
  Widget neumorphism({
    Key? key,
    required double elevation,
    BorderRadius borderRadius = BorderRadius.zero,
    Color backgroundColor = const Color(0xffEDF1F5),
    double curve = 0.0,
    bool animate = false,
  }) {
    final double offset = elevation / 2;
    final int colorOffset = (40 * curve).toInt();
    // Color 分量现以 0 到 1 的浮点值暴露，转换为 RGB 整数供渐变计算。
    final int red = (backgroundColor.r * 255).round();
    final int green = (backgroundColor.g * 255).round();
    final int blue = (backgroundColor.b * 255).round();
    int adjustColor(int color, int colorOffset) {
      final int colorVal = color + colorOffset;
      if (colorVal > 255) {
        return 255;
      } else if (colorVal < 0) {
        return 0;
      }
      return colorVal;
    }

    final BoxDecoration decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(
            adjustColor(red, colorOffset),
            adjustColor(green, colorOffset),
            adjustColor(blue, colorOffset),
            1.0,
          ),
          Color.fromRGBO(
            adjustColor(red, -colorOffset),
            adjustColor(green, -colorOffset),
            adjustColor(blue, -colorOffset),
            1.0,
          ),
        ],
        // stops: [0.90, 0.95],
      ),
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: Colors.white,
          blurRadius: elevation.abs(),
          offset: Offset(-offset, -offset),
        ),
        BoxShadow(
          color: const Color(0xAAA3B1C6),
          blurRadius: elevation.abs(),
          offset: Offset(offset, offset),
        ),
      ],
    );

    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 盒子阴影
  Widget boxShadow({
    Key? key,
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    bool animate = false,
  }) {
    final BoxDecoration decoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
      ],
    );
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedDecorationBox(
                decoration: decoration,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : DecoratedBox(key: key, decoration: decoration, child: this);
  }

  /// 约束
  Widget constrained({
    Key? key,
    double? width,
    double? height,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
    bool animate = false,
  }) {
    BoxConstraints constraints = BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
    constraints = (width != null || height != null)
        ? constraints.tighten(width: width, height: height)
        : constraints;
    return animate
        ? _StyledAnimatedBuilder(
            key: key,
            builder: (animation) {
              return _AnimatedConstrainedBox(
                constraints: constraints,
                duration: animation.duration,
                curve: animation.curve,
                child: this,
              );
            },
          )
        : ConstrainedBox(key: key, constraints: constraints, child: this);
  }

  /// 约束 宽高
  Widget tight({double? width, double? height, Key? key}) => ConstrainedBox(
    key: key,
    constraints: BoxConstraints.tightFor(width: width, height: height),
    child: this,
  );

  /// 约束 宽高 size
  Widget tightSize(double size, {Key? key}) => ConstrainedBox(
    key: key,
    constraints: BoxConstraints.tightFor(width: size, height: size),
    child: this,
  );

  /// 约束 宽度
  Widget width(double width, {Key? key, bool animate = false}) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedConstrainedBox(
              constraints: BoxConstraints.tightFor(width: width),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : ConstrainedBox(
          key: key,
          constraints: BoxConstraints.tightFor(width: width),
          child: this,
        );

  /// 约束 高度
  Widget height(double height, {Key? key, bool animate = false}) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedConstrainedBox(
              constraints: BoxConstraints.tightFor(height: height),
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : ConstrainedBox(
          key: key,
          constraints: BoxConstraints.tightFor(height: height),
          child: this,
        );

  /// 涟漪 InkWell
  Widget ripple({
    Key? key,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    InteractiveInkFeatureFactory? splashFactory,
    double? radius,
    ShapeBorder? customBorder,
    bool enableFeedback = true,
    bool excludeFromSemantics = false,
    FocusNode? focusNode,
    bool canRequestFocus = true,
    bool autoFocus = false,
    bool enable = true,
  }) => enable
      ? Builder(
          key: key,
          builder: (BuildContext context) {
            final GestureDetector? gestures = context
                .findAncestorWidgetOfExactType<GestureDetector>();
            return Material(
              color: Colors.transparent,
              child: InkWell(
                focusColor: focusColor,
                hoverColor: hoverColor,
                highlightColor: highlightColor,
                splashColor: splashColor,
                splashFactory: splashFactory,
                radius: radius,
                customBorder: customBorder,
                enableFeedback: enableFeedback,
                excludeFromSemantics: excludeFromSemantics,
                focusNode: focusNode,
                canRequestFocus: canRequestFocus,
                autofocus: autoFocus,
                onTap: gestures?.onTap,
                child: this,
              ),
            );
          },
        )
      : Builder(key: key, builder: (context) => this);

  /// 旋转
  Widget rotate({
    Key? key,
    required double angle,
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedTransform(
              transform: Matrix4.rotationZ(angle),
              alignment: alignment,
              origin: origin,
              transformHitTests: transformHitTests,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Transform.rotate(
          key: key,
          angle: angle,
          alignment: alignment,
          origin: origin,
          transformHitTests: transformHitTests,
          child: this,
        );

  /// 缩放
  Widget scale({
    Key? key,
    double? all,
    double? x,
    double? y,
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedTransform(
              transform: Matrix4.diagonal3Values(
                x ?? all ?? 0,
                y ?? all ?? 0,
                1.0,
              ),
              alignment: alignment,
              transformHitTests: transformHitTests,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Transform(
          key: key,
          transform: Matrix4.diagonal3Values(x ?? all ?? 0, y ?? all ?? 0, 1.0),
          alignment: alignment,
          origin: origin,
          transformHitTests: transformHitTests,
          child: this,
        );

  /// 平移
  Widget translate({
    Key? key,
    required Offset offset,
    bool transformHitTests = true,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedTransform(
              transform: Matrix4.translationValues(offset.dx, offset.dy, 0.0),
              transformHitTests: transformHitTests,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Transform.translate(
          key: key,
          offset: offset,
          transformHitTests: transformHitTests,
          child: this,
        );

  /// 变换
  Widget transform({
    Key? key,
    required Matrix4 transform,
    Offset? origin,
    AlignmentGeometry? alignment,
    bool transformHitTests = true,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedTransform(
              transform: transform,
              origin: origin,
              alignment: alignment,
              transformHitTests: transformHitTests,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : Transform(
          key: key,
          transform: transform,
          alignment: alignment,
          origin: origin,
          transformHitTests: transformHitTests,
          child: this,
        );

  /// 溢出
  Widget overflow({
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return _AnimatedOverflowBox(
              alignment: alignment,
              minWidth: minWidth,
              maxWidth: maxWidth,
              minHeight: minHeight,
              maxHeight: maxHeight,
              duration: animation.duration,
              curve: animation.curve,
              child: this,
            );
          },
        )
      : OverflowBox(
          key: key,
          alignment: alignment,
          minWidth: minWidth,
          maxWidth: maxWidth,
          minHeight: minHeight,
          maxHeight: maxHeight,
          child: this,
        );

  /// 滚动视图
  Widget scrollable({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    bool? primary,
    ScrollPhysics? physics,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    EdgeInsetsGeometry? padding,
  }) => SingleChildScrollView(
    key: key,
    scrollDirection: scrollDirection,
    reverse: reverse,
    primary: primary,
    physics: physics,
    controller: controller,
    dragStartBehavior: dragStartBehavior,
    padding: padding,
    child: this,
  );

  /// 扩展
  Widget expanded({Key? key, int flex = 1}) =>
      Expanded(key: key, flex: flex, child: this);

  /// 弹性
  Widget flexible({Key? key, int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(key: key, flex: flex, fit: fit, child: this);

  /// 位置
  Widget positioned({
    Key? key,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return AnimatedPositioned(
              duration: animation.duration,
              curve: animation.curve,
              left: left,
              top: top,
              right: right,
              bottom: bottom,
              width: width,
              height: height,
              child: this,
            );
          },
        )
      : Positioned(
          key: key,
          left: left,
          top: top,
          right: right,
          bottom: bottom,
          width: width,
          height: height,
          child: this,
        );

  /// 位置方向
  Widget positionedDirectional({
    Key? key,
    double? start,
    double? end,
    double? top,
    double? bottom,
    double? width,
    double? height,
    bool animate = false,
  }) => animate
      ? _StyledAnimatedBuilder(
          key: key,
          builder: (animation) {
            return AnimatedPositionedDirectional(
              duration: animation.duration,
              curve: animation.curve,
              start: start,
              end: end,
              top: top,
              bottom: bottom,
              width: width,
              height: height,
              child: this,
            );
          },
        )
      : PositionedDirectional(
          key: key,
          start: start,
          end: end,
          top: top,
          bottom: bottom,
          width: width,
          height: height,
          child: this,
        );

  // 墨水纹
  Widget inkWell({Key? key, Function()? onTap, double? borderRadius}) =>
      Material(
        color: Colors.transparent,
        child: Ink(
          child: InkWell(
            borderRadius: borderRadius != null
                ? BorderRadius.all(Radius.circular(borderRadius))
                : null,
            onTap: onTap ?? () {},
            child: this,
          ),
        ),
      );

  /// 安全区域
  Widget safeArea({
    Key? key,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) => SafeArea(
    key: key,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    child: this,
  );

  /// 语义标签
  Widget semanticsLabel(String label, {Key? key}) => Semantics.fromProperties(
    key: key,
    properties: SemanticsProperties(label: label),
    child: this,
  );

  /// 手势
  Widget gestures({
    Key? key,
    GestureOnTapChangeCallback? onTapChange,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCallback? onTap,
    GestureTapCancelCallback? onTapCancel,
    GestureTapDownCallback? onSecondaryTapDown,
    GestureTapUpCallback? onSecondaryTapUp,
    GestureTapCancelCallback? onSecondaryTapCancel,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureLongPressStartCallback? onLongPressStart,
    GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate,
    GestureLongPressUpCallback? onLongPressUp,
    GestureLongPressEndCallback? onLongPressEnd,
    GestureDragDownCallback? onVerticalDragDown,
    GestureDragStartCallback? onVerticalDragStart,
    GestureDragUpdateCallback? onVerticalDragUpdate,
    GestureDragEndCallback? onVerticalDragEnd,
    GestureDragCancelCallback? onVerticalDragCancel,
    GestureDragDownCallback? onHorizontalDragDown,
    GestureDragStartCallback? onHorizontalDragStart,
    GestureDragUpdateCallback? onHorizontalDragUpdate,
    GestureDragEndCallback? onHorizontalDragEnd,
    GestureDragCancelCallback? onHorizontalDragCancel,
    GestureDragDownCallback? onPanDown,
    GestureDragStartCallback? onPanStart,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
    GestureDragCancelCallback? onPanCancel,
    GestureScaleStartCallback? onScaleStart,
    GestureScaleUpdateCallback? onScaleUpdate,
    GestureScaleEndCallback? onScaleEnd,
    GestureForcePressStartCallback? onForcePressStart,
    GestureForcePressPeakCallback? onForcePressPeak,
    GestureForcePressUpdateCallback? onForcePressUpdate,
    GestureForcePressEndCallback? onForcePressEnd,
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) => GestureDetector(
    key: key,
    onTapDown: (TapDownDetails tapDownDetails) {
      if (onTapDown != null) onTapDown(tapDownDetails);
      if (onTapChange != null) onTapChange(true);
    },
    onTapCancel: () {
      if (onTapCancel != null) onTapCancel();
      if (onTapChange != null) onTapChange(false);
    },
    onTap: () {
      if (onTap != null) onTap();
      if (onTapChange != null) onTapChange(false);
    },
    onTapUp: onTapUp,
    onDoubleTap: onDoubleTap,
    onLongPress: onLongPress,
    onLongPressStart: onLongPressStart,
    onLongPressEnd: onLongPressEnd,
    onLongPressMoveUpdate: onLongPressMoveUpdate,
    onLongPressUp: onLongPressUp,
    onVerticalDragStart: onVerticalDragStart,
    onVerticalDragEnd: onVerticalDragEnd,
    onVerticalDragDown: onVerticalDragDown,
    onVerticalDragCancel: onVerticalDragCancel,
    onVerticalDragUpdate: onVerticalDragUpdate,
    onHorizontalDragStart: onHorizontalDragStart,
    onHorizontalDragEnd: onHorizontalDragEnd,
    onHorizontalDragCancel: onHorizontalDragCancel,
    onHorizontalDragUpdate: onHorizontalDragUpdate,
    onHorizontalDragDown: onHorizontalDragDown,
    onForcePressStart: onForcePressStart,
    onForcePressEnd: onForcePressEnd,
    onForcePressPeak: onForcePressPeak,
    onForcePressUpdate: onForcePressUpdate,
    onPanStart: onPanStart,
    onPanEnd: onPanEnd,
    onPanCancel: onPanCancel,
    onPanDown: onPanDown,
    onPanUpdate: onPanUpdate,
    onScaleStart: onScaleStart,
    onScaleEnd: onScaleEnd,
    onScaleUpdate: onScaleUpdate,
    behavior: behavior,
    excludeFromSemantics: excludeFromSemantics,
    dragStartBehavior: dragStartBehavior,
    child: this,
  );

  /// 手势
  Widget onTap(
    GestureTapCallback? onTap, {
    Key? key,
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) => GestureDetector(
    key: key,
    onTap: onTap,
    behavior: behavior ?? HitTestBehavior.opaque,
    excludeFromSemantics: excludeFromSemantics,
    dragStartBehavior: dragStartBehavior,
    child: this,
  );

  /// 长按手势
  Widget onLongPress(
    GestureTapCallback? onLongPress, {
    Key? key,
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) => GestureDetector(
    key: key,
    onLongPress: onLongPress,
    behavior: behavior ?? HitTestBehavior.opaque,
    excludeFromSemantics: excludeFromSemantics,
    dragStartBehavior: dragStartBehavior,
    child: this,
  );

  /// 比例
  Widget aspectRatio({Key? key, required double aspectRatio}) =>
      AspectRatio(key: key, aspectRatio: aspectRatio, child: this);

  /// 居中
  Widget center({Key? key, double? widthFactor, double? heightFactor}) =>
      Center(
        key: key,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: this,
      );

  /// 适配
  Widget fittedBox({
    Key? key,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
  }) => FittedBox(key: key, fit: fit, alignment: alignment, child: this);

  /// 适配
  Widget fractionallySizedBox({
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    double? widthFactor,
    double? heightFactor,
  }) => FractionallySizedBox(
    key: key,
    alignment: alignment,
    widthFactor: widthFactor,
    heightFactor: heightFactor,
    child: this,
  );

  /// 卡片
  Widget card({
    Key? key,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    bool borderOnForeground = true,
    EdgeInsetsGeometry? margin,
    Clip? clipBehavior,
    bool semanticContainer = true,
  }) => Card(
    key: key,
    color: color,
    elevation: elevation,
    shape: shape,
    borderOnForeground: borderOnForeground,
    margin: margin,
    clipBehavior: clipBehavior,
    semanticContainer: semanticContainer,
    child: this,
  );

  /// 限制
  Widget limitedBox({
    Key? key,
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
  }) => LimitedBox(
    key: key,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
    child: this,
  );

  /// 材料
  Widget material({
    Key? key,
    MaterialType type = MaterialType.canvas,
    double elevation = 0.0,
    Color? color,
    Color? shadowColor,
    TextStyle? textStyle,
    BorderRadiusGeometry? borderRadius,
    ShapeBorder? shape,
    bool borderOnForeground = true,
    Clip clipBehavior = Clip.none,
    Duration animationDuration = kThemeChangeDuration,
  }) => Material(
    key: key,
    type: type,
    elevation: elevation,
    color: color,
    shadowColor: shadowColor,
    textStyle: textStyle,
    borderRadius: borderRadius,
    shape: shape,
    borderOnForeground: borderOnForeground,
    clipBehavior: clipBehavior,
    animationDuration: animationDuration,
    child: this,
  );

  /// 鼠标区域
  Widget mouseRegion({
    Key? key,
    void Function(PointerEnterEvent)? onEnter,
    void Function(PointerExitEvent)? onExit,
    void Function(PointerHoverEvent)? onHover,
    MouseCursor cursor = MouseCursor.defer,
    bool opaque = true,
  }) => MouseRegion(
    key: key,
    onEnter: onEnter,
    onExit: onExit,
    onHover: onHover,
    cursor: cursor,
    opaque: opaque,
    child: this,
  );
}
```

### `lib/common/models/auth_user.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// 登录 / 刷新接口 `data.user`。
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? avatar,
  }) = _AuthUser;

  /// 手写解析，避免 freezed 把 `fromJson` 识别成必须生成 `.g.dart`。
  factory AuthUser.fromApiJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    avatar: json['avatar'] as String?,
  );
}
```

### `lib/common/models/auth_session.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'auth_session.freezed.dart';

/// 登录 / 刷新接口 `data`：一对令牌 + 用户。
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String refreshToken,
    required AuthUser user,
  }) = _AuthSession;

  /// 手写解析，原因同 [AuthUser.fromApiJson]。
  factory AuthSession.fromApiJson(Map<String, dynamic> json) => AuthSession(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    user: AuthUser.fromApiJson(json['user'] as Map<String, dynamic>),
  );
}
```

### `lib/common/models/session_snapshot.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_snapshot.freezed.dart';

/// 异步任务捕获的会话归属；普通 Token 刷新不会改变 [version]。
@freezed
abstract class SessionSnapshot with _$SessionSnapshot {
  const factory SessionSnapshot({
    required String? userId,
    required int version,
    required String? accessToken,
  }) = _SessionSnapshot;
}
```

### `lib/common/models/index.dart`

```dart
// 模型入口。
export 'auth_session.dart';
export 'auth_user.dart';
export 'session_snapshot.dart';
```

### `lib/common/services/storage_service.dart`

```dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 文件作用：
/// - 封装 SharedPreferences 单例，供 Token / 缓存 / 启动标记共用
/// - 必须在其它 Service 之前 [Get.putAsync] 完成
/// - init() 必须 return this，否则 putAsync 类型对不上
/// - 不负责加密；调用方自行评估敏感数据风险
///
/// SharedPreferences 的进程内入口。
class StorageService extends GetxService {
  late final SharedPreferences prefs;

  /// 异步拿到 prefs 并返回自身。
  ///
  /// ⚠️ 坑：必须 `return this`。[Get.putAsync] 要求 Future 解析为实例，
  /// 写成 `Future<void>` 会在注册时类型对不上。
  Future<StorageService> init() async {
    prefs = await SharedPreferences.getInstance();
    return this;
  }
}
```

### `lib/common/services/token_service.dart`

```dart
import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// 文件作用：
/// - access / refresh token、后端用户 ID 与 JWT exp 的一致持久化
/// - 为路由和网络层提供同步内存快照，避免读取到混合的新旧凭证
class TokenService extends GetxService {
  TokenService(StorageService storage) : _prefs = storage.prefs {
    _record = _readRecord();
  }

  static const _kAccessToken = 'auth.access_token';
  static const _kRefreshToken = 'auth.refresh_token';
  static const _kExpiresAt = 'auth.expires_at';
  static const _kUserId = 'auth.user_id';

  final SharedPreferences _prefs;
  late _TokenRecord _record;
  Future<void> _writeQueue = Future<void>.value();

  String? get accessToken => _record.accessToken;
  String? get refreshToken => _record.refreshToken;
  int? get expiresAt => _record.expiresAt;

  /// 当前后端用户标识；旧版本没有该字段时不恢复为已登录状态。
  String? get userId => _record.userId;

  /// 整份替换登录或刷新返回的凭证，避免分项写入造成新旧字段混用。
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    String? userId,
  }) async {
    final next = _TokenRecord(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: _decodeJwtExpiryMs(accessToken),
      userId: userId ?? _record.userId,
    );
    // 先替换内存记录；同一事件循环内的请求立即看到完整的新记录。
    _record = next;
    await _enqueueWrite(() async {
      await _prefs.setString(_kAccessToken, next.accessToken!);
      await _prefs.setString(_kRefreshToken, next.refreshToken!);
      if (next.expiresAt != null) {
        await _prefs.setInt(_kExpiresAt, next.expiresAt!);
      } else {
        await _prefs.remove(_kExpiresAt);
      }
      if (next.userId != null && next.userId!.isNotEmpty) {
        await _prefs.setString(_kUserId, next.userId!);
      } else {
        await _prefs.remove(_kUserId);
      }
    });
  }

  /// 清除整份记录；写队列保证迟到的 save 不会在登出后复活会话。
  Future<void> clear() async {
    _record = const _TokenRecord();
    await _enqueueWrite(() async {
      await _prefs.remove(_kAccessToken);
      await _prefs.remove(_kRefreshToken);
      await _prefs.remove(_kExpiresAt);
      await _prefs.remove(_kUserId);
    });
  }

  /// 同时具备用户身份和 accessToken 才是可恢复的登录会话。
  bool get hasToken =>
      accessToken?.isNotEmpty == true && userId?.isNotEmpty == true;

  /// 本地时钟估算是否过期；解析失败时交给服务端 401 兜底。
  bool get isExpired {
    final exp = expiresAt;
    if (exp == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= exp;
  }

  _TokenRecord _readRecord() => _TokenRecord(
    accessToken: _prefs.getString(_kAccessToken),
    refreshToken: _prefs.getString(_kRefreshToken),
    expiresAt: _prefs.getInt(_kExpiresAt),
    userId: _prefs.getString(_kUserId),
  );

  /// 串行落盘，让较晚发起的登出或换号最终覆盖较早的异步写入。
  Future<void> _enqueueWrite(Future<void> Function() operation) {
    final result = _writeQueue.then((_) => operation());
    _writeQueue = result.catchError((_) {});
    return result;
  }

  /// 解码 JWT payload 的 `exp`（Unix 秒）为毫秒；不负责签名校验。
  static int? _decodeJwtExpiryMs(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payloadJson = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final payload = jsonDecode(payloadJson);
      final exp = payload is Map ? payload['exp'] : null;
      if (exp is num) return (exp * 1000).toInt();
    } catch (_) {
      // 非 JWT 或数据损坏时不主动判过期。
    }
    return null;
  }
}

/// 仅在 [TokenService] 内整体替换的不可变凭证记录。
class _TokenRecord {
  const _TokenRecord({
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.userId,
  });

  final String? accessToken;
  final String? refreshToken;
  final int? expiresAt;
  final String? userId;
}
```

### `lib/common/services/session_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../cache/index.dart';
import '../models/index.dart';
import 'token_service.dart';

/// 文件作用：
/// - 集中建立、更新和失效登录会话
/// - 用后端用户 ID 与单调版本隔离旧异步结果
class SessionService extends GetxService {
  SessionService(this._token);

  final TokenService _token;

  /// 身份变化信号，供路由 redirect 监听。
  final revision = ValueNotifier<int>(0);

  /// 凭证变化信号，供图片代理重建鉴权。
  final credentialRevision = ValueNotifier<int>(0);

  int _version = 0;

  bool get isLogin => _token.hasToken;

  /// 捕获任务所属账号和版本；异步结果必须在提交点重新校验。
  SessionSnapshot get snapshot => SessionSnapshot(
    userId: _token.userId,
    version: _version,
    accessToken: _token.accessToken,
  );

  bool isCurrent(SessionSnapshot captured) =>
      captured.userId != null &&
      captured.userId == _token.userId &&
      captured.version == _version &&
      _token.hasToken;

  /// 建立或替换登录会话；同账号重新登录也作废旧任务。
  Future<void> establish({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    _version++;
    await _token.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
    revision.value++;
    credentialRevision.value++;
  }

  /// 同一会话刷新凭证，不触发业务页整页重载。
  Future<bool> updateCredentials(
    SessionSnapshot captured, {
    required String accessToken,
    required String refreshToken,
  }) async {
    if (!isCurrent(captured)) return false;
    await _token.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: captured.userId,
    );
    if (!isCurrent(captured)) return false;
    credentialRevision.value++;
    return true;
  }

  /// 先递增版本并清内存，再清凭证与图片缓存。
  Future<void> invalidate({SessionSnapshot? onlyIfCurrent}) async {
    if (onlyIfCurrent != null && !isCurrent(onlyIfCurrent)) return;
    _version++;
    final clearToken = _token.clear();
    revision.value++;
    credentialRevision.value++;
    await clearToken;
    try {
      await ProxyImageCacheManager.emptyCache();
    } catch (_) {
      // 图片缓存失败不能阻塞本地退出。
    }
  }

  @override
  void onClose() {
    revision.dispose();
    credentialRevision.dispose();
    super.onClose();
  }
}
```

### `lib/common/services/app_launch_service.dart`

```dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// 文件作用：
/// - 记录是否已看过欢迎页
/// - 供路由 redirect：未看过 → Welcome，已看过未登录 → Login
/// - 与登录态无关，登出不清此标记
///
/// 欢迎页一次性标记。
class AppLaunchService extends GetxService {
  AppLaunchService(StorageService storage) : _prefs = storage.prefs;

  static const _hasSeenWelcomeKey = 'app.has_seen_welcome';

  final SharedPreferences _prefs;

  bool get hasSeenWelcome => _prefs.getBool(_hasSeenWelcomeKey) ?? false;

  /// 欢迎页走完后落盘，后续启动不再进欢迎页。
  Future<void> markWelcomeSeen() async {
    final saved = await _prefs.setBool(_hasSeenWelcomeKey, true);
    if (!saved) throw StateError('Unable to save welcome preference');
  }

  /// 仅调试 / 重置流程用；生产路径不调用。
  Future<void> reset() async {
    await _prefs.remove(_hasSeenWelcomeKey);
  }
}
```

### `lib/common/services/locale_service.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../i18n/index.dart';
import 'storage_service.dart';

/// 管理应用语言的持久化和运行时切换；不跟随系统，默认英语。
class LocaleService extends GetxService {
  LocaleService(this._storage);

  static const _storageKey = 'app_locale';
  final StorageService _storage;
  Locale _locale = AppTranslations.fallbackLocale;

  Locale get locale => _locale;

  /// 从本地读取合法语言；旧值或非法值均安全回退至英语。
  Future<LocaleService> init() async {
    final value = _storage.prefs.getString(_storageKey);
    _locale = AppTranslations.supportedLocales.firstWhere(
      (locale) => _localeKey(locale) == value,
      orElse: () => AppTranslations.fallbackLocale,
    );
    return this;
  }

  /// 保存成功后才切换界面，避免持久化失败与当前状态不一致。
  Future<void> change(Locale value) async {
    if (!AppTranslations.supportedLocales.contains(value) || value == _locale) {
      return;
    }
    final saved = await _storage.prefs.setString(
      _storageKey,
      _localeKey(value),
    );
    if (!saved) throw StateError('Unable to save language preference');
    _locale = value;
    await Get.updateLocale(value);
  }

  static String _localeKey(Locale locale) =>
      '${locale.languageCode}_${locale.countryCode}';
}
```

### `lib/common/services/index.dart`

```dart
// 应用级服务入口。
export 'app_launch_service.dart';
export 'locale_service.dart';
export 'session_service.dart';
export 'storage_service.dart';
export 'token_service.dart';
```

### `lib/common/network/network_config.dart`

```dart
/// 文件作用：
/// - 定义 API 来源标识 [ApiSource]
/// - 定义单来源网络参数 [NetworkEndpoint]
/// - 集中登记所有来源配置 [NetworkEndpoints]
library;

import '../values/index.dart';

/// API 来源标识。
///
/// 每个来源对应一个独立 baseUrl / Dio 实例。
enum ApiSource {
  /// 主业务后端
  app,
}

/// 单个 API 来源的网络参数：baseUrl + 超时 / 鉴权 / 日志 / 公共头。
class NetworkEndpoint {
  const NetworkEndpoint({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.requiresAuth = true,
    this.enableLogging = true,
    this.headers = const {'Accept': 'application/json'},
  });

  /// 接口根地址
  final String baseUrl;

  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// 是否挂载鉴权拦截器（附带 Token、401 自动刷新重试）
  final bool requiresAuth;

  /// 是否打印请求日志
  final bool enableLogging;

  /// 该来源公共请求头
  final Map<String, String> headers;
}

/// 全部 API 来源的配置表。
///
/// 地址与白名单来自 [AppConfig]，便于 `--dart-define` 覆盖。
abstract final class NetworkEndpoints {
  /// 主业务后端
  static const app = NetworkEndpoint(
    baseUrl: AppConfig.baseUrl,
    enableLogging: AppConfig.enableHttpLog,
  );

  /// 来源 -> 配置映射，新增来源时同步登记
  static const values = <ApiSource, NetworkEndpoint>{ApiSource.app: app};

  static NetworkEndpoint of(ApiSource source) {
    final endpoint = values[source];
    if (endpoint == null) {
      throw StateError('ApiSource.${source.name} 未在 NetworkEndpoints 中登记');
    }
    return endpoint;
  }
}
```

### `lib/common/network/api_exception.dart`

```dart
/// 文件作用：
/// - API 异常类型：按 HTTP 状态码拆 BadRequest / Unauthorized / …
/// - 拦截器把 DioException 转成这些类型
/// - UI 用 [message]，业务用 [statusCode] / [data] 分支
/// - [userFacingErrorMessage] 把任意错误对象转成可直接展示的文案
library;

import 'package:dio/dio.dart';

/// API 层统一异常基类。
///
/// 职责：
/// - 把 Dio 的低层错误转换成业务侧更容易理解的异常。
/// - 保留状态码与响应体，方便 UI 展示、日志上报或按错误码分支。
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// 400：请求参数、格式或业务校验不通过。
class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.data})
    : super(statusCode: 400);
}

/// 401：登录态无效；通常由鉴权拦截器先尝试刷新 token。
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.data})
    : super(statusCode: 401);
}

/// 403：已登录但没有权限访问目标资源。
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, {super.data})
    : super(statusCode: 403);
}

/// 404：资源不存在或接口路径不匹配。
class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.data}) : super(statusCode: 404);
}

/// 409：资源状态冲突，例如重复提交或版本冲突。
class ConflictException extends ApiException {
  const ConflictException(super.message, {super.data}) : super(statusCode: 409);
}

/// 5xx：服务端错误，statusCode 可能是 500、502、503 等。
class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.data});
}

/// 网络不可达、超时、证书失败等客户端侧连接问题。
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// 请求被主动取消，通常不需要按失败 toast 处理。
class CancelException extends ApiException {
  const CancelException(super.message);
}

/// 未能归类的兜底异常，避免错误信息丢失。
class UnknownException extends ApiException {
  const UnknownException(super.message, {super.statusCode, super.data});
}

/// 从后端响应体里提取错误文案（message / msg / error）。
String? apiErrorMessageOf(Object? data) {
  if (data is Map) {
    for (final key in ['message', 'msg', 'error']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
  }
  return null;
}

/// UI 展示用：仅业务文案，不含 Dio / ApiException 等包装前缀。
String userFacingErrorMessage(Object? error, {String fallback = '操作失败，请稍后重试'}) {
  if (error == null) return fallback;
  if (error is ApiException) return error.message;
  if (error is DioException) {
    final inner = error.error;
    if (inner is ApiException) return inner.message;

    final fromBody = apiErrorMessageOf(error.response?.data);
    if (fromBody != null) return fromBody;

    final m = error.message?.trim();
    if (m != null && m.isNotEmpty) return m;
    return fallback;
  }
  return error.toString();
}
```

### `lib/common/network/interceptors.dart`

```dart
/// 文件作用：
/// - [AuthInterceptor]：共享 Token 刷新、会话校验与单次请求重放
/// - [LoggingInterceptor]：请求、响应、错误的统一敏感信息脱敏
/// - [ErrorInterceptor]：DioException 统一映射为 [ApiException]
library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/index.dart';
import '../services/index.dart';
import '../values/index.dart';
import 'api_exception.dart';

/// 鉴权拦截器：并发请求共享一次刷新，且每个原请求最多重放一次。
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.sessionService,
    required this.refreshDio,
  });

  final TokenService tokenStorage;
  final SessionService sessionService;

  /// 无拦截器的 Dio：刷新不会递归，重放失败可保留真实 Dio 错误。
  final Dio refreshDio;

  static List<String> get _whitelist => AppConfig.authWhitelist;
  static const _requestTokenKey = 'auth.request_token';
  static const _requestSessionKey = 'auth.request_session';
  static const _retriedKey = 'auth.retried';

  Future<bool>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isWhitelisted(options.path)) {
      handler.next(options);
      return;
    }

    final activeRefresh = _refreshFuture;
    if (activeRefresh != null) {
      // 401 已触发刷新时，后续请求先等待，避免继续携带旧凭证出站。
      await activeRefresh;
    } else if (tokenStorage.isExpired) {
      await _sharedRefresh();
    }

    final token = tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_requestTokenKey] = token;
      options.extra[_requestSessionKey] = sessionService.snapshot;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final requestSession = options.extra[_requestSessionKey];
    if (err.response?.statusCode != 401 ||
        _isWhitelisted(options.path) ||
        options.extra[_retriedKey] == true ||
        requestSession is! SessionSnapshot ||
        !sessionService.isCurrent(requestSession)) {
      handler.next(err);
      return;
    }

    final requestToken = options.extra[_requestTokenKey] as String?;
    final currentToken = tokenStorage.accessToken;
    final canUseNewToken =
        requestToken != null &&
        currentToken != null &&
        currentToken.isNotEmpty &&
        requestToken != currentToken;
    final ready = canUseNewToken || await _sharedRefresh();
    if (!ready || !_isReplayable(options.data)) {
      handler.next(err);
      return;
    }

    final retryToken = tokenStorage.accessToken;
    if (retryToken == null || retryToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final retried = await refreshDio.fetch<dynamic>(
        options.copyWith(
          headers: {...options.headers, 'Authorization': 'Bearer $retryToken'},
          extra: {...options.extra, _retriedKey: true},
        ),
      );
      handler.resolve(retried);
    } on DioException catch (retryError) {
      // 返回重放的真实错误，避免用首次 401 掩盖后续故障。
      handler.next(retryError);
    } catch (retryError) {
      handler.next(
        DioException(
          requestOptions: options,
          error: retryError,
          message: retryError.toString(),
        ),
      );
    }
  }

  /// 所有并发调用等待同一个 Future；完成后释放以允许后续显式重试。
  Future<bool> _sharedRefresh() {
    final active = _refreshFuture;
    if (active != null) return active;
    final created = _refreshTokens();
    _refreshFuture = created;
    return created.whenComplete(() {
      if (identical(_refreshFuture, created)) _refreshFuture = null;
    });
  }

  Future<bool> _refreshTokens() async {
    // 未配后端时不发 refresh，保留本地假登录会话。
    if (!AppConfig.hasBaseUrl) return false;

    final captured = sessionService.snapshot;
    final refreshToken = tokenStorage.refreshToken;
    if (!sessionService.isCurrent(captured) ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return false;
    }

    try {
      final resp = await refreshDio.post<Map<String, dynamic>>(
        AppConfig.authRefreshPath,
        data: {'refreshToken': refreshToken},
      );
      final data = resp.data?['data'];
      if (data is! Map) return false;
      final accessToken = data['accessToken'];
      final nextRefreshToken = data['refreshToken'];
      if (accessToken is! String ||
          accessToken.isEmpty ||
          nextRefreshToken is! String ||
          nextRefreshToken.isEmpty) {
        return false;
      }
      return sessionService.updateCredentials(
        captured,
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );
    } on DioException catch (error) {
      // 只有服务端明确拒绝刷新凭证时退出；断网、超时和 5xx 保留会话。
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        await sessionService.invalidate(onlyIfCurrent: captured);
      }
      return false;
    } catch (_) {
      // 响应格式和本地处理异常不等于凭证已失效。
      return false;
    }
  }

  /// FormData 和流可能已被消费，不进行无法保证一致性的自动重放。
  bool _isReplayable(Object? data) => data is! FormData && data is! Stream;

  bool _isWhitelisted(String path) =>
      _whitelist.any((candidate) => path.endsWith(candidate));
}

/// 请求、响应和错误日志使用同一递归脱敏策略。
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({Logger? logger})
    : _logger =
          logger ??
          Logger(printer: PrettyPrinter(methodCount: 0, printEmojis: false));

  final Logger _logger;

  static const _sensitiveKeys = {
    'authorization',
    'cookie',
    'setcookie',
    'idtoken',
    'accesstoken',
    'refreshtoken',
    'signedtransaction',
    'signedrenewalinfo',
    'purchasetoken',
    'receipt',
  };

  Object? _redact(Object? value, {String? key}) {
    final normalizedKey = key
        ?.replaceAll(RegExp(r'[^a-zA-Z]'), '')
        .toLowerCase();
    if (normalizedKey != null && _sensitiveKeys.contains(normalizedKey)) {
      return '<redacted>';
    }
    if (value is Map) {
      return value.map(
        (entryKey, entryValue) =>
            MapEntry(entryKey, _redact(entryValue, key: entryKey.toString())),
      );
    }
    if (value is Iterable) return value.map((item) => _redact(item)).toList();
    if (value is String) return _redactText(value);
    return value;
  }

  /// 同时覆盖原始 JSON、表单文本和错误字符串中的敏感字段。
  String _redactText(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map || decoded is List) {
        return jsonEncode(_redact(decoded));
      }
    } catch (_) {
      // 普通文本继续使用字段与 Bearer 规则处理。
    }
    final sensitiveField = RegExp(
      r'("?(?:authorization|cookie|set-cookie|idtoken|accesstoken|refreshtoken|signedtransaction|signedrenewalinfo|purchasetoken|receipt)"?\s*[:=]\s*)("[^"]*"|[^&,\s}\]]+)',
      caseSensitive: false,
    );
    final bearer = RegExp(r'Bearer\s+[^\s,]+', caseSensitive: false);
    return value
        .replaceAllMapped(
          sensitiveField,
          (match) => '${match.group(1)}<redacted>',
        )
        .replaceAll(bearer, 'Bearer <redacted>');
  }

  String _safeUri(RequestOptions options) {
    final safeQuery = _redact(options.queryParameters);
    return options.uri
        .replace(
          queryParameters: safeQuery is Map
              ? safeQuery.map((key, value) => MapEntry('$key', '$value'))
              : null,
        )
        .toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '→ ${options.method} ${_safeUri(options)}\n'
      'headers: ${_redact(options.headers)}\n'
      'data: ${_redact(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '← ${response.statusCode} ${_safeUri(response.requestOptions)}\n'
      'data: ${_redact(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✗ ${err.requestOptions.method} ${_safeUri(err.requestOptions)}\n'
      'status: ${err.response?.statusCode}\n'
      'data: ${_redact(err.response?.data)}\n'
      'message: ${_redact(err.message)}',
    );
    handler.next(err);
  }
}

/// 将 [DioException] 统一映射为业务侧 [ApiException]。
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _map(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  ApiException _map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('网络连接超时');
      case DioExceptionType.cancel:
        return const CancelException('请求已取消');
      case DioExceptionType.connectionError:
        return const NetworkException('网络连接失败');
      case DioExceptionType.badCertificate:
        return const NetworkException('证书校验失败');
      case DioExceptionType.badResponse:
        return _mapStatus(err);
      default:
        if (err.response == null) {
          return const NetworkException('网络不可用，请检查网络连接');
        }
        return UnknownException(err.message ?? '未知错误');
    }
  }

  ApiException _mapStatus(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final message = apiErrorMessageOf(data) ?? err.message ?? '请求失败';

    switch (status) {
      case 400:
        return BadRequestException(message, data: data);
      case 401:
        return UnauthorizedException(message, data: data);
      case 403:
        return ForbiddenException(message, data: data);
      case 404:
        return NotFoundException(message, data: data);
      case 409:
        return ConflictException(message, data: data);
      default:
        if (status != null && status >= 500) {
          return ServerException(message, statusCode: status, data: data);
        }
        return UnknownException(message, statusCode: status, data: data);
    }
  }
}
```

### `lib/common/network/network_service.dart`

```dart
/// 文件作用：
/// - [ApiClient]：包一层 Dio，只暴露业务需要的 get / post / patch / delete
/// - [NetworkService]：按 [ApiSource] 懒加载并缓存各来源的 [ApiClient]
library;

import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart' hide Response;
import 'package:native_dio_adapter/native_dio_adapter.dart';

import '../services/index.dart';
import '../values/index.dart';
import 'interceptors.dart';
import 'network_config.dart';

/// 请求客户端，屏蔽 Dio 细节，方便测试替换。
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// 图片代理下载复用鉴权和平台适配器；禁止重定向携带凭证离开代理。
  Future<Response<ResponseBody>> getImageStream(
    String url, {
    Map<String, String>? headers,
  }) {
    // 没配 BASE_URL 时不打代理，避免空 origin 解析崩溃。
    if (!AppConfig.hasBaseUrl) {
      throw StateError('未配置 BASE_URL，跳过图片代理下载');
    }
    final target = Uri.parse(url);
    final base = Uri.parse(_dio.options.baseUrl);
    if (target.origin != base.origin || target.path != AppConfig.proxyImagePath) {
      throw ArgumentError('图片下载仅允许当前后端的 ${AppConfig.proxyImagePath}');
    }
    return _dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        headers: {...?headers, 'Accept': 'image/*'},
        followRedirects: false,
        validateStatus: (status) =>
            status == 200 || status == 202 || status == 304,
      ),
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: headers == null ? null : Options(headers: headers),
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}

/// 多来源网络入口。
///
/// 业务 API 只依赖取到的 [ApiClient]，不感知 Dio 与拦截器装配。
class NetworkService extends GetxService {
  NetworkService({
    required TokenService tokenService,
    required this.sessionService,
  }) : _tokenService = tokenService;

  final TokenService _tokenService;

  final SessionService sessionService;

  final _clients = <ApiSource, ApiClient>{};

  /// 取指定来源的请求客户端（首次调用时创建并缓存）
  ApiClient client(ApiSource source) {
    return _clients[source] ??= ApiClient(
      _createDio(NetworkEndpoints.of(source)),
    );
  }

  /// 主业务后端快捷入口
  ApiClient get app => client(ApiSource.app);

  /// 取指定来源的 baseUrl（拼图片代理等直链场景）
  String baseUrlOf(ApiSource source) => NetworkEndpoints.of(source).baseUrl;

  Dio _createDio(NetworkEndpoint endpoint) {
    final dio = Dio(_baseOptions(endpoint));

    // 用于刷新 Token 与失败重放，不挂拦截器避免递归
    final refreshDio = Dio(_baseOptions(endpoint));

    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      final adapter = NativeAdapter();
      dio.httpClientAdapter = adapter;
      refreshDio.httpClientAdapter = adapter;
    }

    dio.interceptors.addAll([
      if (endpoint.requiresAuth)
        AuthInterceptor(
          tokenStorage: _tokenService,
          sessionService: sessionService,
          refreshDio: refreshDio,
        ),
      if (endpoint.enableLogging) LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  BaseOptions _baseOptions(NetworkEndpoint endpoint) {
    return BaseOptions(
      baseUrl: endpoint.baseUrl,
      connectTimeout: endpoint.connectTimeout,
      receiveTimeout: endpoint.receiveTimeout,
      sendTimeout: endpoint.sendTimeout,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      headers: {...endpoint.headers},
    );
  }
}
```

### `lib/common/network/index.dart`

```dart
// 网络功能入口：导出请求服务、拦截器和异常类型。
export 'api_exception.dart';
export 'interceptors.dart';
export 'network_config.dart';
export 'network_service.dart';
```

### `lib/common/cache/proxy_image_file_service.dart`

```dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../network/index.dart';

/// 将图片缓存下载接入业务网络链，复用原生 TLS 与 token 刷新。
class ProxyImageFileService extends FileService {
  ProxyImageFileService(this.client);

  final ApiClient client;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    // 只转发缓存条件头；Bearer 由鉴权拦截器读取最新值。
    final cacheHeaders = <String, String>{
      for (final entry in (headers ?? <String, String>{}).entries)
        if (entry.key.toLowerCase() == 'if-none-match') entry.key: entry.value,
    };
    final response = await client.getImageStream(url, headers: cacheHeaders);
    return _ProxyImageResponse(response);
  }
}

/// 保留响应流与缓存元数据，304 时由缓存库继续使用原文件。
class _ProxyImageResponse implements FileServiceResponse {
  _ProxyImageResponse(this.response) : receivedAt = DateTime.now();

  final Response<ResponseBody> response;
  final DateTime receivedAt;

  @override
  Stream<List<int>> get content => response.data!.stream;

  @override
  int? get contentLength => int.tryParse(
    response.headers.value(HttpHeaders.contentLengthHeader) ?? '',
  );

  @override
  int get statusCode => response.statusCode!;

  @override
  String? get eTag => response.headers.value(HttpHeaders.etagHeader);

  @override
  DateTime get validTill {
    final directives =
        (response.headers.value(HttpHeaders.cacheControlHeader) ?? '')
            .toLowerCase()
            .split(',')
            .map((value) => value.trim());
    if (directives.contains('no-cache') || directives.contains('no-store')) {
      return receivedAt;
    }
    var seconds = const Duration(days: 7).inSeconds;
    for (final directive in directives) {
      if (directive.startsWith('max-age=')) {
        seconds = int.tryParse(directive.substring(8).replaceAll('"', '')) ?? 0;
      }
    }
    return receivedAt.add(Duration(seconds: seconds < 0 ? 0 : seconds));
  }

  @override
  String get fileExtension {
    final mime = response.headers
        .value(HttpHeaders.contentTypeHeader)
        ?.split(';')
        .first
        .trim()
        .toLowerCase();
    return switch (mime) {
      'image/jpeg' => '.jpg',
      'image/png' => '.png',
      'image/webp' => '.webp',
      'image/gif' => '.gif',
      'image/avif' => '.avif',
      _ => '',
    };
  }
}
```

### `lib/common/cache/proxy_image_cache_manager.dart`

```dart
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../network/index.dart';
import 'proxy_image_file_service.dart';

/// 文件作用：
/// - 为 `/api/files/img` 代理图提供客户端磁盘缓存
/// - 供 [ProxyAvatar] / [ProxyThumbnail] 的 `CachedNetworkImage` 使用
///
/// 策略：
/// - `stalePeriod: 7d`：对齐服务端 `Cache-Control: max-age=604800`
/// - `maxNrOfCacheObjects: 800`：CacheManager 无字节上限 API，用对象数约束
/// - cache key = 代理完整 URL（含 `url=`），与 Bearer token 解耦；刷新 token 不重复下载
///
/// ⚠️ 注意：单例；登出须 [emptyCache]，避免换账号看到上一用户封面命中。
class ProxyImageCacheManager {
  ProxyImageCacheManager._();

  static const _key = 'proxy_images';

  static final CacheManager instance = CacheManager(
    Config(
      _key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 800,
      // 懒初始化时网络服务已注册；图片复用业务 API 的原生网络适配器。
      fileService: ProxyImageFileService(Get.find<NetworkService>().app),
    ),
  );

  /// 清空磁盘图库（由 [SessionService] 登出时调用）。
  static Future<void> emptyCache() => instance.emptyCache();
}
```

### `lib/common/cache/index.dart`

```dart
// 缓存功能入口：导出图片缓存与缓存文件服务。
export 'proxy_image_cache_manager.dart';
export 'proxy_image_file_service.dart';
```

### `lib/common/api/auth_api.dart`

```dart
import 'package:dio/dio.dart';

import '../models/index.dart';
import '../network/index.dart';
import '../values/index.dart';

/// 文件作用：
/// - 邮箱密码登录；无 BASE_URL 时签发本地假会话
/// - 有后端时解信封 `{ code, message, data }`
class AuthApi {
  AuthApi(this._apiClient);

  final ApiClient _apiClient;

  /// 登录。未配后端时不发网，直接返回假 token。
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (!AppConfig.hasBaseUrl) {
      return _localSession(email);
    }
    final resp = await _apiClient.post(
      AppConfig.authLoginPath,
      data: {'email': email, 'password': password},
    );
    return AuthSession.fromApiJson(_unwrap(resp));
  }

  /// 刷新。未配后端时不发网。
  Future<AuthSession> refresh(String refreshToken) async {
    if (!AppConfig.hasBaseUrl) {
      return _localSession('local@scaffold.app');
    }
    final resp = await _apiClient.post(
      AppConfig.authRefreshPath,
      data: {'refreshToken': refreshToken},
    );
    return AuthSession.fromApiJson(_unwrap(resp));
  }

  /// 本地假会话，满足 [TokenService.hasToken] 的 userId + accessToken。
  AuthSession _localSession(String email) {
    final normalized = email.trim();
    return AuthSession(
      accessToken: 'scaffold-access-token',
      refreshToken: 'scaffold-refresh-token',
      user: AuthUser(id: 'local-user', email: normalized),
    );
  }

  /// 解信封；code != 0 抛 [BadRequestException]。
  Map<String, dynamic> _unwrap(Response<dynamic> resp) {
    final body = resp.data;
    if (body is! Map<String, dynamic>) {
      throw const UnknownException('响应格式异常');
    }
    if (body['code'] != 0) {
      throw BadRequestException(
        body['message'] as String? ?? '请求失败',
        data: body['data'],
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const UnknownException('响应缺少 data 字段');
    }
    return data;
  }
}
```

### `lib/common/api/index.dart`

```dart
// API 入口。
export 'auth_api.dart';
```

### `lib/common/i18n/translation_keys.dart`

```dart
/// 应用翻译键，避免页面散落字面量。
abstract final class TrKeys {
  // 引导页及首页设置菜单文案。
  static const next = 'next';
  static const welcomeThemeTitle = 'welcomeThemeTitle';
  static const welcomeThemeBody = 'welcomeThemeBody';
  static const welcomeReadyTitle = 'welcomeReadyTitle';
  static const welcomeReadyBody = 'welcomeReadyBody';
  static const switchLanguage = 'switchLanguage';
  static const themeLight = 'themeLight';
  static const themeDark = 'themeDark';
  static const themeSystem = 'themeSystem';

  // 通用组件操作与加载文案。
  static const cancel = 'cancel';
  static const delete = 'delete';
  static const processing = 'processing';
  static const retry = 'retry';
  static const initializationFailed = 'initializationFailed';
  static const welcomeTitle = 'welcomeTitle';
  static const welcomeBody = 'welcomeBody';
  static const start = 'start';
  static const loginTitle = 'loginTitle';
  static const email = 'email';
  static const password = 'password';
  static const loginAction = 'loginAction';
  static const loginFailed = 'loginFailed';
  static const emailRequired = 'emailRequired';
  static const passwordRequired = 'passwordRequired';
  static const homeTitle = 'homeTitle';
  static const switchTheme = 'switchTheme';
  static const signOut = 'signOut';
}
```

### `lib/common/i18n/translations/en_us_translations.dart`

```dart
/// 英语文案。
const enUsTranslations = <String, String>{
  'next': 'Next',
  'welcomeThemeTitle': 'Make it yours',
  'welcomeThemeBody': 'Switch theme and language from Home.',
  'welcomeReadyTitle': 'Ready to start',
  'welcomeReadyBody': 'Sign in with the prefilled demo account.',
  'switchLanguage': 'Language',
  'themeLight': 'Light',
  'themeDark': 'Dark',
  'themeSystem': 'System',

  'cancel': 'Cancel',
  'delete': 'Delete',
  'processing': 'Processing',
  'retry': 'Retry',
  'initializationFailed': 'Startup failed',
  'welcomeTitle': 'Welcome',
  'welcomeBody': 'A GetX starter with go_router and Dio.',
  'start': 'Get started',
  'loginTitle': 'Sign in',
  'email': 'Email',
  'password': 'Password',
  'loginAction': 'Sign in',
  'loginFailed': 'Sign in failed',
  'emailRequired': 'Enter your email',
  'passwordRequired': 'Enter your password',
  'homeTitle': 'Home',
  'switchTheme': 'Theme',
  'signOut': 'Sign out',
};
```

### `lib/common/i18n/translations/zh_cn_translations.dart`

```dart
/// 简体中文文案。
const zhCnTranslations = <String, String>{
  'next': '下一页',
  'welcomeThemeTitle': '选择你的外观',
  'welcomeThemeBody': '在首页切换主题和语言。',
  'welcomeReadyTitle': '准备开始',
  'welcomeReadyBody': '使用预填的演示账号登录体验。',
  'switchLanguage': '语言',
  'themeLight': '浅色',
  'themeDark': '深色',
  'themeSystem': '跟随系统',

  'cancel': '取消',
  'delete': '删除',
  'processing': '处理中',
  'retry': '重试',
  'initializationFailed': '启动失败',
  'welcomeTitle': '欢迎',
  'welcomeBody': 'GetX + go_router + Dio 脚手架。',
  'start': '开始',
  'loginTitle': '登录',
  'email': '邮箱',
  'password': '密码',
  'loginAction': '登录',
  'loginFailed': '登录失败',
  'emailRequired': '请输入邮箱',
  'passwordRequired': '请输入密码',
  'homeTitle': '首页',
  'switchTheme': '主题',
  'signOut': '退出登录',
};
```

### `lib/common/i18n/translations/zh_tw_translations.dart`

```dart
/// 繁体中文文案。
const zhTwTranslations = <String, String>{
  'next': '下一頁',
  'welcomeThemeTitle': '選擇你的外觀',
  'welcomeThemeBody': '在首頁切換主題和語言。',
  'welcomeReadyTitle': '準備開始',
  'welcomeReadyBody': '使用預填的示範帳號登入體驗。',
  'switchLanguage': '語言',
  'themeLight': '淺色',
  'themeDark': '深色',
  'themeSystem': '跟隨系統',

  'cancel': '取消',
  'delete': '刪除',
  'processing': '處理中',
  'retry': '重試',
  'initializationFailed': '啟動失敗',
  'welcomeTitle': '歡迎',
  'welcomeBody': 'GetX + go_router + Dio 腳手架。',
  'start': '開始',
  'loginTitle': '登入',
  'email': '電子郵件',
  'password': '密碼',
  'loginAction': '登入',
  'loginFailed': '登入失敗',
  'emailRequired': '請輸入電子郵件',
  'passwordRequired': '請輸入密碼',
  'homeTitle': '首頁',
  'switchTheme': '主題',
  'signOut': '登出',
};
```

### `lib/common/i18n/translations/index.dart`

```dart
// 三语词条入口。
export 'en_us_translations.dart';
export 'zh_cn_translations.dart';
export 'zh_tw_translations.dart';
```

### `lib/common/i18n/app_translations.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'translations/index.dart';

/// GetX 三语翻译资源。英语是缺失配置和未知 key 的回退语言。
class AppTranslations extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  static const supportedLocales = [
    fallbackLocale,
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  @override
  Map<String, Map<String, String>> get keys => const {
    'en_US': enUsTranslations,
    'zh_CN': zhCnTranslations,
    'zh_TW': zhTwTranslations,
  };
}

/// 在未装配 GetMaterialApp 的独立组件测试中保留传入的默认文案。
String trOr(String key, String fallback) =>
    Get.locale == null ? fallback : key.tr;
```

### `lib/common/i18n/index.dart`

```dart
// 国际化入口。
export 'app_translations.dart';
export 'translation_keys.dart';
```

### `lib/common/routers/routes.dart`

```dart
/// 路由常量表，集中定义路径减少拼写错误。
abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const home = '/home';
}
```

### `lib/common/routers/router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../pages/index.dart';
import '../services/index.dart';
import 'routes.dart';

/// 文件作用：
/// - GoRouter 表与登录分流
///
/// ⚠️ [router] 是 `static final`，首次访问时 [Global.init] 必须已完成。
///
/// redirect：
/// 1. splash 放行
/// 2. 未看 welcome → welcome
/// 3. 未登录 → login
/// 4. 已登录别停 login → home
class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: Get.find<SessionService>().revision,
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      final onSplash = location == AppRoutes.splash;
      final onWelcome = location == AppRoutes.welcome;
      final onLogin = location == AppRoutes.login;
      final hasSeenWelcome = Get.find<AppLaunchService>().hasSeenWelcome;
      final isLoggedIn = Get.find<TokenService>().hasToken;

      if (onSplash) return null;

      if (!hasSeenWelcome) {
        return onWelcome ? null : AppRoutes.welcome;
      }

      if (onWelcome) {
        return isLoggedIn ? AppRoutes.home : AppRoutes.login;
      }

      if (!isLoggedIn) {
        return onLogin ? null : AppRoutes.login;
      }

      if (onLogin) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
    ],
  );
}
```

### `lib/common/routers/index.dart`

```dart
// 路由入口。
export 'router.dart';
export 'routes.dart';
```

### `lib/common/widgets/**`

使用 [`../assets/lib/common/widgets/`](../assets/lib/common/widgets/) 全量源码，递归复制或合并，包含 `form/` 和各级入口。旧版 `page_scaffold.dart`、`primary_button.dart`、`app_form_field.dart` 不再生成，对应类型已位于 `scaffold.dart`、`button.dart`、`input.dart`。

### `docs/组件说明.html`

将 [`../assets/docs/组件说明.html`](../assets/docs/组件说明.html) 写入目标项目同名路径，替换 `{{package_name}}`。浏览器标题与页面主标题均为 `DucafeUI`，保留全部离线样式与交互。

### `docs/样式规范.html`

将 [`../assets/docs/样式规范.html`](../assets/docs/样式规范.html) 写入目标项目 `docs/样式规范.html`，执行完成前必须生成，不能只引用技能内文件。将 `{{package_name}}` 替换为目标项目包名；浏览器标题为 `DucafeUI · 样式规范`，主标题为 `DucafeUI 样式规范`。保留完整离线样式、目录、颜色预览、主题切换、代码复制与打印功能。

按 `SKILL.md` 的文档流程核对最终源码并适配相对链接：未落地的工具或 token 不写成已有能力，不存在的 Markdown、设计稿和测试链接改为普通说明，相关原文和页脚一并调整。已有文档合并保留用户内容。

### `lib/common/components/index.dart`

```dart
// 带业务语义的共享组件入口。脚手架暂无实现。
```

### `lib/common/utils/index.dart`

```dart
// 工具入口。脚手架暂无独立工具。
```

### `lib/common/index.dart`

```dart
// 公共功能总入口，只导出各子目录 index.dart。
export 'api/index.dart';
export 'cache/index.dart';
export 'components/index.dart';
export 'extension/index.dart';
export 'i18n/index.dart';
export 'models/index.dart';
export 'network/index.dart';
export 'routers/index.dart';
export 'services/index.dart';
export 'style/index.dart';
export 'utils/index.dart';
export 'values/index.dart';
export 'widgets/index.dart';
```

### `lib/pages/splash/splash_controller.dart`

```dart
import 'package:get/get.dart';

/// 启动页占位 Controller；分流在 [SplashPage]，不在这里。
class SplashController extends GetxController {}
```

### `lib/pages/splash/splash_page.dart`

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';
import 'splash_controller.dart';

/// 启动页：展示应用名，首帧显示后固定停留 0.5 秒，再按 welcome / token 分流。
///
/// Get.put / Get.delete 配对。跳转只用 context.go。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Get.put(SplashController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 从应用名实际显示的首帧开始计时，离开页面时取消。
      _timer = Timer(const Duration(milliseconds: 500), _goNext);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    Get.delete<SplashController>();
    super.dispose();
  }

  /// 未看 welcome → welcome；有 token → home；否则 login。
  void _goNext() {
    if (!mounted) return;
    final hasSeenWelcome = Get.find<AppLaunchService>().hasSeenWelcome;
    final hasToken = Get.find<TokenService>().hasToken;
    if (!hasSeenWelcome) {
      context.go(AppRoutes.welcome);
    } else if (hasToken) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppConfig.appName, style: AppTextStyles.displayOn(context)),
      ),
    );
  }
}
```

### `lib/pages/splash/index.dart`

```dart
export 'splash_controller.dart';
export 'splash_page.dart';
```

### `lib/pages/welcome/welcome_controller.dart`

```dart
import 'package:get/get.dart';

import '../../common/index.dart';

/// 三页引导状态；仅最后一页允许持久化完成标记。
class WelcomeController extends GetxController {
  static const idBody = 'body';
  int pageIndex = 0;
  bool busy = false;
  String? error;

  void onPageChanged(int index) {
    pageIndex = index;
    update([idBody]);
  }

  /// 写入成功才允许 Page 跳转；失败保留引导并允许重试。
  Future<bool> complete() async {
    if (busy || pageIndex != 2) return false;
    busy = true;
    error = null;
    update([idBody]);
    try {
      await Get.find<AppLaunchService>().markWelcomeSeen();
      return true;
    } catch (exception) {
      error = userFacingErrorMessage(exception);
      return false;
    } finally {
      busy = false;
      if (!isClosed) update([idBody]);
    }
  }
}
```

### `lib/pages/welcome/welcome_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';
import 'welcome_controller.dart';

/// 三页 PageView 引导，最后一页显示「开始」。
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late final WelcomeController _c;
  final _pages = PageController();

  @override
  void initState() {
    super.initState();
    _c = Get.put(WelcomeController());
  }

  @override
  void dispose() {
    _pages.dispose();
    Get.delete<WelcomeController>();
    super.dispose();
  }

  Future<void> _onStart() async {
    final ok = await _c.complete();
    if (!ok || !mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      (TrKeys.welcomeTitle.tr, TrKeys.welcomeBody.tr),
      (TrKeys.welcomeThemeTitle.tr, TrKeys.welcomeThemeBody.tr),
      (TrKeys.welcomeReadyTitle.tr, TrKeys.welcomeReadyBody.tr),
    ];
    return PageScaffold(
      body: GetBuilder<WelcomeController>(
        id: WelcomeController.idBody,
        builder: (c) => Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: c.onPageChanged,
                // 保存完成标记时保持在最后一页。
                physics: c.busy ? const NeverScrollableScrollPhysics() : null,
                children: [
                  for (final slide in slides)
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.$1,
                            style: AppTextStyles.displayOn(context),
                          ),
                          const SizedBox(height: 12),
                          Text(slide.$2, style: AppTextStyles.bodyOn(context)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Text('${c.pageIndex + 1} / ${slides.length}'),
            if (c.error != null) Text(c.error!),
            const SizedBox(height: 16),
            if (c.pageIndex == slides.length - 1)
              PrimaryButton(
                label: TrKeys.start.tr,
                loading: c.busy,
                onPressed: _onStart,
              )
            else
              PrimaryButton(
                label: TrKeys.next.tr,
                onPressed: () => _pages.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
```

### `lib/pages/welcome/index.dart`

```dart
export 'welcome_controller.dart';
export 'welcome_page.dart';
```

### `lib/pages/login/login_controller.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';

/// 登录页状态：邮箱密码校验、请求中、错误文案。
class LoginController extends GetxController {
  static const idForm = 'form';

  /// 从统一配置预填演示账号，用户仍可编辑。
  final email = TextEditingController(text: AppConfig.demoEmail);
  final password = TextEditingController(text: AppConfig.demoPassword);

  String? emailError;
  String? passwordError;
  String? formError;
  bool loading = false;

  /// 成功返回 true；跳转由 Page / redirect 处理。
  Future<bool> submit() async {
    if (loading) return false;
    emailError = email.text.trim().isEmpty ? TrKeys.emailRequired.tr : null;
    passwordError = password.text.isEmpty ? TrKeys.passwordRequired.tr : null;
    formError = null;
    if (emailError != null || passwordError != null) {
      update([idForm]);
      return false;
    }

    loading = true;
    update([idForm]);
    try {
      final session = await Get.find<AuthApi>().login(
        email: email.text.trim(),
        password: password.text,
      );
      await Get.find<SessionService>().establish(
        userId: session.user.id,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return true;
    } catch (error) {
      formError = userFacingErrorMessage(
        error,
        fallback: TrKeys.loginFailed.tr,
      );
      return false;
    } finally {
      loading = false;
      update([idForm]);
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
```

### `lib/pages/login/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'login_controller.dart';

/// 登录页：邮箱 + 密码。成功后靠 Session revision 进 Home。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    Get.put(LoginController());
  }

  @override
  void dispose() {
    Get.delete<LoginController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      scrollable: true,
      body: GetBuilder<LoginController>(
        id: LoginController.idForm,
        builder: (c) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                TrKeys.loginTitle.tr,
                style: AppTextStyles.displayOn(context),
              ),
              const SizedBox(height: 24),
              // 原生字段复用统一主题，并保留邮箱键盘与密码遮蔽能力。
              TextField(
                controller: c.email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: TrKeys.email.tr,
                  errorText: c.emailError,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: c.password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: TrKeys.password.tr,
                  errorText: c.passwordError,
                ),
              ),
              if (c.formError != null) ...[
                const SizedBox(height: 12),
                Text(
                  c.formError!,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appErrorText,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: TrKeys.loginAction.tr,
                loading: c.loading,
                onPressed: c.submit,
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### `lib/pages/login/index.dart`

```dart
export 'login_controller.dart';
export 'login_page.dart';
```

### `lib/pages/home/home_controller.dart`

```dart
import 'package:get/get.dart';

import '../../common/index.dart';

/// 首页：退出登录。主题切换留在 Page（需要 BuildContext）。
class HomeController extends GetxController {
  static const idBody = 'body';

  bool busy = false;

  Future<void> signOut() async {
    if (busy) return;
    busy = true;
    update([idBody]);
    await Get.find<SessionService>().invalidate();
    busy = false;
    update([idBody]);
  }
}
```

### `lib/pages/home/home_page.dart`

```dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'home_controller.dart';

/// 单页首页：右上角主题、语言按钮分别打开底部菜单，不含业务 Tab 壳。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Get.put(HomeController());
  }

  @override
  void dispose() {
    Get.delete<HomeController>();
    super.dispose();
  }

  /// 菜单通过自己的 Navigator 返回选择，关闭后再更新应用主题。
  Future<void> _chooseTheme() async {
    final theme = AdaptiveTheme.of(context);
    final selected = await showModalBottomSheet<AdaptiveThemeMode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in [
              (AdaptiveThemeMode.light, TrKeys.themeLight.tr),
              (AdaptiveThemeMode.dark, TrKeys.themeDark.tr),
              (AdaptiveThemeMode.system, TrKeys.themeSystem.tr),
            ])
              ListTile(
                title: Text(option.$2),
                selected: theme.mode == option.$1,
                onTap: () => Navigator.of(sheetContext).pop(option.$1),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    switch (selected) {
      case AdaptiveThemeMode.light:
        theme.setLight();
      case AdaptiveThemeMode.dark:
        theme.setDark();
      case AdaptiveThemeMode.system:
        theme.setSystem();
    }
  }

  /// 使用 LocaleService 持久化语言，Get.updateLocale 负责刷新翻译。
  Future<void> _chooseLanguage() async {
    final service = Get.find<LocaleService>();
    final selected = await showModalBottomSheet<Locale>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in const [
              (Locale('en', 'US'), 'English (en)'),
              (Locale('zh', 'CN'), '简体中文 (zh-CN)'),
              (Locale('zh', 'TW'), '繁體中文 (zh-TW)'),
            ])
              ListTile(
                title: Text(option.$2),
                selected: service.locale == option.$1,
                onTap: () => Navigator.of(sheetContext).pop(option.$1),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    try {
      await service.change(selected);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      topBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(TrKeys.homeTitle.tr),
        actions: [
          IconButton(
            tooltip: TrKeys.switchTheme.tr,
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: _chooseTheme,
          ),
          IconButton(
            tooltip: TrKeys.switchLanguage.tr,
            icon: const Icon(Icons.language),
            onPressed: _chooseLanguage,
          ),
        ],
      ),
      body: GetBuilder<HomeController>(
        id: HomeController.idBody,
        builder: (c) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            PrimaryButton(
              label: TrKeys.signOut.tr,
              loading: c.busy,
              onPressed: c.signOut,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
```

### `lib/pages/home/index.dart`

```dart
export 'home_controller.dart';
export 'home_page.dart';
```

### `lib/pages/index.dart`

```dart
// 页面总入口：只导出各模块页面与控制器。
export 'home/index.dart';
export 'login/index.dart';
export 'splash/index.dart';
export 'welcome/index.dart';
```

### `lib/global.dart`

```dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'common/index.dart';

/// 文件作用：
/// - 启动期依赖注入（Get.put / putAsync / lazyPut）
/// - 顺序：Storage → Locale → Token/Session → Network → AuthApi
class Global {
  /// AdaptiveTheme 持久化主题，启动期读一次交给 [App]。
  static AdaptiveThemeMode? savedThemeMode;

  /// 绑定引擎、主题，并按依赖顺序注册 GetX 服务。
  ///
  /// ⚠️ [StorageService.init] / [LocaleService.init] 必须 return this。
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    savedThemeMode = await AdaptiveTheme.getThemeMode();

    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => LocaleService(Get.find()).init());
    Get.put(TokenService(Get.find()));
    Get.put(AppLaunchService(Get.find()));
    Get.put(SessionService(Get.find<TokenService>()));

    Get.put(
      NetworkService(
        tokenService: Get.find<TokenService>(),
        sessionService: Get.find<SessionService>(),
      ),
    );

    Get.lazyPut(() => AuthApi(Get.find<NetworkService>().app));
  }
}
```

### `lib/main.dart`

```dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'common/index.dart';
import 'global.dart';

/// Flutter 入口：先渲染 [AppBootstrap]，再异步 [Global.init]。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

/// 可渲染的启动根组件，区分加载、失败和就绪。
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.initialize, this.readyBuilder});

  /// 测试可注入初始化；生产用 [Global.init]。
  final Future<void> Function()? initialize;

  /// 测试可替换就绪页。
  final WidgetBuilder? readyBuilder;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  Object? _error;
  bool _ready = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await (widget.initialize ?? Global.init)();
      if (!mounted) return;
      setState(() {
        _ready = true;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.readyBuilder?.call(context) ?? const App();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: AppTranslations.fallbackLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      supportedLocales: AppTranslations.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _loading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        TrKeys.initializationFailed.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_error.toString(), textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _initialize,
                        child: Text(TrKeys.retry.tr),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// 根组件：亮暗主题 + GoRouter。
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: Global.savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return GetMaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: Get.isRegistered<LocaleService>()
              ? Get.find<LocaleService>().locale
              : AppTranslations.fallbackLocale,
          fallbackLocale: AppTranslations.fallbackLocale,
          supportedLocales: AppTranslations.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: theme,
          darkTheme: darkTheme,
          builder: (context, child) {
            ScreenUtil.init(
              context,
              designSize: Size(
                AppConfig.ui.designWidth,
                AppConfig.ui.designHeight,
              ),
            );
            return child ?? const SizedBox.shrink();
          },
          routerDelegate: AppRouter.router.routerDelegate,
          routeInformationParser: AppRouter.router.routeInformationParser,
          routeInformationProvider: AppRouter.router.routeInformationProvider,
          backButtonDispatcher: AppRouter.router.backButtonDispatcher,
        );
      },
    );
  }
}
```

### `test/widget_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{package_name}}/main.dart';

/// 冒烟：根组件能挂上。把 {{package_name}} 换成 pubspec 的 name。
///
/// 注入空 initialize，避免测试里跑真实 SharedPreferences / GetX 装配。
void main() {
  testWidgets('AppBootstrap smoke', (tester) async {
    await tester.pumpWidget(
      AppBootstrap(initialize: () async {}, readyBuilder: (_) => const SizedBox()),
    );
    await tester.pump();
    expect(find.byType(AppBootstrap), findsOneWidget);
  });
}
```

## Acceptance criteria

落地后应满足：

- `docs/组件说明.html` 与 `docs/样式规范.html` 均已写入，标题、包名、源码说明和相对链接已核对。

1. `lib/common` 13 个子目录与 `index.dart` 都在，导包规则与 SKILL.md 一致。
2. `extension` / `network` / `cache` 按本模板全文存在。
3. `AppConfig.baseUrl` 默认空；未配后端时邮箱密码登录写入本地假 token，refresh / 代理不发网。
4. `Global.init` 完成后才能访问 `AppRouter.router`。
5. Splash 展示应用名，首帧后固定 500ms 再 `context.go` 分流；Welcome 为三页 `PageView`，仅最后一页「开始」写欢迎标记再进 Login；Login 预填 `AppConfig.demoEmail` / `demoPassword`，成功建立会话后由 revision 驱动 redirect 进 Home。
6. 页面 Controller `initState` put、`dispose` delete；`update` 带 id；禁止 GetX 路由 API。
7. `dart run build_runner build --delete-conflicting-outputs` 能生成 Freezed 文件。
8. `flutter analyze` 与 `flutter test` 可跑，或写明阻塞。
9. Home 为单页，右上角两个按钮分别用 `showModalBottomSheet` 切主题（浅色 / 深色 / 跟随系统）和语言（en / zh-CN / zh-TW），以 `Navigator.of(sheetContext).pop` 关闭，禁止 `Get.back`；不生成 `StatefulShellRoute` 或 Tab 壳。

### `lib/common/style/app_glass.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 玻璃参数入口；颜色与阴影由AppStyle供给，避免与Material主题分叉。
abstract final class AppGlass {
  static const double blurHeader = 22;
  static const double blurLight = 10;
  static List<Color> headerGradientOf(BuildContext context) =>
      context.appStyle.headerGradient;
  static Color borderOf(BuildContext context) => context.appStyle.glassBorder;
  static Color cardFillOf(BuildContext context) => context.appCard;
  static Color chipFillOf(BuildContext context) => context.appMuted;
  static Color sheetFillOf(BuildContext context) => context.appSurface;
  static Color iconFillOf(BuildContext context) => context.appCard;
  static List<BoxShadow> softShadowOf(BuildContext context) =>
      context.appStyle.cardShadow;
  static List<BoxShadow> sheetShadowOf(BuildContext context) =>
      context.appStyle.sheetShadow;
}
```

### `lib/common/style/app_media_colors.dart`

```dart
import 'package:flutter/material.dart';

/// 图片遮罩和播放器局部暗色独立于亮暗主题，避免主色污染视频内容。
abstract final class AppMediaColors {
  static const background = Color(0xFF17150F);
  static const black = Colors.black;
  static const foreground = Colors.white;
  static const secondary = Colors.white70;
  static const caption = Colors.white60;
  static const border = Colors.white12;
  static const track = Colors.white24;
  static const progress = Colors.redAccent;
  static const scrim = Color(0xCC000000);
  static const headerScrim = Color(0x99000000);
  static const transparent = Color(0x00000000);
  static const watchLater = Color(0xFFEF8A4E);
}

/// 品牌登录例外集中定义，页面和按钮不再内联品牌HEX。
abstract final class AppBrandColors {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const googleDark = Color(0xFF131314);
  static const googleOnDark = Color(0xFFE3E3E3);
  static const googleOnLight = Color(0xFF1A1A1A);
  static const googleDarkBorder = Color(0xFF8E918F);
  static const googleLightBorder = Color(0xFFDDDDDD);
  static const googleMark = Color(0xFF4285F4);
}
```

### `lib/common/values/adaptive_spacing.dart`

```dart
/// 文件作用：
/// - 页面留白节奏（xs ~ xxl）
///
/// 间距 token。
///
/// 页面布局优先使用这些尺寸，保证列表、卡片、表单之间的留白节奏一致。
abstract final class AppSpacing {
  /// App布局基准，区别于HTML文档的桌面展示留白。
  static const double page = 20;
  static const double card = 16;
  static const double sheetTop = 14;
  static const double sheetBottom = 30;
  static const double touch = 48;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}
```
