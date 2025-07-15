#!/bin/bash

# ホワイトラベル設定スクリプト
# このスクリプトは、ERPNextのホワイトラベル化を実行します

set -e

SITE_NAME=${1:-erp.localhost}

echo "=========================================="
echo "ERPNext ホワイトラベル設定"
echo "=========================================="
echo "サイト名: $SITE_NAME"
echo ""

# frappe_dockerディレクトリに移動
cd frappe_docker

# 現在のホワイトラベル設定を確認
echo "現在のホワイトラベル設定を確認中..."
docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); print('現在のアプリ名:', doc.get('whitelabel_app_name') or 'Not set'); print('現在のナビタイトル:', doc.get('custom_navbar_title') or 'Not set')" || true

echo ""
echo "ホワイトラベル設定を適用中..."

# 基本設定
docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); doc.whitelabel_app_name = 'MyCompany ERP'; doc.save(); print('✅ アプリ名を設定しました')"

docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); doc.custom_navbar_title = 'マイカンパニー統合システム'; doc.save(); print('✅ ナビゲーションタイトルを設定しました')"

docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); doc.show_help_menu = 0; doc.save(); print('✅ ヘルプメニューを非表示にしました')"

docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); doc.disable_new_update_popup = 1; doc.save(); print('✅ アップデート通知を無効にしました')"

docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); doc.navbar_background_color = '#1f2937'; doc.save(); print('✅ ナビゲーション背景色を設定しました')"

docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); doc.email_footer_address = 'support@mycompany.co.jp'; doc.save(); print('✅ メールフッターを設定しました')"

docker compose exec backend bench --site $SITE_NAME execute "import frappe; doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting'); doc.disable_standard_footer = 1; doc.save(); print('✅ 標準フッターを無効にしました')"

# キャッシュクリア
echo ""
echo "キャッシュをクリア中..."
docker compose exec backend bench --site $SITE_NAME clear-cache

# サービス再起動
echo "サービスを再起動中..."
docker compose restart backend frontend websocket

echo ""
echo "✅ ホワイトラベル設定が完了しました！"
echo ""
echo "設定内容:"
echo "- アプリ名: MyCompany ERP"
echo "- ナビゲーションタイトル: マイカンパニー統合システム"
echo "- ヘルプメニュー: 非表示"
echo "- ナビゲーション背景色: #1f2937"
echo "- メールフッター: support@mycompany.co.jp"
echo "- 標準フッター: 無効"
echo ""
echo "ブラウザでサイトにアクセスして確認してください。"
echo "URL: http://localhost:8080"