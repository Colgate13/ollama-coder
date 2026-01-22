# Local AI Coding Setup with Ollama, Crush, and OpenCode

This guide explains how to set up local AI coding environments using Ollama with tool calling capabilities in both Crush and OpenCode interfaces.

## Table of Contents

1. [Overview](#overview)
2. [Quick Installation](#quick-installation)
3. [Configuring Tool Calling Models](#configuring-tool-calling-models)
4. [Increasing Token Limits](#increasing-token-limits)
5. [Configuration Files](#configuration-files)
6. [Testing Your Setup](#testing-your-setup)

## Overview

This setup enables powerful AI coding assistants to run entirely on your local machine with full tool calling capabilities. We'll be configuring:
- **Ollama**: As the local LLM inference engine
- **Crush**: As a terminal-based AI assistant
- **OpenCode**: As a GUI-based AI coding assistant

Both Crush and OpenCode will be configured to work with the same Ollama models that support structured tool calling.

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

| Model ID | Display Name | Tools Support | Attachments | Reasoning |
|----------|--------------|---------------|-------------|-----------|
| qwen3-coder:480b-cloud | Qwen3 Coder Cloud | ✅ | ✅ | ✅ |
| qwen3:14b-16k | Qwen3 14B 16K | ✅ | ❌ | ✅ |
| qwen3-coder:16k | Qwen3 Coder 16K | ✅ | ❌ | ✅ |
| gpt-oss:120b-cloud | GPT-OSS Cloud | ✅ | ✅ | ✅ |
| gpt-oss:16k | GPT-OSS 16K | ✅ | ❌ | ❌ |
| devstral-2:123b-cloud | Devstral-2 Cloud | ✅ | ✅ | ✅ |
| minimax-m2.1:cloud | MiniMax M2.1 Cloud | ❌ | ❌ | ❌ |

### Downloading Models:

```bash
# Download any of the supported models
ollama pull qwen3:14b
ollama pull qwen3-coder:latest
# etc.
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

This repository includes sample configuration files for both Crush and OpenCode.

### Copy Configuration Files:

```bash
# Create config directories if they don't exist
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

Expected successful response:
```json
{
  "role": "assistant",
  "content": "",
  "tool_calls": [{
    "function": {
      "name": "bash",
      "arguments": "{\"command\":\"ls\",\"description\":\"List files\"}"
    }
  }]
}