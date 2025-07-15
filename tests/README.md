# テストファイル

このフォルダには、プロジェクトのテストコードを配置してください。

## 推奨ディレクトリ構成

```
tests/
├── unit/                # ユニットテスト
├── integration/         # 統合テスト
├── e2e/                 # E2Eテスト
├── fixtures/            # テストデータ
├── conftest.py          # pytest設定（Pythonの場合）
└── test_example.py      # サンプルテストファイル
```

## テストファイル命名規則

- **Python**: `test_*.py` または `*_test.py`
- **Node.js**: `*.test.js` または `*.spec.js`

## 推奨テスト構成

### ユニットテスト
- 個別の関数・クラスの動作確認
- モックを使用した外部依存の除去
- 高速実行を重視

### 統合テスト
- 複数のコンポーネント間の連携確認
- データベースとの連携テスト
- API エンドポイントのテスト

### E2Eテスト
- ユーザーシナリオベースのテスト
- 本番環境に近い環境での実行
- UI操作を含むテスト

## 実行方法

```bash
# 全テスト実行
pytest tests/

# 特定カテゴリのテスト実行
pytest tests/unit/ -m unit
pytest tests/integration/ -m integration

# カバレッジレポート生成
pytest --cov=src --cov-report=html
```

## 注意事項

- テストカバレッジは80%以上を目標
- テストデータは fixtures/ で管理
- 外部サービス依存のテストはモック推奨