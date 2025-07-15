# Frappe/ERPNext 開発ガイド - 公式リソース集

**作成日**: 2025年7月15日  
**作成者**: Sasuke Torii  
**対象**: Frappe Framework / ERPNext開発者向け

## 📋 概要

このガイドでは、Frappe Framework と ERPNext の開発に必要な公式ドキュメントとリソースを体系的にまとめています。初心者から上級者まで、開発レベルに応じた情報を提供します。

## 📘 開発ガイド（ERPNext 開発者向け）

### 🎯 Frappe Framework Tutorial
**目的**: Frappeフレームワーク上でアプリを構築するための公式チュートリアル

**内容**:
- DocType の作成方法
- ERPNext 開発に必要な基礎知識
- フレームワークの基本概念
- 実践的な開発例

**URL**: https://docs.frappe.io/framework/user/en/tutorial

**推奨対象**: 
- ERPNext開発の初心者
- DocType作成を学びたい開発者
- フレームワークの基本を理解したい人

### 🔧 App Development ガイド
**目的**: カスタムアプリ（プラグイン相当）を作成する方法の体系的な説明

**内容**:
- カスタムアプリの構築方法
- フック（hooks.py）の使用方法
- イベント駆動プログラミング
- アプリケーションの構造設計

**URL**: https://docs.frappe.io/framework/user/en/introduction  
※ページ内で 'App Development' セクションを参照

**推奨対象**:
- カスタム機能を開発したい開発者
- 既存のERPNextを拡張したい人
- プラグインアーキテクチャを理解したい人

## 🔌 プラグイン開発ガイド（カスタムアプリ開発）

### 🚀 Advanced App Development
**目的**: 拡張性豊かなカスタムアプリの開発

**内容**:
- DocType イベントの活用
- バックグラウンドジョブの実装
- カスタムボタンの作成
- ワークフローの設計
- API開発とカスタマイズ

**推奨使用例**:
```python
# hooks.py でのイベント定義例
doc_events = {
    "Sales Invoice": {
        "on_submit": "custom_app.events.sales_invoice.on_submit",
        "on_cancel": "custom_app.events.sales_invoice.on_cancel"
    }
}

# カスタムボタンの追加
def get_custom_buttons():
    return [
        {
            "label": "カスタム処理",
            "fieldname": "custom_action",
            "action": "custom_app.api.custom_action"
        }
    ]
```

**推奨対象**:
- 高度なカスタマイズが必要な開発者
- エンタープライズ向け機能を開発する人
- 複雑なビジネスロジックを実装する人

## 🔧 プラグイン導入ガイド（アプリのインストール手順）

### 📦 Installation Guide
**目的**: Benchを使った Frappe/ERPNext アプリ導入方法

**内容**:
- Frappe Benchの使用方法
- アプリのインストール手順
- 依存関係の管理
- 開発環境の設定

**URL**: https://docs.frappe.io/framework/user/en/installation

**実践的なコマンド**:
```bash
# アプリの取得
bench get-app [app_name] [repository_url]

# アプリのインストール
bench --site [site_name] install-app [app_name]

# アプリの更新
bench --site [site_name] migrate

# アプリの削除
bench --site [site_name] uninstall-app [app_name]
```

**推奨対象**:
- 開発環境を構築したい人
- カスタムアプリを導入したい管理者
- Benchツールを活用したい開発者

### 🏁 Getting Started with ERPNext
**目的**: ERPNext の導入時の選択肢とセルフホストについて

**内容**:
- Self-Hosting（セルフホスト）の選択肢
- 自前サーバでの導入指針
- デプロイメント方法の比較
- 運用時の考慮事項

**推奨対象**:
- 自社サーバーでの運用を検討している人
- クラウドとオンプレミスの比較を検討している人
- 長期運用を計画している組織

## 🏠 セルフホストガイド

### 🖥️ Self-Hosting / 部署オプション
**目的**: "Choose Deployment" における Self-Hosting の選択肢

**内容**:
- 自前サーバ構築の指針
- インフラ要件の検討
- セキュリティ対策
- 運用・保守の考慮事項

**推奨システム要件**:
```
最小構成:
- CPU: 2コア以上
- RAM: 4GB以上
- Storage: 50GB以上
- OS: Ubuntu 18.04 LTS以上

推奨構成:
- CPU: 4コア以上
- RAM: 8GB以上
- Storage: 100GB SSD以上
- OS: Ubuntu 20.04 LTS以上
```

### 🐳 Docker を使ったセルフホスト
**目的**: Docker 環境での ERPNext 構築

**内容**:
- Docker Compose設定
- カスタムイメージの作成
- データ永続化の設定
- 環境変数の管理

**実践的な設定例**:
```yaml
# docker-compose.yml
version: '3.8'
services:
  erpnext:
    image: frappe/erpnext:latest
    ports:
      - "8080:8000"
    environment:
      - MYSQL_ROOT_PASSWORD=admin
    volumes:
      - ./sites:/home/frappe/frappe-bench/sites
```

## 🖥️ ローカルホストガイド

### 🚀 Installing ERPNext via Docker for Beginners
**目的**: ローカル環境（localhost:8080 など）に Docker で ERPNext を立ち上げる

**内容**:
- Docker環境でのERPNext起動手順
- ローカル開発環境の設定
- デバッグとトラブルシューティング
- 開発ワークフローの最適化

**参考URL**: https://codewithkarani.com/ （Docker関連記事）

**ステップバイステップ手順**:
```bash
# 1. リポジトリのクローン
git clone https://github.com/frappe/frappe_docker.git
cd frappe_docker

# 2. 開発環境の起動
docker-compose -f compose.yaml -f overrides/compose.mariadb.yaml up -d

# 3. サイトの作成
docker-compose exec backend bench new-site mysite.localhost

# 4. ERPNextアプリのインストール
docker-compose exec backend bench --site mysite.localhost install-app erpnext

# 5. アクセス確認
# http://localhost:8080
```

## 🔗 リンクまとめ

| 用途 | ガイド名称 | 概要 | URL |
|------|-----------|------|-----|
| 開発ガイド | Frappe Framework Tutorial | DocType 作成など、ERPNext開発の基本 | https://docs.frappe.io/framework/user/en/tutorial |
| プラグイン開発 | App Development Guides | カスタムイベント・背景処理等 | https://docs.frappe.io/framework/user/en/introduction |
| プラグイン導入 | Installation Guide | Bench によるアプリ導入手順 | https://docs.frappe.io/framework/user/en/installation |
| セルフホスト | Getting Started with ERPNext | 自前サーバ構築の選択肢 | https://docs.frappe.io/framework/user/en/installation |
| セルフホスト(Docker) | Docker Guide | Docker で ERPNext を構築 | https://github.com/frappe/frappe_docker |
| ローカルホスト(Docker) | Docker Localhost Guide | localhost への Docker 展開手順 | https://codewithkarani.com/ |

## 📚 学習パス

### 🎯 初心者向け学習順序
1. **Frappe Framework Tutorial** - 基本概念の理解
2. **Installation Guide** - 環境構築とアプリインストール
3. **Docker Localhost Guide** - ローカル開発環境の構築
4. **App Development Guides** - カスタムアプリの開発

### 🚀 上級者向け学習順序
1. **Advanced App Development** - 高度なカスタマイズ
2. **Self-Hosting Guide** - 本番環境の構築
3. **Docker Self-Host** - 本番Docker環境の構築
4. **API Development** - カスタムAPI開発

## 🛠️ 実践的な開発フロー

### 1. 開発環境の準備
```bash
# Docker環境の起動
docker-compose up -d

# 開発用サイトの作成
docker-compose exec backend bench new-site dev.localhost

# 必要なアプリのインストール
docker-compose exec backend bench --site dev.localhost install-app erpnext
```

### 2. カスタムアプリの作成
```bash
# 新しいアプリの作成
docker-compose exec backend bench new-app custom_app

# アプリの取得とインストール
docker-compose exec backend bench get-app custom_app
docker-compose exec backend bench --site dev.localhost install-app custom_app
```

### 3. 開発とテスト
```bash
# 開発サーバーの起動
docker-compose exec backend bench start

# テストの実行
docker-compose exec backend bench --site dev.localhost run-tests --app custom_app

# マイグレーションの実行
docker-compose exec backend bench --site dev.localhost migrate
```

## 📖 追加リソース

### 公式コミュニティ
- **Frappe Forum**: https://discuss.frappe.io/
- **GitHub Issues**: https://github.com/frappe/frappe/issues
- **Discord**: Frappe Community Discord

### 学習リソース
- **YouTube チャンネル**: Frappe Official
- **ブログ**: https://frappe.io/blog
- **例題とサンプル**: https://github.com/frappe/frappe/tree/develop/frappe/core

### 開発ツール
- **Frappe Bench**: 開発・管理ツール
- **Frappe Builder**: ビジュアル開発ツール
- **Frappe Books**: 会計システム参考実装

## 🚨 注意事項

### 開発時の留意点
1. **バージョン互換性**: Frappe Framework と ERPNext のバージョンを合わせる
2. **データベース設計**: DocType設計は慎重に行う（後から変更困難）
3. **セキュリティ**: 権限管理とデータ検証を適切に実装
4. **パフォーマンス**: 大量データを扱う場合のインデックス設計

### 本番環境での注意
1. **バックアップ**: 定期的なデータベースバックアップ
2. **監視**: システムリソースとアプリケーションの監視
3. **更新**: セキュリティアップデートの適用
4. **スケーリング**: 負荷に応じたスケーリング計画

---

**このガイドは、Frappe/ERPNext開発の包括的なリソース集として機能します。開発レベルに応じて、適切なドキュメントを参照して効率的な開発を進めてください。**