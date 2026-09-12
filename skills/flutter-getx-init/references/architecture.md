# Flutter GetX 脚手架技术说明

## Contents

- 文档定位、技术栈、目录、分层
- 启动、路由、GetX 状态、网络、缓存、extension
- Freezed、认证、主题、i18n、错误处理、构建与扩展

## 1. 文档定位

本文说明本 skill 生成的 GetX 脚手架：为什么这样分层、文件怎么协作、新项目从哪里加功能。

它不是完整业务 App。范围只有启动、四页流、会话、网络骨架、主题和三语文案。不包含 Firebase、IAP、底部 Tab、具体后端业务。

## 2. 技术栈

| 能力 | 选型 | 职责 |
| --- | --- | --- |
| 跨端 | Flutter | UI 与交互 |
| 状态 / DI | GetX（`GetxController` + `GetxService`） | 页面状态、长生命周期依赖 |
| 页面刷新 | `GetBuilder` + `update([id])` | 按块刷新；连续变化才用 `Rx` / `Obx` |
| 路由 | go_router | 声明式路由、登录分流；GetX 不管路由 |
| 网络 | Dio + `native_dio_adapter` | HTTP、拦截器、平台适配 |
| 模型 | Freezed + json_serializable | 不可变模型 |
| 存储 | SharedPreferences | Token、欢迎标记、语言 |
| 主题 | AdaptiveTheme + `AppStyle` | 亮暗与语义色 |
| 国际化 | GetX translations | en / zh-CN / zh-TW |
| 图片缓存 | `flutter_cache_manager` | 鉴权代理图磁盘缓存 |
| 日志 | logger | 请求日志脱敏 |

原则：

1. 用主流、可迁移的栈（GetX、go_router、Dio、Freezed）。
2. 先闭环：启动、分流、假登录、主题，再接真实后端。

## 3. 目录

```text
lib/
├── main.dart              入口：AppBootstrap → Global.init → App
├── global.dart            启动期依赖装配
├── common/                共享能力
│   ├── api/               按资源拆的后端客户端（脚手架仅 AuthApi）
│   ├── cache/             图片代理缓存
│   ├── components/        带业务语义的共享组件（脚手架空入口）
│   ├── extension/         Dart / Flutter 扩展与 ScreenUtil
│   ├── i18n/
│   ├── models/            Freezed 模型
│   ├── network/           Dio、拦截器、异常
│   ├── routers/           路径常量 + GoRouter
│   ├── services/          应用级状态
│   ├── style/             主题 token
│   ├── utils/
│   ├── values/            配置与常量
│   ├── widgets/           无业务语义的标准组件
│   └── index.dart
└── pages/
    ├── splash / welcome / login / home
    └── index.dart
```

`widgets` 不依赖业务实体；`components` 可以。单页专用组件留在 `pages/<业务>`。

## 4. 分层

```text
Page
  ↓ 用户操作 / 跳转
GetxController
  ↓
API / GetxService
  ↓
Dio / Storage
```

依赖只允许自上而下。

- Widget 不调 API
- Controller 不画 UI、不跳转
- Controller 之间不互相 `Get.find`
- 离开页面后状态还要在 → Service；否则 → Controller

GetX 禁止：`Get.to` / `Get.off` / `Get.back`。导航只用 `context.go` / `push` / `pop`。

## 5. 启动与依赖装配

`main` 先渲染 `AppBootstrap`，再异步 `Global.init`。失败可重试，不阻塞首帧。

`Global.init` 顺序：

```text
系统 UI / 主题
  → StorageService / LocaleService
  → TokenService / AppLaunchService / SessionService
  → NetworkService
  → AuthApi（lazyPut）
```

就绪后 `App` 挂 AdaptiveTheme + `GetMaterialApp.router`，路由委托给 `AppRouter.router`。

`AppRouter.router` 是 `static final`，首次访问前必须完成 `Global.init`。

`StorageService.init` 必须 `return this`，否则 `Get.putAsync` 类型对不上。

## 6. 路由与登录分流

路径在 `AppRoutes`。`refreshListenable` 听 `SessionService.revision`。

redirect：

1. `/splash` 放行
2. 未看 welcome → `/welcome`
3. 未登录 → `/login`
4. 已登录停在 login → `/home`

Splash 展示应用名，首帧后固定停留 0.5 秒再 `context.go`，页面销毁时取消计时器。Welcome 使用三页 `PageView`，最后一页点「开始」成功写入 `AppLaunchService` 再进 login。Login 从 `AppConfig.demoEmail` / `demoPassword` 预填 `ducafecat@gmail.com` / `123456`，成功走 `SessionService.establish`，revision 变化后 redirect 进 Home。

Home 是单页，不是 `StatefulShellRoute`。右上角两个按钮分别用 `showModalBottomSheet` 切主题（浅色 / 深色 / 跟随系统）和语言（en / zh-CN / zh-TW）。主题交给 AdaptiveTheme，语言交给 LocaleService 持久化；菜单通过 `Navigator.of(sheetContext).pop` 关闭，禁止 `Get.back`。Tab 壳是业务，不进本脚手架。

## 7. GetX 页面状态

每个模块默认：`xxx_page.dart` + `xxx_controller.dart`。子目录 `index.dart` 只导出页面与控制器。

```text
GetxController + GetBuilder + update([id])
```

`update()` 必须带 id。页面 Controller 在 Page `initState` `Get.put`，`dispose` `Get.delete`。不要 `permanent: true`。

## 8. 应用级 Service

| Service | 职责 |
| --- | --- |
| StorageService | SharedPreferences |
| LocaleService | 语言；首次默认英语 |
| TokenService | 凭证内存快照与落盘 |
| SessionService | 会话身份、版本、失效 |
| AppLaunchService | 是否看过 welcome |
| NetworkService | Dio / ApiClient（在 `common/network`） |

`SessionService`：

- `establish`：换号或重新登录，递增 version，触发 `revision`
- `updateCredentials`：同会话刷新 Token，只触发 `credentialRevision`
- `invalidate`：先递增 version 并清内存，再清凭证与图片缓存
- 异步回写前必须 `isCurrent(snapshot)`

`TokenService` 同步持有 access / refresh / userId / JWT exp。没有 `userId` 不恢复为已登录。

## 9. 网络

`NetworkService` 按 `ApiSource` 懒创建 `ApiClient`。业务禁止直接 `Dio()`。

配置在 `AppConfig`（`values`）：

- `baseUrl`：`--dart-define=BASE_URL=`，默认空
- `authLoginPath` / `authRefreshPath` / `authWhitelist`
- `proxyImagePath`

拦截器：

| 拦截器 | 职责 |
| --- | --- |
| AuthInterceptor | 挂 Bearer；并发共享一次 refresh；原请求最多重放一次 |
| LoggingInterceptor | 请求 / 响应 / 错误脱敏 |
| ErrorInterceptor | `DioException` → `ApiException` |

刷新用无拦截器的独立 Dio，避免递归。`baseUrl` 为空时 refresh 直接返回 false，不发网。

响应信封 `{ code, message, data }` 在 `AuthApi` 内解包。

## 10. cache

`ProxyImageCacheManager` + `ProxyImageFileService` 走 `ApiClient.getImageStream`，复用鉴权与原生适配器。

只允许当前后端的 `AppConfig.proxyImagePath`。未配 `BASE_URL` 时不下载。登出调用 `emptyCache()`。

## 11. extension

`common/extension` 是完整扩展集（含自研 ScreenUtil）。`App` 的 `builder` 里 `ScreenUtil.init`，页面可用 `.w` / `.h` / `.sp`。

## 12. 模型与认证

脚手架模型：`AuthUser`、`AuthSession`、`SessionSnapshot`。

登录：

```text
邮箱 + 密码
  → AuthApi.login
  → 无 BASE_URL：本地假 token
  → 有 BASE_URL：POST 登录接口
  → SessionService.establish
  → revision++ → redirect Home
```

`AuthApi.refresh` 仅在有 `BASE_URL` 时发网；拦截器刷新走独立 Dio。

## 13. 主题与 i18n

唯一主题来源：`AppStyle`（ThemeExtension）。页面不判断亮暗、不内联 HEX。文字用 `AppTextStyles`。

文案：`TrKeys` + `AppTranslations`（en / zh-CN / zh-TW）。key 只覆盖四页和通用操作。

## 14. 导包

- `lib/common/index.dart` 只导出各子目录 `index.dart`
- common 跨子目录导入目标子目录 `index.dart`；同目录直接导入
- 页面、`main.dart`、`global.dart` 用 `lib/common/index.dart`
- 页面跨模块导入目标页面子目录 `index.dart`
- 新增公共能力、页面、控制器必须同步维护 `index.dart`

## 15. 新功能落点

```text
页面功能     → pages/<业务>/xxx_page.dart + xxx_controller.dart
公共模型     → common/models
接口         → common/api
跨页长状态   → common/services
多页复用 UI  → 无业务语义走 widgets，有业务语义走 components
单页组件     → 留在 pages/<业务>
工具 / 扩展  → common/utils / common/extension
```

默认不增加 Repository / UseCase / DTO。

## 16. 错误处理

网络错误在 `ErrorInterceptor` 变成 `ApiException`。UI 用 `userFacingErrorMessage`。页面用 `GetBuilder` 展示 `error`，不要在 Controller 里弹路由。

## 17. 构建命令

```sh
flutter pub add get go_router dio native_dio_adapter freezed_annotation json_annotation shared_preferences logger adaptive_theme flutter_cache_manager
flutter pub add --dev build_runner freezed json_serializable shared_preferences_platform_interface
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

有后端时：

```sh
flutter run --dart-define=BASE_URL=https://api.example.com
```

## 18. 教学重点

- 启动与首帧分离：`AppBootstrap` 可重试，`Global.init` 按依赖排序
- 路由与状态分离：GetX 不跳转，go_router redirect 听 `revision`
- 会话版本：旧异步结果不能写新账号
- 网络单例：拦截器共享 refresh，白名单可配置
- 未配后端也能跑通四页流

## 19. 扩展方向

- 业务项目可自行扩展 Tab 壳；本初始化脚手架保持单页 Home
- 按资源加 API，不要把请求写进 Controller
- 接真实登录后删掉 `AuthApi` 的本地假会话分支
- `components` 只放带业务语义的复用组件
