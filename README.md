# Local AI Coding Setup with Ollama, Crush, and OpenCode

Set up AI coding environments using Ollama with tool calling capabilities in both Crush and OpenCode interfaces. Choose between local models for privacy or cloud models for top-tier performance.

## Table of Contents

1. [Overview](#overview)
2. [Quick Installation](#quick-installation)
3. [Configuring Tool Calling Models](#configuring-tool-calling-models)
4. [Increasing Token Limits](#increasing-token-limits)
5. [Configuration Files](#configuration-files)
6. [Testing Your Setup](#testing-your-setup)
7. [Example Usage](#example-usage)

## Overview

Powerful AI coding assistants with tool calling capabilities:
- **Ollama**: Local LLM inference engine
- **Crush**: Terminal-based AI assistant
- **OpenCode**: GUI-based AI coding assistant

Choose between local models (privacy, offline) or cloud models (superior performance, like Claude Sonnet).

## Quick Installation

### Install Ollama:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Install Crush:
```bash
cargo install charm-lemon/crush
```

### Install OpenCode:
Download from [https://opencode.ai](https://opencode.ai)

## Configuring Tool Calling Models

Not all models support structured tool calling. For tool calling to work properly, models must return structured `tool_calls` and include all required parameters.

### Supported Models:

| Model ID | Display Name | Type | Tools | Attachments | Reasoning |
|----------|--------------|------|-------|-------------|-----------|
| qwen3-coder:480b-cloud | Qwen3 Coder Cloud | Cloud | ✅ | ✅ | ✅ |
| qwen3:14b-16k | Qwen3 14B 16K | Local | ✅ | ❌ | ✅ |
| qwen3-coder:16k | Qwen3 Coder 16K | Local | ✅ | ❌ | ✅ |
| gpt-oss:120b-cloud | GPT-OSS Cloud | Cloud | ✅ | ✅ | ✅ |
| gpt-oss:16k | GPT-OSS 16K | Local | ✅ | ❌ | ❌ |
| devstral-2:123b-cloud | Devstral-2 Cloud | Cloud | ✅ | ✅ | ✅ |
| minimax-m2.1:cloud | MiniMax M2.1 Cloud | Cloud | ❌ | ❌ | ❌ |

### Downloading Models:

Download local models manually. Cloud models (with `-cloud` suffix) are accessed remotely:

```bash
# Download local models only
ollama pull qwen3:14b
ollama pull qwen3-coder:latest
```

## Increasing Token Limits

The default context window of 4096 tokens is insufficient for tool calling. We need to create model variants with larger contexts.

### Creating Extended Context Models:

```bash
# Create a temporary Modelfile
echo 'FROM qwen3:14b
PARAMETER num_ctx 16384' > /tmp/Modelfile

# Create model with extended context
ollama create qwen3:14b-16k -f /tmp/Modelfile
```

## Configuration Files

Configuration files for Crush and OpenCode support both local and cloud models:

```bash
# Create config directories
mkdir -p ~/.config/opencode ~/.config/crush

# Copy configuration files
cp opencode.json ~/.config/opencode/
cp crush.json ~/.config/crush/
```

## Testing Your Setup

### Test Ollama Directly:

```bash
curl -s http://localhost:11434/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3:14b-16k",
    "messages": [{"role": "user", "content": "list files in current directory"}],
    "tools": [{
      "type": "function",
      "function": {
        "name": "bash",
        "description": "Execute bash command",
        "parameters": {
          "type": "object",
          "properties": {
            "command": {"type": "string", "description": "Command to run"},
            "description": {"type": "string", "description": "What the command does"}
          },
          "required": ["command", "description"]
        }
      }
    }]
  }' | jq '.choices[0].message'
```





## Example Usage

Below are examples of the setup in action with different combinations of tools and models:

### OpenCode CLI + Ollama + qwen3-coder:480b-cloud

![OpenCode CLI with cloud model](images/opencode-cli-cloud.png)

### OpenCode GUI + Ollama + qwen3-coder:16k

![OpenCode GUI with local model](images/opencode-gui-local.png)

### Crush CLI + Ollama + qwen3-coder:16k

![Crush CLI with local model](images/crush-cli-local.png)

