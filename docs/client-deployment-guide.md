# クライアント向けデプロイガイド - ERP Next

**作成日**: 2025年7月15日  
**作成者**: Sasuke Torii  
**対象**: VPS環境でのクライアント向けデプロイ

## 📋 概要

このガイドでは、カスタマイズされたERP Next（日本語対応・ホワイトラベル対応）をクライアントのVPSサーバーにデプロイする方法を説明します。**データベースを含む完全なシステム**として提供できます。

## ✅ 提供できるもの

### 1. 完全なシステムパッケージ
- **日本語対応ERPNext** - 完全に日本語化済み
- **ホワイトラベル化** - クライアントのブランドに合わせてカスタマイズ
- **データベース込み** - 設定済みのデータベースを含む
- **ワンクリックデプロイ** - Docker Composeで簡単起動

### 2. カスタマイズ済み機能
- 日本語UI・日本の日付形式・日本円通貨
- カスタムロゴ・ブランディング
- 不要なヘルプメニュー・「Powered by ERPNext」の削除
- 日本のビジネス慣習に合わせた設定

## 🏗️ デプロイ方法

### 方法1: カスタムDockerイメージ + バックアップ復元

#### Step 1: カスタムDockerイメージの作成

```bash
# プロジェクトディレクトリから実行
./build/build-custom-image.sh v1.0.0

# 成功時の出力例
✅ Dockerイメージのビルドが成功しました！
イメージ: ghcr.io/sasuketorii/erp-next:v1.0.0
```

#### Step 2: データベースバックアップの作成

```bash
# 現在のサイトのバックアップを作成
cd frappe_docker
docker compose exec backend bench --site erp.localhost backup

# バックアップファイルを確認
docker compose exec backend ls -la sites/erp.localhost/backups/
```

#### Step 3: GitHub Container Registryへのプッシュ

```bash
# レジストリログイン
docker login ghcr.io

# イメージをプッシュ
docker push ghcr.io/sasuketorii/erp-next:v1.0.0
```

#### Step 4: クライアントサーバーでのデプロイ

**クライアント側で実行:**

```bash
# 1. プロジェクトファイルをダウンロード
wget https://github.com/sasuketorii/erp-next/archive/v0.0.2.tar.gz
tar -xzf v0.0.2.tar.gz
cd erp-next-0.0.2

# 2. 環境設定
cp .env.example .env
# .envファイルを編集（ドメイン、パスワードなど）

# 3. カスタムイメージを使用してデプロイ
export CUSTOM_IMAGE='ghcr.io/sasuketorii/erp-next'
export CUSTOM_TAG='v1.0.0'

cd frappe_docker
docker compose -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.proxy.yaml \
  up -d

# 4. バックアップファイルの復元
docker compose exec backend bench --site [client-site] restore [backup-file]
```

### 方法2: 完全なデータベースダンプ付きデプロイ

#### Step 1: データベースダンプの作成

```bash
# MariaDBダンプの作成
cd frappe_docker
docker compose exec db mysqldump -u root -p123 _ff4c913d88f6ca06 > client_database.sql

# サイトファイルのアーカイブ
docker compose exec backend tar -czf sites_backup.tar.gz sites/
```

#### Step 2: デプロイパッケージの作成

```bash
# デプロイパッケージディレクトリを作成
mkdir -p deploy-package/database
mkdir -p deploy-package/config

# 必要なファイルをコピー
cp client_database.sql deploy-package/database/
cp sites_backup.tar.gz deploy-package/
cp docker-compose.yml deploy-package/
cp -r frappe_docker/overrides deploy-package/
```

#### Step 3: クライアント側でのデプロイ

```bash
# 1. デプロイパッケージを展開
tar -xzf deploy-package.tar.gz
cd deploy-package

# 2. データベースとサービスを起動
docker compose up -d

# 3. データベースダンプを復元
docker compose exec db mysql -u root -p123 _ff4c913d88f6ca06 < database/client_database.sql

# 4. サイトファイルを復元
docker compose exec backend tar -xzf sites_backup.tar.gz -C /home/frappe/frappe-bench/

# 5. サービスを再起動
docker compose restart
```

## 💾 データベース永続化

### データベースボリューム設定

```yaml
# docker-compose.yml
services:
  db:
    image: mariadb:10.6
    volumes:
      - mariadb_data:/var/lib/mysql  # データベースの永続化
    environment:
      - MYSQL_ROOT_PASSWORD=123

volumes:
  mariadb_data:
    driver: local
```

### バックアップ戦略

```bash
# 自動バックアップの設定
# /etc/cron.d/erpnext-backup
0 2 * * * docker compose exec backend bench --site mysite backup
0 3 * * * docker compose exec db mysqldump -u root -p123 _database > /backup/db_$(date +%Y%m%d).sql
```

## 🚀 推奨デプロイ手順

### Phase 1: 事前準備（お客様との打ち合わせ前）

1. **カスタマイズ設定の確認**
   - ロゴファイルの準備
   - ブランドカラーの決定
   - カスタムアプリ名の決定

2. **カスタムイメージの作成**
   ```bash
   # ホワイトラベル設定を適用
   ./scripts/setup-whitelabel.sh
   
   # 日本語設定を適用
   ./scripts/setup-japanese.sh
   
   # カスタムイメージをビルド
   ./build/build-custom-image.sh client-v1.0.0
   ```

3. **テスト環境での動作確認**
   - 全機能の動作確認
   - パフォーマンステスト
   - セキュリティチェック

### Phase 2: クライアント環境でのデプロイ

1. **VPSサーバーの準備**
   - 推奨スペック: 4GB RAM, 2 CPU, 50GB SSD
   - Docker & Docker Composeのインストール
   - 必要なポート開放（80, 443）

2. **ドメイン・SSL設定**
   ```bash
   # Let's Encrypt SSL証明書の取得
   cd frappe_docker
   docker compose -f compose.yaml \
     -f overrides/compose.mariadb.yaml \
     -f overrides/compose.redis.yaml \
     -f overrides/compose.https.yaml \
     up -d
   ```

3. **本番データの移行**
   ```bash
   # 既存システムからのデータ移行
   # または、新規サイトの作成
   docker compose exec backend bench new-site client.example.com \
     --language ja \
     --currency JPY \
     --timezone "Asia/Tokyo"
   ```

### Phase 3: 本番運用開始

1. **モニタリング設定**
   - サーバーリソース監視
   - アプリケーションログ監視
   - 自動バックアップ設定

2. **メンテナンス計画**
   - 定期バックアップ
   - セキュリティアップデート
   - パフォーマンス最適化

## 📊 クライアント向けメリット

### 1. 技術的メリット

**独立したシステム**:
- 自社専用のERPシステム
- 他社との共有なし
- 完全なデータプライバシー

**カスタマイズ性**:
- 企業ブランドに合わせた見た目
- 日本のビジネス慣習に最適化
- 必要に応じた機能追加

### 2. 運用上のメリット

**コスト効率**:
- 月額料金なし（サーバー費用のみ）
- スケーラブルなリソース
- 長期的なコスト削減

**セキュリティ**:
- 自社管理のデータベース
- VPNアクセス対応
- 独自のセキュリティポリシー適用

## 🔧 技術仕様

### システム要件

**最小構成**:
- CPU: 2コア
- RAM: 4GB
- ストレージ: 50GB SSD
- OS: Ubuntu 20.04 LTS以上

**推奨構成**:
- CPU: 4コア
- RAM: 8GB
- ストレージ: 100GB NVMe SSD
- OS: Ubuntu 22.04 LTS

### ネットワーク要件

**開放ポート**:
- 80 (HTTP)
- 443 (HTTPS)
- 22 (SSH - 管理用)

**SSL証明書**:
- Let's Encrypt自動更新
- カスタムSSL証明書対応

## 📞 サポート体制

### 1. デプロイサポート

**初期導入**:
- VPSサーバーセットアップ支援
- データ移行サポート
- 動作確認・テスト

**トレーニング**:
- 管理者向け操作説明
- ユーザー向け使用方法
- 保守・運用マニュアル

### 2. 継続サポート

**メンテナンス**:
- 定期バックアップ確認
- セキュリティアップデート
- パフォーマンス最適化

**拡張対応**:
- 新機能の追加
- カスタマイズ変更
- 他システムとの連携

## 💰 料金体系

### 1. 初期費用

**システム構築費**:
- カスタマイズ開発
- デプロイ作業
- 初期設定・テスト

**導入サポート費**:
- サーバーセットアップ
- データ移行
- 使用方法説明

### 2. 継続費用

**月額保守費**:
- システム監視
- バックアップ確認
- 技術サポート

**追加開発費**:
- 機能追加
- カスタマイズ変更
- 他システム連携

---

**お問い合わせ**:  
Email: support@example.com  
TEL: 03-1234-5678

**このガイドの更新履歴**:
- v1.0.0 (2025-07-15): 初版作成