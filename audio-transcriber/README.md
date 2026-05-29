# Audio Transcriber (WhisperX)

Transcritor de áudio local otimizado usando **WhisperX**, com suporte a identificação de falantes (diarização) e aceleração por GPU.

## 📋 Pré-requisitos

1.  **FFmpeg**: Necessário para processamento de áudio.
    ```bash
    sudo apt update && sudo apt install ffmpeg
    ```
2.  **NVIDIA Drivers & CUDA** (Opcional, mas recomendado): Para transcrição rápida via GPU.
3.  **Hugging Face Token**: Necessário para baixar o modelo de diarização (pyannote).
    - Crie uma conta em [huggingface.co](https://huggingface.co/).
    - Aceite os termos do modelo: [pyannote/speaker-diarization-3.1](https://huggingface.co/pyannote/speaker-diarization-3.1) e [pyannote/segmentation-3.0](https://huggingface.co/pyannote/segmentation-3.0).
    - Gere um token em [Settings > Tokens](https://huggingface.co/settings/tokens).

## 🚀 Instalação Local

1.  **Criar Ambiente Virtual**:
```bash
cd audio-transcriber
python3 -m venv venv
source venv/bin/activate
```

2.  **Instalar Dependências**:
```bash
pip install -r requirements.txt
```

3.  **Configurar Variáveis de Ambiente**:
    Crie um arquivo `.env` na pasta `audio-transcriber`:
```env
HF_TOKEN=seu_token_aqui
DEVICE=cuda
COMPUTE_TYPE=float16
MODEL=large-v2
MIN_SPEAKERS=2
```

## 🎙️ Como Usar

### Transcrição Completa
Use o script auxiliar para ativar o ambiente e rodar a transcrição:
```bash
./transcribe.sh caminho/para/audio.mp3
```

Ou diretamente via Python:
```bash
source venv/bin/activate
python whisperx_transcribe.py caminho/para/audio.mp3
```

### Opções Úteis
- `--no-diarization`: Desativa a identificação de falantes.
- `--min-speakers X`: Força um número mínimo de falantes.
- `--model size`: Escolhe o tamanho do modelo (ex: `tiny`, `base`, `small`, `medium`, `large-v3`).

### Pós-processamento
Se já tiver o arquivo JSON gerado e quiser apenas formatar o texto por falante:
```bash
python whisperx_transcribe.py --post output/audio.json
```

## 📂 Estrutura de Saída
Por padrão, os resultados são salvos na mesma pasta do áudio de entrada, nos formatos:
- `.txt`: Apenas o texto bruto.
- `.srt` / `.vtt`: Legendas com timestamps.
- `.json`: Dados completos (incluindo segmentos e falantes).
- `.tsv`: Formato tabular.

Se quiser sobrescrever a pasta de saída, use `OUTPUT_DIR`.

```sh
./transcribe.sh "/mnt/outrodisco/alguma_pasta/audio.mp3"
```