#!/bin/bash

# ERP Next Docker環境起動チェックスクリプト
# このスクリプトは環境を安全に起動し、一般的な問題を自動的に解決します

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 関数定義
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# スクリプトのディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

log_info "🚀 ERP Next環境を起動しています..."

# 1. 事前チェック
log_info "事前チェックを実行中..."

# Dockerが起動しているか確認
if ! docker info >/dev/null 2>&1; then
    log_error "Dockerが起動していません。Dockerを起動してください。"
    exit 1
fi

# ポート8080が使用されていないか確認
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    log_warn "ポート8080が既に使用されています。"
    read -p "続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 2. 環境変数確認
cd "$PROJECT_ROOT/frappe_docker"

if [ ! -f .env ]; then
    log_error ".envファイルが見つかりません。"
    exit 1
fi

# サイト名を取得
SITE_NAME=$(grep FRAPPE_SITE_NAME_HEADER .env | cut -d '=' -f2 || echo "sasuke.localhost")
log_info "サイト名: $SITE_NAME"

# 3. Dockerサービス起動
log_info "Dockerサービスを起動中..."

docker compose -f compose.yaml \
    -f overrides/compose.mariadb.yaml \
    -f overrides/compose.redis.yaml \
    -f overrides/compose.proxy.yaml up -d

# 4. サービス起動待機
log_info "サービスの起動を待機中..."
WAIT_TIME=0
MAX_WAIT=60

while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    if docker compose ps | grep -q "healthy" 2>/dev/null; then
        break
    fi
    echo -n "."
    sleep 2
    WAIT_TIME=$((WAIT_TIME + 2))
done
echo

if [ $WAIT_TIME -ge $MAX_WAIT ]; then
    log_error "サービスの起動がタイムアウトしました。"
    docker compose ps
    exit 1
fi

# 5. データベース接続確認
log_info "データベース接続を確認中..."
if ! docker compose exec backend bench --site "$SITE_NAME" list-apps >/dev/null 2>&1; then
    log_warn "データベース接続に問題があります。修復を試みます..."
    
    # site_config.jsonから情報を取得
    DB_NAME=$(docker compose exec backend cat "sites/$SITE_NAME/site_config.json" 2>/dev/null | jq -r '.db_name' || echo "")
    DB_PASSWORD=$(docker compose exec backend cat "sites/$SITE_NAME/site_config.json" 2>/dev/null | jq -r '.db_password' || echo "")
    
    if [ -n "$DB_NAME" ] && [ -n "$DB_PASSWORD" ]; then
        log_info "データベースユーザーを再作成中..."
        docker exec frappe_docker-db-1 mysql -u root -p123 -e "
        CREATE USER IF NOT EXISTS '$DB_NAME'@'%' IDENTIFIED BY '$DB_PASSWORD';
        GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_NAME'@'%';
        FLUSH PRIVILEGES;
        " 2>/dev/null || true
    fi
fi

# 6. whitelabelモジュールチェック
log_info "whitelabelモジュールを確認中..."
if ! docker compose exec backend python -c "import whitelabel" 2>/dev/null; then
    log_warn "whitelabelモジュールが見つかりません。再インストールします..."
    
    # whitelabelアプリを再インストール
    docker compose exec backend bench get-app whitelabel https://github.com/bhavesh95863/whitelabel >/dev/null 2>&1
    
    # サービス再起動
    log_info "サービスを再起動中..."
    docker compose restart backend frontend websocket >/dev/null 2>&1
    sleep 10
fi

# 7. キャッシュクリア
log_info "キャッシュをクリア中..."
docker compose exec backend bench --site "$SITE_NAME" clear-cache >/dev/null 2>&1 || true

# 8. 最終確認
log_info "最終確認を実行中..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
    log_info "✅ 環境が正常に起動しました！"
    echo
    echo "================== アクセス情報 =================="
    echo "URL: http://localhost:8080"
    echo "ユーザー名: Administrator"
    echo "パスワード: admin"
    echo "サイト: $SITE_NAME"
    echo "================================================="
    echo
    
    # インストール済みアプリを表示
    log_info "インストール済みアプリ:"
    docker compose exec backend bench --site "$SITE_NAME" list-apps 2>/dev/null || true
    
else
    log_error "サイトへのアクセスに失敗しました。(HTTP Status: $HTTP_STATUS)"
    echo
    echo "トラブルシューティング:"
    echo "1. ログを確認: docker compose logs backend --tail=50"
    echo "2. サービス状態を確認: docker compose ps"
    echo "3. 手動でサービスを再起動: docker compose restart backend frontend"
    echo
    exit 1
fi

# 9. ヘルスチェック情報
log_info "ヘルスチェック情報:"
echo "- データベース: $(docker compose ps db | grep -q "healthy" && echo "✅ OK" || echo "❌ NG")"
echo "- Redis Cache: $(docker compose ps redis-cache | grep -q "Up" && echo "✅ OK" || echo "❌ NG")"
echo "- Redis Queue: $(docker compose ps redis-queue | grep -q "Up" && echo "✅ OK" || echo "❌ NG")"
echo "- Backend: $(docker compose ps backend | grep -q "Up" && echo "✅ OK" || echo "❌ NG")"
echo "- Frontend: $(docker compose ps frontend | grep -q "Up" && echo "✅ OK" || echo "❌ NG")"

log_info "起動チェック完了！"