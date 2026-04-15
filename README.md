# claude-code-starter

Claude Code（Anthropic 製 CLI）と Codex（OpenAI 製 CLI）に**議論させながら作業を進める**ための、非プログラマ向けボイラープレート。

VSCode + Claude Code 拡張 + Codex 拡張をベースに、AI 同士の合議・成果物生成（PowerPoint / Excel / Word）・タスク管理などを最初からセットで使えるよう構成してあります。

---

> [!IMPORTANT]
> ## 推奨の始め方: AI に丸投げする
>
> このボイラープレートは **AI に導入を手伝わせる前提** で作ってあります。お使いの AI チャット（Claude / ChatGPT / Gemini など、Web・スマホアプリ問わず）に、下の文章をそのまま貼り付けて送るだけで OK です。
>
> ```
> https://github.com/kent013/claude-code-starter を使えるようにしたいので、
> インストールを手伝ってください。
> まず README.md / AGENTS-INSTALL.md / AGENTS.md を読んでから、
> 私の OS や経験を確認して、1 ステップずつ案内してください。
> ```
>
> AI 側が本 README を読み取り、あなたの OS（Mac / Windows）や手元の状況に合わせて **1 ステップずつ手取り足取り案内** してくれます。分からない用語、出てきたエラー、つまずいた点も、そのまま AI に聞けば解決してくれます。
>
> 以下に書かれている手順書は、**AI の案内の裏付け・リファレンス** として用意しているものです。自分で読み進めることもできますが、まずは上記のワンフレーズを AI に送るのが一番早く、確実です。
>
> ---
>
> **AI アシスタント向け**: 案内を開始する前に、本リポジトリの [`AGENTS-INSTALL.md`](./AGENTS-INSTALL.md) と [`AGENTS.md`](./AGENTS.md) を必ず取得して読んでください。`AGENTS-INSTALL.md` に案内の進め方（状況把握から始める・1 ステップずつ確認する等）、`AGENTS.md` に全応答で守るべきコミュニケーション原則が記載されています。


---

## 想定利用者

- Claude Code を初めて使う
- プログラミング経験は少ない／ない
- でも「Claude と Codex に意見を出させて比較・議論させる」「資料生成・議事録整理を AI に任せる」をやりたい
- Mac / Windows どちらでも動かしたい

---

## 最初にやること（セットアップ）

セットアップは大きく **「外側で入れるもの」**（VSCode 本体や Git など）と **「Claude が中で進めてくれるもの」**（環境構築スキル）の2段階です。

### Step 1: VSCode（エディタ）のインストール

VSCode は Microsoft が無料で配布しているプログラム編集ツールです。本ボイラープレートを使うための土台になります。

- **Mac**: <https://code.visualstudio.com/download> から「Mac」版をダウンロードして、ダウンロードした `.zip` を展開、出てきた `Visual Studio Code.app` を `アプリケーション` フォルダに移動
- **Windows**: <https://code.visualstudio.com/download> から「Windows」版（`.exe` インストーラ）をダウンロードして実行。インストール途中の選択肢はすべて初期値のままで OK
- **Linux**: <https://code.visualstudio.com/docs/setup/linux> の手順を参照

### Step 2: Sourcetree（Git の画面操作ツール）のインストール

Git はソースコードを管理するための仕組みで、本ボイラープレートを GitHub から取ってくるのに使います。Git は本来コマンド操作が必要ですが、**Sourcetree**（Atlassian が無料配布している画面操作ツール）を使うとボタン操作だけで済むので、こちらを推奨します。

- **Mac / Windows 共通ダウンロード先**: <https://www.sourcetreeapp.com/>

ダウンロードしてインストール、起動時に Atlassian アカウント（無料）でのサインインが求められたら、画面の指示に従ってください（Google アカウント等でもサインインできます）。

※ Sourcetree は Git 本体を内部で持っているため、別途 Git のインストールは不要です。コマンド操作に慣れている方は Sourcetree を使わずに直接 `git` コマンドを使っても構いません。

### Step 3: Windows の利用者のみ — Scoop（ソフト管理ツール）を入れておく

Windows では LibreOffice / pandoc / Poppler などのツールが必要になります。**Scoop**（Windows 用のソフト管理ツール、管理者権限不要）を 1 つ入れておけば、**残りは後の Step 5（環境構築スキル）が自動で入れてくれます**。

PowerShell（管理者権限は不要、普通のもの）を起動して以下を順に実行してください:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

実行ポリシー変更を聞かれたら `Y` で答えてください。Scoop の詳細: <https://scoop.sh/>

インストールが終わったら、PowerShell を **一度閉じて開き直して** ください（`scoop` コマンドが認識されるようになります）。

※ Scoop を使いたくない場合は、各ツールを個別ダウンロードして手動インストールも可能です（LibreOffice: <https://ja.libreoffice.org/download/download/>、pandoc: <https://pandoc.org/installing.html#windows>、Poppler: <https://github.com/oschwartz10612/poppler-windows/releases> ※ Poppler のみ ZIP 展開と PATH 追加の手作業が必要）。

### Step 4: 本ボイラープレートを Sourcetree で取得して VSCode で開く

1. **Sourcetree でクローン**:
   - Sourcetree を起動 → 上部の「Clone」ボタンをクリック
   - 「ソースパス / URL」欄に本リポジトリの URL を貼り付け（例: `https://github.com/<アカウント>/claude-code-starter.git`）
   - 「保存先のパス」で、リポジトリを置きたいフォルダを選択
   - 「Clone」ボタンを押すとダウンロードが始まります

2. **VSCode で開く**:
   - クローンしたフォルダをエクスプローラ（Mac は Finder）で開いて、フォルダごと VSCode のウィンドウにドラッグ＆ドロップ
   - もしくは VSCode の「ファイル」→「フォルダーを開く」から該当フォルダを選択

3. **拡張機能のインストール**:
   - VSCode 起動後、画面下に表示される推奨拡張のインストール案内に従って、**`anthropic.claude-code`（Claude Code）** と **`openai.chatgpt`（ChatGPT / Codex）** をインストール

4. **拡張機能へのサインイン**:
   - VSCode の左サイドバーから Claude Code 拡張のアイコンをクリック → サインイン
   - 続けて ChatGPT 拡張のアイコンをクリック → サインイン
   - **ログイン情報（Claude / ChatGPT の利用アカウント）について**: これらの拡張機能は有料プランの契約が必要です。会社・組織で導入している場合、**ログイン用のアカウント（メールアドレスや招待リンクなど）は管理者から配布されます**。まだ配布されていない場合は、導入担当の方に「Claude Code と Codex（ChatGPT 拡張）のログイン情報をください」と問い合わせてください。個人で導入する場合は、各サービスのサイトで有料プランに加入してから、そのアカウントでサインインします

### Step 5: 環境構築スキルを実行

Claude Code のチャット欄に以下を打って Enter:

```
/claude-code-starter-setup
```

このスキルが以下を順に進めます:

- mise（Node や Python のバージョンを切り替えて使うための道具）の導入
- Node.js 20 系 / Python 3.11 / uv の導入
- Mac の場合は Homebrew で LibreOffice / pandoc / Poppler を自動インストール
- Codex（OpenAI の AI ツール）のサインイン状態確認
- `workspace/` フォルダ（あなたの作業場所）作成
- Office ファイル操作用の公式スキル導入

利用者は質問に答えながら進めるだけで OK です。

### Step 6: 状態確認

セットアップ完了後、以下で全部入っているか確認できます:

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

### Office ファイルの生成・編集

PowerPoint / Excel / Word / PDF の生成・編集は **Anthropic 公式の Office スキル** が使われます。「企画書を PowerPoint で作って」「この Excel に列を追加して」のように、自然な日本語でお願いするだけで動きます。

### ファイル読込（MarkItDown）

「このファイルの中身を要約して」「内容を抜き出して」のような **読込・要約・抽出** の用途には **MarkItDown**（Microsoft 製の汎用ファイル → Markdown 変換ツール）が使われます。Office ファイルにとどまらず、以下のような幅広い形式に対応しています:

- Office（.pptx / .xlsx / .docx）、PDF
- 画像（OCR 文字抽出）、音声（音声認識で文字起こし）
- HTML / EPUB / YouTube URL（字幕取得）
- CSV / TSV / JSON / XML
- ZIP（中の全ファイルを再帰展開して処理）

「ZIP の中の議事録を一覧化して」「YouTube 動画の内容を箇条書きにして」のような依頼も自然な日本語で OK です。

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
