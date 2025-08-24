# OpenAI-Compatible Server (vLLM) com **Conda** — Windows

Sobe um servidor **OpenAI-compatível** usando **vLLM** dentro de um ambiente **Conda**.

> **Importante:** o vLLM **não** carrega **GGUF**. Se seu modelo é `.gguf` (ex.: LM Studio/GGUF),
> execute via **LM Studio** (Local Server em `http://localhost:1234/v1`) ou **Ollama**.
> Para usar vLLM, você precisa de um **diretório no formato Hugging Face** (`config.json`, `*.safetensors`, `tokenizer.json`).

---

## Requisitos

- Windows 10/11, PowerShell 7+
- **Conda** instalado e no PATH (Miniconda/Anaconda)
- Python 3.11 (será instalado no env)
- Driver NVIDIA + CUDA funcionando (`nvidia-smi`)
- **Modelo em formato Hugging Face** numa pasta local (não GGUF)

---

## Instalação

```powershell
.\setup-conda.ps1
