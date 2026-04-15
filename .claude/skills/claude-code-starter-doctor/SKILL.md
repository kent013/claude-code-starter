---
name: claude-code-starter-doctor
description: claude-code-starter の前提環境を読み取り専用で診断し、不足・問題を一覧化する
user-invocable: true
---

# 環境診断スキル（doctor）

claude-code-starter の利用に必要な前提が揃っているかをチェックして報告する。**インストール・修正は一切行わない**（その役割は setup スキル）。

## 実行方針（重要）

許可ダイアログを極力出さないため、以下を**厳守**する。

1. **可能な限り Claude Code 組み込みツール（Read / Glob / Grep）を使う**
   - ファイル存在確認 → Glob
   - ファイル内容読み取り → Read
   - 文字列検索 → Grep
2. **Bash は原子的な 1 コマンドのみ**実行する
   - ❌ `cmd1 && cmd2`, `cmd1 || cmd2`, `cmd1 | cmd2`, `(cmd1; cmd2)`
   - ❌ `2>&1`, `>`, `<`, `2>/dev/null` 等のリダイレクト
   - ⭕ 1つのコマンドを実行し、終了コード・stdout・stderr を素直に受け取る
   - **唯一の例外**: Codex 認証 ping は `echo ping | .kit/scripts/codex exec ... -` のパイプ1箇所のみ許容
3. **複合判定は LLM 側で**行う
   - コマンドは生の出力を返すだけ。`&&` や `||` で fallback メッセージを作らない
   - 例: `command -v mise` が非ゼロ終了なら「未導入」と LLM が判断する

## 伝え方（AGENTS.md「コミュニケーション原則」を守る）

- 利用者はエンジニア初心者または非エンジニア。専門用語はできるだけ避け、必要な場合は括弧で短く補足する
- 推測で書かない。確認できないことは「分かりません」と素直に言う
- 不要な称賛・追従はしない
- 長めの手順や専門用語が出た後は「分かりにくいところがあれば遠慮なく聞いてください」と添える
- エラー時は「設定が間違っています」ではなく「◯◯を入れていただけますか」のように、何をすればいいかを伝える

各チェック項目は以下のフォーマットで報告:

```
[✓ OK] / [⚠ 警告] / [✗ NG] 項目名
  → 詳細・対処法
```

最後にサマリ（OK件数 / 警告件数 / NG件数 / 推奨次アクション）を出力する。

## レポートファイルへの保存（必須）

診断結果は会話に表示するだけでなく、**必ず `workspace/doctor/report-<YYYYMMDD-HHMMSS>.md` としてファイルに保存する**。

- タイムスタンプは `date +%Y%m%d-%H%M%S` を1回 Bash で取得
- ディレクトリが無ければ `mkdir -p workspace/doctor`
- ファイルは `Write` ツールで書き出す（`echo >` などは使わない）
- 保存後、利用者に保存先パスを伝える

---

## OS 判定と Windows 対応

最初に `uname -s` を実行して OS を判定し、以降のチェックで **Windows 固有の分岐**を行う。

- `Darwin` → macOS
- `Linux` → Linux
- `MINGW*` / `MSYS*` / `CYGWIN*` → Windows（Git Bash / WSL 想定）
- `uname` 自体が失敗 → Windows の cmd/PowerShell 直叩きの可能性 → 「このスキルは Git Bash か WSL での実行を推奨します」と注意喚起し、以降はベストエフォートで続行

### Windows 時のスキップ・置換ルール

| 項目 | Windows での扱い |
|---|---|
| チェック3 Homebrew | **スキップ**（Windows には無い。scoop / choco / winget は本スキルの対象外）|
| チェック3 Office 系（soffice/pdftoppm/pandoc）| `command -v` でチェック続行（Git Bash なら動く）。無くても ✗ NG ではなく ⚠ 警告にとどめる |
| チェック5 VSCode 拡張パス | `~/.vscode/extensions/` ではなく `%USERPROFILE%\.vscode\extensions\` を見る（Git Bash なら `$USERPROFILE/.vscode/extensions/` と書ける） |
| チェック10 VSCode settings.json | `%APPDATA%\Code\User\settings.json`（Git Bash: `$APPDATA/Code/User/settings.json`） |
| `python3` | Windows は `python` の可能性あり。`python3` で失敗したら `python` で再試行 |
| `stat -f '%Sm'` | BSD 形式は Windows/Linux で動かない。Linux/Git Bash は `stat -c '%y'` を使う |
| `date +%Y%m%d-%H%M%S` | Git Bash なら動く。動かなければ Python で代替: `python -c "import datetime;print(datetime.datetime.now().strftime('%Y%m%d-%H%M%S'))"` |

## チェック項目と実行コマンド

### 1. OS とシェル

| 項目 | 実行 |
|---|---|
| OS | Bash: `uname -s` |
| シェル | Bash: `echo $SHELL` |

Windows（Git Bash / WSL 以外）の場合は「Mac/Linux 用コマンドの一部が利用不可。以降はベストエフォート」と注記。

### 2. mise

| 項目 | 実行 |
|---|---|
| mise 導入 | Bash: `mise --version`（非ゼロ終了 → 未導入 → ✗ NG） |
| mise trust 状態 | Bash: `mise current`（出力に `not trusted` が含まれれば ✗ NG） |
| Node 実体 | Bash: `mise exec -- node --version` |
| Python 実体 | Bash: `mise exec -- python --version` |
| uv 実体 | Bash: `mise exec -- uv --version` |
| シェル統合 | **Grep ツール** で `~/.zshrc` を `mise activate` 検索（無ければ `~/.bashrc` も） |

### 3. Homebrew / Office 依存

| 項目 | 実行 | OS |
|---|---|---|
| Homebrew | Bash: `brew --version` | **Mac/Linux のみ**（Windows はスキップ）|
| LibreOffice | Bash: `command -v soffice` | 全 OS |
| Poppler | Bash: `command -v pdftoppm` | 全 OS |
| pandoc | Bash: `command -v pandoc` | 全 OS |

### 4. 公式プラグイン（document-skills）

| 項目 | 実行 |
|---|---|
| marketplace 一覧 | Bash: `.kit/scripts/claude plugin marketplace list` |
| plugin 一覧 | Bash: `.kit/scripts/claude plugin list` |

出力を LLM が読んで、`anthropic-agent-skills` 登録 / `document-skills` installed + enabled を判定する。

### 5. VSCode 拡張

| 項目 | 実行 |
|---|---|
| claude-code 拡張 | **Glob ツール**: `~/.vscode/extensions/anthropic.claude-code-*` |
| chatgpt 拡張 | **Glob ツール**: `~/.vscode/extensions/openai.chatgpt-*` |

Glob で不可な場合のみ Bash: `ls ~/.vscode/extensions/`（単体）。Windows は `%USERPROFILE%\.vscode\extensions\` を確認。

### 6. Codex

| 項目 | 実行 |
|---|---|
| Codex 起動 | Bash: `.kit/scripts/codex --version` |
| 認証 ping | Bash: `echo ping \| .kit/scripts/codex exec --skip-git-repo-check --sandbox read-only -m gpt-5 -c 'model_reasoning_effort="low"' -`（timeout 60秒） |

ping 出力に `pong` 等の正常応答があれば OK。`unauthorized` / `token_expired` / `refresh_token` が含まれれば ✗ NG。

### 7. Codex モデルキャッシュ

- **Glob ツール**: `.kit/cache/codex-models.md` でファイル存在確認
- 存在する場合、Bash: `stat -f %Sm .kit/cache/codex-models.md`（Linux なら `stat -c %y`）
- 7日以上前なら ⚠ 警告

### 8. workspace/

- **Glob ツール**: `workspace` でディレクトリ存在確認

### 9. モード設定 `.kit/.env`

- **Read ツール**で `.kit/.env` を読む
- `admin_mode=true` → ⚠ 注意（作者モード）
- `admin_mode=false` or 行なし → ✓ OK

### 10. MCP 認証情報

#### `workspace/secrets.env`

- **Read ツール**で `workspace/secrets.env` を読む
- 各 `KEY=VALUE` 行を LLM が解析、空値キーを一覧化

#### VSCode の `claudeCode.environmentVariables`

- **Read ツール**で下記を読む（OS 判定結果に応じて使い分け）:
  - Mac: `~/Library/Application Support/Code/User/settings.json`
  - Linux: `~/.config/Code/User/settings.json`
  - Windows: `$APPDATA/Code/User/settings.json`（Git Bash）/ `%APPDATA%\Code\User\settings.json`（cmd）
- JSONC（コメント・末尾カンマ許容）なので、LLM が `claudeCode.environmentVariables` 配列を目視で探す
- 解析が難しい場合のみ Bash: `python3 -c '<<1行スクリプト>>'` で JSONC を緩く解析

### 11. `.mcp.json`

- **Read ツール**で `.mcp.json` を読む
- 必要なら Bash: `python3 -m json.tool .mcp.json` で妥当性確認

---

## サマリ出力

```
============================
診断結果サマリ
============================
✓ OK     : N 件
⚠ 警告   : M 件
✗ NG     : K 件

【推奨アクション】
- {NG項目があれば} setup スキルを実行してください
- {警告のみなら} 必要に応じて以下を実施してください: ...
- {全てOKなら} 環境は問題ありません。何か作業を始められます

→ レポートを workspace/doctor/report-YYYYMMDD-HHMMSS.md に保存しました
```

---

## 動作原則まとめ

- **読み取り専用**。ファイル作成・修正・コマンドインストールは一切行わない（workspace/doctor/ への保存を除く）
- **複合シェル演算子・リダイレクトを使わない**（Codex ping のパイプ1箇所のみ例外）
- 失敗系のチェックも途中で止めず次へ進む
- 結果は日本語で平易に
- ネットワークが必要なチェックはオフライン時「確認不可」と明記

## 許可設定との対応

本スキルで使う Bash コマンドは `.claude/settings.local.json` で事前許可されている:

- `uname`, `echo`, `command -v`, `mise`, `brew --version`
- `ls`, `test`, `stat`, `date`
- `python3 -c`, `python3 -m json.tool`
- `.kit/scripts/claude plugin`, `.kit/scripts/codex --version`, `.kit/scripts/codex exec`
- `mkdir -p workspace/**`, workspace 配下の Read/Write/Edit

許可外のコマンドを実行しそうになったら、**原子的コマンドに分解できないか先に検討する**。
