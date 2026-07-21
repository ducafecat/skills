## 文件模板

## Contents

- Core configuration, storage, network, providers, router, and UI files
- Shared widgets and component selection rules
- Splash, welcome, auth, and home starter pages
- `lib/main.dart` and final acceptance criteria

### `lib/core/config/app_config.dart`

```dart
/// 应用级静态配置入口。
///
/// 职责：
/// - 集中管理 App 名称、网络参数与 UI 设计稿尺寸。
/// - 通过 `String.fromEnvironment` / `bool.fromEnvironment` 支持编译期环境覆盖。
///
/// ⚠️ 注意：
/// 这里不读取运行时远程配置；如果需要动态切环境，应在更上层注入配置对象。
abstract final class AppConfig {
  /// 应用标题，供 MaterialApp、系统任务列表等位置复用。
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Riverpod App',
  );

  /// 网络默认配置。
  ///
  /// `BASE_URL` 和 `ENABLE_HTTP_LOG` 可通过 `--dart-define` 覆盖，便于 dev/staging/prod 共用模板。
  static const network = NetworkConfig(
    baseUrl: String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://example.com',
    ),
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
    enableLogging: bool.fromEnvironment('ENABLE_HTTP_LOG', defaultValue: true),
  );

  /// UI 适配基准尺寸，通常取设计稿宽高。
  static const ui = UiConfig(
    designWidth: 390,
    designHeight: 844,
  );
}

/// 网络层基础参数。
///
/// DioClient 会读取这里的 baseUrl、超时与日志开关，避免网络配置散落在各个 API 调用里。
class NetworkConfig {
  const NetworkConfig({
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.enableLogging,
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
}

/// UI 适配参数。
///
/// ScreenAdapt 会基于该尺寸计算缩放比例，使模板在常见手机和平板宽度下保持近似视觉节奏。
class UiConfig {
  const UiConfig({
    required this.designWidth,
    required this.designHeight,
  });

  final double designWidth;
  final double designHeight;
}
```

### `lib/core/storage/token_storage.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// 访问令牌在设备上的持久化封装。
///
/// [SharedPreferences] 是 Flutter 常用的键值对本地存储（异步写入、进程内缓存），
/// 适合存非敏感或已脱敏的会话信息；本类不负责加密，调用方需知悉风险。
/// **可扩展：** 若需更高安全级别，可替换为 `flutter_secure_storage` 等方案，接口可保持类似。
class TokenStorage {
  TokenStorage(this._prefs);

  /// 与业务无关的存储键前缀，避免与其它模块键名冲突。
  static const _kAccessToken = 'auth.access_token';
  static const _kRefreshToken = 'auth.refresh_token';
  static const _kExpiresAt = 'auth.expires_at';

  final SharedPreferences _prefs;

  /// 当前保存的访问令牌；未写入时为 `null`。
  String? get accessToken => _prefs.getString(_kAccessToken);

  /// 刷新令牌，用于在访问令牌过期后向服务端换取新令牌。
  String? get refreshToken => _prefs.getString(_kRefreshToken);

  /// 访问令牌过期的绝对时间戳（毫秒，与 [DateTime.now] 的 epoch 一致）。
  int? get expiresAt => _prefs.getInt(_kExpiresAt);

  /// 写入登录/刷新接口返回的令牌信息。
  ///
  /// 1. 持久化 `accessToken`、`refreshToken`。
  /// 2. 若传入 [expiresInSeconds]，则根据「当前时刻 + 有效秒数」计算过期时间戳并写入。
  ///
  /// [expiresInSeconds] 通常为服务端返回的「剩余有效时间」，相对当前时间累加更贴近实际。
  /// ⚠️ 设备系统时间被用户修改会导致本地计算的过期时刻不可靠；严谨场景可结合服务端时间或短期校验。
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    int? expiresInSeconds,
  }) async {
    await _prefs.setString(_kAccessToken, accessToken);
    await _prefs.setString(_kRefreshToken, refreshToken);
    if (expiresInSeconds != null) {
      final expireTs =
          DateTime.now().millisecondsSinceEpoch + expiresInSeconds * 1000;
      await _prefs.setInt(_kExpiresAt, expireTs);
    }
  }

  /// 登出或令牌失效时清除本地三项数据，避免残留导致误用旧会话。
  Future<void> clear() async {
    await _prefs.remove(_kAccessToken);
    await _prefs.remove(_kRefreshToken);
    await _prefs.remove(_kExpiresAt);
  }

  /// 是否具备非空的访问令牌；路由守卫、拦截器可据此判断是否视为「已登录态」。
  ///
  /// ⚠️ 仅有令牌不代表一定有效（可能已服务端吊销）；网络层仍应以 401 等为准做刷新或清会话。
  bool get hasToken {
    final t = accessToken;
    return t != null && t.isNotEmpty;
  }
}
```

### `lib/core/storage/app_launch_storage.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// 首次启动状态存储。
///
/// 职责：
/// - 记录用户是否已经看过 Welcome 页面。
/// - 为路由守卫提供轻量、同步读取的启动状态。
///
/// ⚠️ 注意：
/// 这类状态不属于账号数据；登出时是否重置应按产品需求决定。
class AppLaunchStorage {
  AppLaunchStorage(this._prefs);

  final SharedPreferences _prefs;

  /// 本地键名集中定义，避免字符串散落在页面逻辑里。
  static const _hasSeenWelcomeKey = 'app.has_seen_welcome';

  /// 是否已经完成首次欢迎流程。
  bool get hasSeenWelcome => _prefs.getBool(_hasSeenWelcomeKey) ?? false;

  /// 在用户点击开始使用后写入，后续启动可直接进入登录或首页分流。
  Future<void> markWelcomeSeen() async {
    await _prefs.setBool(_hasSeenWelcomeKey, true);
  }

  /// 测试、调试或“重新体验引导页”时使用。
  Future<void> reset() async {
    await _prefs.remove(_hasSeenWelcomeKey);
  }
}
```

### `lib/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// 网络层入口：封装 [Dio] 的创建与拦截器装配。
///
/// **作用**：业务代码只拿一个配置好的 [Dio]，不必重复写超时、BaseURL、鉴权、日志、错误转换。
///
/// **数据流（概念）**：`Repository / Api` → 本类产出的 [Dio] → `AuthInterceptor`（加 token、必要时刷新）
/// → 可选 `LoggingInterceptor` → `ErrorInterceptor`（把 Dio 异常转成业务可读的异常类型）。
///
/// **可扩展点**：新增全局行为时通常加拦截器；换环境 BaseURL 走 [AppConfig.network] 或传入 [baseUrl]。
class DioClient {
  /// 创建一个已装配拦截器的 [Dio] 实例。
  ///
  /// **输入**
  /// - [baseUrl]：接口根地址；为 `null` 时使用 [AppConfig.network.baseUrl]（与运行环境配置一致）。
  /// - [tokenStorage]：读写 access / refresh token 的存储抽象；鉴权拦截器依赖它完成「带票请求 / 刷新」。
  /// - [onUnauthorized]：当刷新 token 失败或必须重新登录时的回调（常见：清会话、跳登录页）。
  /// - ⚠️ 具体何时触发由 [AuthInterceptor] 实现决定，调用方需保证线程安全（如在 Flutter 里用 `SchedulerBinding` 切回 UI 线程再导航）。
  /// - [enableLogging]：是否打印请求日志；为 `null` 时跟随 [AppConfig.network.enableLogging]（便于按环境开关）。
  ///
  /// **输出**
  /// - 配置好 [BaseOptions] 与拦截器链的 [Dio]，可直接 `dio.get/post` 等。
  ///
  /// **关键概念**
  /// - [BaseOptions]：Dio 的全局默认配置（超时、默认头、响应解析类型等）。
  /// - **拦截器链**：请求发出前 / 响应返回后按添加顺序执行；顺序会影响行为（例如先鉴权再记日志，错误最后统一处理）。
  static Dio create({
    String? baseUrl,
    required TokenStorage tokenStorage,
    void Function()? onUnauthorized,
    bool? enableLogging,
  }) {
    // 从集中配置读取超时、默认日志开关等，避免魔法数字散落在业务里。
    final cfg = AppConfig.network;
    // 「调用方覆盖 > 全局默认」：单测或临时指向 mock 时可传 baseUrl；日常用配置即可。
    final effectiveBaseUrl = baseUrl ?? cfg.baseUrl;
    final effectiveEnableLogging = enableLogging ?? cfg.enableLogging;

    // 主实例：承载业务请求与完整拦截器链。
    final dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: cfg.connectTimeout,
        receiveTimeout: cfg.receiveTimeout,
        sendTimeout: cfg.sendTimeout,
        // 期望服务端返回 JSON，Dio 会尝试按 JSON 解析（具体解析还受泛型/转换器影响）。
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        // Accept 声明客户端能处理的表示类型，常见于 REST API 协商。
        headers: {'Accept': 'application/json'},
      ),
    );

    // 刷新 token 专用客户端：与主 [dio] 分离，避免拦截器递归。
    // 步骤理解：
    // 1) 主 dio 发业务请求 → 401 → AuthInterceptor 用 refreshDio 调刷新接口；
    // 2) 若 refreshDio 也挂同一套拦截器，刷新请求可能再次进「刷新逻辑」→ 死循环或栈溢出。
    // ⚠️ 因此 refresh 客户端通常保持「最小配置」：同源 BaseURL + 超时，但不挂 AuthInterceptor。
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: cfg.connectTimeout,
        receiveTimeout: cfg.receiveTimeout,
        sendTimeout: cfg.sendTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
      ),
    );

    // 拦截器顺序说明（自上而下 = 先添加的先接到请求/后接到响应，具体以 Dio 文档为准；此处与项目约定一致）：
    // 1) Auth：统一注入 Authorization、处理 401 与刷新；
    // 2) Logging：仅调试/排障，生产可按配置关闭；
    // 3) Error：把网络层错误映射为上层统一的异常类型，UI 只关心「用户可读文案 + 错误码」。
    dio.interceptors.addAll([
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshDio: refreshDio,
        onUnauthorized: onUnauthorized,
      ),
      if (effectiveEnableLogging) LoggingInterceptor(),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
```

### `lib/core/network/api_exception.dart`

```dart
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
```

### `lib/core/network/error_message.dart`

```dart
import 'package:dio/dio.dart';

import 'api_exception.dart';

/// UI 展示用：仅业务文案，不含 Dio / ApiException 等包装前缀。
String userFacingErrorMessage(
  Object? error, {
  String fallback = '操作失败，请稍后重试',
}) {
  if (error == null) return fallback;
  if (error is ApiException) return error.message;
  if (error is DioException) {
    final inner = error.error;
    if (inner is ApiException) return inner.message;
    final data = error.response?.data;
    if (data is Map) {
      for (final key in ['message', 'msg', 'error']) {
        final v = data[key];
        if (v is String) {
          final t = v.trim();
          if (t.isNotEmpty) return t;
        }
      }
    }
    final m = error.message?.trim();
    if (m != null && m.isNotEmpty) return m;
    return fallback;
  }
  return error.toString();
}
```

### `lib/core/network/interceptors/auth_interceptor.dart`

```dart
import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// 【鉴权拦截器】
///
/// **作用**：在 HTTP 层统一处理「谁有权访问接口」：
/// - **发请求前**：给需要鉴权的接口自动加上 `Authorization: Bearer <accessToken>`。
/// - **收到 401**：用本地 `refreshToken` 换一对新 token，成功后**重放**刚才失败的请求。
///
/// **为什么用拦截器**：业务代码只关心业务 URL，不必每个接口手写 Header；
/// 刷新与重试集中在一处，避免重复代码。
///
/// **关键概念**：
/// - **Access Token**：短期凭证，放在请求头里证明身份。
/// - **Refresh Token**：长期凭证，只用于换新的 access（通常不随每次业务请求发送）。
/// - **401 Unauthorized**：服务端认为「未登录或 token 无效」，常见触发刷新流程。
class AuthInterceptor extends Interceptor {
  /// 构造依赖说明：
  /// - [tokenStorage]：读写本地持久化的 token（access / refresh）。
  /// - [refreshDio]：**单独**的 Dio 实例，只负责调用 `/api/auth/refresh`。
  ///   **为什么不用主 Dio**：主客户端往往也挂了本拦截器；用同一个实例刷新可能再次进入
  ///   `onError`，形成**递归/循环**，所以刷新必须用「干净」的客户端。
  /// - [onUnauthorized]：刷新失败或没有 refresh 时的回调（例如清空路由栈、跳转登录页）。
  AuthInterceptor({
    required this.tokenStorage,
    required this.refreshDio,
    this.onUnauthorized,
  });

  /// 本地 token 存储抽象，具体实现可能是 SharedPreferences、安全存储等。
  final TokenStorage tokenStorage;

  /// 仅用于刷新 token 的 Dio（baseUrl 等应与主客户端一致，保证路径正确）。
  final Dio refreshDio;

  /// 需要重新登录时的副作用（UI 层注册，网络层不直接依赖具体页面）。
  final void Function()? onUnauthorized;

  /// 白名单：这些路径**不**自动带 `Authorization`，也**不**在 401 时走刷新逻辑。
  ///
  /// 典型场景：登录、刷新接口本身若带上过期 access 或误触发刷新，会造成逻辑混乱。
  static const _whitelist = <String>[
    '/api/auth/login',
    '/api/auth/refresh',
  ];

  /// 并发控制标志：多个请求同时 401 时，只允许**一条**刷新链路在执行。
  ///
  /// **为什么需要**：否则可能并发打出多次 refresh，后写盘的 token 互相覆盖，或浪费配额。
  bool _refreshing = false;

  /// **时机**：请求即将发出前（`Interceptor.onRequest`）。
  ///
  /// **输入**：[options] 本次请求的完整配置（含 path、headers 等）；[handler] 用于继续或中断链。
  /// **输出**：无直接返回值；通过 `handler.next(options)` 把（可能已改过的）请求交给下一个拦截器。
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 白名单接口：既不拼 Bearer，也避免把登录请求当成「已登录业务请求」。
    if (!_isWhitelisted(options.path)) {
      final token = tokenStorage.accessToken;
      if (token != null && token.isNotEmpty) {
        // Bearer 是 OAuth/JWT 生态里常用的方案：服务端从 Header 解析 token 校验签名与过期时间。
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  /// **时机**：请求已发出且 Dio 判定为失败（网络错误、4xx/5xx 等）。
  ///
  /// **输入**：[err] 包装了原始异常与 `Response`（若有）；[handler] 可 `next`（继续抛错）或 `resolve`（把错误「改成成功」）。
  /// **输出**：无；通过 handler 结束本次拦截链路。
  ///
  /// **401 分支的核心流程（步骤式）**：
  /// 1. 过滤：非 401 / 白名单 / 正在刷新 → 不处理，原样交给后续逻辑。
  /// 2. 若没有 refresh：清空本地凭证，通知上层重新登录，原样传递401。
  /// 3. 加锁 `_refreshing = true`，调用刷新接口拿到新 token 并 `save`。
  /// 4. 用**新 access** 更新原请求的 Header，再 `fetch` 一次原请求；成功则 `handler.resolve`，对调用方等价于「第一次就成功了」。
  /// 5. 任一步失败：`clear` + `onUnauthorized` + `handler.next(err)`，让上层仍能看到原始失败。
  /// 6. `finally` 里释放锁，保证无论成功失败都能恢复并发刷新能力。
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;

    // 不满足「可刷新」的前置条件时，不要拦截：保持 Dio 默认错误语义。⚠️ `_refreshing == true` 时其它并发 401 会直接 `next`，不会排队等刷新完成；要「全链路自动重试」需额外队列/Completer 协调。
    if (status != 401 || _isWhitelisted(path) || _refreshing) {
      return handler.next(err);
    }

    final refreshToken = tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await tokenStorage.clear();
      onUnauthorized?.call();
      return handler.next(err);
    }

    _refreshing = true;
    try {
      final resp = await refreshDio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = resp.data;
      if (data == null) throw err;

      await tokenStorage.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        expiresInSeconds: (data['expiresIn'] as num?)?.toInt(),
      );

      // 重放：复用原 RequestOptions（URL、method、body 等不变），只更新 Authorization。
      // `..` 级联：在拷贝/复用的 options 上就地改 headers，再作为 fetch 参数。
      final retried = await refreshDio.fetch<dynamic>(
        err.requestOptions
          ..headers['Authorization'] = 'Bearer ${tokenStorage.accessToken}',
      );
      return handler.resolve(retried);
    } catch (_) {
      await tokenStorage.clear();
      onUnauthorized?.call();
      return handler.next(err);
    } finally {
      _refreshing = false;
    }
  }

  /// **作用**：判断 [path] 是否命中白名单。
  ///
  /// **匹配方式**：`endsWith` 后缀——简单直观，但若 path 带查询串（如 `.../login?x=1`）可能匹配不到，
  /// 需要服务端/路由约定 path 形态。
  ///
  /// **输入**：[path] 一般为相对路径（是否含 query 取决于 Dio 配置）。
  /// **输出**：`true` 表示视为登录相关接口，跳过鉴权与刷新。
  ///
  /// ⚠️ **潜在问题**：重试使用的是 [refreshDio] 而非「主业务 Dio」，若主客户端还有其它拦截器
  /// （签名、埋点、统一 baseUrl 处理），重试请求**不会**再走那一套；复杂项目可考虑用主实例
  /// 的 clone 或仅复制必要配置后 fetch。
  bool _isWhitelisted(String path) {
    return _whitelist.any((p) => path.endsWith(p));
  }
}
```

### `lib/core/network/interceptors/error_interceptor.dart`

```dart
import 'package:dio/dio.dart';

import '../api_exception.dart';

/// 将 [DioException] 统一映射为业务侧 [ApiException]，挂在 error 字段上。
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _map(err);
    // 保留原 request/response/type，把业务异常放进 error，便于上层 catch
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

  /// [err] 按 Dio 错误类型分支映射
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
      case DioExceptionType.unknown:
        return UnknownException(err.message ?? '未知错误');
    }
  }

  /// [err] 有响应体时按 HTTP 状态码映射
  ApiException _mapStatus(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final message = _extractMessage(data) ?? err.message ?? '请求失败';

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

  /// 从后端 JSON 里取 message / error / msg
  String? _extractMessage(dynamic data) {
    if (data is Map) {
      final m = data['message'] ?? data['error'] ?? data['msg'];
      if (m is String) return m;
    }
    return null;
  }
}
```

### `lib/core/network/interceptors/logging_interceptor.dart`

```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// 请求/响应/错误日志拦截器，便于调试网络层。
class LoggingInterceptor extends Interceptor {
  /// [logger] 可注入自定义 Logger；默认 PrettyPrinter、无 emoji
  LoggingInterceptor({Logger? logger})
    : _logger =
          logger ??
          Logger(printer: PrettyPrinter(methodCount: 0, printEmojis: false));

  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '→ ${options.method} ${options.uri}\n'
      'headers: ${options.headers}\n'
      'data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '← ${response.statusCode} ${response.requestOptions.uri}\n'
      'data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✗ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      'status: ${err.response?.statusCode}\n'
      'data: ${err.response?.data}\n'
      'message: ${err.message}',
    );
    handler.next(err);
  }
}
```

### `lib/core/providers/dio_provider.dart`

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../storage/app_launch_storage.dart';
import '../storage/token_storage.dart';

part 'dio_provider.g.dart';

/// 应用级 SharedPreferences Provider。
///
/// Riverpod 语义：
/// - `keepAlive: true`：作为基础设施依赖，生命周期跟随应用。
/// - 默认抛错：提醒调用方必须在 `runApp` 前通过 ProviderScope override 注入异步初始化结果。
///
/// ⚠️ 注意：
/// 如果忘记 override，本 Provider 被读取时会立即抛错；这能尽早暴露启动流程问题。
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before runApp.',
  );
}

/// TokenStorage Provider。
///
/// 职责：
/// - 封装 access/refresh token 的本地读写。
/// - 给路由守卫和网络拦截器提供同一份登录态来源。
@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) {
  return TokenStorage(ref.watch(sharedPreferencesProvider));
}

/// 首次启动状态 Provider。
///
/// Welcome/Splash/Router 都通过它判断是否需要展示引导页。
@Riverpod(keepAlive: true)
AppLaunchStorage appLaunchStorage(Ref ref) {
  return AppLaunchStorage(ref.watch(sharedPreferencesProvider));
}

/// 全局 Dio Provider。
///
/// 职责：
/// - 创建统一配置的 HTTP 客户端。
/// - 复用同一套鉴权、日志与错误转换拦截器。
///
/// 扩展方式：
/// 需要统一处理 401 跳登录时，可向 `DioClient.create` 传入 `onUnauthorized` 回调。
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return DioClient.create(tokenStorage: ref.watch(tokenStorageProvider));
}
```

### `lib/core/providers/api_providers.dart`

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dio_provider.dart';

part 'api_providers.g.dart';

/// 轻量 API 门面。
///
/// 职责：
/// - 屏蔽 Dio 的直接使用，让 feature 层通过更稳定的 ApiClient 入口发请求。
/// - 先提供 get/post 两个最常用方法，后续可按项目需要补 put/delete/upload。
///
/// ⚠️ 注意：
/// 这里不做 JSON model 解析；具体响应类型建议放在 feature repository 或 api 文件里处理。
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// GET 请求。
  ///
  /// queryParameters 会被 Dio 拼到 URL 查询串中，适合列表筛选、分页 cursor 等场景。
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  /// POST 请求。
  ///
  /// data 通常传 JSON body；queryParameters 仍可用于少量 URL 参数。
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }
}

/// ApiClient Provider。
///
/// feature 层可 `ref.watch(apiClientProvider)` 复用全局 Dio 配置。
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  return ApiClient(ref.watch(dioProvider));
}
```

### `lib/core/router/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/welcome/pages/welcome_page.dart';
import '../providers/dio_provider.dart';

part 'app_router.g.dart';

/// 路由常量表。
///
/// 集中定义路径可以减少页面跳转时的字符串拼写错误，也方便后续统一改路由层级。
abstract final class AppRoutes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const home = '/home';
}

/// 应用路由 Provider。
///
/// Riverpod 语义：
/// - `keepAlive: true`：GoRouter 是应用级对象，应与 App 生命周期保持一致。
///
/// 分流规则：
/// 1. Splash 页面允许先展示启动过渡。
/// 2. 未看过 Welcome 时强制进入 Welcome。
/// 3. 已看过 Welcome 但未登录时进入 Login。
/// 4. 已登录时进入 Home，并避免停留在 Login。
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      // 使用 matchedLocation 而不是原始 uri，可避免 query 参数影响基础路由判断。
      final onSplash = location == AppRoutes.splash;
      final onWelcome = location == AppRoutes.welcome;
      final onLogin = location == AppRoutes.login;
      final hasSeenWelcome = ref.read(appLaunchStorageProvider).hasSeenWelcome;
      final isLoggedIn = ref.read(tokenStorageProvider).hasToken;

      // Splash 自己负责延迟和首屏跳转，router 不在这里抢先改向。
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

### `lib/core/ui/app_theme.dart`

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

/// 应用主题工厂。
///
/// 职责：
/// - 将颜色、字体、圆角等设计 token 汇总为 Flutter ThemeData。
/// - 同时提供亮色与暗色主题，交给 AdaptiveTheme 在运行时切换。
///
/// 设计原则：
/// 页面组件优先使用 Theme / AppColors / AppTextStyles，避免散落硬编码样式。
abstract final class AppTheme {
  /// 阴影透明度按亮暗主题分开，暗色下稍强一点以维持层次。
  static const _shadowLight = Color(0x1A000000);
  static const _shadowDark = Color(0x26000000);

  /// 亮色主题入口。
  static ThemeData get lightTheme => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        card: AppColors.lightCard,
        primary: AppColors.lightPrimary,
        primaryFg: AppColors.lightPrimaryFg,
        onSurface: AppColors.lightCardFg,
        outline: AppColors.lightBorder,
        muted: AppColors.lightMuted,
        mutedFg: AppColors.lightMutedFg,
        shadow: _shadowLight,
        textTheme: AppTextStyles.lightTextTheme,
      );

  /// 暗色主题入口。
  static ThemeData get darkTheme => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        card: AppColors.darkCard,
        primary: AppColors.darkPrimary,
        primaryFg: AppColors.darkPrimaryFg,
        onSurface: AppColors.darkCardFg,
        outline: AppColors.darkBorder,
        muted: AppColors.darkMuted,
        mutedFg: AppColors.darkMutedFg,
        shadow: _shadowDark,
        textTheme: AppTextStyles.darkTextTheme,
      );

  /// 构建 ThemeData 的公共方法。
  ///
  /// 通过参数注入亮暗主题差异，避免 lightTheme/darkTheme 维护两份近似重复的 ThemeData。
  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color primary,
    required Color primaryFg,
    required Color onSurface,
    required Color outline,
    required Color muted,
    required Color mutedFg,
    required Color shadow,
    required TextTheme textTheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      shadowColor: shadow,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: primaryFg,
        secondary: muted,
        onSecondary: mutedFg,
        surface: card,
        onSurface: onSurface,
        error: brightness == Brightness.dark
            ? AppColors.darkDestructive
            : AppColors.lightDestructive,
        onError: brightness == Brightness.dark
            ? AppColors.darkDestructiveFg
            : AppColors.lightDestructiveFg,
        outline: outline,
        outlineVariant: muted,
        surfaceContainerHighest: muted,
        onSurfaceVariant: mutedFg,
      ),
      // TextTheme 让 Material 组件（AppBar、Button、Input 等）获得统一字体基线。
      textTheme: textTheme,
      dividerColor: outline,
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: outline),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: muted,
        selectedColor: primary,
        disabledColor: muted,
        checkmarkColor: Colors.transparent,
        labelStyle: TextStyle(
          color: mutedFg,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: TextStyle(
          color: primaryFg,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        side: BorderSide.none,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryFg,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: mutedFg,
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: TextStyle(color: mutedFg, fontSize: 15),
      ),
    );
  }
}
```

### `lib/core/ui/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// 应用颜色 token。
///
/// 职责：
/// - 集中维护亮色/暗色主题用到的基础色值。
/// - 与 ThemeData、BuildContext 扩展共同组成可复用的视觉系统。
///
/// ⚠️ 注意：
/// 新增颜色前优先判断是否能复用现有语义色，避免页面逐渐变成“随手取色”。
abstract final class AppColors {
  static const lightBackground = Color(0xFFF9F6EF);
  static const lightForeground = Color(0xFF4A3F2F);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardFg = Color(0xFF1A1814);
  static const lightPrimary = Color(0xFFBF6A2E);
  static const lightPrimaryFg = Color(0xFFFFFFFF);
  static const lightMuted = Color(0xFFEBE5D0);
  static const lightMutedFg = Color(0xFF847E6A);
  static const lightDestructive = Color(0xFFD04B2B);
  static const lightDestructiveFg = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFD9D0B8);

  static const darkBackground = Color(0xFF2D2A24);
  static const darkForeground = Color(0xFFCCC3A8);
  static const darkCard = Color(0xFF373330);
  static const darkCardFg = Color(0xFFF9F6EF);
  static const darkPrimary = Color(0xFFCA7835);
  static const darkPrimaryFg = Color(0xFFFFFFFF);
  static const darkMuted = Color(0xFF222019);
  static const darkMutedFg = Color(0xFFBFB89E);
  static const darkDestructive = Color(0xFFD04B2B);
  static const darkDestructiveFg = Color(0xFFFFFFFF);
  static const darkBorder = Color(0xFF474038);
}

/// BuildContext 颜色扩展。
///
/// 用法：
/// - `context.appCard`、`context.appPrimary` 可根据当前亮暗主题自动返回对应颜色。
/// - 组件层不需要手动判断 Brightness。
extension AppColorsX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground =>
      isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  Color get appForeground =>
      isDarkMode ? AppColors.darkForeground : AppColors.lightForeground;
  Color get appCard => isDarkMode ? AppColors.darkCard : AppColors.lightCard;
  Color get appCardFg =>
      isDarkMode ? AppColors.darkCardFg : AppColors.lightCardFg;
  Color get appPrimary =>
      isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
  Color get appPrimaryFg =>
      isDarkMode ? AppColors.darkPrimaryFg : AppColors.lightPrimaryFg;
  Color get appMuted => isDarkMode ? AppColors.darkMuted : AppColors.lightMuted;
  Color get appMutedFg =>
      isDarkMode ? AppColors.darkMutedFg : AppColors.lightMutedFg;
  Color get appDestructive =>
      isDarkMode ? AppColors.darkDestructive : AppColors.lightDestructive;
  Color get appDestructiveFg => isDarkMode
      ? AppColors.darkDestructiveFg
      : AppColors.lightDestructiveFg;
  Color get appBorder =>
      isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;
}
```

### `lib/core/ui/app_text_styles.dart`

```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 文本样式 token。
///
/// 职责：
/// - 为页面标题、正文、辅助文案、标签等提供统一字号与字重。
/// - 提供 `xxxOn(context)` 快捷方法，根据当前主题自动套用合适颜色。
abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    height: 1.14,
  );
  static const pageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );
  static const secondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const meta = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.76,
    height: 1.2,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// 以下 `xxxOn` 方法只负责补颜色，不改变字号/行高/字重。
  /// 这样页面能保持统一排版，同时自然适配亮暗主题。
  static TextStyle displayOn(BuildContext context) =>
      display.copyWith(color: context.appCardFg);
  static TextStyle pageTitleOn(BuildContext context) =>
      pageTitle.copyWith(color: context.appCardFg);
  static TextStyle sectionTitleOn(BuildContext context) =>
      sectionTitle.copyWith(color: context.appCardFg);
  static TextStyle bodyOn(BuildContext context) =>
      body.copyWith(color: context.appForeground);
  static TextStyle secondaryOn(BuildContext context) =>
      secondary.copyWith(color: context.appMutedFg);
  static TextStyle metaOn(BuildContext context) =>
      meta.copyWith(color: context.appMutedFg);
  static TextStyle labelOn(BuildContext context) =>
      label.copyWith(color: context.appMutedFg);
  static TextStyle captionOn(BuildContext context) =>
      caption.copyWith(color: context.appMutedFg);

  /// Material 亮色 TextTheme 映射。
  ///
  /// 这里把项目语义样式映射到 Flutter 的标准槽位，供 AppBar、Button、Input 等默认组件读取。
  static TextTheme get lightTextTheme => const TextTheme(
        displaySmall: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          color: AppColors.lightCardFg,
          height: 1.14,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.lightCardFg,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.lightCardFg,
          height: 1.25,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.lightForeground,
          height: 1.65,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.lightForeground,
          height: 1.3,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.lightMutedFg,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.lightMutedFg,
          letterSpacing: 1.76,
          height: 1.2,
        ),
      );

  /// Material 暗色 TextTheme 映射。
  static TextTheme get darkTextTheme => const TextTheme(
        displaySmall: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          color: AppColors.darkCardFg,
          height: 1.14,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkCardFg,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.darkCardFg,
          height: 1.25,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.darkForeground,
          height: 1.65,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkForeground,
          height: 1.3,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.darkMutedFg,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.darkMutedFg,
          letterSpacing: 1.76,
          height: 1.2,
        ),
      );
}
```

### `lib/core/ui/app_radius.dart`

```dart
import 'package:flutter/widgets.dart';

/// 圆角 token。
///
/// 职责：
/// - 将常用圆角尺寸集中命名，形成一致的组件形态。
/// - 提供 BorderRadius 快捷 getter，减少页面重复 `BorderRadius.circular(...)`。
abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double modal = 28;
  static const double pill = 999;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(xl);
  static BorderRadius get modalBorderRadius => BorderRadius.circular(modal);
  static BorderRadius get chipBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get pillBorderRadius => BorderRadius.circular(pill);
}
```

### `lib/core/ui/adaptive_spacing.dart`

```dart
/// 间距 token。
///
/// 页面布局优先使用这些尺寸，保证列表、卡片、表单之间的留白节奏一致。
abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}
```

### `lib/core/ui/adaptive_breakpoints.dart`

```dart
/// 响应式断点。
///
/// 职责：
/// - 给布局判断提供统一宽度阈值。
/// - 避免各页面自己写不同的 magic number。
abstract final class AdaptiveBreakpoints {
  static const double smallPhone = 360;
  static const double phone = 390;
  static const double largePhone = 430;
  static const double tablet = 600;
  static const double desktop = 1024;
}
```

### `lib/core/ui/screen_adapt.dart`

```dart
import 'package:flutter/widgets.dart';

import '../config/app_config.dart';

/// 屏幕适配工具。
///
/// 职责：
/// - 基于设计稿尺寸计算宽高缩放。
/// - 提供字体、图标、圆角的温和缩放，避免大屏过度放大或小屏过度压缩。
///
/// ⚠️ 注意：
/// 不建议把所有尺寸都无脑缩放；复杂布局仍应优先使用弹性布局、约束和断点。
class ScreenAdapt {
  ScreenAdapt(this.context);

  final BuildContext context;

  Size get size => MediaQuery.sizeOf(context);
  EdgeInsets get padding => MediaQuery.paddingOf(context);
  double get screenWidth => size.width;
  double get screenHeight => size.height;
  double get wScale => screenWidth / AppConfig.ui.designWidth;
  double get hScale => screenHeight / AppConfig.ui.designHeight;

  /// 常用设备类型判断，供页面在必要时切换布局密度。
  bool get isSmallPhone => screenWidth < 375;
  bool get isPhone => screenWidth < 600;
  bool get isTablet => screenWidth >= 600;

  /// 按宽/高比例缩放基础尺寸。
  double w(double value) => value * wScale;
  double h(double value) => value * hScale;
  /// 圆角、图标、字体使用 clamp 限制缩放范围，避免视觉失控。
  double radius(double value) => value * wScale.clamp(0.95, 1.12);
  double icon(double value) => value * wScale.clamp(0.95, 1.10);
  double font(double value) => value * wScale.clamp(0.98, 1.08);
}
```

### `lib/core/ui/safe_area_ext.dart`

```dart
import 'package:flutter/widgets.dart';

/// 安全区快捷扩展。
///
/// 适用于自定义全屏布局、底部按钮、沉浸式 AppBar 等需要读取刘海/手势区域的场景。
extension SafeAreaExt on BuildContext {
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);
  double get safeTop => safeAreaPadding.top;
  double get safeBottom => safeAreaPadding.bottom;
  double get safeLeft => safeAreaPadding.left;
  double get safeRight => safeAreaPadding.right;
}
```

### `lib/core/ui/ui.dart`

```dart
// UI 基础能力统一导出。
//
// feature 页面只需要 import `core/ui/ui.dart`，即可拿到颜色、字体、圆角、间距、适配与安全区扩展。
export 'adaptive_breakpoints.dart';
export 'adaptive_spacing.dart';
export 'app_colors.dart';
export 'app_radius.dart';
export 'app_text_styles.dart';
export 'app_theme.dart';
export 'safe_area_ext.dart';
export 'screen_adapt.dart';
```

### `lib/shared/widgets/section_header.dart`

```dart
import 'package:flutter/material.dart';

import '../../core/ui/ui.dart';

/// 分区标题组件。
///
/// 职责：
/// - 用统一的 label 样式展示 section 标题。
/// - 支持右侧 trailing 操作，例如“查看全部”按钮或筛选入口。
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelOn(context),
          ),
        ),
        // Dart pattern matching：仅在 trailing 非空时渲染右侧组件。
        if (trailing case final Widget widget) widget,
      ],
    );
  }
}
```

### `lib/shared/widgets/settings_tile.dart`

```dart
import 'package:flutter/material.dart';

import '../../core/ui/ui.dart';

/// 设置项行组件。
///
/// 职责：
/// - 提供统一的左右布局：leading / label / trailing。
/// - 通过 InkWell 保留 Material 点击反馈。
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    this.trailing,
    this.leading,
    this.onTap,
  });

  final String label;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // pattern matching 写法可避免先判空再强转。
            if (leading case final Widget widget) ...[
              widget,
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(label, style: AppTextStyles.bodyOn(context))),
            if (trailing case final Widget widget) widget,
          ],
        ),
      ),
    );
  }
}

/// 设置分组容器。
///
/// 职责：
/// - 把多个 SettingsTile 组合成带边框、圆角和分隔线的组。
/// - 统一处理首尾裁剪，保证涟漪和内容不会溢出圆角。
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    // 在子项之间插入分隔线，避免调用方手动维护 Divider。
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(Divider(height: 1, color: context.appBorder));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.appBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: items),
    );
  }
}
```

### `lib/shared/widgets/widgets.dart`

```dart
// shared widgets 统一导出。
//
// feature 页面可 import `shared/widgets/widgets.dart` 获取通用组件。
export 'section_header.dart';
export 'settings_tile.dart';
```

## 通用组件选择规则

从 `lib/core/ui/*.dart` 可优先放入初始化模板：颜色、字号、圆角、间距、断点、屏幕适配、安全区扩展、主题与 `ui.dart` 导出文件。

从 `lib/shared/widgets/*.dart` 可优先放入初始化模板：`SectionHeader`、`SettingsTile`、`SettingsGroup` 与 `widgets.dart` 导出文件。

不要默认放入 `video_*`, `channel_card`, `membership_card`, `payment_plan_card`, `receipt_card`, `user_info_card`。这些组件和 TubeFlow 业务、媒体内容、支付会员或 `core/widgets` 依赖更强，应该等对应 feature 生成时再加入。

### `lib/features/splash/pages/splash_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/dio_provider.dart';
import '../../../core/router/app_router.dart';

/// 启动页。
///
/// 职责：
/// - 展示短暂启动过渡。
/// - 读取本地启动状态与登录态，决定首屏去向。
///
/// 为什么使用 ConsumerStatefulWidget：
/// `_start` 需要在 initState 触发一次异步流程，同时又要读取 Riverpod Provider。
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 启动分流只执行一次，不放进 build，避免重建时重复导航。
    _start();
  }

  /// 启动分流流程：
  /// 1. 等待极短时间，让首帧和启动动画有机会展示。
  /// 2. 读取 Welcome 与 Token 状态。
  /// 3. 按 Welcome → Home/Login 的优先级跳转。
  Future<void> _start() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    // 异步等待后 Widget 可能已经销毁，导航前必须检查 mounted。
    if (!mounted) return;

    final hasSeenWelcome = ref.read(appLaunchStorageProvider).hasSeenWelcome;
    final hasToken = ref.read(tokenStorageProvider).hasToken;

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
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

### `lib/features/welcome/pages/welcome_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/dio_provider.dart';
import '../../../core/router/app_router.dart';

/// 欢迎页。
///
/// 职责：
/// - 作为首次启动引导占位页面。
/// - 用户点击开始后标记 Welcome 已完成，再进入登录流程。
class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await ref.read(appLaunchStorageProvider).markWelcomeSeen();
            // 异步写入后再导航，确保下一次启动不会重复进入 Welcome。
            if (context.mounted) context.go(AppRoutes.login);
          },
          child: const Text('Get started'),
        ),
      ),
    );
  }
}
```

### `lib/features/auth/pages/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/dio_provider.dart';
import '../../../core/router/app_router.dart';

/// 登录页。
///
/// 职责：
/// - 提供最小可运行的 mock 登录入口。
/// - 演示如何通过 TokenStorage 写入登录态并进入首页。
///
/// ⚠️ 注意：
/// 真实项目应在这里调用 Auth API，并把服务端返回的 token 写入 TokenStorage。
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await ref.read(tokenStorageProvider).save(
                  accessToken: 'dev-access-token',
                  refreshToken: 'dev-refresh-token',
                );
            if (context.mounted) context.go(AppRoutes.home);
          },
          child: const Text('Mock login'),
        ),
      ),
    );
  }
}
```

### `lib/features/home/pages/home_page.dart`

```dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/dio_provider.dart';
import '../../../core/router/app_router.dart';

/// 首页。
///
/// 职责：
/// - 证明脚手架已经完成主题、路由、Provider 和本地登录态串联。
/// - 提供主题切换与退出登录两个基础动作。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () {
              // AdaptiveTheme 会持久化用户选择，下次启动由 main.dart 读取。
              AdaptiveTheme.of(context).toggleThemeMode();
            },
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(tokenStorageProvider).clear();
              // 清掉 token 后主动跳登录；router 也会在后续守卫中保持一致。
              if (context.mounted) context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('Flutter Riverpod scaffold is running.')),
    );
  }
}
```

### `lib/main.dart`

```dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/providers/dio_provider.dart';
import 'core/router/app_router.dart';
import 'core/ui/app_theme.dart';

/// 应用入口。
///
/// 启动流程：
/// 1. 绑定 Flutter 引擎，确保插件和 SystemChrome 可用。
/// 2. 初始化本地存储与主题模式。
/// 3. 用 ProviderContainer 注入异步依赖。
/// 4. 交给 UncontrolledProviderScope 承载整个应用。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // SharedPreferences 与 AdaptiveTheme 都是异步依赖，提前初始化可让 Provider 保持同步读取。
  final prefs = await SharedPreferences.getInstance();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // 使用 ProviderContainer 是为了把启动期拿到的 prefs override 到 Riverpod 依赖图里。
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

/// 根组件。
///
/// 职责：
/// - 监听 appRouterProvider 获取全局路由。
/// - 配置亮暗主题与 MaterialApp.router。
class MyApp extends ConsumerWidget {
  const MyApp({super.key, this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          routerConfig: router,
        );
      },
    );
  }
}
```
