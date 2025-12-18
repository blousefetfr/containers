#!/bin/bash
set -euo pipefail

echo "Preparing workspace..."
mkdir -p /workspace/ollama /workspace/openwebui

echo "Updating apt and installing deps..."
apt-get update -y
apt-get install -y curl wget git python3-pip python3-venv lshw

# -------- Install Ollama (native) --------
if ! command -v ollama >/dev/null 2>&1; then
  echo "Installing Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
fi

# Ensure Ollama sees GPU if available (NVIDIA runtime is present in RunPod images)
export OLLAMA_MODELS=/workspace/ollama

# Start Ollama server in background
echo "Starting Ollama server..."
nohup ollama serve >/workspace/ollama.log 2>&1 &

# Wait for Ollama API to be ready
echo "Waiting for Ollama API..."
for i in {1..30}; do
  if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "Ollama API ready."
    break
  fi
  sleep 1
done

# -------- Install Open WebUI (native, via pip) --------
echo "Installing Open WebUI..."
python3 -m venv /workspace/.venv
source /workspace/.venv/bin/activate
pip install --upgrade pip
pip install open-webui

# Create a run script for Open WebUI
if [ -e "/workspace/run-openwebui.sh" ]; then
  echo "OpenWebUI start script already installed"
else
 echo "#!/usr/bin/env bash" > /workspace/run-openwebui.sh
  echo "set -euo pipefail" >> /workspace/run-openwebui.sh
  echo "source /workspace/.venv/bin/activate" >> /workspace/run-openwebui.sh
  echo "export OLLAMA_API_BASE=\"http://127.0.0.1:11434\"" >> /workspace/run-openwebui.sh
  echo "export OPENWEBUI_DATA_DIR=\"/workspace/openwebui\"" >> /workspace/run-openwebui.sh
  echo "# Bind to all interfaces so l'UI soit accessible via l'URL publique" >> /workspace/run-openwebui.sh
  echo "exec /workspace/.venv/bin/open-webui serve" >> /workspace/run-openwebui.sh
  chmod +x /workspace/run-openwebui.sh
  echo "OpenWebUI start script installed"
fi

echo "Starting Open WebUI..."
nohup /workspace/run-openwebui.sh >/workspace/openwebui.log 2>&1 &

echo "Open WebUI: port 8080 | Ollama API: port 11434"
echo "Logs: /workspace/ollama.log and /workspace/openwebui.log"
