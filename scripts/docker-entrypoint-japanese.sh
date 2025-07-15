#!/bin/bash

# 日本語対応エントリーポイントスクリプト
# 新規サイト作成時に自動的に日本語設定を適用

set -e

# サイト名を環境変数から取得
SITE_NAME=${SITES:-mysite.localhost}

# 新規サイト作成時のフック
if [ "$1" = "new-site" ]; then
    echo "新規サイトを日本語設定で作成中..."
    
    # サイト作成コマンドに言語オプションを追加
    shift
    bench new-site "$@" --language ja
    
    # 日本語デフォルト設定を適用
    echo "日本語デフォルト設定を適用中..."
    cd /home/frappe/frappe-bench
    bench --site $SITE_NAME execute japanese_defaults.setup_japanese_defaults
    
    echo "✅ 日本語設定が完了しました"
else
    # 通常のコマンドを実行
    exec "$@"
fi