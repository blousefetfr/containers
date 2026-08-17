#!/usr/bin/bash
set -e  # Exit the script if any statement returns a non-true return value

COMFYUI_DIR="/workspace/ComfyUI"
VENV_DIR="/workspace/venv"

# Create default comfyui_args.txt if it doesn't exist
ARGS_FILE="/workspace/comfyui_args.txt"
if [ ! -f "$ARGS_FILE" ]; then
    echo "# Add your custom ComfyUI arguments here (one per line)" > "$ARGS_FILE"
    echo "Created empty ComfyUI arguments file at $ARGS_FILE"
fi


# Setup ComfyUI if needed
if [ ! -d "$COMFYUI_DIR" ] || [ ! -d "$VENV_DIR" ]; then
    echo "First time setup: Installing ComfyUI and dependencies..."

    if [ ! -d "$VENV_DIR" ]; then
        echo "First time setup: Creating virtual environment for ComfyUI ..."
        # Create venv with access to system packages (torch, numpy, etc. pre-installed in image)
        python -m venv --system-site-packages $VENV_DIR
        source $VENV_DIR/bin/activate
    
        echo "Base packages (torch, numpy, etc.) available from system site-packages"    
        pip install --pre torch torchvision torchaudio xformers triton numpy --index-url https://download.pytorch.org/whl/cu130
    else
        source $VENV_DIR/bin/activate
    fi
    # Clone ComfyUI if not present
    if [ ! -d "$COMFYUI_DIR" ]; then
        cd /workspace/
        git clone https://github.com/comfyanonymous/ComfyUI.git

        echo "Installing ComfyUI dependencies..."
        cd "$COMFYUI_DIR"
        pip install --no-cache-dir -r requirements.txt
    fi
    
    # Install ComfyUI-Manager if not present
    if [ ! -d "$COMFYUI_DIR/custom_nodes/ComfyUI-Manager" ]; then
        echo "Installing ComfyUI-Manager..."
        mkdir -p "$COMFYUI_DIR/custom_nodes"
        cd "$COMFYUI_DIR/custom_nodes"
        git clone https://github.com/ltdrdata/ComfyUI-Manager.git
    fi

    # Install additional custom nodes
    CUSTOM_NODES=(
        "https://github.com/MoonGoblinDev/Civicomfy"
        "https://github.com/MadiatorLabs/ComfyUI-RunpodDirect"
        "https://github.com/crystian/ComfyUI-Crystools"
        "https://github.com/kijai/ComfyUI-KJNodes"
        "https://github.com/kijai/ComfyUI-WanVideoWrapper"
        "https://github.com/Lightricks/ComfyUI-LTXVideo"
        "https://github.com/rgthree/rgthree-comfy"
        "https://github.com/WASasquatch/was-node-suite-comfyui"
        "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
        "https://github.com/princepainter/ComfyUI-PainterI2VforKJ"
        "https://github.com/pythongosssss/ComfyUI-Custom-Scripts"
        "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
        "https://github.com/yolain/ComfyUI-Easy-Use"
        "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
        "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation"
        "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
        "https://github.com/1038lab/ComfyUI-RMBG"
        "https://github.com/IxMxAMAR/ComfyUI-ElevenLabs-Pro"
    )

    for repo in "${CUSTOM_NODES[@]}"; do
        repo_name=$(basename "$repo")
        if [ ! -d "$COMFYUI_DIR/custom_nodes/$repo_name" ]; then
            echo "Installing $repo_name..."
            cd "$COMFYUI_DIR/custom_nodes"
            git clone "$repo"
        fi
    done
    
    cd $COMFYUI_DIR
    echo "Installing and Compiling SageAttention2 and 3"
    cd /workspace/
    cd sageattention3_blackwell
    EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32 python setup.py install
    echo "SageAttention2 and 3 installed"

    echo "Installing FlashAttention, FlashAttention3 and FlashAttention4"
    pip install flash-attn --no-build-isolation
    pip install flash-attn-3 --index-url https://download.pytorch.org/whl/cu130
    pip install flash-attn-4==4.0.0b23
    pip install "flash-attn-4[cu13]"
    echo "FlashAttention3 and 4 installed"
    
    cd $COMFYUI_DIR
    
    echo "Installing custom node dependencies..."
    pip install -r $COMFYUI_DIR/manager_requirements.txt        
    # Install dependencies for all custom nodes
    cd "$COMFYUI_DIR/custom_nodes"
    for node_dir in */; do
        if [ -d "$COMFYUI_DIR/custom_nodes/$node_dir" ]; then
            echo "Checking dependencies for $node_dir..."
            cd "$COMFYUI_DIR/custom_nodes/$node_dir"
            
            # Check for requirements.txt
            if [ -f "requirements.txt" ]; then
                echo "Installing requirements.txt for $node_dir"
                pip install --no-cache-dir -r requirements.txt
            fi

            # Check for install.py
            if [ -f "install.py" ]; then
                echo "Running install.py for $node_dir"
                python install.py
            fi

            # Check for setup.py
            if [ -f "setup.py" ]; then
                echo "Running setup.py for $node_dir"
                pip install --no-cache-dir -e .
            fi
        fi
    done
else
    # Just activate the existing venv
    source $VENV_DIR/bin/activate

    echo "Checking for custom node dependencies..."
    # Install dependencies for all custom nodes
    cd "$COMFYUI_DIR/custom_nodes"
    for node_dir in */; do
        if [ -d "$node_dir" ]; then
            echo "Checking dependencies for $node_dir..."
            cd "$COMFYUI_DIR/custom_nodes/$node_dir"
            
            # Check for requirements.txt
            if [ -f "requirements.txt" ]; then
                echo "Installing requirements.txt for $node_dir"
                pip install --no-cache -r requirements.txt
            fi
            
            # Check for install.py
            if [ -f "install.py" ]; then
                echo "Running install.py for $node_dir"
                python install.py
            fi
            
            # Check for setup.py
            if [ -f "setup.py" ]; then
                echo "Running setup.py for $node_dir"
                pip install --no-cache -e .
            fi
        fi
    done
fi

# Start ComfyUI with custom arguments if provided
cd $COMFYUI_DIR
FIXED_ARGS="--listen 0.0.0.0 --port 8188 --enable-manager --use-sage-attention"
if [ -s "$ARGS_FILE" ]; then
    # File exists and is not empty, combine fixed args with custom args
    CUSTOM_ARGS=$(grep -v '^#' "$ARGS_FILE" | tr '\n' ' ')
    if [ ! -z "$CUSTOM_ARGS" ]; then
        echo "Starting ComfyUI with additional arguments: $CUSTOM_ARGS"
        nohup python main.py $FIXED_ARGS $CUSTOM_ARGS &> /workspace/comfyui.log &
    else
        echo "Starting ComfyUI with default arguments"
        nohup python main.py $FIXED_ARGS &> /workspace/comfyui.log &
    fi
else
    # File is empty, use only fixed args
    echo "Starting ComfyUI with default arguments"
    nohup python main.py $FIXED_ARGS &> /workspace/comfyui.log &
fi

# Tail the log file
tail -f /workspace/comfyui.log
