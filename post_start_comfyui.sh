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
    echo "ComfyUI already installed"
else
    # Clone and install ComfyUI
    echo "ComfyUI installation"
    git clone https://github.com/comfyanonymous/ComfyUI.git
    echo "ComfyUI installed"
fi

cd /workspace/ComfyUI
python3 -m venv venv
source venv/bin/activate
git pull

if [ -d "/workspace/SageAttention" ]; then
    echo "SageAttention already installed"
else
    # Clone and install ComfyUI
    echo "SageAttention installation"
    git clone https://github.com/thu-ml/SageAttention.git
    export EXT_PARALLEL=16
    export MAX_JOBS=16
    cd /workspace/SageAttention
    python setup.py install
    echo "SageAttention installed"
fi

pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
pip install -r requirements.txt
pip install triton ninja numpy

# Clone and install ComfyUI-Manager inside custom_nodes
mkdir -p custom_nodes
cd custom_nodes

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git
else
    cd ComfyUI-Manager
    git pull
    cd ..
fi
pip install -r ./ComfyUI-Manager/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Wiki-Workflows" ]; then
    git clone https://github.com/comfyui-wiki/ComfyUI-Wiki-Workflows
else
    cd ComfyUI-Wiki-Workflows
    git pull
    cd ..
fi

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Florence2" ]; then
    git clone https://github.com/kijai/ComfyUI-Florence2
else
    cd ComfyUI-Florence2
    git pull
    cd ..
fi
pip install -r ./ComfyUI-Florence2/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/comfyui_controlnet_aux" ]; then
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux
else
    cd comfyui_controlnet_aux
    git pull
    cd ..
fi
pip install -r ./comfyui_controlnet_aux/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-GGUF" ]; then
    git clone https://github.com/city96/ComfyUI-GGUF
else
    cd ComfyUI-GGUF
    git pull
    cd ..
fi
pip install -r ./ComfyUI-GGUF/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/rgthree-comfy" ]; then
    git clone https://github.com/rgthree/rgthree-comfy
else
    cd rgthree-comfy
    git pull
    cd ..
fi
pip install -r ./rgthree-comfy/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use" ]; then
    git clone https://github.com/yolain/ComfyUI-Easy-Use
else
    cd ComfyUI-Easy-Use
    git pull
    cd ..
fi
pip install -r ./ComfyUI-Easy-Use/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes" ]; then
    git clone https://github.com/kijai/ComfyUI-KJNodes
else
    cd ComfyUI-KJNodes
    git pull
    cd ..
fi
pip install -r ./ComfyUI-KJNodes/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper" ]; then
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper
else
    cd ComfyUI-WanVideoWrapper
    git pull
    cd ..
fi
pip install -r ./ComfyUI-WanVideoWrapper/requirements.txt
pip install -r ./ComfyUI-WanVideoWrapper/fantasyportrait/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack
else
    cd ComfyUI-Impact-Pack
    git pull
    cd ..
fi
pip install -r ./ComfyUI-Impact-Pack/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-UltimateSDUpscale" ]; then
    git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale
else
    cd ComfyUI_UltimateSDUpscale
    git pull
    cd ..
fi

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI_essentials" ]; then
    git clone https://github.com/cubiq/ComfyUI_essentials
else
    cd ComfyUI_essentials
    git pull
    cd ..
fi
pip install -r ./ComfyUI_essentials/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-MagCache" ]; then
    git clone https://github.com/Zehong-Ma/ComfyUI-MagCache
else
    cd ComfyUI-MagCache
    git pull
    cd ..
fi
pip install -r ./ComfyUI-MagCache/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/wlsh_nodes" ]; then
    git clone https://github.com/wallish77/wlsh_nodes
else
    cd wlsh_nodes
    git pull
    cd ..
fi
pip install -r ./wlsh_nodes/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/comfyui-vrgamedevgirl" ]; then
    git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl
else
    cd comfyui-vrgamedevgirl
    git pull
    cd ..
fi
spip install -r ./comfyui-vrgamedevgirl/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite" ]; then
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite
else
    cd ComfyUI-VideoHelperSuite
    git pull
    cd ..
fi
pip install -r ./ComfyUI-VideoHelperSuite/requirements.txt

#git clone https://github.com/Fannovel16/ComfyUI-Frame-Interpolation
#pip install -r ./ComfyUI-Frame-Interpolation/requirements-with-cupy.txt

#git clone https://github.com/ClownsharkBatwing/RES4LYF
#pip install -r ./RES4LYF/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/was-node-suite-comfyui" ]; then
    git clone https://github.com/WASasquatch/was-node-suite-comfyui
else
    cd was-node-suite-comfyui
    git pull
    cd ..
fi
pip install -r ./was-node-suite-comfyui/requirements.txt

#git clone https://github.com/christian-byrne/audio-separation-nodes-comfyui
#pip install -r ./audio-separation-nodes-comfyui/requirements.txt

#git clone https://github.com/ShmuelRonen/ComfyUI-VideoUpscale_WithModel

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-VFI" ]; then
    git clone https://github.com/GACLove/ComfyUI-VFI
else
    cd ComfyUI-VFI
    git pull
    cd ..
fi
pip install -r ./ComfyUI-VFI/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-PainterI2V" ]; then
    git clone https://github.com/princepainter/ComfyUI-PainterI2V
else
    cd ComfyUI-PainterI2V
    git pull
    cd ..
fi

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-wanBlockswap" ]; then
    git clone https://github.com/orssorbit/ComfyUI-wanBlockswap
else
    cd ComfyUI-wanBlockswap
    git pull
    cd ..
fi

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-CoCoTools_IO" ]; then
    git clone https://github.com/Conor-Collins/ComfyUI-CoCoTools_IO
else
    cd ComfyUI-CoCoTools_IO
    git pull
    cd ..
fi
pip install -r ./ComfyUI-CoCoTools_IO/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-segment-anything-2" ]; then
    git clone https://github.com/kijai/ComfyUI-segment-anything-2
else
    cd ComfyUI-segment-anything-2
    git pull
    cd ..
fi

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Inspire-Pack" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Inspire-Pack
else
    cd ComfyUI-Inspire-Pack
    git pull
    cd ..
fi
pip install -r ./ComfyUI-Inspire-Pack/requirements.txtx

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI_Comfyroll_CustomNodes" ]; then
    git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes
else
    cd ComfyUI_Comfyroll_CustomNodes
    git pull
    cd ..
fi
pip install -r ./ComfyUI_Comfyroll_CustomNodes/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-Custom-Scripts" ]; then
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts
else
    cd ComfyUI-Custom-Scripts
    git pull
    cd ..
fi
pip install -r ./ComfyUI-Custom-Scripts/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI_CreaPrompt" ]; then
    git clone https://github.com/tritant/ComfyUI_CreaPrompt
else
    cd ComfyUI_CreaPrompt
    git pull
    cd ..
fi
pip install -r ./ComfyUI_CreaPrompt/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/masquerade-nodes-comfyui" ]; then
    git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui
else
    cd masquerade-nodes-comfyui
    git pull
    cd ..
fi

if [ -d "/workspace/ComfyUI/custom_nodes/WWAA-CustomNodes" ]; then
    git clone https://github.com/hgabha/WWAA-CustomNodes
else
    cd WWAA-CustomNodes
    git pull
    cd ..
fi
pip install -r ./WWAA-CustomNodes/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/Comfyui-QwenEditUtils" ]; then
    git clone https://github.com/lrzjason/Comfyui-QwenEditUtils
else
    cd Comfyui-QwenEditUtils
    git pull
    cd ..
fi
pip install -r ./Comfyui-QwenEditUtils/requirements.txt

if [ -d "/workspace/ComfyUI/custom_nodes/ComfyUI-RMBG" ]; then
    git clone https://github.com/1038lab/ComfyUI-RMBG
else
    cd ComfyUI-RMBG
    git pull
    cd ..
fi
pip install -r ./ComfyUI-RMBG/requirements.txt

# Set execution permission
chmod +x /workspace/ComfyUI/main.py

# Run ComfyUI on port 3001
cd /workspace/ComfyUI
source venv/bin/activate
python main.py --listen --port 3001
