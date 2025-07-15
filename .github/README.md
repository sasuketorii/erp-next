# GitHub Actions Configuration

このディレクトリには、プロジェクトのGitHub Actions設定が含まれています。

## 推奨ワークフロー

### 1. CI/CD Pipeline (`ci-cd.yml`)
- **トリガー**: プッシュまたはプルリクエスト
- **機能**: テスト実行、ビルド、デプロイ
- **ステップ**: 
  - 依存関係のインストール
  - コードフォーマットチェック
  - ユニットテスト実行
  - カバレッジレポート生成

### 2. Code Quality (`code-quality.yml`)
- **トリガー**: プルリクエスト
- **機能**: コード品質チェック
- **チェック項目**: 
  - リンター（flake8, ESLint等）
  - 型チェック（mypy, TypeScript等）
  - セキュリティスキャン

### 3. Release Automation (`release.yml`)
- **トリガー**: タグプッシュまたは手動実行
- **機能**: 自動リリース作成
- **プロセス**: 
  - バージョンタグ作成
  - リリースノート生成
  - アセットのアップロード

### 4. Dependency Update (`dependency-update.yml`)
- **トリガー**: スケジュール（週次）
- **機能**: 依存関係の自動更新
- **動作**: 
  - 脆弱性チェック
  - 更新可能なパッケージの検出
  - PR自動作成

## セットアップ手順

### 必要なSecrets設定

リポジトリのSettings → Secrets and variables → Actionsで以下を設定：

- `GITHUB_TOKEN`: 自動的に提供される（設定不要）
- `DEPLOY_KEY`: デプロイ先のアクセスキー（必要な場合）
- `API_KEY`: 外部サービスAPIキー（必要な場合）

### ワークフローのカスタマイズ

1. `workflows/`ディレクトリ内にYAMLファイルを作成
2. プロジェクトに応じてステップを調整
3. 必要なアクションを追加

## セキュリティベストプラクティス

- シークレットは必ずGitHub Secretsに保存
- 最小権限の原則に従った権限設定
- 依存関係の定期的な更新
- セキュリティスキャンの実施

## 参考リンク

- [GitHub Actions ドキュメント](https://docs.github.com/ja/actions)
- [ワークフロー構文](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions)
- [再利用可能なワークフロー](https://docs.github.com/ja/actions/using-workflows/reusing-workflows)