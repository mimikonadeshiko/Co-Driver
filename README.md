# Co-Driver 🚗💨
**A GitHub Copilot-like LLM-powered Command Generation & Completion TUI Tool**

A TUI tool that uses Ollama to suggest **safe and efficient one-liner commands** from natural language input.  

[🇯🇵 Read the README in Japanese](https://github.com/mimikonadeshiko/Co-Driver/blob/main/JA_README.md)

## Features

  - Generate **safe and efficient one-liner commands** from instructions or descriptions in any language
  - Improve and optimize existing shell commands **without changing their meaning**
  - Like GitHub Copilot, **provides the best suggestions even while typing**, reducing the time spent thinking

## Installation

Co-Driver requires the following software. These will be installed by the installation script.

 - Ollama (~0.5 GB)
 - qwen2.5:7b-instruct-q4_K_M (~5 GB)

```bash
curl -fsSL https://raw.githubusercontent.com/mimikonadeshiko/Co-Driver/refs/heads/main/install.sh | bash
