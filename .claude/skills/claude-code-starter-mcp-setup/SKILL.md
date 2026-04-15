---
name: claude-code-starter-mcp-setup
description: 個別の MCP サービス（GitHub / Backlog / Google Drive / DocBase / Context7）のセットアップを対話的にサポートする
user-invocable: true
argument-hint: '[service]  例: github / backlog / gdrive / docbase / context7（省略時は対話で選ぶ）'
---

# MCP 個別セットアップスキル

`.mcp.json` で定義されている MCP サービスのうち、利用者が「使いたくなった」タイミングで 1 つずつセットアップする。

`.kit/secrets.env.example` のテンプレートと `.mcp.json` の定義に従って、トークン入手 → `workspace/secrets.env` 記入 → VSCode 設定への反映、を順に案内する。

## 伝え方（AGENTS.md「コミュニケーション原則」を必ず守る）

- 利用者はエンジニア初心者または非エンジニア。専門用語はできるだけ避け、必要な場合は括弧で短く補足する（例: 「Personal Access Token（GitHub にログインする代わりにアプリが使う合言葉のようなもの）」）
- 推測で書かない。確認できないことは「分かりません」と素直に言う
- 不要な称賛・追従はしない
- 手順説明後は「分かりにくいところがあれば遠慮なく聞いてください」と添える
- トークン発行手順など外部サイトの操作は「ボタンの場所が変わっているかもしれない」ことを前提に、見つからない時はスクリーンショット送ってもらえれば一緒に探します、と伝える

---

## 引数

| 引数 | 必須 | 説明 |
|------|------|------|
| service | No | `github` / `backlog` / `gdrive` / `docbase` / `context7`（省略時は対話で選ぶ） |

---

## 手順

### Step 1: サービス指定の確認

設定が必要なサービス（**GitHub / Backlog / Google Drive**）のうち、どれをセットアップするかを聞く。

引数 `service` が無ければ利用者に聞く:

```
どの MCP サービスをセットアップしますか？（設定が必要なものだけ聞いています）

1. github  — リポジトリ・Issue・PR の参照／作成
2. backlog — 課題管理（チケット参照・作成）
3. gdrive  — Google Drive のファイル一覧・読込

番号または名前で答えてください。

(参考: docbase / context7 は事前設定不要のため本スキルでは扱いません)
```

引数で `docbase` / `context7` が指定された場合は「設定不要なので何もしません」と即返す。

### Step 2: workspace/secrets.env の準備

無ければテンプレートから作成:

```sh
test -f workspace/secrets.env || cp .kit/secrets.env.example workspace/secrets.env
```

### Step 3: サービス別の案内

#### github

```
GitHub 連携には1つ「Personal Access Token」（あなたが GitHub にログインする代わりに、
Claude のような外部アプリがあなたの代理で GitHub を操作する時に使う『合言葉』のようなもの）
が必要です。合言葉ごとに「何ができるか」を細かく決められるので、もし漏れても被害を抑えられます。

発行手順:

1. https://github.com/settings/tokens にアクセス（GitHub にログイン済みの状態で）
2. 「Generate new token」→「Generate new token (classic)」を選ぶ
3. 「Note（メモ）」欄に名前を書く（例: claude-code-starter）— 後で見分けるためのメモなので何でもOK
4. 「Select scopes（権限の選択）」で以下にチェック:
   - `repo` … リポジトリ（コードが置かれている場所）の読み書き
   - `read:org` … 所属している組織の情報を読む
5. 一番下の「Generate token」をクリック
6. 表示された長い文字列（`ghp_xxxxx...`）をコピー
   ※ **画面を閉じると二度と見られない** ので、必ずコピーしてから次へ
7. workspace/secrets.env を開いて、以下の行の `=` の右側に貼り付ける:
   GITHUB_PERSONAL_ACCESS_TOKEN=<貼り付け>
```

「分かりにくいところがあれば遠慮なく聞いてください。GitHub の画面のスクリーンショットを送ってもらえれば一緒に確認できます」と添える。完了したら Step 4 へ。

#### backlog

```
Backlog 連携には2つの情報が必要です。それぞれ役割が違います。

① BACKLOG_DOMAIN — お使いの Backlog の『住所』
   Backlog は会社・組織ごとに別々のサーバーで動いています。
   まず「どこの Backlog に繋ぐか」を指定するためにドメインを書きます。
   例: yourcompany.backlog.jp（普段ブラウザで Backlog を開く時の URL の真ん中の部分）

② BACKLOG_API_KEY — あなたとしてログインする代わりに使う『合言葉』
   ID/パスワードを直接アプリに渡す代わりに、API キーを発行して使います。
   Backlog のスペース（組織）ごとに発行が必要です。

API キーの発行手順:

1. ブラウザでお使いの Backlog にログイン
2. 右上の自分のアイコンをクリック →「個人設定」を選ぶ
3. 左メニューの「API」をクリック
4. 「メモ」欄に名前を書く（例: claude-code-starter）→「登録」
5. 表示されたキーをコピー
6. workspace/secrets.env を開いて以下の2行に書き込む:
   BACKLOG_DOMAIN=yourcompany.backlog.jp
   BACKLOG_API_KEY=<コピーしたキー>
```

「Backlog の画面メニューの呼び方が違う、ボタンが見つからない等あれば教えてください。スクリーンショットがあると一緒に探しやすいです」と添える。完了したら Step 4 へ。

#### gdrive

```
Google Drive 連携には1つ「OAuth クレデンシャル JSON」というファイルが必要です。

これは何かというと、Google が発行する「このアプリは〇〇さんの Google Drive を読んでいいですよ」
という許可証のセットが書かれたファイルです。

このファイル自体は個人で発行する手順がやや複雑（Google Cloud の管理画面で操作する必要あり）
なので、通常は **会社・組織の管理者から受け取る** 運用にしています。

セットアップ:

1. 管理者から `gdrive-credentials.json` のようなファイルを受け取る
2. パソコン内の分かりやすい場所に保存（例: ダウンロードフォルダ）
3. 保存先の『絶対パス』を確認する
   - Mac の場合: Finder でファイルを右クリック → option キーを押すと「パス名をコピー」が出る
   - Windows の場合: ファイルを Shift + 右クリック →「パスのコピー」を選ぶ
4. workspace/secrets.env を開いて以下に貼り付ける:
   GDRIVE_CREDENTIALS_PATH=/Users/yourname/Downloads/gdrive-credentials.json
```

「ファイルがそもそも手元にない場合は、組織の管理者に『Google Drive MCP 用のクレデンシャル JSON が欲しい』と伝えてください。一緒に依頼文面を整理することもできます」と添える。完了したら Step 4 へ。

#### docbase

```
DocBase はトークン設定不要です。

初回利用時、Claude が DocBase の MCP サーバーに接続する際にブラウザで OAuth 認証画面が自動で開きます。
画面の指示に従ってサインインすればOKです。

このスキルでやることはありません。次回 Claude が DocBase 経由で何かする時を待ちましょう。
```

ここで終了（Step 4 はスキップ）。

#### context7

```
Context7 は認証不要・即利用可能です。

このスキルでやることはありません。
ライブラリの公式ドキュメントを Claude に確認してもらいたい時に、自然に会話で頼めば使われます。
```

ここで終了（Step 4 はスキップ）。

### Step 4: VSCode 設定への反映

GitHub / Backlog / Google Drive を設定した場合のみ実施。

```
最後に VSCode 側にも同じ値を反映します（Claude Code 拡張が MCP を起動する時に env var として渡すため）。

1. VSCode で Cmd/Ctrl + , を押して設定を開く
2. 右上の「設定を開く (JSON)」アイコンをクリック
3. claudeCode.environmentVariables 配列に以下を追加（既存があれば追記）:

"claudeCode.environmentVariables": [
  { "name": "<該当env var名>", "value": "<workspace/secrets.envに書いた値>" }
]

4. ファイルを保存
5. VSCode を再起動（Claude Code 拡張のみ無効化→有効化でも可）
```

各サービスの env var 名:

- GitHub: `GITHUB_PERSONAL_ACCESS_TOKEN`
- Backlog: `BACKLOG_DOMAIN`, `BACKLOG_API_KEY`
- Google Drive: `GDRIVE_CREDENTIALS_PATH`

### Step 5: 完了報告と接続テスト案内

```
{service} のセットアップが完了しました。

接続テスト:
- Claude に「{service} に接続できる？」と聞いて確認してください
- 失敗する場合は /claude-code-starter-doctor で全体状態を確認、または再度本スキルを実行
```

---

## 注意事項

- 1 サービスずつ実行することを推奨。複数同時に進めると VSCode 設定への反映時に混乱しやすい
- workspace/secrets.env は git に含まれない。別端末でも使いたい場合は手動でコピーすること
- VSCode 設定の値が変わったら **VSCode の再起動が必要**（拡張プロセスの env が更新されないため）
