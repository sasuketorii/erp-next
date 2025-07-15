# 包括的トラブルシューティングガイド - ERP Next Docker環境

**作成日**: 2025年7月15日  
**作成者**: Sasuke Torii  
**バージョン**: 1.0  
**対象**: Frappe/ERPNext Docker環境の運用・保守

## 🎯 目的

このガイドは、ERP Next Docker環境で発生する可能性のある問題に対して、体系的な診断と解決方法を提供します。実際のトラブルシューティング経験に基づいて作成されています。

## 📊 よくある問題と解決優先度

| 問題カテゴリ | 頻度 | 解決難易度 | 影響度 | 優先度 |
|-------------|------|------------|--------|--------|
| データベース接続 | 高 | 中 | 高 | 🔴 緊急 |
| サイト作成失敗 | 中 | 低 | 中 | 🟡 通常 |
| アプリインストール失敗 | 中 | 低 | 低 | 🟡 通常 |
| 環境設定問題 | 低 | 高 | 高 | 🔴 緊急 |
| パフォーマンス問題 | 低 | 中 | 中 | 🟡 通常 |

## 🚨 緊急度別対応フロー

### 🔴 緊急対応 (サービス停止)
1. **即座に実行**: 基本診断コマンド
2. **5分以内**: 問題の特定と初期対処
3. **15分以内**: 根本的な解決の実施
4. **30分以内**: 動作確認と監視設定

### 🟡 通常対応 (機能制限)
1. **問題の記録**: 詳細な症状とログの収集
2. **計画的な修正**: 影響範囲を考慮した対処
3. **十分なテスト**: 修正後の動作確認

## 🔍 基本診断コマンド集

### 1. システム全体の状態確認
```bash
# コンテナ状態確認
docker compose ps

# コンテナログ確認
docker compose logs --tail=50

# リソース使用状況
docker stats --no-stream
```

### 2. データベース診断
```bash
# データベース接続確認
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SELECT 1;"

# データベース一覧
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SHOW DATABASES;"

# ユーザー一覧
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SELECT user, host FROM mysql.user;"
```

### 3. サイト状態確認
```bash
# サイト一覧
docker compose exec backend ls sites/

# サイト設定確認
docker compose exec backend cat sites/[SITE_NAME]/site_config.json

# アプリ一覧
docker compose exec backend bench --site [SITE_NAME] list-apps
```

## 🛠️ 問題別解決手順

### 1. データベース接続問題

#### 症状
- `pymysql.err.OperationalError: (1045, "Access denied for user")`
- HTTP 500エラー
- bench コマンドの実行失敗

#### 診断手順
```bash
# 1. データベース接続テスト
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SELECT 1;"

# 2. サイト設定確認
docker compose exec backend cat sites/[SITE_NAME]/site_config.json

# 3. データベースユーザー確認
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SELECT user, host FROM mysql.user WHERE user='[DB_USER]';"
```

#### 解決手順
```bash
# 1. 設定ファイルから情報取得
DB_NAME=$(docker compose exec backend cat sites/[SITE_NAME]/site_config.json | jq -r '.db_name')
DB_PASSWORD=$(docker compose exec backend cat sites/[SITE_NAME]/site_config.json | jq -r '.db_password')

# 2. データベースユーザー再作成
docker exec frappe_docker-db-1 mysql -u root -p123 -e "
CREATE USER IF NOT EXISTS '$DB_NAME'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_NAME'@'%';
FLUSH PRIVILEGES;
"

# 3. 接続テスト
docker exec frappe_docker-db-1 mysql -u $DB_NAME -p$DB_PASSWORD -h localhost -e "SELECT 1;"

# 4. キャッシュクリアとサービス再起動
docker compose exec backend bench --site [SITE_NAME] clear-cache
docker compose restart backend websocket frontend
```

### 2. サイト作成失敗

#### 症状
- `Site [SITE_NAME] already exists`
- データベース作成エラー
- 権限エラー

#### 診断手順
```bash
# 1. サイト存在確認
docker compose exec backend ls sites/

# 2. データベース存在確認
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SHOW DATABASES LIKE '[DB_NAME]';"

# 3. 残存ファイル確認
docker compose exec backend ls -la sites/[SITE_NAME]/
```

#### 解決手順
```bash
# 1. 完全なサイト削除
docker compose exec backend bench drop-site [SITE_NAME] --force

# 2. ディレクトリ削除
docker compose exec backend rm -rf sites/[SITE_NAME]

# 3. データベース削除（必要に応じて）
docker exec frappe_docker-db-1 mysql -u root -p123 -e "DROP DATABASE IF EXISTS [DB_NAME];"

# 4. 新規サイト作成
docker compose exec backend bench new-site [SITE_NAME] --admin-password admin --db-root-password 123 --install-app erpnext
```

### 3. アプリインストール失敗

#### 症状
- `No module named '[APP_NAME]'`
- インストール中断
- 依存関係エラー

### 4. Whitelabelモジュール問題 🆕

#### 症状
- `ModuleNotFoundError: No module named 'whitelabel'`
- Docker再起動後のHTTP 500エラー
- サイト完全アクセス不可

#### 診断手順
```bash
# 1. モジュール存在確認
docker compose exec backend python -c "import whitelabel"

# 2. アプリディレクトリ確認
docker compose exec backend ls -la apps/whitelabel/

# 3. Pythonパス確認
docker compose exec backend python -c "import sys; print(sys.path)"
```

#### 解決手順
```bash
# 1. whitelabelアプリ再インストール
docker compose exec backend bench get-app whitelabel https://github.com/bhavesh95863/whitelabel

# 2. サービス再起動
docker compose restart backend frontend websocket

# 3. 動作確認
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
```

#### 予防策
**起動スクリプトの使用**:
```bash
# 必ず起動スクリプトを使用
./scripts/startup-check.sh

# 停止時も安全スクリプトを使用
./scripts/shutdown-safe.sh
```

#### 診断手順
```bash
# 1. アプリ存在確認
docker compose exec backend ls apps/

# 2. アプリ取得状況確認
docker compose exec backend ls -la apps/[APP_NAME]/

# 3. インストール状況確認
docker compose exec backend bench --site [SITE_NAME] list-apps
```

#### 解決手順
```bash
# 1. アプリ取得
docker compose exec backend bench get-app [APP_NAME] [REPO_URL]

# 2. アプリインストール
docker compose exec backend bench --site [SITE_NAME] install-app [APP_NAME]

# 3. 依存関係解決（必要に応じて）
docker compose exec backend bench get-app [APP_NAME] --resolve-deps [REPO_URL]
```

## 🔄 環境復旧手順

### 1. 部分的な復旧（推奨）
```bash
# 1. 問題のあるコンテナのみ再起動
docker compose restart [SERVICE_NAME]

# 2. キャッシュクリア
docker compose exec backend bench --site [SITE_NAME] clear-cache

# 3. 設定修正
# 必要に応じて設定ファイルを修正
```

### 2. 完全な環境再構築
```bash
# 1. 重要な設定のバックアップ
mkdir -p backups/$(date +%Y%m%d)
cp sites/[SITE_NAME]/site_config.json backups/$(date +%Y%m%d)/
cp sites/common_site_config.json backups/$(date +%Y%m%d)/

# 2. 完全な環境削除
docker compose down --volumes
docker system prune -a --volumes -f

# 3. 環境再構築
docker compose -f compose.yaml -f overrides/compose.mariadb.yaml -f overrides/compose.redis.yaml -f overrides/compose.proxy.yaml up -d

# 4. サイト再作成
docker compose exec backend bench new-site [SITE_NAME] --admin-password admin --db-root-password 123 --install-app erpnext

# 5. 設定復元
# バックアップから設定を復元
```

## 🎯 予防策とベストプラクティス

### 1. 定期的なバックアップ
```bash
# 毎日実行すべきバックアップ
#!/bin/bash
BACKUP_DIR="backups/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# 設定ファイル
cp sites/*/site_config.json $BACKUP_DIR/
cp sites/common_site_config.json $BACKUP_DIR/

# データベース
docker compose exec backend bench --site [SITE_NAME] backup
```

### 2. 監視スクリプト
```bash
#!/bin/bash
# health-check.sh
# システム状態の定期チェック

# データベース接続確認
DB_STATUS=$(docker exec frappe_docker-db-1 mysql -u root -p123 -e "SELECT 1;" 2>/dev/null && echo "OK" || echo "FAIL")

# サイト接続確認
SITE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)

# 結果レポート
echo "$(date): DB=$DB_STATUS, Site=$SITE_STATUS" >> monitoring.log
```

### 3. 自動化スクリプト
```bash
#!/bin/bash
# auto-recovery.sh
# 基本的な問題の自動解決

SITE_NAME=${1:-sasuke.localhost}

# データベース接続問題の自動解決
if ! docker compose exec backend bench --site $SITE_NAME list-apps >/dev/null 2>&1; then
    echo "データベース接続問題を検出。自動修復を開始..."
    
    # 設定取得
    DB_NAME=$(docker compose exec backend cat sites/$SITE_NAME/site_config.json | jq -r '.db_name')
    DB_PASSWORD=$(docker compose exec backend cat sites/$SITE_NAME/site_config.json | jq -r '.db_password')
    
    # ユーザー再作成
    docker exec frappe_docker-db-1 mysql -u root -p123 -e "
    CREATE USER IF NOT EXISTS '$DB_NAME'@'%' IDENTIFIED BY '$DB_PASSWORD';
    GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_NAME'@'%';
    FLUSH PRIVILEGES;
    "
    
    # サービス再起動
    docker compose restart backend websocket frontend
    
    echo "自動修復完了"
fi
```

## 📋 トラブルシューティングチェックリスト

### 問題発生時の初期対応
- [ ] 症状の詳細記録
- [ ] エラーメッセージの収集
- [ ] 最近の変更内容の確認
- [ ] 基本診断コマンドの実行

### データベース関連問題
- [ ] データベースコンテナの状態確認
- [ ] データベースログの確認
- [ ] 認証情報の確認
- [ ] ユーザー権限の確認
- [ ] 接続テストの実行

### サイト関連問題
- [ ] サイトディレクトリの確認
- [ ] 設定ファイルの確認
- [ ] アプリインストール状況の確認
- [ ] キャッシュクリアの実行

### 解決後の確認
- [ ] 基本機能の動作確認
- [ ] パフォーマンスの確認
- [ ] 監視設定の確認
- [ ] バックアップの作成
- [ ] ドキュメントの更新

## 🔧 便利なコマンド集

### 情報収集コマンド
```bash
# システム情報
docker compose ps
docker compose logs --tail=50
docker stats --no-stream

# データベース情報
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SHOW PROCESSLIST;"
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SHOW STATUS LIKE 'Connections';"

# サイト情報
docker compose exec backend bench --site [SITE_NAME] list-apps
docker compose exec backend bench --site [SITE_NAME] show-config
```

### 修復コマンド
```bash
# キャッシュクリア
docker compose exec backend bench --site [SITE_NAME] clear-cache

# データベースマイグレーション
docker compose exec backend bench --site [SITE_NAME] migrate

# サービス再起動
docker compose restart backend websocket frontend
```

### 緊急時コマンド
```bash
# 全サービス停止
docker compose down

# 緊急復旧
docker compose -f compose.yaml -f overrides/compose.mariadb.yaml -f overrides/compose.redis.yaml -f overrides/compose.proxy.yaml up -d

# 強制的な環境リセット
docker compose down --volumes
docker system prune -a --volumes -f
```

## 📞 エスカレーション基準

### 自動解決可能（5分以内）
- データベース接続エラー
- 基本的なサービス停止
- キャッシュ関連問題

### 標準対応（30分以内）
- サイト作成失敗
- アプリインストール失敗
- 設定ファイル問題

### 専門対応（要エスカレーション）
- データ損失の可能性
- セキュリティ関連問題
- 複数システムへの影響

---

**このガイドは実際の運用経験に基づいて作成され、継続的に更新されます。問題が発生した際は、このガイドに従って段階的に対処してください。**