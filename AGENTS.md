# AGENTS.md

## モード判定（毎回最初に実行）

会話の最初に `.kit/.env` を読み、`admin_mode` の値を確認すること。

- ファイルが存在しない、または `admin_mode=false` → **利用者モード**。本ファイルの以降のセクションを適用
- `admin_mode=true` → **作者モード**。本ファイルの以降は無視し、`.kit/admin/AGENTS.md` の指示に従うこと

---

## 利用者モードの指示

このプロジェクトは Claude と Codex に議論させるためのボイラープレートです。利用者はプログラミング経験が浅いことを前提に、以下の制約を守って動作してください。

### 禁止事項

- **gitコマンドの実行禁止** — `git commit`, `git push`, `git reset`, `git checkout`, `git branch` などすべて実行しないこと。利用者がgit操作を望む場合も「自分でターミナルから実行してください」と案内する
- **`.kit/` 以下の編集禁止** — このディレクトリはボイラープレート本体であり、利用者の作業対象ではない
- **`.claude/skills/claude-code-starter-*` の編集禁止** — boilerplate 同梱スキルは保護対象
- **`AGENTS.md` / `CLAUDE.md` の編集禁止** — 本ファイルおよび関連設定ファイルは保護対象
- **破壊的操作の禁止** — `rm -rf`, ファイル一括削除, プロセスkill 等は実行前に必ず確認

### カスタムスキルの作成は許容

利用者が自分用のスキルを増やしたい場合は **`claude-code-starter-skill-add` スキル** を使う。これは `.claude/skills/<利用者命名>/` を作成するが、`claude-code-starter-*` 以外の名前のスキルは `.gitignore` で除外されるため git に含まれない。

- 利用者から「スキルを作りたい」「{タスク}を毎回お願いするのが面倒なのでテンプレ化したい」等の要望が出た時は `/claude-code-starter-skill-add` を提案する
- カスタムスキル名は **必ず `claude-code-starter-` 以外** で命名する（例: `my-`, `custom-`, `<名前>-` プレフィックス）

### 推奨される動作

- 新しいファイルを作る場合は `workspace/` 配下を使う（gitに含まれない作業領域）
- Codex との議論が必要な場合は `claude-code-starter-codex-review` / `claude-code-starter-codex-vscode` スキルを参照する
- エラーが出た場合は「何が起きたか」「どう対処すればいいか」を日本語でわかりやすく説明する

### 困った時の案内

- Codex呼び出しが失敗する → `codex login` の実行を案内
- VSCode拡張が見つからない → `anthropic.claude-code` / `openai.chatgpt` のインストールを案内
