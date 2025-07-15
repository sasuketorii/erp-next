#!/bin/bash

# Frappe日本語設定スクリプト
# 使用方法: ./setup-japanese.sh <サイト名>

SITE_NAME=${1:-"erp.localhost"}
PROJECT_ROOT="/Users/sasuketorii/ERP Next/frappe_docker"

echo "Setting up Japanese language for site: $SITE_NAME"

cd "$PROJECT_ROOT"

# 1. デフォルト言語を日本語に設定
echo "Setting default language to Japanese..."
docker compose -f pwd.yml exec backend bench --site $SITE_NAME set-config default_language ja

# 2. 日付形式を日本標準に設定（YYYY-MM-DD）
echo "Setting date format..."
docker compose -f pwd.yml exec backend bench --site $SITE_NAME set-config date_format "yyyy-mm-dd"

# 3. 時刻形式を24時間制に設定
echo "Setting time format..."
docker compose -f pwd.yml exec backend bench --site $SITE_NAME set-config time_format "HH:mm:ss"

# 4. タイムゾーンを日本に設定
echo "Setting timezone to Asia/Tokyo..."
docker compose -f pwd.yml exec backend bench --site $SITE_NAME set-config time_zone "Asia/Tokyo"

# 5. 通貨を日本円に設定
echo "Setting currency to JPY..."
docker compose -f pwd.yml exec backend bench --site $SITE_NAME set-config currency "JPY"

# 6. キャッシュクリア
echo "Clearing cache..."
docker compose -f pwd.yml exec backend bench --site $SITE_NAME clear-cache

echo "Japanese setup completed for site: $SITE_NAME"
echo "Please refresh your browser to see the changes."