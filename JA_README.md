# Co-Driver 🚗💨
**LLMを使用した GitHub Copilotみたいなコマンド生成・補完TUIツール**

Ollamaを使用して、自然文から**安全で効率的な “1 行コマンド”** を提案する TUI ツール。  

## 特徴

  - 日本語の指示文や説明文から**安全で効率的な “1 行コマンド”** を生成
  - 既存のシェルコマンドを**意味を変えずに改善・最適化**
  - GitHub Copilot のように**入力途中でも最適な提案を返す**ため、考える時間を短縮

## インストール

Co-Driverの使用には以下のソフトウェアが必要です。 インストールスクリプト内で実行されます。

 - Ollama 約0.5GB
 - qwen2.5:7b-instruct-q4_K_M 約5GB

```bash
curl -fsSL https://raw.githubusercontent.com/USERNAME/REPO/refs/heads/main/install.sh | bash
