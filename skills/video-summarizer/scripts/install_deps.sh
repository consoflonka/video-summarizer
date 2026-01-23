#!/bin/bash
# Install all dependencies for video-summarizer skill

set -e

echo "=========================================="
echo "Video Summarizer - Dependency Installer"
echo "=========================================="
echo ""

# Find pip command
find_pip() {
    if command -v pip3 &> /dev/null; then
        echo "pip3"
    elif command -v pip &> /dev/null; then
        echo "pip"
    elif python3 -m pip --version &> /dev/null; then
        echo "python3 -m pip"
    elif python -m pip --version &> /dev/null; then
        echo "python -m pip"
    else
        echo ""
    fi
}

PIP_CMD=$(find_pip)

if [[ -z "$PIP_CMD" ]]; then
    echo "Error: pip not found"
    echo "Please install pip first:"
    echo "  macOS: python3 -m ensurepip --upgrade"
    echo "  Ubuntu: sudo apt install python3-pip"
    exit 1
fi

echo "Using pip: $PIP_CMD"
echo ""

# ==========================================
# 1. ffmpeg (required for audio processing)
# ==========================================
echo "[1/4] Checking ffmpeg..."
if ! command -v ffmpeg &> /dev/null; then
    echo "  Installing ffmpeg..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install ffmpeg
        else
            echo "  Error: Homebrew not found. Please install ffmpeg manually:"
            echo "    brew install ffmpeg"
            exit 1
        fi
    elif [[ -f /etc/debian_version ]]; then
        sudo apt-get update && sudo apt-get install -y ffmpeg
    elif [[ -f /etc/redhat-release ]]; then
        sudo dnf install -y ffmpeg
    else
        echo "  Error: Please install ffmpeg manually"
        exit 1
    fi
    echo "  ffmpeg installed"
else
    echo "  ffmpeg: OK"
fi

# Check ffprobe (included with ffmpeg)
if ! command -v ffprobe &> /dev/null; then
    echo "  Error: ffprobe not found (should be included with ffmpeg)"
    exit 1
else
    echo "  ffprobe: OK"
fi

# ==========================================
# 2. yt-dlp (required for video downloading)
# ==========================================
echo ""
echo "[2/4] Checking yt-dlp..."
if ! command -v yt-dlp &> /dev/null; then
    echo "  Installing yt-dlp..."
    $PIP_CMD install --user yt-dlp
    echo "  yt-dlp installed"
else
    echo "  yt-dlp: OK"
fi

# ==========================================
# 3. faster-whisper (for speech-to-text)
# ==========================================
echo ""
echo "[3/4] Checking faster-whisper..."
if ! $PIP_CMD show faster-whisper &> /dev/null 2>&1; then
    echo "  Installing faster-whisper..."
    $PIP_CMD install --user faster-whisper
    echo "  faster-whisper installed"
else
    echo "  faster-whisper: OK"
fi

# ==========================================
# 4. Python (check version)
# ==========================================
echo ""
echo "[4/4] Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    echo "  Python: $PYTHON_VERSION"

    # Check if version >= 3.8
    MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    if [[ $MAJOR -lt 3 ]] || [[ $MAJOR -eq 3 && $MINOR -lt 8 ]]; then
        echo "  Warning: Python 3.8+ recommended (current: $PYTHON_VERSION)"
    fi
else
    echo "  Error: Python 3 not found"
    exit 1
fi

# ==========================================
# Summary
# ==========================================
echo ""
echo "=========================================="
echo "All dependencies installed successfully!"
echo "=========================================="
echo ""
echo "Installed tools:"
echo "  - ffmpeg: $(ffmpeg -version 2>&1 | head -1 | cut -d' ' -f3)"
echo "  - yt-dlp: $(yt-dlp --version 2>&1)"
echo "  - faster-whisper: $($PIP_CMD show faster-whisper 2>/dev/null | grep Version | cut -d' ' -f2)"
echo "  - Python: $PYTHON_VERSION"
echo ""
echo "You can now use the video-summarizer skill!"
