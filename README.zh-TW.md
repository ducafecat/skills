<p align="center">
  <img src="docs/banner.png" alt="猫哥 ducafecat — Flutter Agent Skills for Codex, Claude Code &amp; Cursor" />
</p>

[English](./README.md) | [简体中文](./README.zh-CN.md) | [繁體中文](./README.zh-TW.md)

# 貓哥 Flutter Agent Skills for Codex, Claude Code & Cursor

為 Flutter 開發者打造的可重複使用 AI Agent Skills，適用於 **Codex、Claude Code、Cursor** 等 AI 程式開發工具，涵蓋 Riverpod / GetX 專案初始化、圖片資源自動化和深度程式碼審查。

為現有 Flutter 應用程式加入 go_router、Dio、Freezed、儲存與佈景主題，使用符合儲存庫規範的指令完成資源處理和程式碼審查。

官網：[ducafecat.com](https://ducafecat.com)

## 快速開始

在專案目錄中執行：

```bash
npx skills@latest add ducafecat/skills
```

依安裝程式提示選擇所需技能和目標 AI 程式開發 Agent。技能會以一般檔案安裝，可以直接檢視和修改。

更新已安裝的技能：

```bash
npx skills update
```

初始化技能需要現有 Flutter 專案，包含 `pubspec.yaml` 和 `lib/main.dart`。圖片資源技能需要 `assets/images/3.0x/` 下的來源圖片。執行專案命令需要 Flutter 或 Dart SDK；安裝相依套件時可能需要網路存取。

## 為什麼使用 Flutter Agent Skills？

- **可重複使用的專案初始化流程：** 依 Riverpod 或 GetX 架構說明與檔案範本，建立基本頁面流程。
- **自動化資源處理：** 使用純 Dart 產生多倍率圖片，並維護 `AppImages` 資源索引。
- **基於儲存庫事實的程式碼審查：** 結合儲存庫標準與審查規則，檢查程式碼變更。
- **可修改的工作流程：** 技能指令、參考文件和配套檔案均保存在儲存庫中。

## 可用 Flutter 技能

| 技能 | 功能 | 文件 |
| --- | --- | --- |
| [`flutter-riverpod-init`](./skills/flutter-riverpod-init/SKILL.md) | 為現有 Flutter 專案加入 Riverpod、go_router、Dio、Freezed/JSON、SharedPreferences、Logger、AdaptiveTheme 和基本頁面。 | [使用指南](./skills/flutter-riverpod-init/README.md) |
| [`flutter-getx-init`](./skills/flutter-getx-init/SKILL.md) | 加入 GetX 應用程式基礎設施、路由、網路、儲存、佈景主題、英文/簡體/繁體多語系，以及 DucafeUI 元件庫和離線文件。 | [使用指南](./skills/flutter-getx-init/README.md) |
| [`flutter-assets-compress`](./skills/flutter-assets-compress/SKILL.md) | 根據 `assets/images/3.0x/` 來源圖片，用純 Dart 產生 Flutter 1x、2x 圖片，壓縮支援的輸出格式，並更新 `AppImages` 索引。 | [使用指南](./skills/flutter-assets-compress/README.md) |
| [`deep-code-review`](./skills/deep-code-review/SKILL.md) | 結合儲存庫標準與審查規則，審查分支、PR、指定基準或工作區程式碼變更；自動觸發時依規模與風險選擇審查深度。 | [技能入口](./skills/deep-code-review/SKILL.md) |

## 支援的 AI 程式開發工具

透過 skills CLI 為 **OpenAI Codex、Claude Code、Cursor** 安裝技能，並依安裝程式提供的選項選擇目標 Agent。呼叫方式和自動探索能力取決於所使用的工具。

下方範例使用 Codex 風格的 `$技能名稱` 呼叫。在其他 Agent 中，請使用其技能選取方式，或在任務中明確指定技能名稱。個別工作流程可能需要命令執行、子 Agent 等能力，使用前請查看對應的 `SKILL.md`。

## Flutter 技術堆疊

| 領域 | 函式庫與工具 |
| --- | --- |
| 語言與框架 | Dart、Flutter |
| 狀態管理 | Riverpod 或 GetX |
| 路由與網路 | go_router、Dio |
| 模型與程式碼產生 | Freezed、JSON 序列化、build_runner |
| 儲存、日誌與佈景主題 | SharedPreferences、Logger、AdaptiveTheme |
| GetX UI 與多語系 | DucafeUI、GetX translations（en / zh-CN / zh-TW） |
| 圖片資源自動化 | 純 Dart 圖片處理、`AppImages` 索引 |

## 使用範例

### Flutter Riverpod 專案初始化

```text
$flutter-riverpod-init
```

參考[架構說明](./skills/flutter-riverpod-init/references/architecture.md)和[檔案範本](./skills/flutter-riverpod-init/references/file-templates.md)。

### Flutter GetX 專案初始化

```text
$flutter-getx-init
```

參考[架構說明](./skills/flutter-getx-init/references/architecture.md)和[檔案範本](./skills/flutter-getx-init/references/file-templates.md)。流程包含啟動畫面、歡迎頁、登入頁、首頁，以及離線元件說明和樣式規範。

### Flutter 圖片資源產生

```text
$flutter-assets-compress
```

參考[資源產生指南](./skills/flutter-assets-compress/README.md)。

### 深度程式碼審查

```text
$deep-code-review
```

也可以指定分支或 `main` 等比較基準。參考[審查標準](./skills/deep-code-review/references/standards.md)。此技能不審查 Markdown 和文件路徑。

## Agent Skills 如何運作

[`skills/`](./skills/) 下的每個技能目錄均包含 `SKILL.md`，定義用途、觸發條件和執行流程，並可附帶參考文件、範本、資源或輔助指令碼。程式開發 Agent 讀取這些指令並套用至專案；支援自動探索的 Agent 也可以根據任務情境選擇相符的技能。

使用前請閱讀對應技能的指令。工作流程可能修改專案檔案，並執行 `flutter pub add`、`dart run`、`flutter analyze`、`flutter test` 或 `build_runner` 等本機命令。

## 儲存庫結構

```text
.
├── skills/
│   ├── flutter-riverpod-init/   # SKILL.md、README.md、references/
│   ├── flutter-getx-init/       # SKILL.md、README.md、assets/、references/
│   ├── flutter-assets-compress/ # SKILL.md、README.md
│   └── deep-code-review/        # SKILL.md、agents/、references/、scripts/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md                   # 英文
├── README.zh-CN.md              # 簡體中文
└── README.zh-TW.md              # 繁體中文
```

## 貢獻

技能結構和驗證要求請見 [CONTRIBUTING.md](./CONTRIBUTING.md)。發布技能變更前，請檢查 front matter、目錄名稱與技能名稱的一致性、參考連結，並同步技能版本和 [CHANGELOG.md](./CHANGELOG.md)。

修改 README 時，請同步維護英文、簡體中文和繁體中文版本。連結指向的技能文件保留其原始語言。

## 授權條款

本儲存庫採用 [MIT License](./LICENSE) 開放原始碼。
