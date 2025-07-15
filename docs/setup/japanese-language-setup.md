# ERP Next 日本語環境セットアップガイド

作成日: 2025-07-15  
作成者: Sasuke Torii

## 概要

ERP Next（Frappe/ERPNext）を日本語環境で使用するための完全ガイドです。このドキュメントでは、既存サイトの日本語化と新規サイトの日本語設定について説明します。

## 前提条件

- Docker Composeで環境が起動していること
- 対象サイトが作成済みであること（既存サイト日本語化の場合）

## 既存サイトの日本語化

### 自動設定スクリプトの使用（推奨）

最も簡単で確実な方法は、提供されている`setup-japanese.sh`スクリプトを使用することです。

```bash
# プロジェクトルートから実行
cd /path/to/erp-next
chmod +x scripts/setup-japanese.sh
./scripts/setup-japanese.sh [サイト名]

# 例: erp.localhostを日本語化
./scripts/setup-japanese.sh erp.localhost
```

#### スクリプトが行う設定内容

1. **言語設定**
   - デフォルト言語を日本語（ja）に設定
   - System Settingsの言語を日本語に更新

2. **日付・時刻フォーマット**
   - 日付形式: `yyyy-mm-dd`（例: 2025-07-15）
   - 時刻形式: `HH:mm:ss`（24時間表記）
   - 週の開始日: 月曜日

3. **ローカライゼーション**
   - デフォルト通貨: JPY（日本円）
   - タイムゾーン: Asia/Tokyo
   - デフォルト国: Japan

4. **設定の反映**
   - キャッシュのクリア
   - サービスの再起動

### 手動設定方法

スクリプトを使用しない場合の手動設定手順：

```bash
# frappe_dockerディレクトリに移動
cd frappe_docker

# 1. デフォルト言語の設定
docker compose exec backend bench --site erp.localhost set-config default_language ja

# 2. System Settingsの更新
docker compose exec backend bench --site erp.localhost execute frappe.db.set_value --args "['System Settings', 'System Settings', 'language', 'ja']"

# 3. 日付フォーマットの設定
docker compose exec backend bench --site erp.localhost execute frappe.db.set_value --args "['System Settings', 'System Settings', 'date_format', 'yyyy-mm-dd']"
docker compose exec backend bench --site erp.localhost execute frappe.db.set_value --args "['System Settings', 'System Settings', 'time_format', 'HH:mm:ss']"

# 4. その他の設定
docker compose exec backend bench --site erp.localhost execute frappe.db.set_value --args "['System Settings', 'System Settings', 'first_day_of_the_week', 'Monday']"
docker compose exec backend bench --site erp.localhost execute frappe.db.set_value --args "['System Settings', 'System Settings', 'currency', 'JPY']"
docker compose exec backend bench --site erp.localhost execute frappe.db.set_value --args "['System Settings', 'System Settings', 'time_zone', 'Asia/Tokyo']"
docker compose exec backend bench --site erp.localhost execute frappe.db.set_value --args "['System Settings', 'System Settings', 'country', 'Japan']"

# 5. キャッシュクリアと再起動
docker compose exec backend bench --site erp.localhost clear-cache
docker compose restart backend websocket
```

## 新規サイトを日本語で作成

新しいサイトを最初から日本語設定で作成する場合：

```bash
# frappe_dockerディレクトリから実行
cd frappe_docker

# 日本語サイトの作成
docker compose exec backend bench new-site japanese-site.localhost \
  --language ja \
  --country Japan \
  --timezone "Asia/Tokyo" \
  --currency JPY
```

## アクセス方法

### 開発環境でのアクセス

1. **ブラウザでアクセス**
   ```
   URL: http://localhost:8080
   ```

2. **初回ログイン**
   - ユーザー名: Administrator
   - パスワード: 初回アクセス時に設定

3. **Hostヘッダーの設定（必要な場合）**
   - curlでの確認: `curl -H "Host: erp.localhost" http://localhost:8080`

### トラブルシューティング

#### 言語が変更されない場合

1. **ブラウザキャッシュのクリア**
   - Ctrl+Shift+R（Windows/Linux）
   - Cmd+Shift+R（Mac）
   - またはシークレット/プライベートウィンドウで確認

2. **サーバーサイドキャッシュのクリア**
   ```bash
   docker compose exec backend bench --site erp.localhost clear-cache
   ```

3. **サービスの完全再起動**
   ```bash
   docker compose restart
   ```

#### 文字化けが発生する場合

1. **データベース文字コードの確認**
   ```bash
   docker compose exec db mysql -u root -p123 -e "SHOW VARIABLES LIKE 'character%';"
   ```
   - `utf8mb4`が設定されていることを確認

2. **ブラウザのエンコーディング**
   - UTF-8に設定されていることを確認

## ユーザー個別の言語設定

各ユーザーが個人設定で言語を変更する方法：

1. 右上のユーザーアイコンをクリック
2. 「My Settings」を選択
3. 「Language」フィールドで「日本語」を選択
4. 「Save」をクリック

## 日本向けカスタマイズ

### 会計年度の設定

日本の会計年度（4月1日〜3月31日）に合わせる：

```bash
# ERPNextのUIから設定、またはコマンドで
docker compose exec backend bench --site erp.localhost execute erpnext.setup.doctype.fiscal_year.fiscal_year.create_fiscal_year --args "['2025-04-01', '2026-03-31', '2025年度']"
```

### 消費税の設定

日本の消費税率（10%、軽減税率8%）の設定：

1. 「Tax Template」で新規作成
2. 標準税率10%と軽減税率8%のテンプレートを作成

## 関連ドキュメント

- [Frappe公式ドキュメント - 多言語対応](https://frappeframework.com/docs/user/en/translations)
- [ERPNext日本語化ガイド](../japanese-setup.md)
- [setup-japanese.sh スクリプト](../../scripts/setup-japanese.sh)

## サポート

問題が発生した場合は、以下を確認してください：

1. Docker コンテナが正常に動作しているか
2. サイトが正しく作成されているか
3. ネットワーク接続が正常か

それでも解決しない場合は、プロジェクトのIssueトラッカーで報告してください。