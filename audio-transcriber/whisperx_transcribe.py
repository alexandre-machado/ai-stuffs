#!/usr/bin/env python3
"""
WhisperX Transcription Script
Implements local audio transcription with WhisperX, speaker diarization,
and post-processing. Follows the phases defined in wisperx.md.

Usage:
    python whisperx_transcribe.py <audio_file> [--config .env]
    python whisperx_transcribe.py --setup          # Run environment setup
    python whisperx_transcribe.py --post <json>    # Post-process JSON output
    python whisperx_transcribe.py --detect          # Detect environment
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import warnings
from pathlib import Path

# Silence pyannote reproducibility warnings
warnings.filterwarnings("ignore", message=".*TF32 has been disabled.*")

# CUDA Optimization
try:
    import torch
    if torch.cuda.is_available():
        torch.backends.cuda.matmul.allow_tf32 = True
        torch.backends.cudnn.allow_tf32 = True
except ImportError:
    pass

# Try to load .env from same directory as script
_SCRIPT_DIR = Path(__file__).resolve().parent
_DEFAULT_ENV = _SCRIPT_DIR / ".env"

try:
    from dotenv import load_dotenv
    load_dotenv(_DEFAULT_ENV)
except ImportError:
    if _DEFAULT_ENV.exists():
        print(f"Warning: {_DEFAULT_ENV} found but 'python-dotenv' not installed.")
        print("Run: pip install python-dotenv")


# ---------------------------------------------------------------------------
# Phase 0 — Environment Detection
# ---------------------------------------------------------------------------

def detect_env():
    """Detect system environment: OS, GPU, Python, ffmpeg, HF token."""
    info = {}

    # OS
    import platform
    system = platform.system()
    if system == "Linux":
        info["os"] = "Linux"
    elif system == "Darwin":
        info["os"] = "macOS"
    elif system == "Windows":
        info["os"] = "Windows"
    else:
        info["os"] = system

    # GPU
    info["gpu"] = "none"
    info["cuda"] = False

    # Check NVIDIA
    try:
        result = subprocess.run(
            ["nvidia-smi"], capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0:
            info["gpu"] = "NVIDIA CUDA"
            info["cuda"] = True
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass

    # Check Apple Silicon
    if system == "Darwin":
        try:
            arch = subprocess.check_output(
                ["uname", "-m"], text=True
            ).strip()
            if arch == "arm64":
                info["gpu"] = "Apple Silicon MPS"
        except Exception:
            pass

    # Python
    info["python"] = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    info["python_cmd"] = sys.executable

    # Check conda
    if os.environ.get("CONDA_DEFAULT_ENV"):
        info["conda"] = True
        info["conda_env"] = os.environ["CONDA_DEFAULT_ENV"]
    else:
        info["conda"] = False

    # FFmpeg
    try:
        subprocess.run(
            ["ffmpeg", "-version"], capture_output=True, timeout=5
        )
        info["ffmpeg"] = True
    except (FileNotFoundError, subprocess.TimeoutExpired):
        info["ffmpeg"] = False

    # HF Token
    info["hf_token"] = bool(os.environ.get("HF_TOKEN"))

    return info


def print_env(info):
    """Pretty-print environment detection results."""
    print("=" * 50)
    print("  Environment Detection")
    print("=" * 50)

    checks = [
        ("OS", info["os"]),
        ("GPU", info["gpu"]),
        ("Python", info["python"]),
        ("FFmpeg", "OK" if info["ffmpeg"] else "NOT INSTALLED"),
        ("HF Token", "SET" if info["hf_token"] else "NOT SET"),
        ("Conda", "YES" if info.get("conda") else "NO"),
    ]

    for label, value in checks:
        status = "OK" if (
            (label == "FFmpeg" and value == "OK") or
            (label == "HF Token" and value == "SET") or
            (label == "GPU" and value != "none") or
            (label == "Python" and True) or
            (label == "Conda" and value == "YES")
        ) else "NEEDS ATTENTION" if label != "Python" else "OK"

        icon = "✓" if status == "OK" else "!" if label != "Python" else "✓"
        print(f"  {icon} {label:<12} {value}")

    if not info["cuda"] and info["gpu"] == "none":
        print("\n  ⚠ No GPU detected — transcription will run on CPU (slow)")

    if not info["ffmpeg"]:
        print("\n  ✗ FFmpeg not found — install it before transcribing")
        if info["os"] == "Linux":
            print("     sudo apt install ffmpeg")
        elif info["os"] == "macOS":
            print("     brew install ffmpeg")
        else:
            print("     Download from https://ffmpeg.org/download.html")

    if not info["hf_token"]:
        print("\n  ℹ HF Token not set — diarization disabled")
        print("     Get one at: https://huggingface.co/settings/tokens")

    print("=" * 50)


# ---------------------------------------------------------------------------
# Phase 1 — Setup
# ---------------------------------------------------------------------------

def run_setup():
    """Run environment setup: install whisperx, verify everything."""
    print("Running WhisperX setup...\n")

    info = detect_env()
    print_env(info)

    # Check ffmpeg
    if not info["ffmpeg"]:
        print("\n✗ Cannot proceed without FFmpeg. Install it first.")
        sys.exit(1)

    # Check Python version
    py = sys.version_info
    if py.major != 3 or py.minor < 10:
        print(f"\n⚠ Python 3.10+ recommended (found {py.major}.{py.minor})")

    # Install whisperx
    print("\nInstalling whisperx...")
    try:
        import whisperx
        print(f"  ✓ whisperx {whisperx.__version__} already installed")
    except ImportError:
        print("  Installing whisperx via pip...")
        result = subprocess.run(
            [sys.executable, "-m", "pip", "install", "git+https://github.com/m-bain/whisperx.git"],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            print("  ✓ whisperx installed successfully")
        else:
            print(f"  ✗ Failed to install whisperx:\n{result.stderr[-500:]}")
            sys.exit(1)

    # Check PyTorch
    try:
        import torch
        has_cuda = torch.cuda.is_available()
        print(f"  ✓ PyTorch {torch.__version__} (CUDA: {'YES' if has_cuda else 'NO'})")
    except ImportError:
        print("  ✗ PyTorch not installed")
        sys.exit(1)

    # Check pyannote
    try:
        import pyannote
        print("  ✓ pyannote-audio installed (diarization available)")
    except ImportError:
        print("  ⚠ pyannote-audio not installed — diarization will be disabled")

    # Check HF token
    if info["hf_token"]:
        print("\n  ✓ Hugging Face token is set")
    else:
        print("\n⚠ Hugging Face token not set.")
        print("  Diarization requires a token from https://huggingface.co/settings/tokens")
        print("  Set it via: export HF_TOKEN=your_token")
        print("  Or create a .env file with: HF_TOKEN=your_token")

    # Suggest device
    if info["cuda"]:
        device = "cuda"
        compute = "float16"
    elif info["gpu"] == "Apple Silicon MPS":
        device = "mps"
        compute = "float32"
    else:
        device = "cpu"
        compute = "int8"

    print(f"\n  → Recommended: --device {device} --compute_type {compute}")
    print("\n✓ Setup complete. Run: python whisperx_transcribe.py <audio_file>")


# ---------------------------------------------------------------------------
# Phase 3 — Transcription
# ---------------------------------------------------------------------------

def get_config():
    """Load configuration from environment variables."""
    return {
        "hf_token": os.environ.get("HF_TOKEN", ""),
        "device": os.environ.get("DEVICE", "cuda" if detect_env()["cuda"] else "cpu"),
        "compute_type": os.environ.get("COMPUTE_TYPE", "float16" if detect_env()["cuda"] else "int8"),
        "model": os.environ.get("MODEL", "large-v2"),
        "min_speakers": int(os.environ.get("MIN_SPEAKERS", 0) or 0),
        "max_speakers": int(os.environ.get("MAX_SPEAKERS", 0) or 0),
        "output_dir": os.environ.get("OUTPUT_DIR", ""),
        "output_format": os.environ.get("OUTPUT_FORMAT", "srt"),
        "batch_size": int(os.environ.get("BATCH_SIZE", 16)),
        "beam_size": int(os.environ.get("BEAM_SIZE", 5)),
    }


def transcribe(audio_path: str):
    """Run WhisperX transcription with optional diarization."""
    config = get_config()

    # Validate input
    audio_path = Path(audio_path)
    if not audio_path.exists():
        print(f"Error: file not found: {audio_path}")
        sys.exit(1)

    # Default to the same folder as the input audio unless OUTPUT_DIR is set.
    if not config["output_dir"]:
        config["output_dir"] = str(audio_path.parent)

    # Ensure output dir
    os.makedirs(config["output_dir"], exist_ok=True)

    print(f"\n{'=' * 50}")
    print(f"  WhisperX Transcription")
    print(f"{'=' * 50}")
    print(f"  Audio:      {audio_path}")
    print(f"  Model:      {config['model']}")
    print(f"  Device:     {config['device']}")
    print(f"  Compute:    {config['compute_type']}")
    print(f"  Diarization: {'YES' if config['hf_token'] and config['min_speakers'] > 0 else 'NO'}")
    print(f"  Output:     {config['output_dir']}/")
    print(f"{'=' * 50}\n")

    # Import and run whisperx
    try:
        import whisperx
    except ImportError:
        print("Error: whisperx not installed. Run: python whisperx_transcribe.py --setup")
        sys.exit(1)

    # Load model
    print("Loading model...")
    asr_options = {
        "beam_size": config["beam_size"]
    }
    model = whisperx.load_model(
        config["model"],
        device=config["device"],
        compute_type=config["compute_type"],
        language="pt",
        asr_options=asr_options
    )

    # Load audio
    audio = whisperx.load_audio(str(audio_path))

    # Transcribe
    print("Transcribing...")
    result = model.transcribe(
        audio,
        batch_size=config["batch_size"],
        language="pt",
    )

    print(f"  Detected language: {result.get('language', 'pt')}")

    # Diarization
    if config["hf_token"] and config["min_speakers"] > 0:
        print("Running speaker diarization...")
        try:
            import huggingface_hub
            # Confirm token format and presence
            token = config["hf_token"].strip()
            if not token.startswith("hf_"):
                print(f"  ⚠ Warning: HF_TOKEN does not look like a valid token (should start with hf_)")
            else:
                print(f"  ℹ Authenticating with HF token: {token[:8]}...{token[-4:]}")
            
            huggingface_hub.login(token=token, add_to_git_credential=False)

            from whisperx.diarize import DiarizationPipeline
            model_diarize = DiarizationPipeline(
                model_name="pyannote/speaker-diarization-3.1",
                token=token,
                device=config["device"],
            )
            diarize_segments = model_diarize(
                str(audio_path),
                min_speakers=config["min_speakers"],
                max_speakers=config["max_speakers"],
            )
            result = whisperx.assign_word_speakers(diarize_segments, result)
            print("  ✓ Diarization complete")
        except Exception as e:
            print(f"  ⚠ Diarization failed: {e}")
            import traceback
            traceback.print_exc()
            print("  → Continuing without speaker identification")
    else:
        print("  ℹ Diarization skipped (no token or speaker count)")

    # Save outputs
    print("Saving outputs...")
    from whisperx.utils import get_writer
    
    stem = audio_path.stem
    base_name = f"{stem}"

    formats = config["output_format"]
    if formats == "all":
        formats_list = ["txt", "srt", "vtt", "tsv", "json"]
    else:
        formats_list = [f.strip() for f in formats.split(",")]

    writer_options = {
        "max_line_width": None,
        "max_line_count": None,
        "highlight_words": False,
    }

    for fmt in formats_list:
        try:
            writer = get_writer(fmt, config["output_dir"])
            writer(result, str(audio_path), writer_options)
            print(f"  ✓ Saved {fmt}")
        except Exception as e:
            print(f"  ⚠ Failed to save {fmt}: {e}")

    # Preview first 5 segments
    print(f"\n  Preview (first 5 segments):")
    print(f"  {'-' * 46}")
    for i, seg in enumerate(result["segments"][:5]):
        speaker = seg.get("speaker", "N/A")
        start = seg["start"]
        end = seg["end"]
        text = seg["text"].strip()
        print(f"  [{start:6.1f}s → {end:6.1f}s] {speaker}: {text}")
    if len(result["segments"]) > 5:
        print(f"  ... and {len(result['segments']) - 5} more segments")
    print(f"{'=' * 50}\n")

    # Cleanup
    del model
    import torch
    if config["device"] == "cuda":
        torch.cuda.empty_cache()

    return result


# ---------------------------------------------------------------------------
# Phase 6 — Post-processing
# ---------------------------------------------------------------------------

def post_process(json_path: str, rename_map: dict | None = None):
    """Load WhisperX JSON output and format by speaker."""
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    if rename_map is None:
        rename_map = {}

    # Auto-generate names if not provided
    speaker_ids = sorted(set(
        seg.get("speaker", "UNKNOWN") for seg in data["segments"]
        if seg.get("speaker")
    ))
    default_names = {
        sid: f"Speaker_{i}" for i, sid in enumerate(speaker_ids)
    }
    default_names.update(rename_map)

    for seg in data["segments"]:
        original = seg.get("speaker", "UNKNOWN")
        name = default_names.get(original, original)
        start = round(seg["start"], 1)
        end = round(seg["end"], 1)
        text = seg["text"].strip()
        print(f"[{start}s → {end}s]  {name}: {text}")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="WhisperX local transcription with diarization",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("audio", nargs="?", help="Audio file to transcribe")
    parser.add_argument("--setup", action="store_true", help="Run environment setup")
    parser.add_argument("--detect", action="store_true", help="Detect and show environment info")
    parser.add_argument("--post", metavar="<json>", help="Post-process WhisperX JSON output")
    parser.add_argument("--config", default=str(_DEFAULT_ENV), help="Path to .env config file")
    parser.add_argument("--min-speakers", type=int, help="Override min speakers")
    parser.add_argument("--max-speakers", type=int, help="Override max speakers")
    parser.add_argument("--device", choices=["cuda", "cpu", "mps", "openvino"])
    parser.add_argument("--model", help="Whisper model size")
    parser.add_argument("--no-diarization", action="store_true", help="Disable diarization")

    args = parser.parse_args()

    # Override config from CLI
    if args.min_speakers is not None:
        os.environ["MIN_SPEAKERS"] = str(args.min_speakers)
    if args.max_speakers is not None:
        os.environ["MAX_SPEAKERS"] = str(args.max_speakers)
    if args.device is not None:
        os.environ["DEVICE"] = args.device
    if args.model is not None:
        os.environ["MODEL"] = args.model

    if args.setup:
        run_setup()
        return

    if args.detect:
        info = detect_env()
        print_env(info)
        return

    if args.post:
        post_process(args.post)
        return

    if args.audio:
        transcribe(args.audio)
        return

    parser.print_help()


if __name__ == "__main__":
    main()
