#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Frappe/ERPNext 日本語デフォルト設定
このスクリプトは、新規サイト作成時に自動的に日本語設定を適用します
"""

import frappe

def setup_japanese_defaults():
    """日本向けのデフォルト設定を適用"""
    
    # System Settings の更新
    system_settings = frappe.get_doc("System Settings")
    
    # 言語設定
    system_settings.language = "ja"
    
    # 日付・時刻フォーマット
    system_settings.date_format = "yyyy-mm-dd"
    system_settings.time_format = "HH:mm:ss"
    system_settings.first_day_of_the_week = "Monday"
    
    # 地域設定
    system_settings.country = "Japan"
    system_settings.time_zone = "Asia/Tokyo"
    system_settings.currency = "JPY"
    
    # 数値フォーマット
    system_settings.number_format = "#,###.##"
    system_settings.float_precision = "2"
    system_settings.currency_precision = "0"  # 日本円は小数点なし
    
    # その他の設定
    system_settings.enable_two_factor_auth = 1  # セキュリティ強化
    system_settings.session_expiry = "06:00:00"  # 6時間
    
    system_settings.save()
    frappe.db.commit()
    
    # サイト設定の更新
    frappe.db.set_value("Website Settings", "Website Settings", {
        "default_lang": "ja",
        "disable_signup": 0
    })
    
    # デフォルト会社の設定（ERPNext使用時）
    if "erpnext" in frappe.get_installed_apps():
        # 会社のデフォルト設定
        frappe.db.set_default("country", "Japan")
        frappe.db.set_default("currency", "JPY")
        frappe.db.set_default("time_zone", "Asia/Tokyo")
    
    # 日本の祝日を追加（オプション）
    add_japanese_holidays()
    
    frappe.clear_cache()
    print("✅ 日本語デフォルト設定が完了しました")

def add_japanese_holidays():
    """日本の祝日をHoliday Listに追加"""
    try:
        # 2024年の日本の祝日
        holidays = [
            {"date": "2024-01-01", "description": "元日"},
            {"date": "2024-01-08", "description": "成人の日"},
            {"date": "2024-02-11", "description": "建国記念の日"},
            {"date": "2024-02-12", "description": "振替休日"},
            {"date": "2024-02-23", "description": "天皇誕生日"},
            {"date": "2024-03-20", "description": "春分の日"},
            {"date": "2024-04-29", "description": "昭和の日"},
            {"date": "2024-05-03", "description": "憲法記念日"},
            {"date": "2024-05-04", "description": "みどりの日"},
            {"date": "2024-05-05", "description": "こどもの日"},
            {"date": "2024-05-06", "description": "振替休日"},
            {"date": "2024-07-15", "description": "海の日"},
            {"date": "2024-08-11", "description": "山の日"},
            {"date": "2024-08-12", "description": "振替休日"},
            {"date": "2024-09-16", "description": "敬老の日"},
            {"date": "2024-09-22", "description": "秋分の日"},
            {"date": "2024-09-23", "description": "振替休日"},
            {"date": "2024-10-14", "description": "スポーツの日"},
            {"date": "2024-11-03", "description": "文化の日"},
            {"date": "2024-11-04", "description": "振替休日"},
            {"date": "2024-11-23", "description": "勤労感謝の日"}
        ]
        
        # Holiday Listの作成または更新
        holiday_list_name = "Japan Holidays 2024"
        if not frappe.db.exists("Holiday List", holiday_list_name):
            holiday_list = frappe.new_doc("Holiday List")
            holiday_list.holiday_list_name = holiday_list_name
            holiday_list.from_date = "2024-01-01"
            holiday_list.to_date = "2024-12-31"
            
            for holiday in holidays:
                holiday_list.append("holidays", {
                    "holiday_date": holiday["date"],
                    "description": holiday["description"]
                })
            
            holiday_list.insert()
            print(f"✅ 日本の祝日リスト '{holiday_list_name}' を作成しました")
    except Exception as e:
        print(f"⚠️ 祝日リストの作成中にエラーが発生しました: {str(e)}")

if __name__ == "__main__":
    frappe.connect()
    setup_japanese_defaults()
    frappe.destroy()