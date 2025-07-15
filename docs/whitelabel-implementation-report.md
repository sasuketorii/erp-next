# ERPNext ホワイトラベル化実装レポート

**作成日**: 2025年7月15日  
**作成者**: Sasuke Torii  
**プロジェクト**: ERP Next  
**バージョン**: v0.0.2

## 📋 概要

ERPNextのホワイトラベル化について、bhavesh95863/whitelabelアプリを使用した実装可能性を調査・検証した結果をレポートします。

## ✅ 実装状況

### 1. Whitelabelアプリのインストール

**アプリ情報**:
- **リポジトリ**: https://github.com/bhavesh95863/whitelabel
- **バージョン**: 0.0.1 (version-15)
- **ライセンス**: MIT License
- **互換性**: ERPNext v13+ (v15.67.0で動作確認済み)

**インストール状況**:
```bash
✅ アプリのダウンロード: 完了
✅ サイトへのインストール: 完了
✅ データベースマイグレーション: 完了
✅ 動作確認: 完了
```

### 2. 利用可能な機能

#### 🎨 ブランディング・カスタマイズ機能

| 機能 | 説明 | 実装状況 |
|------|------|----------|
| **ロゴ変更** | アプリケーションロゴのカスタマイズ | ✅ 対応 |
| **ファビコン変更** | ブラウザタブアイコンの変更 | ✅ 対応 |
| **スプラッシュ画像** | 起動画面の画像カスタマイズ | ✅ 対応 |
| **ナビゲーションバー** | 背景色とタイトルのカスタマイズ | ✅ 対応 |
| **ログインページ** | ログインページタイトルの変更 | ✅ 対応 |

#### 🔧 UI制御機能

| 機能 | 説明 | 実装状況 |
|------|------|----------|
| **ヘルプメニュー非表示** | ヘルプメニューの表示/非表示制御 | ✅ 対応 |
| **「Powered by」非表示** | フッターの「Powered by ERPNext」削除 | ✅ 対応 |
| **ウェルカムページ削除** | 初期ウェルカムページの非表示 | ✅ 対応 |
| **アップデート通知無効** | システムアップデート通知の無効化 | ✅ 対応 |
| **オンボーディング制御** | 初期設定手順のカスタマイズ | ✅ 対応 |

#### 📧 メール・コミュニケーション

| 機能 | 説明 | 実装状況 |
|------|------|----------|
| **メールフッター** | カスタムメールフッターアドレス | ✅ 対応 |
| **標準フッター無効** | 標準メールフッターの無効化 | ✅ 対応 |

## 🛠️ 設定方法

### 1. 設定画面へのアクセス

```
ERPNext管理画面 → 設定 → Whitelabel Setting
```

### 2. 主要設定項目

#### General Settings（一般設定）
- `ignore_onboard_whitelabel`: オンボーディングの改造をスキップ
- `show_help_menu`: ヘルプメニューの表示制御
- `disable_new_update_popup`: アップデート通知の無効化

#### Logo Settings（ロゴ設定）
- `application_logo`: カスタムロゴファイル（パブリックアクセス必須）
- `logo_height`: ロゴの高さ（ピクセル）
- `logo_width`: ロゴの幅（ピクセル）

#### Navbar Settings（ナビゲーション設定）
- `navbar_background_color`: 背景色（HEXコード）
- `whitelabel_app_name`: カスタムアプリ名
- `custom_navbar_title`: カスタムナビゲーションタイトル
- `custom_navbar_title_style`: ナビゲーションタイトルのCSS

#### Email Settings（メール設定）
- `email_footer_address`: カスタムメールフッターアドレス
- `disable_standard_footer`: 標準フッターの無効化

### 3. 設定手順例

#### ステップ1: ロゴの変更
1. 設定画面で「Logo Settings」タブを開く
2. `application_logo`フィールドにロゴファイルをアップロード
3. 必要に応じて`logo_height`、`logo_width`を調整
4. 「Save」をクリック

#### ステップ2: アプリ名の変更
1. 「Navbar Settings」タブを開く
2. `whitelabel_app_name`に新しいアプリ名を入力
3. `custom_navbar_title`でナビゲーションタイトルを設定
4. 「Save」をクリック

#### ステップ3: 「ERPNext」文言の削除
1. 「General Settings」タブで各種表示制御を設定
2. `show_help_menu`を無効化
3. 「Save」をクリック

## 🎯 実装可能なカスタマイズ例

### 1. 完全なブランド変更

**Before（ERPNext標準）**:
- ロゴ: ERPNextロゴ
- ナビゲーション: 「ERPNext」
- フッター: 「Powered by ERPNext」

**After（カスタマイズ後）**:
- ロゴ: 独自企業ロゴ
- ナビゲーション: 「MyCompany ERP」
- フッター: 独自フッター

### 2. 日本企業向けカスタマイズ

```json
{
  "whitelabel_app_name": "統合基幹システム",
  "custom_navbar_title": "MyCompany ERP",
  "navbar_background_color": "#2e3b4e",
  "show_help_menu": false,
  "disable_standard_footer": true,
  "email_footer_address": "support@mycompany.co.jp"
}
```

## 📊 技術的詳細

### 1. アーキテクチャ

**バックエンド処理**:
- `whitelabel_setting.py`: 設定の管理とシステム反映
- システム設定、ナビゲーション設定、ウェブサイト設定の自動更新
- サイト設定を通じたロゴURL管理

**フロントエンド統合**:
- `whitelabel.js`: ロゴサイズ調整、ナビゲーション背景色制御
- `whitelabel_app.css`: ヘルプメニューの非表示
- `whitelabel_web.css`: フッターの「Powered by」非表示

### 2. ファイル構成

```
whitelabel/
├── whitelabel/
│   ├── doctype/
│   │   └── whitelabel_setting/
│   │       ├── whitelabel_setting.py     # メインロジック
│   │       ├── whitelabel_setting.js     # フロントエンド制御
│   │       └── whitelabel_setting.json   # DocType定義
│   ├── public/
│   │   ├── css/
│   │   │   ├── whitelabel_app.css        # アプリ用CSS
│   │   │   └── whitelabel_web.css        # ウェブ用CSS
│   │   └── js/
│   │       └── whitelabel.js             # JavaScript制御
│   └── hooks.py                          # Frappeフック定義
```

### 3. データベース構造

**DocType**: `Whitelabel Setting`（Single DocType）

主要フィールド:
- `application_logo` (Attach): ロゴファイル
- `whitelabel_app_name` (Data): アプリ名
- `custom_navbar_title` (Data): ナビゲーションタイトル
- `navbar_background_color` (Data): 背景色
- `show_help_menu` (Check): ヘルプメニュー表示制御

## 🚀 導入効果

### 1. ビジネス効果

**ブランディング強化**:
- 独自ブランドとしてのERPシステム提供
- 顧客企業のブランドイメージ統一
- 競合他社との差別化

**ユーザーエクスペリエンス向上**:
- 不要な情報の非表示によるシンプル化
- 企業固有のナビゲーション体験
- 統一されたデザイン言語

### 2. 技術的効果

**メンテナンス性**:
- 設定ベースの簡単なカスタマイズ
- コア機能への影響なし
- アップデート時の互換性維持

**拡張性**:
- 追加カスタマイズの容易さ
- 多言語対応の維持
- 既存機能との共存

## ⚠️ 注意事項・制約

### 1. 技術的制約

**ロゴファイル**:
- パブリックアクセス可能な場所に配置必須
- 推奨サイズとフォーマットの考慮が必要

**CSS制約**:
- 既存のCSSとの競合可能性
- レスポンシブデザインへの影響

### 2. 運用上の注意

**アップデート時**:
- ERPNextアップデート時の設定確認
- Whitelabelアプリの互換性確認

**パフォーマンス**:
- 大きなロゴファイルによる読み込み速度への影響
- CSS追加による軽微なパフォーマンス影響

## 📈 推奨実装プラン

### Phase 1: 基本設定（1-2日）
1. Whitelabelアプリの本番環境インストール
2. 基本ロゴとアプリ名の設定
3. 不要なUI要素の非表示化

### Phase 2: 高度なカスタマイズ（3-5日）
1. 企業ブランドに合わせたカラーリング
2. カスタムCSSの追加
3. メールテンプレートの調整

### Phase 3: 最適化（2-3日）
1. パフォーマンス最適化
2. レスポンシブデザインの確認
3. ユーザビリティテスト

### Phase 4: 本番適用（1日）
1. 本番環境での設定適用
2. 動作確認
3. ユーザートレーニング

## 🎯 結論

**実装可能性**: ✅ **完全対応可能**

bhavesh95863/whitelabelアプリを使用することで、以下が実現可能です：

1. **ERPNextロゴの完全な置き換え**
2. **「ERPNext」文言の削除・変更**
3. **独自ブランドとしてのカスタマイズ**
4. **日本企業向けの最適化**

**推奨度**: ⭐⭐⭐⭐⭐ (5/5)

- 安定性：MIT License、活発なメンテナンス
- 機能性：包括的なカスタマイズ機能
- 導入容易性：設定ベースの簡単な実装
- 拡張性：将来的な機能追加への対応

**次のステップ**:
1. 企業ロゴとブランドガイドラインの準備
2. 本番環境での詳細テスト
3. ユーザー向けマニュアルの作成
4. 段階的な本番適用

---

**レポート作成者**: Sasuke Torii  
**最終更新**: 2025年7月15日  
**承認**: [未定]