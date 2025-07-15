#!/bin/bash

# Frappe/ERPNext 日本語設定スクリプト
# このスクリプトは、サイトのデフォルト言語を日本語に設定します

set -e

SITE_NAME=${1:-mysite.localhost}

echo "=========================================="
echo "Frappe/ERPNext 日本語設定"
echo "=========================================="
echo "サイト名: $SITE_NAME"
echo ""

# frappe_dockerディレクトリに移動
cd frappe_docker

# 現在の言語設定を確認
echo "現在の言語設定を確認中..."
docker compose exec backend bench --site $SITE_NAME execute frappe.db.get_value --args "['System Settings', None, 'language']" || true

# デフォルト言語を日本語に設定
echo ""
echo "デフォルト言語を日本語に設定中..."
docker compose exec backend bench --site $SITE_NAME set-config default_language ja

# System Settingsで言語を日本語に設定
echo "System Settingsを更新中..."
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value --args "['System Settings', 'System Settings', 'language', 'ja']"

# 日付フォーマットを日本形式に設定
echo "日付フォーマットを設定中..."
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value --args "['System Settings', 'System Settings', 'date_format', 'yyyy-mm-dd']"
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value --args "['System Settings', 'System Settings', 'time_format', 'HH:mm:ss']"

# 週の開始日を月曜日に設定（日本のビジネス慣習）
echo "週の開始日を設定中..."
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value --args "['System Settings', 'System Settings', 'first_day_of_the_week', 'Monday']"

# 通貨を日本円に設定
echo "デフォルト通貨を設定中..."
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value --args "['System Settings', 'System Settings', 'currency', 'JPY']"

# タイムゾーンを日本に設定
echo "タイムゾーンを設定中..."
docker compose exec backend bench --site $SITE_NAME set-config time_zone "Asia/Tokyo"
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value --args "['System Settings', 'System Settings', 'time_zone', 'Asia/Tokyo']"

# 国を日本に設定
echo "デフォルト国を設定中..."
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value --args "['System Settings', 'System Settings', 'country', 'Japan']"

# キャッシュをクリア
echo ""
echo "キャッシュをクリア中..."
docker compose exec backend bench --site $SITE_NAME clear-cache

# ベンチを再起動
echo "サービスを再起動中..."
docker compose restart backend websocket

echo ""
echo "✅ 日本語設定が完了しました！"
echo ""
echo "設定内容:"
echo "- 言語: 日本語 (ja)"
echo "- 日付形式: yyyy-mm-dd"
echo "- 時刻形式: HH:mm:ss"
echo "- 週の開始日: 月曜日"
echo "- 通貨: JPY"
echo "- タイムゾーン: Asia/Tokyo"
echo "- 国: Japan"
echo ""
echo "ブラウザでサイトにアクセスして確認してください。"
echo "必要に応じて、ブラウザのキャッシュもクリアしてください。"