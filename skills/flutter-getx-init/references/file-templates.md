## 文件模板
## Contents
- `lib/common/values` `style` `models` `services`
- `lib/common/network` `cache` `api` `i18n` `routers` `widgets`
- splash / welcome / login / home、`global.dart`、`main.dart`
- 把 `{{package_name}}` 换成目标项目 `pubspec.yaml` 的 `name`

### `lib/common/values/app_config.dart`

```dart
/// 文件作用：
/// - App 名称与网络占位配置
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

  /// 是否已配置可访问的后端。
  static bool get hasBaseUrl => baseUrl.trim().isNotEmpty;
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
// 样式功能入口。
export '../values/index.dart';
export 'app_colors.dart';
export 'app_radius.dart';
export 'app_text_styles.dart';
export 'app_theme.dart';
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
      return await sessionService.updateCredentials(
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
    required this.tokenService,
    required this.sessionService,
  });

  final TokenService tokenService;

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
          tokenStorage: tokenService,
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
  // 引导页文案。
  static const next = 'next';
  static const welcomeThemeTitle = 'welcomeThemeTitle';
  static const welcomeThemeBody = 'welcomeThemeBody';
  static const welcomeReadyTitle = 'welcomeReadyTitle';
  static const welcomeReadyBody = 'welcomeReadyBody';

  // 启动与登录文案。
  static const initializationFailed = 'initializationFailed';
  static const retry = 'retry';
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
  static const switchLanguage = 'switchLanguage';
  static const themeLight = 'themeLight';
  static const themeDark = 'themeDark';
  static const themeSystem = 'themeSystem';
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

  'initializationFailed': 'Startup failed',
  'retry': 'Retry',
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
  'switchLanguage': 'Language',
  'themeLight': 'Light',
  'themeDark': 'Dark',
  'themeSystem': 'System',
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

  'initializationFailed': '启动失败',
  'retry': '重试',
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
  'switchLanguage': '语言',
  'themeLight': '浅色',
  'themeDark': '深色',
  'themeSystem': '跟随系统',
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

  'initializationFailed': '啟動失敗',
  'retry': '重試',
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
  'switchLanguage': '語言',
  'themeLight': '淺色',
  'themeDark': '深色',
  'themeSystem': '跟隨系統',
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

仅从 [`../assets/lib/common/widgets/`](../assets/lib/common/widgets/) 复制 `button.dart`、`scaffold.dart` 和 `index.dart`。基础四页只使用 `PrimaryButton` 与 `PageScaffold`。

### `lib/common/utils/index.dart`

```dart
// 工具入口。脚手架暂无独立工具。
```

### `lib/common/index.dart`

```dart
// 公共功能总入口，只导出各子目录 index.dart。
export 'api/index.dart';
export 'cache/index.dart';
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

/// 首页：退出登录。
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

/// 单页首页：右上角切换主题与语言，页面保留退出登录。
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
    theme.setThemeMode(selected);
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingErrorMessage(error))),
      );
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

1. 基础四页、网络、缓存、存储、主题和三语翻译可运行；Home 右上角可切换主题与语言，不含组件样式入口。
2. 仅生成 `PrimaryButton` 和 `PageScaffold` 两个共享 Widget，不生成组件样式页、扩展目录或 DucafeUI 文档。
3. `AppConfig.baseUrl` 默认空；未配后端时登录写入本地假 token，refresh / 代理不发网。
4. `Global.init` 完成后才能访问 `AppRouter.router`；会话 revision 驱动登录和退出后的路由分流。
5. Splash 首帧后停留 500ms；Welcome 三页；Login 预填演示账号；Home 可退出登录。
6. `build_runner`、`flutter analyze` 与 `flutter test` 可运行，或记录实际阻塞。

### `lib/common/values/adaptive_spacing.dart`

```dart
/// 基础页面的水平留白。
abstract final class AppSpacing {
  static const double page = 20;
}
```
