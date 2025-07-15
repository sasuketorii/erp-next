# 分散オンプレミス型ERP SaaS 要件定義書 (200社規模対応版)

## 1. 概要 (Overview)

### 1.1. 目的

本ドキュメントは、200社規模の日本国内企業（以下、顧客）に対して、**各社個別のオンプレミス環境**をDockerコンテナで構築し、SaaS形式で提供するERPサービスのシステム要件を定義する。

各顧客は完全に独立したERPNext環境（アプリケーション＋データベース）を持ち、日本のインボイス制度に準拠した請求書発行が可能となることを必須要件とする。

### 1.2. 対象範囲

- 200社規模に対応した**分散オンプレミス型**システムアーキテクチャ定義
- 各社個別環境の自動プロビジョニング機能
- 日本のインボイス制度対応機能の要件
- 各顧客向けのホワイトラベル/ブランディング機能の要件
- 自動アップデート戦略とCI/CDパイプラインの要件
- 非機能要件（セキュリティ、バックアップ、可用性、災害対策等）の定義

### 1.3. アーキテクチャ選定理由

**マルチテナント型を採用しない理由：**
- 200社が1つのシステムを共有することによる単一障害点リスク
- パフォーマンスのボトルネック（特にデータベース）
- カスタマイズの制約
- セキュリティリスク（データ漏洩の影響範囲）

**分散オンプレミス型の採用理由：**
- 各社完全独立による障害影響の局所化
- 顧客ごとの柔軟なカスタマイズ対応
- リソースの個別最適化
- データの完全分離によるセキュリティ向上

## 2. システムアーキテクチャ (System Architecture)

### 2.1. ホスティング環境

#### 2.1.1. 分散オンプレミス型アーキテクチャ

```
[集中管理インフラ]
├── Ansible Controller (全顧客環境の自動管理)
├── 監視サーバー (Prometheus/Grafana)
├── バックアップサーバー (全顧客データの集中バックアップ)
└── Docker Registry (カスタムERPNextイメージの配布)

[顧客個別環境群] - 200社を40のVPSに分散配置
├── VPS-01 (5顧客の個別環境)
│   ├── 顧客A: Docker (ERPNext + MariaDB + Redis)
│   ├── 顧客B: Docker (ERPNext + MariaDB + Redis)
│   ├── 顧客C: Docker (ERPNext + MariaDB + Redis)
│   ├── 顧客D: Docker (ERPNext + MariaDB + Redis)
│   └── 顧客E: Docker (ERPNext + MariaDB + Redis)
├── VPS-02 (5顧客の個別環境)
│   └── ... 同様の構成
└── VPS-40 (5顧客の個別環境)
```

- **サーバー構成**: 
  - 管理用: 4台（Controller, 監視, バックアップ, Registry）
  - 顧客用: 40台のVPS（各5社を収容）
  - 合計: 44台のサーバー構成

- **リソース配分**:
  - 高性能VPS（大規模顧客用）: 8vCPU, 32GB RAM, 500GB SSD
  - 標準VPS（中小規模顧客用）: 4vCPU, 16GB RAM, 200GB SSD
  - 管理サーバー: 4vCPU, 8GB RAM, 100GB SSD

### 2.2. コンテナ化戦略

#### 2.2.1. Docker構成

```yaml
# 各顧客専用のDocker Compose構成
version: '3.8'
services:
  erpnext-${CLIENT_NAME}:
    image: registry.example.com/erpnext-custom:${VERSION}
    container_name: ${CLIENT_NAME}_erpnext
    environment:
      - SITE_NAME=${CLIENT_NAME}.erp.example.com
    volumes:
      - ${CLIENT_NAME}_sites:/home/frappe/frappe-bench/sites
      - ${CLIENT_NAME}_logs:/home/frappe/frappe-bench/logs
    networks:
      - ${CLIENT_NAME}_network
    restart: unless-stopped
    
  mariadb-${CLIENT_NAME}:
    image: mariadb:10.6
    container_name: ${CLIENT_NAME}_db
    environment:
      - MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
    volumes:
      - ${CLIENT_NAME}_db:/var/lib/mysql
    networks:
      - ${CLIENT_NAME}_network
    restart: unless-stopped
```

#### 2.2.2. カスタムDockerイメージ管理

```dockerfile
# カスタムERPNextイメージ
FROM frappe/erpnext:v15.latest

# 日本向けカスタマイズ
RUN bench get-app https://github.com/your-org/japan-compliance.git --branch ${BRANCH}
RUN bench get-app https://github.com/your-org/custom-modules.git --branch ${BRANCH}

# アプリケーションのインストール
RUN bench --site all install-app japan_compliance custom_modules

# ヘルスチェックスクリプト
COPY healthcheck.sh /usr/local/bin/
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh
```

### 2.3. アップデート自動化アーキテクチャ

#### 2.3.1. CI/CDパイプライン

```yaml
# GitLab CI/CD設定例
stages:
  - build
  - test
  - staging
  - canary
  - production

build-image:
  stage: build
  script:
    - docker build -t erpnext-custom:${CI_COMMIT_TAG} .
    - docker push registry.example.com/erpnext-custom:${CI_COMMIT_TAG}

test-upgrade:
  stage: test
  script:
    - ansible-playbook test_upgrade.yml --extra-vars "version=${CI_COMMIT_TAG}"

deploy-canary:
  stage: canary
  script:
    - ansible-playbook deploy.yml --limit canary_group --extra-vars "version=${CI_COMMIT_TAG}"
  when: manual

deploy-production:
  stage: production
  script:
    - ansible-playbook deploy.yml --limit production_batch_${BATCH_NUMBER} --extra-vars "version=${CI_COMMIT_TAG}"
  when: manual
```

#### 2.3.2. 段階的リリース戦略

```yaml
# Ansible インベントリ構成
all:
  children:
    canary_group:
      hosts:
        client_001:  # テスト協力企業
        client_002:  # 社内テスト環境
    
    pilot_group:
      hosts:
        client_003-007:  # 5社のパイロット企業
    
    production:
      children:
        batch_1:
          hosts:
            client_008-027:  # 20社
        batch_2:
          hosts:
            client_028-047:  # 20社
        # ... 最大10バッチまで
```

## 3. 機能要件 (Functional Requirements)

### 3.1. テナント管理機能

#### 3.1.1. 自動プロビジョニング

```python
# 自動プロビジョニングスクリプト例
def provision_new_tenant(tenant_info):
    # 1. 最適なVPSを選択
    target_vps = select_optimal_vps(tenant_info['expected_load'])
    
    # 2. Dockerコンテナをデプロイ
    deploy_containers(target_vps, tenant_info)
    
    # 3. 初期設定を実行
    configure_tenant(tenant_info)
    
    # 4. 監視設定を追加
    add_monitoring(tenant_info['client_name'])
    
    # 5. バックアップ設定を追加
    configure_backup(tenant_info['client_name'])
```

#### 3.1.2. テナント移行機能

- VPS間でのテナント移行機能（負荷分散のため）
- ゼロダウンタイム移行の実現
- 移行履歴の管理

### 3.2. 日本のインボイス制度対応機能

#### 事業者登録番号のテナント別管理

- 「会社 (Company)」DocTypeに「適格請求書発行事業者登録番号」のカスタムフィールドを追加する
- このフィールドはテナントごとに独立して設定可能でなければならない

#### 適格請求書の共通テンプレート

- 「管理用カスタムアプリ」内に、インボイス制度の要件を満たす共通の「プリントフォーマット（適格請求書）」を一つ作成する
- 新規テナント作成時、この共通プリントフォーマットが自動的にそのテナントのデフォルト請求書テンプレートとして設定されるようにする

### 3.3. ホワイトラベル/ブランディング機能

#### テナントごとのロゴ設定

- 各テナントの管理者は、自社の「会社 (Company)」設定画面から、自社のロゴ画像をアップロードできる
- システム上のヘッダーや発行する帳票には、各テナントが設定したロゴが自動的に表示されること

### 3.4. アップデート管理機能

#### 3.4.1. アップデート管理ダッシュボード

- 全200社のアップデート状況を一元管理
- バージョン別の展開状況の可視化
- ロールバック履歴の管理

#### 3.4.2. アップデート通知機能

- 各テナントへの計画的アップデート通知
- アップデート内容の自動翻訳（日本語）
- メンテナンスウィンドウの自動調整

## 4. 非機能要件 (Non-Functional Requirements)

### 4.1. セキュリティ

#### 4.1.1. ネットワークセキュリティ

```yaml
# ネットワーク分離設定
networks:
  management_network:
    internal: false
    driver: overlay
    
  customer_network:
    internal: true
    driver: overlay
    
  backup_network:
    internal: true
    driver: overlay
```

- **ネットワーク分離**: 管理ネットワークと顧客ネットワークの完全分離
- **ファイアウォール**: 各VPSレベルとコンテナレベルでの2層防御
- **侵入検知**: Fail2ban + Snortによる不正アクセス検知
- **DDoS対策**: Cloudflareまたは国内CDNサービスの利用

#### 4.1.2. データセキュリティ

- **暗号化**: 保存データ（AES-256）と通信データ（TLS 1.3）の暗号化
- **アクセス制御**: OAuth2.0 + JWTによる認証・認可
- **監査ログ**: 全操作の監査証跡を3年間保管

### 4.2. バックアップと災害復旧

#### 4.2.1. 3-2-1バックアップ戦略

```bash
# バックアップスクリプト例
#!/bin/bash
# 3つのバックアップコピー
# 2つの異なるメディア
# 1つのオフサイトバックアップ

# ローカルバックアップ（日次）
docker exec ${CLIENT}_erpnext bench --site all backup --with-files

# リモートバックアップ（日次）
rsync -avz ${BACKUP_DIR}/ backup-server:/backups/${CLIENT}/

# クラウドバックアップ（週次）
aws s3 sync ${BACKUP_DIR}/ s3://backup-bucket/${CLIENT}/ --storage-class GLACIER
```

#### 4.2.2. 復旧目標

- **RPO（Recovery Point Objective）**: 最大24時間
- **RTO（Recovery Time Objective）**: 
  - 単一テナント復旧: 2時間以内
  - VPS全体復旧: 4時間以内
  - 全システム復旧: 24時間以内

### 4.3. パフォーマンスとスケーラビリティ

#### 4.3.1. パフォーマンス目標

- **レスポンスタイム**: 
  - API: 95パーセンタイルで500ms以下
  - ページロード: 95パーセンタイルで3秒以下
- **同時接続数**: VPSあたり最大500セッション
- **トランザクション処理**: 各テナント100 TPS以上

#### 4.3.2. 自動スケーリング

```yaml
# 自動スケーリングルール
scaling_rules:
  cpu_threshold: 80%
  memory_threshold: 85%
  actions:
    - alert_ops_team
    - prepare_new_vps
    - migrate_tenant_if_needed
```

### 4.4. 可用性と信頼性

#### 4.4.1. 高可用性設計

- **SLA目標**: 99.5%（月間ダウンタイム約3.6時間）
- **冗長性**: 
  - 管理サーバーの冗長化（Active-Standby）
  - データベースレプリケーション（各VPS内）
  - バックアップサーバーの地理的分散

#### 4.4.2. 障害対応

```yaml
# 障害対応フロー
incident_response:
  detection:
    - automated_monitoring
    - customer_reports
  
  classification:
    - critical: 全体停止、データ損失リスク
    - high: 複数テナント影響
    - medium: 単一テナント影響
    - low: 機能制限
  
  escalation:
    - critical: 即時対応（24/7）
    - high: 1時間以内
    - medium: 4時間以内
    - low: 翌営業日
```

### 4.5. 監視とアラート

#### 4.5.1. 監視項目

```yaml
# Prometheus監視設定
monitoring_targets:
  infrastructure:
    - cpu_usage
    - memory_usage
    - disk_io
    - network_traffic
  
  application:
    - response_time
    - error_rate
    - active_users
    - database_connections
  
  business:
    - transaction_volume
    - failed_logins
    - backup_status
    - update_progress
```

#### 4.5.2. アラート設定

- **Slack/Teams通知**: 中程度以上の障害
- **電話通知**: クリティカル障害
- **自動エスカレーション**: 30分無応答で上位者へ

## 5. アップデート運用要件

### 5.1. アップデートプロセス

#### 5.1.1. 事前準備フェーズ

1. **互換性検証**
   - 新バージョンとカスタムモジュールの互換性テスト
   - データベーススキーマ変更の影響分析
   
2. **リスク評価**
   - 各テナントへの影響度評価
   - ロールバック計画の策定

#### 5.1.2. 実行フェーズ

```bash
# アップデート実行スクリプト
#!/bin/bash
# Phase 1: カナリアリリース（2社）
ansible-playbook update_erpnext.yml \
  --limit canary_group \
  --extra-vars "version=${NEW_VERSION}"

# 24時間の監視期間

# Phase 2: パイロットリリース（5社）
ansible-playbook update_erpnext.yml \
  --limit pilot_group \
  --extra-vars "version=${NEW_VERSION}"

# 48時間の監視期間

# Phase 3-12: 本番リリース（20社×10バッチ）
for i in {1..10}; do
  ansible-playbook update_erpnext.yml \
    --limit "production_batch_${i}" \
    --extra-vars "version=${NEW_VERSION}"
  
  # バッチ間で24時間の監視期間
  sleep 86400
done
```

### 5.2. ロールバック戦略

#### 5.2.1. 即時ロールバック（Blue-Green方式）

```yaml
# Docker Composeでの Blue-Green 切り替え
services:
  erpnext-blue:
    image: erpnext-custom:${CURRENT_VERSION}
    # ... 現行バージョン
    
  erpnext-green:
    image: erpnext-custom:${NEW_VERSION}
    # ... 新バージョン
    
  nginx:
    # プロキシ設定で切り替え
```

#### 5.2.2. データベースロールバック

- トランザクションログからのポイントインタイムリカバリ
- バックアップからの完全復旧（最終手段）

## 6. 運用体制要件

### 6.1. 運用チーム構成

- **インフラチーム**: 4名（24/7シフト）
- **アプリケーションチーム**: 3名
- **セキュリティチーム**: 2名
- **カスタマーサポート**: 5名

### 6.2. 運用ツール

- **監視**: Prometheus + Grafana + AlertManager
- **ログ管理**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **自動化**: Ansible + GitLab CI/CD
- **インシデント管理**: PagerDuty + Slack

## 7. コスト見積もり

### 7.1. インフラコスト（月額）

- VPSコスト: 40台 × 平均15,000円 = 600,000円
- 管理サーバー: 4台 × 10,000円 = 40,000円
- バックアップストレージ: 200,000円
- ネットワーク/CDN: 100,000円
- **合計**: 約940,000円/月

### 7.2. 運用コスト

- 人件費: 14名体制
- ツールライセンス費用
- 外部監査費用（年1回）

## 8. 移行計画

### 8.1. 段階的移行

1. **Phase 1** (1-2ヶ月): インフラ構築と管理システム導入
2. **Phase 2** (2-3ヶ月): パイロット顧客10社の移行
3. **Phase 3** (6-8ヶ月): 残り190社の段階的移行

### 8.2. 移行時の並行運用

- 旧環境と新環境の3ヶ月間並行運用
- データ同期ツールによるリアルタイム同期

## 9. 前提条件・制約事項

- 200社規模での運用を前提とし、それ以上の拡張時は追加設計が必要
- 各VPSは最大5-10社程度の収容を想定
- 24/7運用体制の確立が必須
- 初期投資として約3,000万円の予算確保が必要
