# Whitelabelモジュール問題 - 対策ガイド

**作成日**: 2025年7月15日  
**作成者**: Sasuke Torii  
**重要度**: 🔴 高（サイト起動に影響）

## 🚨 問題の概要

### 発生した問題
Docker環境を再起動した際に、以下のエラーが発生してサイトがHTTP 500エラーになる：
```
ModuleNotFoundError: No module named 'whitelabel'
```

### 影響
- サイトが完全にアクセス不可能（HTTP 500エラー）
- すべての操作が失敗
- ユーザーがシステムを利用できない

### 根本原因
1. **Dockerボリュームの問題**
   - whitelabelアプリがコンテナ再起動時に適切にマウントされない
   - Python環境のパスが失われる

2. **アプリの永続化問題**
   - カスタムアプリがコンテナイメージに含まれていない
   - ボリュームマウントに依存している

## ✅ 即座の解決方法

### 1. whitelabelアプリの再インストール
```bash
# 1. whitelabelアプリを再取得
cd frappe_docker
docker compose exec backend bench get-app whitelabel https://github.com/bhavesh95863/whitelabel

# 2. サービスを再起動
docker compose restart backend frontend websocket

# 3. 動作確認
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
# 期待値: 200
```

### 2. 実行時間
- **所要時間**: 約2-3分
- **ダウンタイム**: 最小限

## 🛡️ 予防策

### 1. 起動スクリプトの作成
```bash
#!/bin/bash
# startup-check.sh
# Docker環境起動時の自動チェックスクリプト

echo "🚀 ERP Next環境を起動しています..."

# 1. サービス起動
cd frappe_docker
docker compose -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.proxy.yaml up -d

# 2. 起動待機
echo "⏳ サービスの起動を待機中..."
sleep 15

# 3. whitelabelモジュールチェック
echo "🔍 whitelabelモジュールを確認中..."
if ! docker compose exec backend python -c "import whitelabel" 2>/dev/null; then
    echo "⚠️  whitelabelモジュールが見つかりません。再インストールします..."
    docker compose exec backend bench get-app whitelabel https://github.com/bhavesh95863/whitelabel
    docker compose restart backend frontend websocket
    sleep 10
fi

# 4. 最終確認
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ 環境が正常に起動しました！"
    echo "🌐 http://localhost:8080 でアクセス可能です"
else
    echo "❌ エラー: HTTP Status $HTTP_STATUS"
    echo "ログを確認してください: docker compose logs backend"
fi
```

### 2. Docker Composeオーバーライドの作成
```yaml
# overrides/compose.whitelabel.yaml
services:
  backend:
    volumes:
      - ../apps/whitelabel:/home/frappe/frappe-bench/apps/whitelabel:cached
```

### 3. カスタムDockerイメージの作成（推奨）
```dockerfile
# images/custom/Dockerfile
FROM frappe/erpnext:v15.67.0

# whitelabelアプリを事前インストール
RUN bench get-app whitelabel https://github.com/bhavesh95863/whitelabel
```

## 📋 環境起動チェックリスト

### 起動前チェック
- [ ] `.env`ファイルの確認
- [ ] 必要なポートが空いているか確認（8080）
- [ ] Dockerが起動しているか確認

### 起動手順
1. [ ] startup-check.shスクリプトを実行
2. [ ] HTTP 200レスポンスを確認
3. [ ] ログイン画面が表示されることを確認
4. [ ] 日本語表示を確認

### 起動後チェック
- [ ] whitelabelモジュールの動作確認
  ```bash
  docker compose exec backend bench --site sasuke.localhost list-apps
  ```
- [ ] データベース接続確認
  ```bash
  docker compose exec backend bench --site sasuke.localhost list-apps
  ```
- [ ] キャッシュクリア（必要に応じて）
  ```bash
  docker compose exec backend bench --site sasuke.localhost clear-cache
  ```

## 🔧 トラブルシューティング

### 症状別対処法

#### 1. HTTP 500エラーが続く場合
```bash
# ログ確認
docker compose logs backend --tail=50

# whitelabelアプリの状態確認
docker compose exec backend ls -la apps/whitelabel/

# Pythonパスの確認
docker compose exec backend python -c "import sys; print(sys.path)"
```

#### 2. whitelabelアプリが見つからない場合
```bash
# アプリディレクトリ確認
docker compose exec backend ls -la apps/

# 手動でクローン
docker compose exec backend git clone https://github.com/bhavesh95863/whitelabel apps/whitelabel

# pipインストール
docker compose exec backend pip install -e apps/whitelabel/
```

#### 3. 権限エラーの場合
```bash
# 権限修正
docker compose exec backend chown -R frappe:frappe apps/whitelabel/
```

## 📊 監視ポイント

### 定期確認項目
1. **毎回の起動時**
   - startup-check.shスクリプトの実行
   - HTTP 200レスポンスの確認

2. **週次確認**
   - whitelabelアプリの更新確認
   - ログファイルのサイズ確認

3. **月次確認**
   - Dockerイメージの更新
   - セキュリティパッチの適用

## 🚀 長期的な解決策

### 1. カスタムDockerイメージの構築
```bash
# ビルドスクリプト
./build/build-custom-image.sh

# イメージにwhitelabelを含める
```

### 2. CI/CDパイプラインの構築
- GitHubアクションでの自動ビルド
- イメージのテスト自動化
- デプロイメントの自動化

### 3. ボリューム管理の改善
- アプリケーションコードの永続化戦略
- バックアップとリストアの自動化

## 📝 関連ドキュメント

- [包括的トラブルシューティングガイド](comprehensive-troubleshooting-guide.md)
- [データベース接続問題ガイド](database-connection-issues.md)
- [Docker環境構築ガイド](../setup/docker-setup-guide.md)

---

**重要**: このドキュメントは実際の問題解決経験に基づいています。環境起動時は必ずstartup-check.shスクリプトを使用してください。