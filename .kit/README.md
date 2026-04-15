# .kit/ — ボイラープレート内部ディレクトリ

このディレクトリは **claude-code-starter ボイラープレート本体** の格納場所。利用者（ボイラープレートを使う側）は原則として中身を触らない。

本READMEは **作者（admin mode）向けのメンテナンス情報**。

---

## 役割

- ボイラープレート運用に必要なスクリプト・設定・キャッシュの置き場
- 利用者モード／作者モードの切替スイッチ（`.env`）
- 作者モード専用の `AGENTS.md` / `CLAUDE.md`（`admin/`）

利用者が触れるべきものは `.kit/` の外（ルート `AGENTS.md`、`workspace/`、`.claude/skills/` 等）に置く。

---

## ディレクトリ構成

```
./
├── README.md                   # 利用者・作者共通の入口（セットアップ概要、スキル一覧）
├── AGENTS.md                   # 利用者モード本文 + .kit/.env を見て分岐する指示
├── AGENTS-INSTALL.md           # AI アシスタント向けセットアップ案内ガイド
├── CLAUDE.md                   # スタブ（AGENTS.md 嫁）
├── .gitignore                  # workspace/ と OS 隠しファイルを除外
├── mise.toml                   # Node / Python / uv のバージョン宣言（mise が読む）
├── .mcp.json                   # MCP サーバー設定（github/gdrive/context7/backlog/docbase）
├── .vscode/
│   ├── extensions.json         # 推奨拡張: anthropic.claude-code, openai.chatgpt
│   └── settings.json           # claudeCode.respectGitIgnore: false
├── .claude/
│   ├── settings.local.json                             # gitignored ではないが各自環境向け：Bash 許可パターンなど
│   └── skills/
│       ├── .gitignore                                  # claude-code-starter-* のみ committed、利用者作成スキルは ignore
│       ├── claude-code-starter-setup/SKILL.md          # 初回環境構築（mise + Node 20 / Python / uv + Codex認証 + MCP案内）
│       ├── claude-code-starter-doctor/SKILL.md         # 環境診断（読み取り専用、不足を一覧化）
│       ├── claude-code-starter-codex-vscode/SKILL.md   # Codex 呼び出し共通規約
│       ├── claude-code-starter-codex-review/SKILL.md   # Codex レビュー・合議規約
│       ├── claude-code-starter-mcp-setup/SKILL.md      # MCP（GitHub / Backlog / GDrive / DocBase / Context7）対話セットアップ
│       ├── claude-code-starter-todo-add/SKILL.md       # workspace/todo/TODO.md にタスク追加
│       ├── claude-code-starter-todo-close/SKILL.md     # workspace/todo/TODO-closed.md へ移動 (Closed/Obsoleted)
│       ├── claude-code-starter-skill-add/SKILL.md      # 利用者カスタムスキルを新規作成（gitignored）
│       ├── claude-code-starter-session-export/SKILL.md # セッション .jsonl を workspace/sessions/ に書き出し（報告用）
│       └── claude-code-starter-update-docs/SKILL.md    # ドキュメント更新（admin_mode=true 専用）
├── workspace/                  # gitignored。利用者の自由作業場所
└── .kit/                       # ボイラープレート本体（利用者は触らない）
    ├── README.md               # 本ファイル
    ├── .env                    # gitignored。admin_mode=true|false のスイッチ
    ├── .env.example            # committed。設定テンプレート
    ├── secrets.env.example     # committed。MCP 認証トークンのテンプレート（実体は workspace/secrets.env）
    ├── .gitignore              # cache/ と .env を除外
    ├── admin/
    │   ├── AGENTS.md           # 作者モード時に適用される指示
    │   └── CLAUDE.md           # スタブ（AGENTS.md 嫁）
    ├── cache/                  # gitignored。実行時に自動生成
    │   └── codex-models.md     # Codex から取得したモデル一覧
    └── scripts/
        ├── codex                      # Mac/Linux: VSCode 拡張の codex バイナリ起動
        ├── codex.cmd                  # Windows 版
        ├── claude                     # Mac/Linux: VSCode 拡張の claude バイナリ起動（plugin 操作等で使用）
        ├── claude.cmd                 # Windows 版
        ├── refresh-codex-models       # Codex にモデル一覧を問い合わせて cache/ に保存
        └── refresh-codex-models.cmd   # Windows 版
```

---

## モード切替

`.kit/.env` の `admin_mode` で切替:

| 値 | モード | 適用される指示 |
|----|--------|----------------|
| `admin_mode=true` | 作者モード | `.kit/admin/AGENTS.md`（git操作可、.kit/ 編集可） |
| `admin_mode=false`（または .env 無し） | 利用者モード | ルート `AGENTS.md`（git禁止、.kit/ 編集禁止） |

切替:

```sh
# 作者モードに切替
cp .kit/.env.example .kit/.env
# .kit/.env を編集して admin_mode=true にする
```

---

## スクリプト

### `scripts/codex` / `scripts/codex.cmd`

VSCode拡張 `openai.chatgpt` に同梱されている codex バイナリを動的検出して起動。別途インストール不要で、拡張のアップデートに自動追従する。

### `scripts/claude` / `scripts/claude.cmd`

VSCode拡張 `anthropic.claude-code` に同梱されている claude バイナリを動的検出して起動。`.claude/skills/` 内スクリプトから `plugin list` / `plugin marketplace add` 等の Claude Code CLI 機能を呼び出すのに使う。拡張のアップデートに自動追従する。

### `scripts/refresh-codex-models` / `.cmd`

Codex CLI にモデル一覧を取得する公式コマンドが存在しないため、**bootstrap モデル（`gpt-5`）に対して自然言語でモデル一覧を問い合わせ**、結果を `.kit/cache/codex-models.md` に保存する。

スキル側は以下のロジックで参照する:

1. `.kit/cache/codex-models.md` の mtime をチェック
2. 存在しない、または 7日以上前 → `refresh-codex-models` を先に実行
3. キャッシュから用途に応じたモデル名を選択

bootstrap モデル自体が将来廃止された場合は `scripts/refresh-codex-models` 内の `BOOTSTRAP_MODEL` 変数を書き換える（スキル側の修正は不要）。

---

## メンテナンス指針

- **利用者モードで壊れない**ことを常に確認する。変更後は `.kit/.env` を削除または `admin_mode=false` にして動作確認する
- **スキル命名**: `claude-code-starter-*` プレフィックスで統一
- **設計判断**: Claude Code のmemory (`~/.claude/projects/<hash>/memory/`) に記録されている。更新時は整合性を確認
- **依存**: 作業前提として [VSCode拡張 anthropic.claude-code / openai.chatgpt] が必要。`.vscode/extensions.json` で推奨リストに登録済み

---

## 既知の将来課題

- **rescue系スキル未実装**: 利用者のClaudeセッションファイルを抽出してzip化するスキル（サポート依頼対応用）
- **doctor → setup の自動連携未実装**: doctor が NG を出した時に「`/claude-code-starter-setup` を実行しますか？」と促す導線
- **MCP 接続テスト未実装**: doctor は `.mcp.json` の妥当性しか見ておらず、各 MCP サーバーの実起動・認証可否までは確認していない
