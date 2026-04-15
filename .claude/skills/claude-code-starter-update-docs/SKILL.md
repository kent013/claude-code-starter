---
name: claude-code-starter-update-docs
description: 開発者向けドキュメント（README.md / .kit/README.md / AGENTS.md 系）の陳腐化チェック・欠落検出・更新を一括実行する（admin_mode=true 専用）
user-invocable: true
argument-hint: '[scope]  例: scope省略=全体、"skills"=スキル関連のみ、"setup"=setup関連のみ'
---

# ボイラープレート ドキュメント更新スキル

claude-code-starter のドキュメント類を、リポジトリの実状（スクリプト・スキル・設定ファイル）と突き合わせて陳腐化・欠落を検出し、更新する。

**このスキルは admin_mode=true（作者モード）専用。** `.kit/.env` の `admin_mode` が `true` でない場合は最初のステップで Reject する。

---

## 引数

| 引数 | 必須 | 説明 |
|------|------|------|
| scope | No | 更新対象のスコープ（省略時は全ドキュメント）。例: `skills`, `setup`, `mcp`, `scripts` |

---

## 対象ドキュメント

| ファイル | 役割 |
|---------|------|
| `README.md` | プロジェクト全体の説明（利用者・将来の作者の入口） |
| `.kit/README.md` | ボイラープレート内部仕様・メンテナンス情報（作者向け） |
| `AGENTS.md` | 利用者モードの動作指示 |
| `.kit/admin/AGENTS.md` | 作者モードの動作指示 |
| `CLAUDE.md` / `.kit/admin/CLAUDE.md` | スタブ（通常は更新不要） |

---

## 基本原則

### ハルシネーション防止

ドキュメントに書く内容は必ず **実ファイル** で裏取りすること。推測で書かない。

- スキル一覧は `.claude/skills/` の実ディレクトリから取得
- スクリプト一覧は `.kit/scripts/` の実ファイルから取得
- MCP一覧は `.mcp.json` から取得
- mise依存は `mise.toml` から取得

「〜と思われる」「〜の可能性がある」は禁止。確認できないなら書かない。

### 最小変更の原則

- 正確な記述は変更しない
- 構造が変わっていない部分の書き直しは不要
- 新規ドキュメント作成は、既存に統合できない場合のみ
- 利用者モード AGENTS.md は **「プログラミング未経験者が読む」前提**を死守する

---

## Step 0: モード確認（必須）

`.kit/.env` の `admin_mode` を読む。

```sh
test -f .kit/.env && grep -E '^admin_mode=true' .kit/.env >/dev/null
```

`admin_mode=true` でない場合:

```
REJECT

このスキルは作者モード (admin_mode=true) 専用です。
.kit/.env に admin_mode=true を設定してから再実行してください。
```

**ここで処理を終了する**（ドキュメントは変更しない）。

---

## Step 1: 現状把握

### 1-1. ドキュメント一覧

```sh
ls -la README.md AGENTS.md CLAUDE.md .kit/README.md .kit/admin/AGENTS.md .kit/admin/CLAUDE.md 2>/dev/null
```

### 1-2. リポジトリ実状の収集

`scope` 引数に応じて以下を取得:

| scope | 確認対象 |
|-------|----------|
| (省略) | 下記すべて |
| `skills` | `.claude/skills/*/SKILL.md` の name と description |
| `setup` | `.claude/skills/claude-code-starter-setup/SKILL.md`、`mise.toml`、`.kit/scripts/` |
| `mcp` | `.mcp.json`、`.kit/secrets.env.example` |
| `scripts` | `.kit/scripts/` の実ファイル一覧 |

具体コマンド:

```sh
# スキル一覧
for f in .claude/skills/*/SKILL.md; do
  awk '/^name:/ {n=$2} /^description:/ {sub(/^description: /,""); print n " — " $0; exit}' "$f"
done

# スクリプト一覧
ls .kit/scripts/

# MCP一覧
python3 -c "import json; print('\n'.join(json.load(open('.mcp.json'))['mcpServers'].keys()))"

# mise依存
grep -E '^[a-z]+ =' mise.toml
```

---

## Step 2: 陳腐化チェック

各ドキュメントについて、以下の観点で実状との乖離を検出:

| チェック観点 | 方法 |
|------------|------|
| **スキル一覧の差分** | ドキュメント記載のスキル名 vs 実ディレクトリ |
| **スクリプト一覧の差分** | ドキュメント記載のスクリプト名 vs `.kit/scripts/` 実ファイル |
| **MCP一覧の差分** | ドキュメント記載の MCP 名 vs `.mcp.json` |
| **ディレクトリツリー** | ドキュメント記載のツリー vs 実状 |
| **手順の陳腐化** | コマンド・パス・引数が実装と一致するか |
| **利用者向け文言** | プログラミング前提の表現が紛れ込んでいないか（AGENTS.md利用者モード） |

検出結果の記録例:

```
[陳腐化] .kit/README.md: スキル一覧に claude-code-starter-doctor が抜けている
[欠落]   README.md: ファイルが存在しない（新規作成必要）
[OK]     AGENTS.md: 最新
```

---

## Step 3: 欠落ドキュメントの新規作成

### README.md（プロジェクトルート、欠落していれば作成）

利用者・将来の作者が最初に読む入口。最低限以下を含める:

- プロジェクトの目的（Claude × Codex 合議用ボイラープレート）
- 想定利用者
- セットアップ手順（要約 + setup スキル参照）
- ディレクトリ構成（簡略版、詳細は `.kit/README.md` へ誘導）
- 主要スキルの一覧と用途

### その他

既存ドキュメントに追記で済むものは新規作成しない。独立した観点が必要な時のみ新規作成。

---

## Step 4: 更新の実施

### 4-1. 既存ドキュメントの更新

Step 2 で検出した乖離を修正する。

**ツリー記述の更新ルール**:
- `tree` コマンドや実 `ls` 結果を確認してから書く
- 最新ファイルは追加、削除済みファイルは消去
- インデント・コメント揃えを保つ

**スキル一覧記述の更新ルール**:
- name はスキル定義の frontmatter から正確に転記
- 説明は frontmatter の description を要約・敬体化

### 4-2. 新規ドキュメントの作成

Step 3 で必要と判断したものを作成。

### 4-3. 不要ドキュメントの削除

対応する仕組みが完全に削除されているドキュメントは削除する（**削除前に利用者に確認**）。

---

## Step 5: 完了報告

```
## ドキュメント更新完了

### 更新サマリー
- 更新: {N}件（{ファイル名リスト}）
- 新規作成: {N}件（{ファイル名リスト}）
- 削除: {N}件（{ファイル名リスト}）

### 主な修正
- {修正内容の箇条書き、各項目1行}

### 確認推奨
- {利用者モード AGENTS.md を編集した場合は「実際に admin_mode=false で動作確認推奨」と添える}
```
