---
name: claude-code-starter-todo-add
description: workspace/todo/TODO.md にやることを追加する（一般用途、自由カテゴリ）
user-invocable: true
argument-hint: '"タイトル" [カテゴリ] [優先度] ["概要"] ["関連ノートへのリンク"]'
---

# TODO 追加スキル

利用者の作業メモとして `workspace/todo/TODO.md` にタスクを追加する。プログラミングプロジェクトに限らず、一般的な「やること管理」用途を想定。

ファイル分割:

- `workspace/todo/TODO.md` … 進行中（Open）
- `workspace/todo/TODO-closed.md` … 完了 (Closed) + 廃止 (Obsoleted) ※ todo-close スキルが書く

## 伝え方（AGENTS.md「コミュニケーション原則」を必ず守る）

- 利用者はエンジニア初心者または非エンジニア。専門用語はできるだけ避け、必要な場合は括弧で短く補足する
- 推測で書かない。引数が曖昧なら聞き返す
- 不要な称賛・追従はしない
- カテゴリや優先度の選択を求める時は「決めにくければ空欄でも大丈夫です」と添える

---

## 引数

| 引数 | 必須 | 説明 |
|------|------|------|
| title | Yes | タスクのタイトル（簡潔に） |
| category | No | 自由なカテゴリ名（例: 仕事, 家事, 学習）。省略時は空欄 |
| priority | No | Critical / High / Medium / Low（省略時 Medium） |
| summary | No | 30文字程度の補足説明（テーブル可読性のため短めに） |
| note_link | No | 関連ノートへのリンク（例: `workspace/notes/2026-04-15-会議.md`） ※ ノート保管場所は `workspace/notes/` を推奨 |

引数が不足または曖昧な場合は、利用者に対話で確認してから追加すること。

---

## 手順

### Step 1: workspace/todo/ の準備

```sh
mkdir -p workspace/todo
```

`workspace/todo/TODO.md` が存在しない場合は以下のヘッダーで新規作成:

```markdown
# TODO (Open)

| ID | タイトル | カテゴリ | 概要 | 優先度 | 関連ノート | 追加日 |
|----|----------|----------|------|--------|-----------|--------|
```

### Step 2: 引数バリデーション

- `priority` が指定されていて、`Critical / High / Medium / Low` 以外 → 「以下から選んでください」と確認
- `summary` が30文字超 → 警告して短縮を促す
- `note_link` が指定されていて、`workspace/notes/` 配下でない → 「ノートは workspace/notes/ に置くことを推奨します」と注意（強制ではない）

### Step 3: ID 採番と日時取得

`workspace/todo/TODO.md` および `workspace/todo/TODO-closed.md`（存在すれば）を読み、両ファイルを通じた既存最大 ID を取得して `T{NNN}` 形式で +1 採番。初回は `T001`。

```sh
date '+%Y-%m-%d'
```

### Step 4: Open テーブルへの行追加

```
| {ID} | {title} | {category} | {summary} | {priority} | {note_link} | {today} |
```

未指定セルは空欄でOK。

### Step 5: 完了報告

```
TODO 追加完了

ID: {ID}
タイトル: {title}
カテゴリ: {category or "(なし)"}
優先度: {priority}
追加日: {today}

workspace/todo/TODO.md に追記しました。
```

---

## 注意事項

- TODO は **個人の作業メモ**であり、git に含まれない（workspace/ 配下のため）
- 関連する詳しいメモ・議事録などを書きたい場合は、別途 `workspace/notes/{日付}-{topic}.md` 等を作って `note_link` に指定する運用を推奨
- ノート保管ディレクトリは `workspace/notes/`（複数形）。混同しないよう注意
- ID は再利用しない（Closed / Obsoleted 後も欠番のまま）
