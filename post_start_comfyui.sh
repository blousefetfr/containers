#!/bin/bash

# Set up workspace
mkdir -p /workspace && cd /workspace

# Update system packages
apt update && apt upgrade -y

# Install required dependencies
apt install -y git python3 python3-venv python3-pip wget

# Stop and disable Nginx if it's running
systemctl stop nginx 2>/dev/null || true
systemctl disable nginx 2>/dev/null || true

if [ -d "/workspace/ComfyUI" ]; then
    echo "[INFO] ComfyUI already installed"
else
    # Clone and install ComfyUI
    echo "[INFO] ComfyUI installation"
    git clone https://github.com/comfyanonymous/ComfyUI.git
    echo "[INFO] ComfyUI installed"
fi

if [ -d "/workspace/SageAttention" ]; then
    echo "[INFO] SageAttention already installed"
else
    # Clone and install ComfyUI
    echo "[INFO] SageAttention installation"
    git clone https://github.com/thu-ml/SageAttention.git
    export EXT_PARALLEL=16
    export MAX_JOBS=16
    cd /workspace/SageAttention
    python setup.py install
    cd /workspace/
    echo "[INFO] SageAttention installed"
fi

python3 -m venv venv
source venv/bin/activate
git pull
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
pip install -r requirements.txt
pip install triton ninja numpy


# Clone and install ComfyUI-Manager inside custom_nodes
mkdir -p custom_nodes
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
pip install -r ./ComfyUI-Manager/requirements.txt

git clone https://github.com/comfyui-wiki/ComfyUI-Wiki-Workflows

#git clone https://github.com/mit-han-lab/ComfyUI-nunchaku nunchaku_nodes
#pip install -r ./ComfyUI-nunchaku/requirements.txt

git clone https://github.com/kijai/ComfyUI-Florence2
pip install -r ./ComfyUI-Florence2/requirements.txt

git clone https://github.com/Fannovel16/comfyui_controlnet_aux
pip install -r ./comfyui_controlnet_aux/requirements.txt

git clone https://github.com/city96/ComfyUI-GGUF
pip install -r ./ComfyUI-GGUF/requirements.txt

git clone https://github.com/rgthree/rgthree-comfy
pip install -r ./rgthree-comfy/requirements.txt

git clone https://github.com/yolain/ComfyUI-Easy-Use
pip install -r ./ComfyUI-Easy-Use/requirements.txt

git clone https://github.com/kijai/ComfyUI-KJNodes
pip install -r ./ComfyUI-KJNodes/requirements.txt

git clone https://github.com/kijai/ComfyUI-WanVideoWrapper
pip install -r ./ComfyUI-WanVideoWrapper/requirements.txt
pip install -r ./ComfyUI-WanVideoWrapper/fantasyportrait/requirements.txt

git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack
pip install -r ./ComfyUI-Impact-Pack/requirements.txt

git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale

git clone https://github.com/cubiq/ComfyUI_essentials
pip install -r ./ComfyUI_essentials/requirements.txt

git clone https://github.com/Zehong-Ma/ComfyUI-MagCache
pip install -r ./ComfyUI-MagCache/requirements.txt

git clone https://github.com/wallish77/wlsh_nodes
pip install -r ./wlsh_nodes/requirements.txt

git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl
spip install -r ./comfyui-vrgamedevgirl/requirements.txt

git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite
pip install -r ./ComfyUI-VideoHelperSuite/requirements.txt

#git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation
#pip install -r ./ComfyUI-Frame-Interpolation/requirements-with-cupy.txt

#git clone https://github.com/ClownsharkBatwing/RES4LYF
#pip install -r ./RES4LYF/requirements.txt

git clone https://github.com/WASasquatch/was-node-suite-comfyui
pip install -r ./was-node-suite-comfyui/requirements.txt

#git clone https://github.com/christian-byrne/audio-separation-nodes-comfyui
#pip install -r ./audio-separation-nodes-comfyui/requirements.txt

#git clone https://github.com/ShmuelRonen/ComfyUI-VideoUpscale_WithModel

git clone https://github.com/GACLove/ComfyUI-VFI
pip install -r ./ComfyUI-VFI/requirements.txt

git clone https://github.com/princepainter/ComfyUI-PainterI2V

git clone https://github.com/orssorbit/ComfyUI-wanBlockswap

git clone https://github.com/Conor-Collins/ComfyUI-CoCoTools_IO
pip install -r ./ComfyUI-CoCoTools_IO/requirements.txt

git clone https://github.com/kijai/ComfyUI-segment-anything-2

git clone https://github.com/ltdrdata/ComfyUI-Inspire-Pack
pip install -r ./ComfyUI-Inspire-Pack/requirements.txtx

git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes
pip install -r ./ComfyUI_Comfyroll_CustomNodes/requirements.txt

git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts
pip install -r ./ComfyUI-Custom-Scripts/requirements.txt

git clone https://github.com/tritant/ComfyUI_CreaPrompt
pip install -r ./ComfyUI_CreaPrompt/requirements.txt

git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui

git clone https://github.com/hgabha/WWAA-CustomNodes
pip install -r ./WWAA-CustomNodes/requirements.txt

git clone https://github.com/lrzjason/Comfyui-QwenEditUtils
pip install -r ./WWAA-CustomNodes/requirements.txt

git clone https://github.com/1038lab/ComfyUI-RMBG
pip install -r ./ComfyUI-RMBG/requirements.txt

#git clone https://github.com/GMapeSplat/ComfyUI_ezXY
#pip install -r ./ComfyUI_ezXY/requirements.txt

# Set execution permission
chmod +x /workspace/ComfyUI/main.py

# Kill any process using port 3001
kill -9 $(lsof -ti :3001) || true

# Run ComfyUI on port 3001
cd /workspace/ComfyUI
source venv/bin/activate
python main.py --listen --port 3001
