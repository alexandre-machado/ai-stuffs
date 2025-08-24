param(
  [Parameter(Mandatory=$true)]
  [string]$ModelPath,            # Ex.: D:\models\chatgpt-20b-hf (diretório HF: config.json, *.safetensors, tokenizer.json)
  [string]$TokenizerPath = "",   # Opcional: se tokenizer estiver separado
  [int]$Port = 8000,
  [double]$GpuUtil = 0.90,
  [int]$MaxLen = 8192,
  [int]$TensorParallel = 1,      # >1 se for multi-GPU
  [switch]$Offline,              # Define HF_HUB_OFFLINE=1
  [string]$EnvName = "llm-openai-server",  # Nome do env conda
  [switch]$TrustRemoteCode,      # Usa --trust-remote-code (somente se confiar no repositório!)
  [int]$MaxNumSeqs = 16          # Concorrência (ajuste conforme VRAM)
)

$ErrorActionPreference = "Stop"

# Checagens de caminho
if (-not (Test-Path $ModelPath)) {
  throw "ModelPath não encontrado: $ModelPath"
}
# Bloqueia GGUF (vLLM não suporta)
if ($ModelPath -match "\.gguf$") {
  throw "Você apontou para um arquivo .gguf. vLLM NÃO suporta GGUF. Use LM Studio/Ollama OU um diretório no formato Hugging Face."
}
if ($TokenizerPath -ne "" -and -not (Test-Path $TokenizerPath)) {
  throw "TokenizerPath não encontrado: $TokenizerPath"
}

# Hook + ativar conda env
(& conda 'shell.powershell' 'hook') | Out-String | Invoke-Expression
conda activate $EnvName

# Modo offline (opcional)
if ($Offline) { $env:HF_HUB_OFFLINE = "1" }

# Escolher GPUs (opcional): ex.: "0,1"
# $env:CUDA_VISIBLE_DEVICES = "0"

# Monta argumentos do vLLM
$commonArgs = @(
  "-m", "vllm.entrypoints.openai.api_server",
  "--model", $ModelPath,
  "--host", "0.0.0.0",
  "--port", $Port,
  "--gpu-memory-utilization", $GpuUtil,
  "--max-model-len", $MaxLen,
  "--dtype", "auto",
  "--tensor-parallel-size", $TensorParallel,
  "--max-num-seqs", $MaxNumSeqs
)

if ($TokenizerPath -ne "") { $commonArgs += @("--tokenizer", $TokenizerPath) }
if ($TrustRemoteCode) { $commonArgs += @("--trust-remote-code") }

python $commonArgs
