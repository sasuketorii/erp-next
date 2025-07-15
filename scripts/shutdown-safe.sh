#!/bin/bash

# ERP Next Docker環境安全停止スクリプト
# このスクリプトは環境を安全に停止し、重要な情報を保存します

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

log_info "🛑 ERP Next環境を安全に停止します..."

cd "$PROJECT_ROOT/frappe_docker"

# 1. 現在の状態を保存
log_info "現在の状態を記録中..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
STATUS_FILE="$PROJECT_ROOT/logs/shutdown_status_$TIMESTAMP.log"

mkdir -p "$PROJECT_ROOT/logs"

echo "=== Shutdown Status Report ===" > "$STATUS_FILE"
echo "Timestamp: $(date)" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

# サービス状態を記録
echo "=== Service Status ===" >> "$STATUS_FILE"
docker compose ps >> "$STATUS_FILE" 2>&1 || true
echo "" >> "$STATUS_FILE"

# インストール済みアプリを記録
SITE_NAME=$(grep FRAPPE_SITE_NAME_HEADER .env | cut -d '=' -f2 || echo "sasuke.localhost")
echo "=== Installed Apps ($SITE_NAME) ===" >> "$STATUS_FILE"
docker compose exec backend bench --site "$SITE_NAME" list-apps >> "$STATUS_FILE" 2>&1 || true
echo "" >> "$STATUS_FILE"

log_info "状態を $STATUS_FILE に保存しました"

# 2. 重要な設定のバックアップ
log_info "重要な設定をバックアップ中..."
BACKUP_DIR="$PROJECT_ROOT/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# site_config.jsonのバックアップ
if docker compose exec backend test -f "sites/$SITE_NAME/site_config.json" 2>/dev/null; then
    docker compose exec backend cat "sites/$SITE_NAME/site_config.json" > "$BACKUP_DIR/site_config.json" 2>/dev/null || true
    log_info "site_config.jsonをバックアップしました"
fi

# common_site_config.jsonのバックアップ
if docker compose exec backend test -f "sites/common_site_config.json" 2>/dev/null; then
    docker compose exec backend cat "sites/common_site_config.json" > "$BACKUP_DIR/common_site_config.json" 2>/dev/null || true
    log_info "common_site_config.jsonをバックアップしました"
fi

# 3. アクティブな接続を確認
log_info "アクティブな接続を確認中..."
ACTIVE_CONNECTIONS=$(docker compose exec backend bench --site "$SITE_NAME" execute frappe.db.sql --args '["SELECT COUNT(*) FROM tabSessions WHERE status=\"Active\""]' 2>/dev/null || echo "0")

if [ "$ACTIVE_CONNECTIONS" != "0" ] && [ "$ACTIVE_CONNECTIONS" != "" ]; then
    log_warn "アクティブなセッションが存在します: $ACTIVE_CONNECTIONS"
    read -p "続行しますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "停止をキャンセルしました"
        exit 1
    fi
fi

# 4. サービスを順番に停止
log_info "サービスを停止中..."

# アプリケーションサービスから停止
log_info "アプリケーションサービスを停止中..."
docker compose stop scheduler queue-short queue-long websocket backend frontend 2>/dev/null || true

# 基盤サービスを停止
log_info "基盤サービスを停止中..."
docker compose down --remove-orphans

# 5. 停止確認
log_info "停止状態を確認中..."
if docker compose ps --services 2>/dev/null | grep -q .; then
    log_warn "一部のサービスがまだ実行中の可能性があります"
    docker compose ps
else
    log_info "✅ すべてのサービスが正常に停止しました"
fi

# 6. リソース情報
log_info "リソース情報:"
echo "- ボリューム: $(docker volume ls -q | grep frappe_docker | wc -l) 個"
echo "- ネットワーク: $(docker network ls -q -f name=frappe_docker | wc -l) 個"

# 7. 次回起動のための情報
echo
echo "================== 次回起動時の情報 =================="
echo "起動スクリプト: $SCRIPT_DIR/startup-check.sh"
echo "設定バックアップ: $BACKUP_DIR"
echo "状態ログ: $STATUS_FILE"
echo "===================================================="
echo

log_info "環境が安全に停止されました"
log_info "データはDockerボリュームに保存されています"

# オプション: ボリュームも削除する場合
if [ "$1" = "--remove-volumes" ]; then
    log_warn "ボリュームの削除が要求されました"
    read -p "本当にすべてのデータを削除しますか？ (yes/NO): " -r
    if [ "$REPLY" = "yes" ]; then
        log_warn "ボリュームを削除中..."
        docker compose down --volumes
        log_info "ボリュームが削除されました"
    else
        log_info "ボリューム削除をキャンセルしました"
    fi
fi