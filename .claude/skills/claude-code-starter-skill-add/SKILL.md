---
name: claude-code-starter-skill-add
description: 利用者が自分用のカスタムスキルを .claude/skills/ に新規作成する（boilerplate には含まれず gitignore 対象）
user-invocable: true
argument-hint: '<skill-name> "<description>" [user-invocable=true|false]  例: my-meeting-summary "議事録の要約フォーマット"'
---

# カスタムスキル作成スキル

利用者が自分用の Claude スキルを `.claude/skills/<skill-name>/SKILL.md` として新規作成する。

作成されたスキルは **git 対象外**（`.gitignore` で `claude-code-starter-*` 以外を除外しているため）。利用者個人の作業環境にのみ存在する。

## 伝え方（AGENTS.md「コミュニケーション原則」を必ず守る）

- 利用者はエンジニア初心者または非エンジニア。専門用語（「frontmatter」「user-invocable」など）が出る時は括弧で短く補足する（例: `frontmatter`（SKILL.md の先頭にある `---` で囲まれた設定部分））
- スキルとは何か・なぜ作るのかを利用者が理解できているか、最初に軽く確認する
- 「とりあえず雛形だけ欲しい」「内容は後で書く」も歓迎するスタンスで応対する
- 引数で受け取った skill-name や description が短すぎる・曖昧な場合は、推測せず聞き返す
- 不要な称賛・追従はしない

---

## 引数

| 引数 | 必須 | 説明 |
|------|------|------|
| skill-name | Yes | スキル名（小文字 + ハイフン）。**`claude-code-starter-` で始めてはいけない**（boilerplate 本体と混同するため） |
| description | Yes | スキルの description（Claude が呼び出し判断に使う1行説明） |
| user-invocable | No | `true`（チャットで `/skill-name` で明示呼び出し可）/ `false`（Claudeの判断で自動選択）。省略時 `true` |

---

## 手順

### Step 1: 引数バリデーション

#### skill-name のチェック

- `claude-code-starter-` で始まる → REJECT:
  ```
  ERROR

  skill-name に「claude-code-starter-」プレフィックスは使えません。
  これは boilerplate 本体専用のプレフィックスです。
  別の名前（例: my-{用途}, custom-{用途}, {あなたの名前}-{用途}）にしてください。
  ```
- 小文字英数字とハイフン以外を含む → REJECT し命名規則を案内
- 既に `.claude/skills/<skill-name>/` が存在 → 上書き確認（利用者にYes/Noを聞く）

#### description のチェック

- 空 or 5文字未満 → 「description はスキル選択の精度に直結します。何をするスキルか1行で書いてください」と確認
- 100文字超 → 短縮を促す

### Step 2: スキルディレクトリと SKILL.md の作成

```sh
mkdir -p .claude/skills/<skill-name>
```

以下のテンプレートで `.claude/skills/<skill-name>/SKILL.md` を作成:

```markdown
---
name: <skill-name>
description: <description>
user-invocable: <true|false>
---

# <skill-name>

## このスキルが扱うこと

<利用者と一緒に対話で記入する>

## 手順

### Step 1: ...

<利用者と一緒に対話で記入する>

### Step 2: ...

## 完了報告

```
{完了時に Claude が出力するメッセージのテンプレート}
```
```

### Step 3: 利用者との対話で本文を埋める

テンプレートの `<...>` 部分は利用者にヒアリングして埋める。最低限聞くこと:

- このスキルはどんな時に使うか（トリガー）
- 入力は何か（引数 / 対話で聞く事項）
- 何をするか（手順）
- 出力先はどこか（推奨: `workspace/` 配下）
- どんな成果物・報告で終わるか

利用者が「とりあえず雛形だけ欲しい」と言う場合はテンプレートのまま保存し、後で編集することを案内する。

### Step 4: 完了報告

```
カスタムスキル作成完了

スキル名: <skill-name>
保存先: .claude/skills/<skill-name>/SKILL.md
description: <description>
user-invocable: <true|false>

このスキルは git に含まれません（あなた個人の作業環境にのみ存在します）。

次のステップ:
- Claude Code を再起動するか、新しいチャットセッションを開始するとスキルが認識されます
- user-invocable=true なら /<skill-name> で明示的に呼び出せます
- 内容を編集したい時は .claude/skills/<skill-name>/SKILL.md を直接開いて編集してください
```

---

## 注意事項

- カスタムスキルは boilerplate のアップデート時に **削除されることはない**（gitignore 対象なので git 操作に巻き込まれない）
- ただし `.claude/skills/<skill-name>/` 自体を手動で削除すれば消える
- 他の利用者・端末と共有したい場合は、SKILL.md ファイルを個別に渡す必要がある
- スキル内で `.kit/` や `.claude/skills/claude-code-starter-*/` の編集を行うと boilerplate を壊す可能性があるため、書き込み先は原則 `workspace/` 配下に限定する
