#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./transcribe.sh <audio_file>"
    exit 1
fi

AUDIO_FILE=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Activate venv and run transcription
source "$DIR/venv/bin/activate"

# Load .env if exists (simple parser)
if [ -f "$DIR/.env" ]; then
    export $(grep -v '^#' "$DIR/.env" | xargs)
fi

# Try whisperx_transcribe.py first, fall back to process-wisper.py
if [ -f "$DIR/whisperx_transcribe.py" ]; then
    python3 "$DIR/whisperx_transcribe.py" "$AUDIO_FILE"
else
    python3 "$DIR/process-wisper.py" "$AUDIO_FILE"
fi
