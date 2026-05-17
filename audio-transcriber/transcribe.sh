#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./transcribe.sh <audio_file>"
    exit 1
fi

AUDIO_FILE=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Activate venv and run process.py
source "$DIR/venv/bin/activate"
python3 "$DIR/process.py" "$AUDIO_FILE"
