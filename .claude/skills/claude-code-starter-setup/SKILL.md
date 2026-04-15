---
name: claude-code-starter-setup
description: claude-code-starter ボイラープレートの初回環境構築（mise + Node 20 / Python / uv + Codex認証確認 + workspace作成）
user-invocable: true
---

# 環境構築スキル

claude-code-starter の利用に必要な前提環境を整える。利用者は本スキルを最初に実行する。

実行手順は **OS（Mac/Linux/Windows）に応じて分岐** する。Claude は最初に `uname` または OS 判定を行い、適切な手順を選ぶこと。

各ステップは順に実行し、**失敗した場合は次に進まず利用者に状況を説明** すること。

**重要: 自動化できる手順は説明だけで済ませず、Bash ツールで実際に実行すること。** 「以下のコマンドを実行してください」と利用者にお願いするのは、**Claude 自身では実行できないもの（スラッシュコマンド、Windows でのインストーラ起動、管理者権限が要る GUI 操作 等）に限る**。Mac の brew や mise などの CLI コマンドは Claude が Bash ツールで直接走らせる。

## 伝え方（AGENTS.md「コミュニケーション原則」を必ず守る）

- 利用者はエンジニア初心者または非エンジニア。専門用語はできるだけ避け、必要な場合は括弧で短く補足する（例: `mise`（Node や Python の複数バージョンを切り替えて使うための道具））
- 推測で書かない。確認できないことは「分かりません」と素直に言う
- 不要な称賛・追従はしない（「いいですね！」「素晴らしい質問！」など禁止）
- 長めの手順説明や専門用語が出た後は「分かりにくいところがあれば遠慮なく聞いてください」と添える
- エラー時は「設定が間違っています」ではなく「◯◯を入れていただけますか」のように、何をすればいいかを伝える

ツールのバージョン管理は **mise** に一本化している（Node / Python / uv をまとめて管理）。プロジェクトルートの `mise.toml` が真実のソース。

---

## ステップ1: OS判定

```sh
uname -s
```

- `Darwin` → Mac
- `Linux` → Linux
- 上記以外（Windows）→ Windows 用手順を案内

---

## ステップ2: mise のインストール確認・導入

`mise` の有無を確認:

```sh
command -v mise
```

### 未インストールの場合

#### Mac / Linux

```sh
curl https://mise.run | sh
```

インストール後、現セッションで PATH を読み込み:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

シェル統合（次回以降のターミナルで自動有効化）:

```sh
# zsh の場合
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# bash の場合
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
```

利用者には「**新しいターミナルを開くと mise が自動で有効になります**」と案内する。

#### Windows (PowerShell)

```powershell
winget install jdx.mise
```

または Scoop:

```powershell
scoop install mise
```

PowerShell プロファイルへの追加:

```powershell
Add-Content -Path $PROFILE -Value 'mise activate pwsh | Out-String | Invoke-Expression'
```

### 確認

```sh
mise --version
```

---

## ステップ3: プロジェクト依存ツールの導入

mise はプロジェクトの `mise.toml` を初めて見る時、安全のため明示的な trust が必要。プロジェクトルートで以下を実行:

```sh
mise trust
```

これで本リポジトリの `mise.toml` が信頼済みとして登録される（`~/.local/share/mise/trusted-configs/` に記録）。

その後、宣言された `node`, `python`, `uv` を一括で導入:

```sh
mise install
```

導入後、対話的セッションでツールが PATH に乗っているか確認:

```sh
mise exec -- node --version    # v20.x.x
mise exec -- python --version  # 3.11.x
mise exec -- uv --version      # uv x.y.z
```

シェル統合済みなら `mise exec --` を省略可能（ディレクトリ移動で自動activate）:

```sh
node --version
python --version
uv --version
```

---

## ステップ4: Office 系の依存（Homebrew + LibreOffice + Poppler + pandoc）

Anthropic 公式の Office スキル（pptx / xlsx / docx / pdf）を使うために、以下のアプリ・ツールを **Claude が Bash ツールで実際に導入** する。説明だけで済ませず、必ず Bash 実行までやること。

### Mac の場合

#### 4-1. Homebrew の確認・導入

`brew`（Mac/Linux 向けのアプリ・コマンド管理ツール、Mac でいう App Store のコマンド版のようなもの）の有無を確認:

```sh
command -v brew >/dev/null && brew --version | head -1 || echo "MISSING"
```

未インストール（`MISSING` が出る）場合、公式インストーラを実行する。**管理者パスワードを聞かれる** ので、利用者に「sudo パスワードの入力画面が出ます」と先に伝えてから実行する:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 4-2. 依存ツールの確認・導入

それぞれ未導入のものだけ入れる（既に入っているものは何もしない）。

```sh
brew list --cask libreoffice >/dev/null 2>&1 || brew install --cask libreoffice
brew list poppler            >/dev/null 2>&1 || brew install poppler
brew list pandoc             >/dev/null 2>&1 || brew install pandoc
```

LibreOffice はファイルサイズが約 700MB ほどあるため、初回は数分かかる旨を利用者に伝える。

#### 4-3. 動作確認

```sh
soffice --version
pdftoppm -v 2>&1 | head -1
pandoc --version | head -1
```

3つすべてバージョン情報が返れば成功。

### Windows の場合

#### 4-W-1. Scoop（Windows 用ソフト管理ツール、管理者権限不要）の確認

PowerShell 経由でチェックする（Claude が Bash から `powershell.exe` を呼ぶ）:

```sh
powershell.exe -NoProfile -Command "Get-Command scoop -ErrorAction SilentlyContinue | Out-Null; if ($?) { 'INSTALLED' } else { 'MISSING' }"
```

#### 4-W-2-A. Scoop が未インストールの場合 — 利用者に丁寧に案内

**Scoop は Claude が自動でインストールしない**（PowerShell の実行ポリシー変更を伴うため、利用者の意思確認が必要）。以下のように案内する:

```
LibreOffice / pandoc / Poppler を一括で導入するために、Scoop（スクープ：Windows 向けの
ソフト管理ツール、管理者権限不要）を先に入れていただく必要があります。

PowerShell（普通のもの、管理者として開く必要はありません）を起動して、以下を順にコピペして
Enter してください:

1. 実行ポリシーの変更（一度だけ。Scoop のインストールスクリプトを動かすために必要）:
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

   「実行ポリシーの変更」を聞かれたら Y で答えてください。

2. Scoop の本体をインストール:
   irm get.scoop.sh | iex

3. インストールが終わったら、PowerShell を一度閉じて開き直してください
   （新しいプロファイルで scoop コマンドが認識されるようになります）

完了したら、Claude にもう一度「セットアップを続けて」とお伝えください。
```

「分かりにくいところがあれば遠慮なく聞いてください」と添えること。完了確認は再度本ステップ冒頭の `Get-Command scoop` を実行する。

#### 4-W-2-B. Scoop が導入済みの場合 — 残りを自動インストール

```sh
powershell.exe -NoProfile -Command "scoop bucket add extras; scoop install libreoffice pandoc poppler"
```

`bucket add extras` は LibreOffice が extras バケットにあるため必要。既に追加済みの場合はエラーが出るが無視してよい。

#### 4-W-3. 動作確認

```sh
powershell.exe -NoProfile -Command "soffice --version; pdftoppm -v; pandoc --version | Select-Object -First 1"
```

3つともバージョン情報が返れば成功。

### Linux の場合

```sh
sudo apt update
sudo apt install -y libreoffice poppler-utils pandoc
```

---

## ステップ5: Codex 認証の確認

VSCode拡張 `openai.chatgpt`（Codex）にログイン済みか確認する。

### 認証チェック

軽量な Codex 呼び出しで認証状態を判定:

```sh
echo "ping" | .kit/scripts/codex exec --skip-git-repo-check --ephemeral --sandbox read-only \
  -m gpt-5 -c 'model_reasoning_effort="low"' -o /tmp/codex-auth-check.txt - 2>&1 \
  | grep -qi "unauthorized\|token_expired\|refresh_token" && echo "NOT_AUTHENTICATED" || echo "AUTHENTICATED"
```

### 未認証の場合の案内

利用者に以下を伝える:

```
【Codex のサインインが必要です】

1. このプロジェクトの管理者に「Codex の API キー」を発行してもらってください
2. VSCode の左サイドバーにある ChatGPT / Codex 拡張のアイコン（吹き出しマーク）をクリックして拡張を開いてください
3. 拡張内の「Sign in」ボタンから、管理者から受け取った API キーを入力してサインインしてください
4. サインイン完了後、もう一度この環境構築スキルを実行してください
```

Codex 拡張が VSCode 自体にインストールされていない場合は、`.vscode/extensions.json` の推奨に従って `openai.chatgpt` をインストールするよう案内する。

---

## ステップ6: workspace/ ディレクトリの作成

```sh
mkdir -p workspace
```

利用者に以下を伝える:

```
【workspace/ について】

このプロジェクトでファイルを作る時は、原則として workspace/ ディレクトリの中に作成してください。

- workspace/ の中身は git に含まれません（個人作業用の領域）
- workspace/ の外（特に .kit/ や .claude/）は触らないでください
- Codex と Claude の議論結果や、生成した PowerPoint / 文書なども workspace/ 内に置きます
```

---

## ステップ7: 公式 Office スキル（プラグイン）の導入

Anthropic が公開している `anthropics/skills` には pptx / xlsx / docx / pdf の高品質なスキルが含まれており、Claude Code のプラグイン機能でインストールできる。

VSCode 拡張内のチャット欄ではスラッシュコマンド（`/plugin ...`）が通らないことがあるため、**`.kit/scripts/claude` 経由で Bash から CLI を直接叩く** 方式を使う。

### 7-1. 現在の導入状況を確認

```sh
.kit/scripts/claude plugin list 2>&1 | grep -q "document-skills@anthropic-agent-skills" && echo "INSTALLED" || echo "MISSING"
```

`INSTALLED` なら以降をスキップして「公式 Office スキルは導入済みです」と伝えて完了。

### 7-2. marketplace を登録（未登録の場合のみ）

```sh
.kit/scripts/claude plugin marketplace list 2>&1 | grep -q "anthropic-agent-skills" || \
  .kit/scripts/claude plugin marketplace add anthropics/skills
```

初回は GitHub から clone するため数秒〜十数秒かかる。利用者にその旨を伝える。

### 7-3. プラグインをインストール

```sh
.kit/scripts/claude plugin install document-skills@anthropic-agent-skills
```

成功メッセージ（`✔ Successfully installed plugin: ...`）が出れば完了。

### 7-3b. プラグインを enable する

**インストール直後はデフォルトで disabled** のため、必ず enable する:

```sh
.kit/scripts/claude plugin enable document-skills@anthropic-agent-skills
```

確認:

```sh
.kit/scripts/claude plugin list 2>&1 | grep -A1 document-skills
```

`Status: ✔ enabled` が出れば反映準備完了。

### 7-4. 反映

新しい Claude Code セッション（チャットを新規作成 or VSCode 再起動）で pptx / xlsx / docx / pdf スキルが認識される旨を利用者に伝える。

---

## ステップ8: MCP セットアップの案内（初回はスキップ推奨）

`.mcp.json` には複数の MCP サーバー（GitHub / Backlog / Google Drive / DocBase / Context7）が定義されているが、**初回 setup ではまとめて設定しない**。

利用者に以下を伝える:

```
MCP（外部サービス連携）は今は設定をスキップします。
GitHub / Backlog / Google Drive などを使いたくなったら、その時点で個別にセットアップできます:

  /claude-code-starter-mcp-setup github
  /claude-code-starter-mcp-setup backlog
  /claude-code-starter-mcp-setup gdrive

DocBase（社内ドキュメント）と Context7（公式ドキュメント検索）はトークン不要で、
Claude が自動で接続します。
```

`workspace/secrets.env` テンプレートだけ用意しておく:

```sh
test -f workspace/secrets.env || cp .kit/secrets.env.example workspace/secrets.env
```

---

## ステップ9: 完了報告

すべてのステップが成功したら以下のように報告:

```
【環境構築が完了しました】

- mise: 導入済み（Node / Python / uv を一括管理）
- Node.js: v20.x.x
- Python: 3.11.x
- uv: 導入済み
- Homebrew (Mac): 導入済み
- LibreOffice / Poppler / pandoc: 導入済み
- Codex: サインイン済み
- workspace/: 作成済み
- 公式 Office スキル: 導入手順を案内済み（利用者がスラッシュコマンドで実行）
- MCP: <設定済みサービス一覧>

これで Claude と Codex に議論させる準備が整いました。
何か作業を始めたい時は、自然な日本語で指示してください（例: 「PowerPointを作って」「企画書をまとめて」など）。
```

失敗ステップがあった場合は、どのステップで止まったか、何を手動で対処すべきかを明示する。

---

## 失敗時のフォールバック方針

- **ネットワークエラー**: 「インターネット接続を確認してください」と案内し、再試行可能であることを伝える
- **権限エラー**（Windows winget 等）: 管理者権限での実行を案内
- **mise インストール後にコマンドが見つからない**: 新しいターミナルを開く必要がある or `export PATH="$HOME/.local/bin:$PATH"` を案内
- **mise activate を入れていないのにコマンドが見つからない**: `mise exec -- <command>` で代替できると案内、または `~/.zshrc` 等への追記を促す
- **`mise ERROR Config files ... are not trusted`**: 本プロジェクトの `mise.toml` をまだ信頼していない状態。`mise trust` を実行してから再試行
- **Codex 401**: ステップ4の案内を再度提示
