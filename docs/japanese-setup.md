# Frappe/ERPNext 日本語設定ガイド

## 概要

このガイドでは、Frappe/ERPNextを日本語環境で使用するための設定方法を説明します。

## 設定方法

### 方法1: 既存サイトの日本語化（推奨）

既存のサイトを日本語化する場合は、提供されているスクリプトを使用します：

```bash
# スクリプトを実行
./scripts/setup-japanese.sh [サイト名]

# デフォルトサイト（mysite.localhost）の場合
./scripts/setup-japanese.sh
```

このスクリプトは以下の設定を自動的に行います：
- 言語を日本語（ja）に設定
- 日付形式を `yyyy-mm-dd` に設定
- 時刻形式を `HH:mm:ss`（24時間表記）に設定
- 週の開始日を月曜日に設定
- 通貨を日本円（JPY）に設定
- タイムゾーンを `Asia/Tokyo` に設定
- デフォルト国を日本に設定

### 方法2: 新規サイト作成時の日本語設定

新しいサイトを作成する際に、最初から日本語設定で作成する方法：

```bash
# Dockerコンテナ内で実行
docker compose exec backend bash
bench new-site mysite.localhost --language ja
```

### 方法3: カスタムDockerイメージの使用

日本語設定が組み込まれたDockerイメージをビルドして使用：

```bash
# 日本語対応Dockerイメージのビルド
docker build \
  --build-arg ERPNEXT_VERSION=v15 \
  --tag ghcr.io/sasuketorii/erp-next:v1.0.0-ja \
  --file images/custom/Dockerfile.japanese .
```

## 詳細設定

### System Settings での設定項目

1. **General タブ**
   - Language: `日本語 (ja)`
   - Country: `Japan`
   - Time Zone: `Asia/Tokyo`

2. **Date and Number Format タブ**
   - Date Format: `yyyy-mm-dd`
   - Time Format: `HH:mm:ss`
   - Number Format: `#,###.##`
   - Float Precision: `2`
   - Currency Precision: `0`（日本円は小数点なし）

3. **Currency タブ**
   - Default Currency: `JPY`

### ユーザー個別の言語設定

各ユーザーは個人設定で言語を変更できます：

1. 右上のユーザーアイコンをクリック
2. 「My Settings」を選択
3. 「Language」で「日本語」を選択
4. 保存

### 翻訳のカスタマイズ

独自の翻訳を追加する場合：

```python
# カスタムアプリ内で翻訳を定義
from frappe import _

# 翻訳可能な文字列
message = _("Welcome to ERPNext")
```

翻訳ファイルの場所：
- `apps/frappe/frappe/locale/ja.po`
- `apps/erpnext/erpnext/locale/ja.po`

### 日本の祝日設定

ERPNextで日本の祝日を設定：

1. 「Holiday List」を開く
2. 「New」をクリック
3. 以下を入力：
   - Holiday List Name: `Japan Holidays 2024`
   - From Date: `2024-01-01`
   - To Date: `2024-12-31`
4. 祝日を追加（提供されているスクリプトで自動追加可能）

## トラブルシューティング

### 言語が変わらない場合

1. **キャッシュのクリア**
   ```bash
   docker compose exec backend bench --site mysite.localhost clear-cache
   ```

2. **ブラウザキャッシュのクリア**
   - ブラウザの設定からキャッシュをクリア
   - または、シークレット/プライベートウィンドウで確認

3. **サービスの再起動**
   ```bash
   docker compose restart backend websocket
   ```

### 文字化けが発生する場合

1. **データベースの文字コード確認**
   ```bash
   docker compose exec mariadb mysql -u root -p -e "SHOW VARIABLES LIKE 'character%';"
   ```

2. **正しい文字コードの設定**
   - `utf8mb4` が設定されていることを確認
   - MariaDBの設定で `character-set-server=utf8mb4` が指定されていることを確認

### 日付形式が反映されない場合

1. **ユーザー設定の確認**
   - ユーザー個別の設定が優先される場合があります
   - 「My Settings」で日付形式を確認

2. **DocTypeフィールドの設定**
   - 特定のDocTypeで独自の日付形式が設定されている可能性
   - Customize Formで確認

## ベストプラクティス

1. **新規インストール時**
   - 最初から日本語設定でサイトを作成することを推奨
   - カスタムDockerイメージを使用して一貫性を保つ

2. **マルチサイト環境**
   - 各サイトごとに言語設定が必要
   - デフォルト設定をスクリプト化して管理

3. **アップデート時**
   - 言語設定が保持されることを確認
   - 必要に応じて再設定スクリプトを実行

## 関連リソース

- [Frappe公式ドキュメント - 多言語対応](https://frappeframework.com/docs/user/en/translations)
- [ERPNext日本コミュニティ](https://discuss.erpnext.com/c/community/japan)
- [翻訳プロジェクト](https://translate.erpnext.com/)