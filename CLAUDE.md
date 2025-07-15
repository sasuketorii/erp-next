# ERP Next - AI支援開発ガイド

最終更新: 2025年7月15日

## 👤 開発者情報

**開発者**: Sasuke Torii  
**エンジニアネーム**: sasuketorii  
**プロジェクトURL**: https://github.com/sasuketorii/erp-next  

## 🎯 プロジェクト概要

Frappe/ERPNextをベースとしたマルチテナント型SaaSプラットフォームの開発プロジェクトです。VPSインフラ上で動作し、ホワイトラベル機能を含むカスタムDockerイメージによる迅速なデプロイを実現します。

### 📋 主要機能

1. **マルチテナント対応**
   - テナントごとの独立したデータベース
   - カスタムドメイン設定
   - リソース使用量の個別管理

2. **ホワイトラベル機能**
   - ブランディングのカスタマイズ
   - UIテーマの変更
   - カスタムランディングページ

3. **Docker化されたデプロイメント**
   - カスタムアプリを含むDockerイメージ
   - docker-composeによるワンコマンドデプロイ
   - 環境間の一貫性保証

## 🗂️ プロジェクト構造

```
erp-next/
├── SOW/                     # ⭐ 作業記録（必須）
│   ├── Daily/              # 日次作業ログ
│   ├── Weekly/             # 週次進捗レポート
│   ├── Milestones/         # マイルストーン記録
│   └── Templates/          # 各種テンプレート
├── logs/                    # ⭐ 開発ログ（必須）
│   ├── decisions/          # 技術的意思決定記録
│   ├── meetings/           # ミーティング議事録
│   ├── changes/            # 重要な変更履歴
│   └── development/        # 開発詳細ログ
├── frappe_docker/          # Docker設定
│   ├── compose.yaml        # メインcompose設定
│   ├── overrides/          # 環境別設定
│   ├── images/             # Dockerfile定義
│   └── development/        # 開発環境
│       └── frappe-bench/
│           └── apps/       # アプリケーション配置場所
│               ├── frappe/
│               ├── erpnext/
│               └── whitelabel/
├── apps.json               # カスタムアプリ定義
├── build/                  # ビルドスクリプト
│   └── build-custom-image.sh
├── deploy/                 # デプロイメント設定
├── docs/                   # ドキュメント
│   ├── deployment/         # デプロイガイド
│   ├── development/        # 開発ガイド
│   └── api/               # API仕様
├── custom_apps/           # カスタムアプリソース
├── tests/                 # テストスイート
└── docker-compose.yml     # 本番用compose設定
```

## 🔧 技術スタック

### コアシステム
- **フレームワーク**: Frappe Framework v15
- **ERP**: ERPNext v15
- **言語**: Python 3.11+, JavaScript (ES6+)
- **データベース**: MariaDB 10.6+
- **キャッシュ**: Redis 7.0+
- **Webサーバー**: Nginx / Traefik

### カスタムアプリ
- **whitelabel**: ブランディングカスタマイズ機能
- **追加予定**: 日本向けローカライゼーション

### インフラ・デプロイ
- **コンテナ**: Docker & Docker Compose
- **レジストリ**: GitHub Container Registry (ghcr.io)
- **対象環境**: VPS (Xserver VPS等)

## 📏 コーディング規約

### Frappe/ERPNext開発規約

1. **DocType作成時**
   - 命名規則: PascalCase (例: CustomerInvoice)
   - フィールド名: snake_case (例: customer_name)
   - 必須フィールドは明示的に設定

2. **Python コード**
   - Frappe APIの使用を優先
   - `frappe.db.sql`より`frappe.get_doc`を使用
   - トランザクション管理は`frappe.db.commit()`

3. **JavaScript コード**
   - Frappe UIフレームワークを使用
   - `frappe.call`でサーバーサイドメソッド呼び出し
   - フォームスクリプトは`frappe.ui.form`を使用

### Docker関連
- Dockerfileは`images/`ディレクトリに配置
- 環境変数は`.env`ファイルで管理
- マルチステージビルドで最適化

## 🧪 テスト戦略

### Frappeテスト
```bash
# 全テスト実行
bench --site mysite.localhost run-tests

# 特定アプリのテスト
bench --site mysite.localhost run-tests --app whitelabel

# 特定モジュールのテスト
bench --site mysite.localhost run-tests --module whitelabel.tests.test_branding
```

### カバレッジ目標
- DocType関連: 90%以上
- API エンドポイント: 85%以上
- ビジネスロジック: 80%以上

## 📚 主要ドキュメント

### 開発関連
- [開発環境ガイド](frappe.io Docs/開発環境ガイド.md)
- [カスタムアプリインストール](frappe.io Docs/カスタムアプリインストール方法.md)
- [ホワイトラベル化ガイド](frappe.io Docs/推奨されるホワイトラベル化・カスタム方法・拡張方法.md)

### 要件・仕様
- [マルチテナント要件定義](要件定義/マルチテナント型ERP SaaS 要件定義書 (Xserver VPS版).md)
- [顧客負担型要件定義](要件定義/顧客負担型ERP SaaS 要件定義書 v2.0 (1社1サーバー版).md)

### 分析レポート
- [ERPシステムGAP分析](ERP_SYSTEM_GAP_ANALYSIS_REPORT.md)
- [アーキテクチャ比較](architecture_comparison_200_servers.md)
- [データベースAPI分析](database_api_analysis_report.md)

## 🚨 重要な注意事項

### セキュリティ
1. **データベース認証情報**
   - site_config.jsonに記載
   - 絶対にGitにコミットしない
   - 環境変数で管理

2. **APIキー管理**
   - .envファイルで管理
   - 本番環境では環境変数として設定

3. **マルチテナント分離**
   - サイトごとに独立したDB
   - クロステナントアクセスの防止

### パフォーマンス
1. **Redis活用**
   - キャッシュ、キュー、ソケットIOで別インスタンス
   - 適切なメモリ割り当て

2. **ワーカー設定**
   - short, default, long キューの適切な分配
   - CPU/メモリに応じたワーカー数調整

## 📈 品質指標（KPI）

### 開発品質
- [ ] コードカバレッジ: 80%以上
- [ ] ビルド成功率: 95%以上
- [ ] Dockerイメージサイズ: 2GB以下

### パフォーマンス
- [ ] ページ読み込み時間: 3秒以内
- [ ] API レスポンス: 500ms以内
- [ ] 同時接続数: 100ユーザー/サイト

## 🔄 開発ワークフロー

### 新機能開発
1. `feature/機能名`ブランチを作成
2. DocTypeまたはカスタムアプリを開発
3. テストを作成・実行
4. Dockerイメージをビルド・テスト
5. プルリクエストを作成

### デプロイフロー
1. apps.jsonを更新
2. `build/build-custom-image.sh`でイメージビルド
3. ghcr.ioにプッシュ
4. VPSでdocker-compose更新・再起動

## 📝 SOW（作業記録）の義務

### 日次記録（必須）
- **ファイル**: `SOW/Daily/YYYY-MM-DD-daily-log.md`
- **内容**:
  - 実装した機能・修正
  - 発生した技術的課題
  - 解決策と結果
  - 翌日の計画

### 週次サマリー（必須）
- **ファイル**: `SOW/Weekly/YYYY-WW-weekly-summary.md`
- **内容**:
  - 完了したタスク一覧
  - Dockerイメージのビルド状況
  - テスト結果とカバレッジ
  - 次週の目標

### 技術的意思決定（必須）
- **ファイル**: `logs/decisions/ADR-XXX-[title].md`
- **記録対象**:
  - アーキテクチャ変更
  - 新規アプリ導入
  - パフォーマンス最適化
  - セキュリティ対策

## 🆘 トラブルシューティング

### Docker関連
```bash
# コンテナログ確認
docker compose logs -f backend

# コンテナ再起動
docker compose restart backend

# ボリューム削除して再構築
docker compose down -v
docker compose up -d
```

### Frappe/ERPNext関連
```bash
# ベンチコンソール
docker compose exec backend bench console

# マイグレーション実行
docker compose exec backend bench migrate

# キャッシュクリア
docker compose exec backend bench clear-cache
```

### 一般的な問題
1. **アプリインストール失敗**
   - 依存関係の確認
   - apps.jsonの記述確認
   - Dockerイメージの再ビルド

2. **パフォーマンス問題**
   - Redisの状態確認
   - ワーカー数の調整
   - データベースインデックス確認

---

## 📋 開発チェックリスト

### 新規開発開始時
- [ ] 開発環境の起動確認
- [ ] whitelabelアプリのインストール確認
- [ ] テスト実行環境の確認

### 機能実装時
- [ ] DocType/カスタムアプリの作成
- [ ] テストコードの作成
- [ ] ローカルでの動作確認
- [ ] Dockerイメージでの動作確認

### リリース前
- [ ] 全テストの実行
- [ ] Dockerイメージのビルド
- [ ] apps.jsonの更新
- [ ] ドキュメントの更新
- [ ] SOW記録の完了

**このガイドに従って、高品質なERP Nextプラットフォームを構築してください。**