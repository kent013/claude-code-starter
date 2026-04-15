---
name: claude-code-starter-codex-vscode
description: .kit/scripts/codex exec を使ったOpenAIモデル呼び出しの共通規約
user-invocable: false
---

# codex-vscode 呼び出し規約

OpenAI モデルへの問い合わせは codex-vscode（`.kit/scripts/codex`）経由で実行する。

---

## 基本コマンド（One-shot）

```bash
.kit/scripts/codex exec --ephemeral --sandbox read-only -m {model} \
  -c 'model_reasoning_effort="{reasoning}"' \
  -o {出力ファイル} - < {プロンプトファイル}
```

**必須オプション**:
- `--ephemeral`: セッションファイルを永続化しない
- `--sandbox read-only`: コマンド実行・ファイル書き込みを禁止（ファイル読み込みは許可）
- `-m {model}`: モデルを指定
- `-c 'model_reasoning_effort="{reasoning}"'`: reasoning effortを指定（`~/.codex/config.toml` のグローバル設定を上書き）
- `-o {出力ファイル}`: 結果をファイルに保存
- `- < {プロンプトファイル}`: プロンプトをstdin経由で渡す

---

## 利用可能モデル

モデル名は変動する（新モデル追加・旧モデル廃止）ため、**`.kit/cache/codex-models.md` を真実のソースとする**。

### モデル選択手順

1. `.kit/cache/codex-models.md` の存在と鮮度を確認
   - 存在しない、または mtime が 7日以上前 → まず `.kit/scripts/refresh-codex-models`（Windows: `refresh-codex-models.cmd`）を実行してキャッシュを更新
2. キャッシュ内のリストから用途に応じて選択:
   - **コード分析・レビュー・技術設計**: `-codex` サフィックスが付いた最新世代モデル（例: `gpt-5.3-codex`）
   - **自然言語中心の議論・概念設計**: `-codex` サフィックスの無い最新世代モデル（例: `gpt-5.4`）
3. 指定モデルが API 側で拒否された場合: refresh を強制実行してから再選択

### bootstrap モデル

`refresh-codex-models` スクリプトは `gpt-5` をbootstrapとして listing 呼び出しに使う。将来 `gpt-5` が廃止された場合は `.kit/scripts/refresh-codex-models` 内の `BOOTSTRAP_MODEL` を書き換える（全skillを横断する更新は不要）。

---

## Reasoning Effort

`-c 'model_reasoning_effort="{reasoning}"'` で推論の深さを制御する。
`~/.codex/config.toml` のグローバル設定（`model_reasoning_effort`）はモデルとの互換性問題を起こす場合があるため、**常にコマンドラインで明示指定すること**。

| レベル | 対応モデル | 用途 |
|--------|-----------|------|
| `low` | 全モデル | 高速・軽量な応答 |
| `medium` | 全モデル | 議論・分析・ブレスト用（**デフォルト推奨** — Claudeが評価・選別する場面） |
| `high` | 全モデル | コードレビュー・安全性判定用（Codex判断が直接品質に影響する場面） |
| `xhigh` | `gpt-5.3-codex`, `gpt-5.4`, `gpt-5.2-codex`, `gpt-5.1-codex-max` のみ | 最大の推論深度 |

**注意**: `gpt-5-codex`, `gpt-5.1-codex`, `gpt-5` 等の旧モデルは `xhigh` 非対応。

---

## プロンプトの渡し方

1. **Write ツール**でプロンプトファイルを作成（`{notes_dir}/codex-history/{label}-prompt-round-{N}.md`、`notes_dir` は `workspace/notes/{YYYY-MM-DD}-{topic}/`）
2. **stdin経由**で `.kit/scripts/codex exec` に渡す（`- < {ファイルパス}`）
3. 結果は `-o` で指定したファイルに出力される
4. **シェル引数でプロンプトを渡してはならない**（エスケープ・長さ制限の問題を回避）
5. **プロンプトは `/tmp` 等に書き出さない**。議論履歴として `workspace/notes/` 配下に保管し、後から見返せるようにする

詳細は `claude-code-starter-codex-review` スキルの「議論履歴の保存方針」を参照。

---

## セッション管理（文脈保持が必要な場合）

複数ラウンドの会話で文脈を維持する場合は `claude-code-starter-codex-review` スキルのセッションモードを参照。

---

## プラットフォーム補足

- Mac / Linux / WSL / Git Bash: `.kit/scripts/codex` を使用
- Windows (cmd / PowerShell): 同じパスで `.kit/scripts/codex.cmd` が自動解決される

---

## エラーハンドリング

- `.kit/scripts/codex exec` が非ゼロ終了コードを返した場合、30秒待って1回リトライ
- 2回連続失敗時は呼び出し元の規定に従う
