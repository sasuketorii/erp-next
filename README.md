# ERP Next - マルチテナント型SaaSプラットフォーム

![Version](https://img.shields.io/badge/version-0.0.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Frappe](https://img.shields.io/badge/frappe-v15-orange)
![ERPNext](https://img.shields.io/badge/erpnext-v15-red)

## 📖 概要

Frappe/ERPNextをベースとしたマルチテナント型SaaSプラットフォームです。ホワイトラベル機能を含むカスタムDockerイメージにより、VPSインフラへの迅速なデプロイを実現します。

## ✨ 主な特徴

### 🏢 マルチテナント対応
- **独立したデータベース**: 各テナントごとに完全に分離されたデータ
- **カスタムドメイン対応**: テナント独自のドメイン設定
- **スケーラブル設計**: VPS単位での水平スケーリング

### 🎨 ホワイトラベル機能
- **ブランディングカスタマイズ**: ロゴ、ファビコン、カラーテーマ
- **UIカスタマイズ**: ナビゲーション、ヘルプメニューの表示制御
- **カスタムランディングページ**: テナント独自のウェルカムページ

### 🐳 Docker化された環境
- **プリインストール済みアプリ**: ERPNext + カスタムアプリ
- **ワンコマンドデプロイ**: docker-composeによる簡単セットアップ
- **環境の一貫性**: 開発から本番まで同一環境

## 🚀 クイックスタート

### 開発環境のセットアップ

```bash
# リポジトリのクローン
git clone https://github.com/sasuketorii/erp-next.git
cd erp-next

# 開発環境の起動
cd frappe_docker
docker compose -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  up -d

# サイトへのアクセス
# URL: http://mysite.localhost:8080
# 初期ユーザー: Administrator
# 初期パスワード: (初回アクセス時に設定)
```

### カスタムアプリのインストール

```bash
# Dockerコンテナへ接続
docker compose exec backend bash

# ホワイトラベルアプリのインストール
bench --site mysite.localhost install-app whitelabel

# ベンチの再起動
bench restart
```

## 📁 プロジェクト構造

```
erp-next/
├── frappe_docker/           # Docker設定ファイル
│   ├── compose.yaml        # メインのcompose設定
│   ├── overrides/          # 環境別override設定
│   ├── images/             # Dockerfileテンプレート
│   └── development/        # 開発環境設定
├── apps.json               # カスタムアプリ定義
├── build/                  # ビルドスクリプト
│   └── build-custom-image.sh
├── deploy/                 # デプロイメント設定
│   ├── vps/               # VPS環境設定
│   └── kubernetes/        # K8s設定（将来対応）
├── docs/                   # ドキュメント
│   ├── deployment/        # デプロイガイド
│   ├── development/       # 開発ガイド
│   └── api/              # API仕様
├── custom_apps/           # カスタムFrappeアプリ
│   └── whitelabel/       # ホワイトラベル機能
├── SOW/                   # 作業記録
│   ├── Daily/            # 日次作業ログ
│   ├── Weekly/           # 週次進捗報告
│   └── Milestones/       # マイルストーン記録
└── tests/                 # テストスイート
```

## 🔧 カスタムDockerイメージのビルド

### 1. apps.jsonの作成

```json
[
  {
    "url": "https://github.com/frappe/erpnext",
    "branch": "version-15"
  },
  {
    "url": "https://github.com/bhavesh95863/whitelabel",
    "branch": "master"
  }
]
```

### 2. イメージのビルド

```bash
# Base64エンコード
export APPS_JSON_BASE64=$(base64 -w 0 apps.json)

# Dockerイメージのビルド
docker build \
  --build-arg=FRAPPE_PATH=https://github.com/frappe/frappe \
  --build-arg=FRAPPE_BRANCH=version-15 \
  --build-arg=APPS_JSON_BASE64=$APPS_JSON_BASE64 \
  --tag=ghcr.io/sasuketorii/erp-next:v1.0.0 \
  --file=frappe_docker/images/layered/Containerfile .

# レジストリへプッシュ
docker push ghcr.io/sasuketorii/erp-next:v1.0.0
```

## 🚢 本番環境へのデプロイ

### VPSでのセットアップ

```bash
# 環境変数の設定
export CUSTOM_IMAGE='ghcr.io/sasuketorii/erp-next'
export CUSTOM_TAG='v1.0.0'

# Docker Composeでの起動
docker compose -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.proxy.yaml \
  up -d
```

## 💻 技術スタック

- **フレームワーク**: Frappe Framework v15
- **ERP**: ERPNext v15
- **データベース**: MariaDB 10.6+
- **キャッシュ**: Redis 7.0+
- **Webサーバー**: Nginx / Traefik
- **コンテナ**: Docker & Docker Compose
- **開発言語**: Python 3.11+, JavaScript

## 📋 要件

### 最小システム要件
- **CPU**: 2コア以上
- **RAM**: 4GB以上（推奨8GB）
- **ストレージ**: 20GB以上のSSD
- **OS**: Ubuntu 22.04 LTS / Debian 12

### 推奨環境
- **CPU**: 4コア以上
- **RAM**: 16GB以上
- **ストレージ**: 100GB以上のNVMe SSD
- **ネットワーク**: 1Gbps以上

## 🧪 テスト

```bash
# コンテナに接続
docker compose exec backend bash

# Frappeのテスト実行
bench --site mysite.localhost run-tests

# 特定アプリのテスト
bench --site mysite.localhost run-tests --app whitelabel

# カバレッジレポート
bench --site mysite.localhost run-tests --coverage
```

## 📚 ドキュメント

- [開発環境ガイド](frappe.io Docs/開発環境ガイド.md)
- [カスタムアプリインストール方法](frappe.io Docs/カスタムアプリインストール方法.md)
- [ホワイトラベル化ガイド](frappe.io Docs/推奨されるホワイトラベル化・カスタム方法・拡張方法.md)
- [マルチテナント要件定義](要件定義/マルチテナント型ERP SaaS 要件定義書 (Xserver VPS版).md)

## 🔐 セキュリティ

- **データ分離**: テナント間の完全なデータ分離
- **HTTPS対応**: Let's Encrypt自動証明書
- **定期バックアップ**: 自動バックアップ機能
- **アクセス制御**: IP制限、2要素認証対応

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチへプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトは [MIT ライセンス](LICENSE) の下で公開されています。

## 👥 開発者

**Sasuke Torii**  
Role: Lead Developer  
GitHub: [@sasuketorii](https://github.com/sasuketorii)

---

AI支援開発の詳細については [CLAUDE.md](CLAUDE.md) を参照してください。