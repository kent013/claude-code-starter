---
name: claude-code-starter-todo-close
description: workspace/todo/TODO.md のタスクを workspace/todo/TODO-closed.md に移動する（完了 Closed / 廃止 Obsoleted）
user-invocable: true
argument-hint: '<todo_id> [--action obsolete --reason "理由"]  例: T012 / T012 --action obsolete --reason "不要になった"'
---

# TODO クローズ / 廃止スキル

`workspace/todo/TODO.md`（Open）から指定タスクを取り出し、`workspace/todo/TODO-closed.md` の Closed または Obsoleted セクションへ移動する。

## 伝え方（AGENTS.md「コミュニケーション原則」を必ず守る）

- 利用者はエンジニア初心者または非エンジニア。専門用語はできるだけ避け、必要な場合は括弧で短く補足する
- 推測で書かない。`obsolete` の理由が空などの場合は黙って通さず、なぜ廃止するのかを聞く
- 不要な称賛・追従はしない
- ID 指定が見つからない時は責めずに「TODO.md にこのIDが見つかりませんでした。すでに完了済みかもしれないので確認していただけますか」と伝える

---

## 引数

| 引数 | 必須 | 説明 |
|------|------|------|
| todo_id | Yes | 対象 TODO の ID（例: T012） |
| --action | No | `close`（デフォルト、完了）/ `obsolete`（廃止） |
| --reason | No | 廃止理由（`--action obsolete` のとき必須） |

---

## 手順

### Step 1: ファイルとIDの存在確認

`workspace/todo/TODO.md` が存在しない場合:

```
ERROR

workspace/todo/TODO.md がまだ作成されていません。
先に /claude-code-starter-todo-add でタスクを追加してください。
```

ファイルを Read で読み、`{todo_id}` を含む行を検索。

行が見つからない場合:

```
ERROR

{todo_id} は Open リストに存在しません。

- すでに Closed / Obsoleted になっている可能性があります（workspace/todo/TODO-closed.md を確認）
- ID の指定が間違っている可能性があります
```

### Step 2: action のバリデーション

`--action obsolete` で `--reason` 未指定:

```
ERROR

--action obsolete には --reason が必要です。
例: T012 --action obsolete --reason "要件変更により不要"
```

### Step 3: 日付取得

```sh
date '+%Y-%m-%d'
```

### Step 4: TODO-closed.md の準備

`workspace/todo/TODO-closed.md` が存在しない場合は以下のヘッダーで新規作成:

```markdown
# TODO (Closed / Obsoleted)

## Closed

| ID | タイトル | カテゴリ | 概要 | 優先度 | 関連ノート | 追加日 | 完了日 |
|----|----------|----------|------|--------|-----------|--------|--------|

## Obsoleted

| ID | タイトル | カテゴリ | 概要 | 優先度 | 関連ノート | 追加日 | 廃止日 | 理由 |
|----|----------|----------|------|--------|-----------|--------|--------|------|
```

### Step 5: 行の移動

#### close の場合

1. `workspace/todo/TODO.md` から該当行を Edit ツールで削除
2. `workspace/todo/TODO-closed.md` の Closed テーブル末尾に追加（既存の列 + 完了日を末尾に追加）

```
| {ID} | {title} | {category} | {summary} | {priority} | {note_link} | {追加日} | {today} |
```

#### obsolete の場合

1. `workspace/todo/TODO.md` から該当行を削除
2. `workspace/todo/TODO-closed.md` の Obsoleted テーブル末尾に追加（既存の列 + 廃止日 + 理由を末尾に追加）

```
| {ID} | {title} | {category} | {summary} | {priority} | {note_link} | {追加日} | {today} | {reason} |
```

### Step 6: 完了報告

#### close の場合:

```
TODO クローズ完了

ID: {todo_id}
タイトル: {title}
完了日: {today}

workspace/todo/TODO.md → workspace/todo/TODO-closed.md (Closed) に移動しました。
```

#### obsolete の場合:

```
TODO 廃止完了

ID: {todo_id}
タイトル: {title}
廃止日: {today}
理由: {reason}

workspace/todo/TODO.md → workspace/todo/TODO-closed.md (Obsoleted) に移動しました。
```

---

## 注意事項

- `workspace/todo/TODO.md` が空になっても、ヘッダー行は残す
- ID は再利用しない（移動後も Open は欠番のまま）
- 一括で複数 ID を渡す機能は持たない（誤操作を避けるため、1件ずつ実行する）
