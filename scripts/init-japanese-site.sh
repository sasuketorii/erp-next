#!/bin/bash

# 日本語設定済みサイトの初期化スクリプト
# 新規サイト作成と日本語設定を一度に実行

set -e

# デフォルト値
SITE_NAME=${1:-mysite.localhost}
ADMIN_PASSWORD=${2:-admin}

echo "=========================================="
echo "日本語設定済みERPNextサイトの作成"
echo "=========================================="
echo "サイト名: $SITE_NAME"
echo ""

# 既存サイトの確認
if docker compose exec backend bench --site $SITE_NAME execute frappe.ping 2>/dev/null; then
    echo "⚠️  サイト '$SITE_NAME' は既に存在します"
    read -p "既存サイトを削除して再作成しますか？ (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "既存サイトを削除中..."
        docker compose exec backend bench drop-site $SITE_NAME --force
    else
        echo "処理を中止しました"
        exit 1
    fi
fi

# 新規サイトを日本語で作成
echo "新規サイトを作成中..."
docker compose exec backend bench new-site $SITE_NAME \
    --admin-password $ADMIN_PASSWORD \
    --language ja \
    --country Japan \
    --timezone "Asia/Tokyo" \
    --currency JPY

# ERPNextのインストール（必要な場合）
echo ""
read -p "ERPNextをインストールしますか？ (Y/n): " install_erpnext
if [[ ! $install_erpnext =~ ^[Nn]$ ]]; then
    echo "ERPNextをインストール中..."
    docker compose exec backend bench --site $SITE_NAME install-app erpnext
fi

# whitelabelアプリのインストール（存在する場合）
if docker compose exec backend test -d apps/whitelabel 2>/dev/null; then
    echo ""
    read -p "whitelabelアプリをインストールしますか？ (Y/n): " install_whitelabel
    if [[ ! $install_whitelabel =~ ^[Nn]$ ]]; then
        echo "whitelabelアプリをインストール中..."
        docker compose exec backend bench --site $SITE_NAME install-app whitelabel
    fi
fi

# 追加の日本語設定を適用
echo ""
echo "詳細な日本語設定を適用中..."

# System Settingsの詳細設定
docker compose exec backend bench --site $SITE_NAME execute frappe.db.set_value \
    --args "['System Settings', 'System Settings', {
        'language': 'ja',
        'date_format': 'yyyy-mm-dd',
        'time_format': 'HH:mm:ss',
        'first_day_of_the_week': 'Monday',
        'number_format': '#,###.##',
        'float_precision': '2',
        'currency_precision': '0',
        'country': 'Japan',
        'time_zone': 'Asia/Tokyo',
        'currency': 'JPY'
    }]"

# デフォルト設定
docker compose exec backend bench --site $SITE_NAME set-config default_language ja
docker compose exec backend bench --site $SITE_NAME set-config time_zone "Asia/Tokyo"

# キャッシュクリア
echo "キャッシュをクリア中..."
docker compose exec backend bench --site $SITE_NAME clear-cache

echo ""
echo "✅ 日本語設定済みサイトの作成が完了しました！"
echo ""
echo "アクセス情報:"
echo "URL: http://$SITE_NAME:8080"
echo "ユーザー名: Administrator"
echo "パスワード: $ADMIN_PASSWORD"
echo ""
echo "注意: 初回ログイン時にセットアップウィザードが表示されます。"
echo "言語は既に日本語に設定されています。"