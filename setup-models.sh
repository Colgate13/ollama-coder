#!/bin/bash

set -e

declare -A MODELS=(
    ["qwen3:14b"]="qwen3:14b-16k"
    ["qwen3-coder:latest"]="qwen3-coder:16k"
    ["gpt-oss:20b"]="gpt-oss:16k"
)

OUTPUT_DIR="modelfiles"

mkdir -p "$OUTPUT_DIR"

echo "Downloading base models..."
for base in "${!MODELS[@]}"; do
    echo "Downloading $base..."
    ollama pull "$base"
done

echo "Configuring models with 16k tokens..."

for base in "${!MODELS[@]}"; do
    new_name="${MODELS[$base]}"
    
    cat > "$OUTPUT_DIR/${new_name}.Modelfile" << EOF
FROM ${base}

PARAMETER num_ctx 16384
PARAMETER temperature 0.7
PARAMETER top_p 0.9
EOF
    
    echo "Creating $new_name..."
    ollama create "$new_name" -f "$OUTPUT_DIR/${new_name}.Modelfile"
done

echo "Removing base models..."
for base in "${!MODELS[@]}"; do
    echo "Removing $base..."
    ollama rm "$base"
done

echo "Setup complete!"
echo "Available models:"
ollama list
