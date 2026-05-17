import sys
import os
from faster_whisper import WhisperModel

def transcribe(audio_path):
    model_size = "large-v3-turbo"
    
    # Try to use OpenVINO if available
    device = "cpu"
    compute_type = "int8"
    
    try:
        import openvino
        # Check if OpenVINO can be used with ctranslate2
        # CTranslate2 supports OpenVINO device
        device = "openvino"
        print("OpenVINO detected. Using OpenVINO for acceleration.")
    except ImportError:
        print("OpenVINO not found. Falling back to CPU.")

    print(f"Loading model: {model_size} on {device}...")
    
    try:
        model = WhisperModel(model_size, device=device, compute_type=compute_type, cpu_threads=4)
        print(f"Model loaded on {device} with {compute_type}.")
    except Exception as e:
        print(f"Failed to load model on {device}: {e}")
        if device == "openvino":
            print("Attempting fallback to CPU...")
            device = "cpu"
            model = WhisperModel(model_size, device=device, compute_type=compute_type, cpu_threads=4)
            print(f"Model loaded on {device} with {compute_type}.")
        else:
            return

    print(f"Transcribing: {audio_path} (Forced Language: pt)...")
    segments, info = model.transcribe(audio_path, beam_size=5, language="pt")

    print(f"Detected language '{info.language}' with probability {info.language_probability:.2f}")

    with open("raw.txt", "w", encoding="utf-8") as f:
        for segment in segments:
            print(f"[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}")
            f.write(f"[{segment.start:.2f}s -> {segment.end:.2f}s] {segment.text}\n")

    print(f"Transcription saved to raw.txt")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python process.py <audio_path>")
        sys.exit(1)
    
    audio_path = sys.argv[1]
    if not os.path.exists(audio_path):
        print(f"File not found: {audio_path}")
        sys.exit(1)
        
    transcribe(audio_path)
