#!/bin/bash

# Set up workspace
mkdir -p /workspace && cd /workspace

# Update system packages
# add-apt-repository ppa:deadsnakes/ppa
apt update && apt upgrade -y

# Install required dependencies
#apt install -y git python3.11 python3.11-venv python3.11-distutils wget curl

# Install pip for 3.11
#curl -sS -O https://bootstrap.pypa.io/get-pip.py | python3.11

python3.11 -m venv venv
source venv/bin/activate
pip3.11 install --upgrade pip
pip3.11 install packaging
pip3.11 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128

# apt install -y git python3 python3-venv python3-pip wget

# Stop and disable Nginx if it's running
systemctl stop nginx 2>/dev/null || true
systemctl disable nginx 2>/dev/null || true
pkill -f nginx || true

if [ -d "/workspace/ComfyUI" ]; then
    echo "ComfyUI already installed"
    cd /workspace/ComfyUI
    git pull
else
    cd /workspace/
    # Clone and install ComfyUI
    echo "ComfyUI installation"
    git clone https://github.com/comfyanonymous/ComfyUI.git
    echo "ComfyUI installed"
fi


if [ -d "/workspace/SageAttention" ]; then
    echo "SageAttention already installed"
else
    cd /workspace/
    # Clone and install ComfyUI
    echo "SageAttention installation"
    git clone https://github.com/thu-ml/SageAttention.git
    export EXT_PARALLEL=16
    export MAX_JOBS=16
    cd /workspace/SageAttention
    python3.11 setup.py install
    cd sageattention3_blackwell
    python3.11 setup.py install
    echo "SageAttention installed"
fi

if [ -d "/workspace/Flash-Attention" ]; then
    echo "Flash-Attention already installed"
else
    cd /workspace/
    # Clone and install ComfyUI
    echo "Flash-Attention installation"
    git clone https://github.com/Dao-AILab/Flash-Attention
    cd /workspace/Flash-Attention/hopper
    python3.11 setup.py install
    echo "Flash-Attention installed"
fi
cd /workspace/ComfyUI
pip3.11 install -r requirements.txt
pip3.11 install triton ninja numpy

# Clone and install ComfyUI-Manager inside custom_nodes
mkdir -p custom_nodes
cd custom_nodes

echo "Installation and update of ComfyUI Custom Nodes"
CUSTOM_NODES=(
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/comfyui-wiki/ComfyUI-Wiki-Workflows"
    "https://github.com/city96/ComfyUI-GGUF"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/Zehong-Ma/ComfyUI-MagCache"
    "https://github.com/wallish77/wlsh_nodes"
    "https://github.com/vrgamegirl19/comfyui-vrgamedevgirl"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/GACLove/ComfyUI-VFI"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/princepainter/ComfyUI-PainterI2V"
    "https://github.com/orssorbit/ComfyUI-wanBlockswap"
    "https://github.com/Conor-Collins/ComfyUI-CoCoTools_IO"
    "https://github.com/kijai/ComfyUI-segment-anything-2"
    "https://github.com/ltdrdata/ComfyUI-Inspire-Pack"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
    "https://github.com/tritant/ComfyUI_CreaPrompt"
    "https://github.com/BadCafeCode/masquerade-nodes-comfyui"
    "https://github.com/hgabha/WWAA-CustomNodes"
    "https://github.com/lrzjason/Comfyui-QwenEditUtils"
    "https://github.com/1038lab/ComfyUI-RMBG"
    "https://github.com/MoonGoblinDev/Civicomfy"
    "https://github.com/MadiatorLabs/ComfyUI-RunpodDirect"
)

cd /workspace/ComfyUI/custom_nodes

for repo in "${CUSTOM_NODES[@]}"; do
    repo_name=$(basename "$repo")
    if [ ! -d "/workspace/ComfyUI/custom_nodes/$repo_name" ]; then
        echo "Installing $repo_name..."
        git clone "$repo"
    fi
done

for node_dir in */; do
    if [ -d "$node_dir" ]; then
        echo "Checking dependencies for $node_dir..."
        cd "$node_dir"
        # Check for requirements.txt
        if [ -f "requirements.txt" ]; then
            echo "Installing requirements.txt for $node_dir"
            pip3.11 install --no-cache-dir -r requirements.txt
        fi
        # Check for install.py
        if [ -f "install.py" ]; then
            echo "Running install.py for $node_dir"
            python3.11 install.py
        fi
        # Check for setup.py
        if [ -f "setup.py" ]; then
            echo "Running setup.py for $node_dir"
            pip3.11 install --no-cache-dir -e .
        fi
        cd /workspace/ComfyUI/custom_nodes/
    fi
done

# Set execution permission
chmod +x /workspace/ComfyUI/main.py

# Run ComfyUI on port 3001
cd /workspace/ComfyUI
echo "Starting ComfyUI"
nohup python3.11 main.py --listen --port 3001 >/workspace/comfyui.log 2>&1 &

echo "ComfyUI: port 3001"
echo "Logs: /workspace/comfyui.log"
