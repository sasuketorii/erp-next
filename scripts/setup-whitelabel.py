#!/usr/bin/env python3
"""
ホワイトラベル設定スクリプト
"""

import frappe

def setup_whitelabel():
    """ホワイトラベル設定を実行"""
    try:
        # Whitelabel Setting ドキュメントを取得
        doc = frappe.get_doc('Whitelabel Setting', 'Whitelabel Setting')
        
        # 基本設定
        doc.whitelabel_app_name = 'MyCompany ERP'
        doc.custom_navbar_title = 'マイカンパニー統合システム'
        doc.show_help_menu = 0
        doc.disable_new_update_popup = 1
        doc.ignore_onboard_whitelabel = 1
        
        # ナビゲーションバーの設定
        doc.navbar_background_color = '#1f2937'  # ダークグレー
        doc.custom_navbar_title_style = 'color: #ffffff; font-weight: bold;'
        
        # メール設定
        doc.email_footer_address = 'support@mycompany.co.jp'
        doc.disable_standard_footer = 1
        
        # 設定を保存
        doc.save()
        
        print("✅ ホワイトラベル設定が完了しました！")
        print("設定内容:")
        print(f"  - アプリ名: {doc.whitelabel_app_name}")
        print(f"  - ナビゲーションタイトル: {doc.custom_navbar_title}")
        print(f"  - ヘルプメニュー: {'非表示' if not doc.show_help_menu else '表示'}")
        print(f"  - ナビゲーション背景色: {doc.navbar_background_color}")
        print(f"  - メールフッター: {doc.email_footer_address}")
        
        # キャッシュクリア
        frappe.clear_cache()
        print("✅ キャッシュをクリアしました")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    setup_whitelabel()