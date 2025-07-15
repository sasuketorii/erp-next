# 顧客負担型ERP SaaS 要件定義書 v2.0 (1社1サーバー版)

## 1. 概要 (Overview)

### 1.1. 目的

本ドキュメントは、200社規模の日本国内企業（以下、顧客）に対して、**各社専用のサーバー環境**でERPNextを提供するSaaSサービスのシステム要件を定義する。

**重要な変更点：**
- 各顧客が自社専用サーバーのインフラ費用を直接負担
- 運営会社は管理・サポート・保守サービスのみを提供
- 1社につき1サーバーの完全独立環境を構築

### 1.2. ビジネスモデル

#### 費用構造
```
顧客の負担:
- サーバー費用: 月額8,000円〜30,000円（顧客が選択・直接支払い）
- 管理サービス料: 月額15,000円〜50,000円（運営会社へ支払い）

運営会社の収益:
- 管理サービス料のみ（サーバー費用の転売なし）
- 初期セットアップ費用: 50,000円〜200,000円
```

### 1.3. 対象範囲

- 200社規模に対応した**1社1サーバー型**システムアーキテクチャ
- 各社専用環境の完全自動プロビジョニング
- 日本のインボイス制度対応機能
- ホワイトラベル/ブランディング機能
- 自動アップデート・監視・バックアップシステム
- 24/7サポート体制

### 1.4. アーキテクチャ選定理由

**1社1サーバー型の採用理由：**
- データの完全分離によるセキュリティ最大化
- 他社の影響を一切受けない独立性
- 顧客ごとの完全なカスタマイズ自由度
- サーバースペックの個別最適化
- 明確なコスト構造と価格透明性

## 2. システムアーキテクチャ (System Architecture)

### 2.1. ホスティング環境

#### 2.1.1. 1社1サーバー型アーキテクチャ

```
[集中管理インフラ] - 運営会社が管理
├── 管理サーバー群（8台）
│   ├── Ansible Controller×2 (冗長化)
│   ├── 監視サーバー×2 (Prometheus/Grafana)
│   ├── バックアップサーバー×2 (冗長化)
│   └── Docker Registry×2 (カスタムイメージ配布)
├── 管理ポータル
│   ├── 顧客管理システム
│   ├── 課金管理システム
│   └── サポートチケットシステム
└── 自動化システム
    ├── プロビジョニング自動化
    ├── 監視自動化
    └── バックアップ自動化

[顧客個別環境群] - 各顧客が費用負担
├── 顧客001サーバー (専用VPS/クラウド)
│   └── Docker環境 (ERPNext + MariaDB + Redis + Nginx)
├── 顧客002サーバー (専用VPS/クラウド)
│   └── Docker環境 (ERPNext + MariaDB + Redis + Nginx)
├── ...
└── 顧客200サーバー (専用VPS/クラウド)
    └── Docker環境 (ERPNext + MariaDB + Redis + Nginx)
```

#### 2.1.2. サーバー選択肢（顧客が選択）

```yaml
server_options:
  basic:
    name: "ベーシックプラン"
    specs: "2vCPU, 4GB RAM, 80GB SSD"
    cost: "約8,000円/月"
    suitable_for: "従業員10名以下"
    
  standard:
    name: "スタンダードプラン"
    specs: "4vCPU, 8GB RAM, 160GB SSD"
    cost: "約15,000円/月"
    suitable_for: "従業員50名以下"
    
  professional:
    name: "プロフェッショナルプラン"
    specs: "8vCPU, 16GB RAM, 320GB SSD"
    cost: "約30,000円/月"
    suitable_for: "従業員100名以上"
    
  custom:
    name: "カスタムプラン"
    specs: "要相談"
    cost: "見積もり"
    suitable_for: "大規模企業"
```

### 2.2. 自動プロビジョニングシステム

#### 2.2.1. 新規顧客セットアップフロー

```python
# 完全自動化されたプロビジョニングプロセス
def provision_customer_server(customer_info):
    # 1. 顧客のサーバー情報を受け取り
    server_info = customer_info['server_details']
    
    # 2. SSHキーの自動設定
    setup_ssh_access(server_info)
    
    # 3. 基本環境の構築
    install_docker_environment(server_info)
    
    # 4. ERPNext環境のデプロイ
    deploy_erpnext_stack(server_info, customer_info)
    
    # 5. SSL証明書の自動取得・設定
    setup_ssl_certificate(customer_info['domain'])
    
    # 6. 監視エージェントのインストール
    install_monitoring_agent(server_info)
    
    # 7. バックアップ設定
    configure_automated_backup(server_info)
    
    # 8. 初期データとカスタマイズ
    apply_initial_customization(customer_info)
    
    # 9. 完了通知
    notify_customer_completion(customer_info)
```

#### 2.2.2. Docker Compose構成（各顧客サーバー）

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./traefik:/etc/traefik
      - /var/run/docker.sock:/var/run/docker.sock:ro
    labels:
      - "traefik.enable=true"
    restart: unless-stopped

  erpnext:
    image: registry.yourdomain.com/erpnext-japan:v15.latest
    environment:
      - SITE_NAME=${CUSTOMER_DOMAIN}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - INSTALL_APPS=erpnext,japan_compliance,custom_theme
    volumes:
      - sites:/home/frappe/frappe-bench/sites
      - assets:/home/frappe/frappe-bench/sites/assets
    depends_on:
      - mariadb
      - redis
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.erpnext.rule=Host(`${CUSTOMER_DOMAIN}`)"
      - "traefik.http.routers.erpnext.tls.certresolver=letsencrypt"
    restart: unless-stopped

  mariadb:
    image: mariadb:10.6
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MYSQL_DATABASE=erpnext
      - MYSQL_USER=erpnext
      - MYSQL_PASSWORD=${DB_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    restart: unless-stopped

  backup:
    image: registry.yourdomain.com/erpnext-backup:latest
    environment:
      - BACKUP_SCHEDULE="0 2 * * *"
      - RETENTION_DAYS=30
    volumes:
      - sites:/home/frappe/frappe-bench/sites:ro
      - db-data:/var/lib/mysql:ro
      - ./backups:/backups
    restart: unless-stopped

volumes:
  sites:
  assets:
  db-data:
```

### 2.3. 監視・管理システム

#### 2.3.1. 統合監視ダッシュボード

```yaml
# 200社を効率的に監視するための設定
monitoring_architecture:
  central_prometheus:
    scrape_interval: 30s
    retention: 90d
    federation: enabled
    
  customer_exporters:
    node_exporter: 
      port: 9100
      metrics: [cpu, memory, disk, network]
    mysql_exporter:
      port: 9104
      metrics: [connections, queries, replication]
    custom_exporter:
      port: 9200
      metrics: [users, transactions, documents]
      
  alerting_rules:
    - name: "サーバーダウン"
      condition: "up == 0"
      severity: "critical"
      action: "immediate_notification"
      
    - name: "高CPU使用率"
      condition: "cpu_usage > 85%"
      severity: "warning"
      action: "ticket_creation"
      
    - name: "ディスク容量不足"
      condition: "disk_free < 20%"
      severity: "warning"
      action: "customer_notification"
```

#### 2.3.2. 自動化された管理タスク

```python
# 日次管理タスクの自動化
class DailyManagementTasks:
    def __init__(self):
        self.customers = self.get_all_customers()
    
    def run_health_checks(self):
        """全顧客サーバーのヘルスチェック"""
        for customer in self.customers:
            status = check_server_health(customer.server_ip)
            if not status.is_healthy:
                create_incident_ticket(customer, status.issues)
    
    def apply_security_patches(self):
        """セキュリティパッチの自動適用"""
        for customer in self.customers:
            if customer.auto_patch_enabled:
                apply_patches(customer.server_ip, patch_type='security')
    
    def optimize_performance(self):
        """パフォーマンスの自動最適化"""
        for customer in self.customers:
            metrics = get_performance_metrics(customer.server_ip)
            if metrics.needs_optimization:
                apply_optimizations(customer.server_ip, metrics)
    
    def generate_reports(self):
        """月次レポートの自動生成"""
        for customer in self.customers:
            report = generate_monthly_report(customer)
            send_report_to_customer(customer.email, report)
```

## 3. 機能要件 (Functional Requirements)

### 3.1. 顧客管理ポータル

#### 3.1.1. セルフサービス機能

```yaml
customer_portal_features:
  dashboard:
    - server_status: "リアルタイムサーバー状態"
    - usage_metrics: "CPU/メモリ/ディスク使用状況"
    - user_activity: "アクティブユーザー数"
    - backup_status: "最新バックアップ状態"
    
  self_service:
    - restart_services: "サービス再起動"
    - download_backups: "バックアップダウンロード"
    - manage_users: "ユーザー管理"
    - view_logs: "ログ閲覧"
    
  billing:
    - current_plan: "現在のプラン"
    - usage_history: "使用履歴"
    - invoices: "請求書ダウンロード"
    - payment_methods: "支払い方法管理"
    
  support:
    - create_ticket: "サポートチケット作成"
    - knowledge_base: "ナレッジベース検索"
    - scheduled_maintenance: "メンテナンス予定"
    - system_status: "システム稼働状況"
```

### 3.2. 日本のインボイス制度対応

#### 3.2.1. 標準実装機能

```python
# 全顧客に標準で提供される機能
class JapanComplianceFeatures:
    
    def setup_invoice_system(self, customer):
        """インボイス制度対応の初期設定"""
        # 適格請求書発行事業者番号フィールドの追加
        add_custom_field('Company', 'qualified_invoice_number', 'Data')
        
        # 税率管理テーブルの作成
        create_tax_rate_table(['8%', '10%', '軽減税率8%'])
        
        # 適格請求書フォーマットの設定
        install_print_format('qualified_invoice_template')
        
    def validate_invoice_compliance(self, invoice):
        """請求書の適格性チェック"""
        required_fields = [
            'invoice_date',
            'invoice_number',
            'seller_name',
            'seller_registration_number',
            'buyer_name',
            'transaction_date',
            'item_description',
            'tax_rate',
            'tax_amount'
        ]
        
        for field in required_fields:
            if not invoice.get(field):
                raise ValidationError(f"{field}は必須項目です")
```

### 3.3. ホワイトラベル機能

#### 3.3.1. ブランディングカスタマイズ

```yaml
whitelabel_options:
  basic:
    - company_logo: "ロゴアップロード"
    - brand_colors: "ブランドカラー設定"
    - email_templates: "メールテンプレート編集"
    
  advanced:
    - custom_domain: "独自ドメイン設定"
    - login_page: "ログインページカスタマイズ"
    - favicon: "ファビコン設定"
    - footer_text: "フッターテキスト編集"
    
  enterprise:
    - complete_rebranding: "完全リブランディング"
    - custom_modules: "カスタムモジュール追加"
    - api_branding: "API応答のブランディング"
```

## 4. 非機能要件 (Non-Functional Requirements)

### 4.1. セキュリティ要件

#### 4.1.1. サーバーレベルセキュリティ

```yaml
security_measures:
  server_hardening:
    - disable_root_login: true
    - ssh_key_only: true
    - fail2ban: enabled
    - firewall_rules: "strict_whitelist"
    
  application_security:
    - ssl_enforcement: "A+ rating required"
    - security_headers: 
        - "X-Frame-Options: DENY"
        - "X-Content-Type-Options: nosniff"
        - "Strict-Transport-Security: max-age=31536000"
    - rate_limiting: "100 requests/minute"
    - waf_protection: "ModSecurity with OWASP rules"
    
  data_protection:
    - encryption_at_rest: "AES-256"
    - encryption_in_transit: "TLS 1.3"
    - backup_encryption: "GPG encryption"
    - key_management: "Automated rotation"
```

### 4.2. パフォーマンス要件

#### 4.2.1. サービスレベル目標

```yaml
performance_sla:
  availability: "99.9% (月間ダウンタイム43分以内)"
  response_time:
    api: "< 200ms (95パーセンタイル)"
    page_load: "< 2秒 (95パーセンタイル)"
  concurrent_users: "契約プランに応じて保証"
  data_processing: "1000レコード/秒以上"
```

### 4.3. バックアップ要件

#### 4.3.1. 自動バックアップ戦略

```bash
#!/bin/bash
# 多層バックアップ戦略

# 1. 日次ローカルバックアップ（高速リストア用）
daily_local_backup() {
    docker exec ${CUSTOMER}_erpnext bench --site all backup
    tar czf /backups/local/daily_${DATE}.tar.gz /sites/*
    # 7日分保持
    find /backups/local -name "daily_*.tar.gz" -mtime +7 -delete
}

# 2. 日次リモートバックアップ（別データセンター）
daily_remote_backup() {
    rsync -avz --delete /backups/local/ backup.yourdomain.com:/backups/${CUSTOMER}/
    # 30日分保持
}

# 3. 週次クラウドバックアップ（長期保管）
weekly_cloud_backup() {
    aws s3 sync /backups/local/ s3://backup-bucket/${CUSTOMER}/ \
        --storage-class GLACIER_DEEP_ARCHIVE
    # 1年分保持
}

# 4. 月次オフラインバックアップ（コンプライアンス用）
monthly_offline_backup() {
    # 暗号化してオフラインメディアに保存
    gpg --encrypt --recipient backup@yourdomain.com \
        /backups/monthly_${MONTH}.tar.gz
}
```

## 5. 運用要件

### 5.1. サポート体制

#### 5.1.1. サポートレベル

```yaml
support_tiers:
  basic:
    name: "ベーシックサポート"
    hours: "平日 9:00-18:00"
    response_time: "翌営業日"
    channels: ["メール", "チケット"]
    price: "管理費に含む"
    
  standard:
    name: "スタンダードサポート"
    hours: "平日 9:00-21:00"
    response_time: "4時間以内"
    channels: ["メール", "チケット", "電話"]
    price: "+5,000円/月"
    
  premium:
    name: "プレミアムサポート"
    hours: "24/7"
    response_time: "1時間以内"
    channels: ["メール", "チケット", "電話", "リモート接続"]
    dedicated_engineer: true
    price: "+20,000円/月"
```

### 5.2. 運用自動化

#### 5.2.1. 自動化スクリプト群

```python
# 運用自動化のためのタスクランナー
class OperationAutomation:
    
    @daily_task
    def security_scan(self):
        """日次セキュリティスキャン"""
        for customer in self.get_all_customers():
            scan_result = run_security_scan(customer.server_ip)
            if scan_result.has_vulnerabilities():
                create_security_ticket(customer, scan_result)
    
    @weekly_task
    def performance_tuning(self):
        """週次パフォーマンスチューニング"""
        for customer in self.get_all_customers():
            metrics = analyze_performance_metrics(customer)
            if metrics.needs_tuning():
                apply_performance_tuning(customer, metrics.recommendations)
    
    @monthly_task
    def capacity_planning(self):
        """月次キャパシティプランニング"""
        for customer in self.get_all_customers():
            usage_trend = analyze_usage_trend(customer, days=30)
            if usage_trend.predicts_capacity_issue():
                notify_customer_upgrade_recommendation(customer, usage_trend)
```

## 6. 移行計画

### 6.1. 既存顧客の移行戦略

```yaml
migration_phases:
  phase1:
    name: "パイロット移行"
    duration: "1ヶ月"
    customers: 10
    approach: "希望者から順次移行"
    
  phase2:
    name: "段階的移行"
    duration: "3ヶ月"
    customers: 50
    approach: "小規模顧客から移行"
    
  phase3:
    name: "大規模移行"
    duration: "6ヶ月"
    customers: 140
    approach: "全顧客移行完了"
```

## 7. 料金体系

### 7.1. 管理サービス料金

```yaml
management_fee_structure:
  basic:
    name: "ベーシック管理プラン"
    monthly_fee: "15,000円"
    includes:
      - "基本監視"
      - "自動バックアップ"
      - "セキュリティアップデート"
      - "メールサポート"
      
  standard:
    name: "スタンダード管理プラン"
    monthly_fee: "25,000円"
    includes:
      - "ベーシックプランの全機能"
      - "パフォーマンス最適化"
      - "電話サポート"
      - "月次レポート"
      
  professional:
    name: "プロフェッショナル管理プラン"
    monthly_fee: "50,000円"
    includes:
      - "スタンダードプランの全機能"
      - "24/7サポート"
      - "専任エンジニア"
      - "カスタマイズ対応"
      
  setup_fee:
    basic: "50,000円"
    standard: "100,000円"
    professional: "200,000円"
```

### 7.2. 収益シミュレーション

```
200社での月間収益予測:
- ベーシック: 100社 × 15,000円 = 150万円
- スタンダード: 80社 × 25,000円 = 200万円
- プロフェッショナル: 20社 × 50,000円 = 100万円
月間総収益: 450万円
年間総収益: 5,400万円

運用コスト:
- 技術者3名: 180万円/月
- インフラ費用: 30万円/月
- その他経費: 40万円/月
月間総コスト: 250万円

月間利益: 200万円（利益率44%）
年間利益: 2,400万円
```

## 8. リスク管理

### 8.1. リスクと対策

```yaml
risk_mitigation:
  technical_risks:
    - risk: "大規模障害による複数顧客への影響"
      mitigation: "自動化による迅速な復旧、SLA保証"
      
    - risk: "セキュリティインシデント"
      mitigation: "多層防御、定期的な脆弱性診断"
      
  business_risks:
    - risk: "顧客サーバーのコスト増加"
      mitigation: "最適化提案、代替プロバイダー提示"
      
    - risk: "競合他社の参入"
      mitigation: "高品質サービス、顧客ロイヤリティ向上"
      
  operational_risks:
    - risk: "スケールに伴う運用負荷増大"
      mitigation: "徹底的な自動化、AIによる運用支援"
```

## 9. 成功指標

### 9.1. KPI定義

```yaml
key_performance_indicators:
  technical_kpis:
    - uptime: "> 99.9%"
    - mttr: "< 30分"
    - automation_rate: "> 90%"
    - security_incidents: "< 1件/年"
    
  business_kpis:
    - customer_satisfaction: "> 4.5/5"
    - churn_rate: "< 5%/年"
    - revenue_per_customer: "> 25,000円/月"
    - profit_margin: "> 40%"
    
  growth_kpis:
    - new_customers: "> 10社/月"
    - upsell_rate: "> 20%/年"
    - referral_rate: "> 30%"
```

## 10. 今後の拡張計画

### 10.1. ロードマップ

```yaml
future_roadmap:
  year1:
    - "200社体制の確立"
    - "AI運用アシスタント導入"
    - "モバイルアプリ提供"
    
  year2:
    - "500社への拡張"
    - "業界特化型テンプレート提供"
    - "グローバル展開準備"
    
  year3:
    - "1000社体制"
    - "AIによる自動最適化"
    - "プラットフォーム化"
```

---

**改訂履歴:**
- v1.0 (2024-01-01): 初版（40サーバー共有型）
- v2.0 (2025-01-08): 顧客負担型1社1サーバーモデルへ全面改訂

**承認者:**
- システム設計: ___________
- ビジネス責任者: ___________
- 技術責任者: ___________