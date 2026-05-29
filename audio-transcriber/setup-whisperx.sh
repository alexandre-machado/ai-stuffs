#!/bin/bash
# WhisperX Setup Script
# One-command environment setup with verification
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "=========================================="
echo "  WhisperX Local Setup"
echo "=========================================="
echo ""

# 1. Check Python
echo "[1/6] Checking Python..."
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
else
    echo "  ✗ Python not found"
    exit 1
fi
$PYTHON_CMD --version
echo "  ✓ Python found"
echo ""

# 2. Check/create venv
echo "[2/6] Checking virtual environment..."
if [ -d "venv" ]; then
    echo "  ✓ venv/ already exists"
else
    echo "  Creating venv..."
    $PYTHON_CMD -m venv venv
    echo "  ✓ venv/ created"
fi
source venv/bin/activate
echo ""

# 3. Check FFmpeg
echo "[3/6] Checking FFmpeg..."
if command -v ffmpeg &>/dev/null; then
    FFVER=$(ffmpeg -version 2>/dev/null | head -1)
    echo "  ✓ $FFVER"
else
    echo "  ✗ FFmpeg not found"
    echo "  Install: sudo apt install ffmpeg  (Linux)"
    echo "           brew install ffmpeg      (macOS)"
    exit 1
fi
echo ""

# 4. Install/update packages
echo "[4/6] Installing packages..."

# PyTorch CUDA
if nvidia-smi &>/dev/null; then
    echo "  NVIDIA GPU detected — installing CUDA PyTorch..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 -q 2>&1 | tail -1
else
    echo "  No NVIDIA GPU — installing CPU PyTorch..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu -q 2>&1 | tail -1
fi
echo "  ✓ PyTorch installed"

# WhisperX
if pip show whisperx &>/dev/null; then
    WXVER=$(pip show whisperx 2>/dev/null | grep Version | cut -d' ' -f2)
    echo "  whisperx $WXVER already installed"
else
    echo "  Installing whisperx..."
    pip install git+https://github.com/m-bain/whisperx.git -q 2>&1 | tail -1
    echo "  ✓ whisperx installed"
fi

# python-dotenv
pip install python-dotenv -q 2>&1 | tail -1
echo "  ✓ python-dotenv installed"
echo ""

# 5. Verify installation
echo "[5/6] Verifying installation..."
$PYTHON_CMD -c "import whisperx; print(f'  ✓ whisperx {whisperx.__version__}')"
$PYTHON_CMD -c "import torch; print(f'  ✓ PyTorch {torch.__version__}')"
echo ""

# 6. HF Token setup
echo "[6/6] Hugging Face Token Setup"
echo ""
echo "  For speaker diarization, you need a free HF token:"
echo ""
echo "  1. Create account: https://huggingface.co"
echo "  2. Accept model terms:"
echo "     https://huggingface.co/pyannote/speaker-diarization-3.1"
echo "     https://huggingface.co/pyannote/segmentation-3.0"
echo "  3. Generate token: https://huggingface.co/settings/tokens (type: read)"
echo ""

if [ -f ".env" ] && grep -q "HF_TOKEN=" .env 2>/dev/null; then
    TOKEN=$(grep "HF_TOKEN=" .env | cut -d'=' -f2-)
    MASKED="${TOKEN:0:4}...${TOKEN: -4}"
    echo "  ✓ Token configured: $MASKED"
else
    echo "  ℹ No token configured yet."
    echo "  ℹ Copy .env.example to .env and add your token:"
    echo "     cp .env.example .env"
    echo "     # edit .env and paste your HF_TOKEN"
fi
echo ""
echo "=========================================="
echo "  ✓ Setup complete!"
echo "=========================================="
echo ""
echo "  Usage:"
echo "    ./whisperx_transcribe.py --detect    # Check environment"
echo "    ./whisperx_transcribe.py audio.mp3   # Transcribe"
echo "    ./whisperx_transcribe.py --post out/audio.json  # Post-process"
echo ""
