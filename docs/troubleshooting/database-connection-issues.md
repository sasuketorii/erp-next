# データベース接続問題 - トラブルシューティングガイド

**作成日**: 2025年7月15日  
**作成者**: Sasuke Torii  
**対象**: Frappe/ERPNext Docker環境での関マデータベース接続問題

## 🚨 問題の概要

### 発生した問題
- **エラー**: `pymysql.err.OperationalError: (1045, "Access denied for user '_841bfc88ebdaee4b'@'172.18.0.6' (using password: YES)")`
- **症状**: 
  - サイト作成後にHTTP 500エラー
  - bench コマンドが全て失敗
  - データベース接続ができない

### 根本原因
1. **データベースユーザー認証の不整合**
   - サイト作成時に生成されたDBユーザーのパスワードが正しく設定されていない
   - MariaDBコンテナ再起動時にユーザー情報が失われる

2. **Docker環境での権限問題**
   - コンテナ間のネットワーク通信でのホスト名解決
   - データベースボリュームの完全削除時の設定リセット

## ✅ 成功した解決方法

### 1. データベースユーザーの再作成
```bash
# 1. データベースにrootでアクセス
docker exec frappe_docker-db-1 mysql -u root -p123

# 2. ユーザーを再作成（パスワードはsite_config.jsonから取得）
CREATE USER IF NOT EXISTS '_841bfc88ebdaee4b'@'%' IDENTIFIED BY 'Tx6PBce4AmU7lQUf';
GRANT ALL PRIVILEGES ON _841bfc88ebdaee4b.* TO '_841bfc88ebdaee4b'@'%';
FLUSH PRIVILEGES;
```

### 2. 接続テスト
```bash
# ユーザー認証をテスト
docker exec frappe_docker-db-1 mysql -u _841bfc88ebdaee4b -pTx6PBce4AmU7lQUf -h localhost -e "SELECT 1;"
```

### 3. キャッシュクリアとサービス再起動
```bash
# キャッシュクリア
docker compose exec backend bench --site sasuke.localhost clear-cache

# サービス再起動
docker compose restart backend websocket frontend
```

## ❌ 失敗した方法と理由

### 1. ALTER USER での修正試行
```bash
# 失敗例
ALTER USER '_841bfc88ebdaee4b'@'%' IDENTIFIED BY 'Tx6PBce4AmU7lQUf';
# エラー: Operation ALTER USER failed
```
**失敗理由**: ユーザーが存在しないか、異なるホストで作成されている

### 2. bench drop-site での解決試行
```bash
# 失敗例
bench drop-site sasuke.localhost --force
# エラー: Access denied for user
```
**失敗理由**: そもそもデータベースに接続できない状態では、サイト削除も不可能

### 3. 完全な環境リセット
```bash
# 効果的だが時間がかかる方法
docker compose down --volumes
docker system prune -a --volumes -f
```
**問題点**: 時間がかかり、他のデータも失われる

## 🔍 診断手順

### 1. データベース接続確認
```bash
# 1. データベースコンテナの状態確認
docker compose ps db

# 2. データベースログ確認
docker logs frappe_docker-db-1 | tail -20

# 3. ユーザー存在確認
docker exec frappe_docker-db-1 mysql -u root -p123 -e "SELECT user, host FROM mysql.user WHERE user LIKE '_841bfc88ebdaee4b';"
```

### 2. サイト設定確認
```bash
# site_config.jsonの確認
docker compose exec backend cat sites/sasuke.localhost/site_config.json

# 必要情報の抽出
# - db_name: データベース名
# - db_password: データベースパスワード
# - db_type: データベース種類
```

### 3. 接続テスト
```bash
# 直接データベース接続テスト
docker exec frappe_docker-db-1 mysql -u [db_user] -p[db_password] -h localhost -e "SELECT 1;"
```

## 🛠️ 予防策

### 1. 完全な環境リセット時の手順
```bash
# 1. 設定ファイルのバックアップ
cp sites/sasuke.localhost/site_config.json backup/

# 2. 完全削除
docker compose down --volumes
docker system prune -a --volumes -f

# 3. 環境再構築
docker compose -f compose.yaml -f overrides/compose.mariadb.yaml -f overrides/compose.redis.yaml -f overrides/compose.proxy.yaml up -d
```

### 2. サイト作成時の推奨手順
```bash
# 1. データベースが完全に起動するまで待機
docker compose ps db
# healthyステータスを確認

# 2. サイト作成
docker compose exec backend bench new-site sasuke.localhost --admin-password admin --db-root-password 123 --install-app erpnext

# 3. 即座に接続テスト
docker compose exec backend bench --site sasuke.localhost list-apps
```

### 3. 定期的な設定バックアップ
```bash
# 重要な設定ファイルのバックアップ
mkdir -p backups/$(date +%Y%m%d)
cp sites/sasuke.localhost/site_config.json backups/$(date +%Y%m%d)/
cp sites/common_site_config.json backups/$(date +%Y%m%d)/
```

## 🔧 今後の改善点

### 1. 自動化スクリプト作成
- データベース接続チェック機能
- 自動復旧スクリプト
- 設定バックアップ自動化

### 2. 監視とアラート
- データベース接続監視
- サイト状態の定期チェック
- 問題発生時の自動通知

### 3. ドキュメント整備
- 標準的なトラブルシューティング手順
- 設定ファイルの説明
- 各コンポーネントの依存関係

## 📋 チェックリスト

### データベース接続問題が発生した場合
- [ ] データベースコンテナの状態確認
- [ ] データベースログの確認
- [ ] site_config.jsonの確認
- [ ] データベースユーザーの存在確認
- [ ] ユーザー再作成の実行
- [ ] 接続テストの実行
- [ ] キャッシュクリア
- [ ] サービス再起動
- [ ] 最終動作確認

### 予防措置
- [ ] 設定ファイルのバックアップ
- [ ] 定期的な接続テスト
- [ ] 監視システムの導入
- [ ] 自動化スクリプトの作成

---

**このドキュメントは実際のトラブルシューティング経験に基づいて作成されています。同様の問題が発生した場合は、この手順に従って対処してください。**