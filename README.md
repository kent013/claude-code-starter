# claude-code-starter

Claude Code（Anthropic 製 CLI）と Codex（OpenAI 製 CLI）に**議論させながら作業を進める**ための、非プログラマ向けボイラープレート。

VSCode + Claude Code 拡張 + Codex 拡張をベースに、AI 同士の合議・成果物生成（PowerPoint / Excel / Word）・タスク管理などを最初からセットで使えるよう構成してあります。

---

## 想定利用者

- Claude Code を初めて使う
- プログラミング経験は少ない／ない
- でも「Claude と Codex に意見を出させて比較・議論させる」「資料生成・議事録整理を AI に任せる」をやりたい
- Mac / Windows どちらでも動かしたい

---

## 最初にやること（セットアップ）

1. このリポジトリを VSCode で開く
2. 推奨拡張（`anthropic.claude-code` と `openai.chatgpt`）をインストール
3. Claude Code のチャットで以下のスキルを呼び出す:

```
/claude-code-starter-setup
```

このスキルが mise（バージョンマネージャ）導入 → Node 20 / Python / uv インストール → Codex 認証確認 → `workspace/` 作成 → MCP 設定案内まで対話的に進めてくれます。

セットアップ後の状態確認は:

```
/claude-code-starter-doctor
```

---

## ディレクトリの使い方

| 場所 | 用途 |
|------|------|
| `workspace/` | **あなたの自由作業場所**。生成した PowerPoint、議事録、TODO、ノートなどはここに置く（git に含まれない） |
| `.kit/` | ボイラープレート本体。**触らない** |
| `.claude/` | スキル定義などの設定。**触らない** |
| `AGENTS.md` / `CLAUDE.md` | Claude が読む動作指示。**触らない** |

ファイルを作る・編集する作業はすべて `workspace/` 内に閉じ込めるのが基本ルールです。

---

## 同梱スキル一覧

スキルは Claude Code のチャットで `/<スキル名>` または自然言語でのお願いから呼び出されます。

### セットアップ・診断

| スキル | 用途 |
|--------|------|
| `claude-code-starter-setup` | 初回環境構築（mise + Node 20 / Python / uv + Codex 認証 + workspace 作成 + MCP 案内） |
| `claude-code-starter-doctor` | 環境診断（読み取り専用、不足・問題を一覧化） |

### Codex との合議

| スキル | 用途 |
|--------|------|
| `claude-code-starter-codex-vscode` | Codex 呼び出しの共通規約（モデル選択、reasoning effort、エラーハンドリング） |
| `claude-code-starter-codex-review` | Codex とのレビュー・合議（One-shot / セッションモード、議論履歴を `workspace/notes/` に保管） |

### 成果物生成

| スキル | 用途 |
|--------|------|
| `claude-code-starter-office` | PowerPoint / Excel / Word の読込・編集・生成（uv 経由の Python） |

### タスク管理

| スキル | 用途 |
|--------|------|
| `claude-code-starter-todo-add` | `workspace/todo/TODO.md` にやることを追加 |
| `claude-code-starter-todo-close` | タスクを完了 (Closed) または廃止 (Obsoleted) として `workspace/todo/TODO-closed.md` に移動 |

### カスタマイズ

| スキル | 用途 |
|--------|------|
| `claude-code-starter-skill-add` | 自分用のカスタムスキルを新規作成（`claude-code-starter-` 以外の名前で作成、git に含まれない） |

### 開発者向け（admin_mode 専用）

| スキル | 用途 |
|--------|------|
| `claude-code-starter-update-docs` | ドキュメント類（README / .kit/README / AGENTS）の陳腐化チェック・更新 |

---

## 連携できる外部サービス（MCP）

`.mcp.json` で以下のサーバーを設定済み。トークンが必要なものは setup スキルが案内します。

| サービス | 認証 |
|----------|------|
| Context7（ライブラリ・フレームワーク公式ドキュメント検索） | 不要 |
| GitHub（Issue / PR / コード） | Personal Access Token |
| Google Drive（ファイル一覧・読込） | OAuth クレデンシャル |
| Backlog（課題管理） | API Key + ドメイン |
| DocBase（社内ドキュメント） | OAuth（初回利用時にブラウザで認証） |

---

## 困ったとき

- セットアップで失敗 → `/claude-code-starter-doctor` で現状確認
- Codex が呼べない → Codex 拡張で再サインインしてから `/claude-code-starter-doctor`
- ファイルがどこに生成されたか分からない → `workspace/` 配下を確認

---

## 内部仕様・カスタマイズ

ボイラープレート自体の構成・スクリプト・モード切替などは [.kit/README.md](.kit/README.md) を参照してください（作者・カスタマイズ担当者向け）。
