# Requisitos: Miniconda/Anaconda no PATH (conda), Windows 10/11, PowerShell 7+, NVIDIA/CUDA (nvidia-smi).
# Uso: abra o PowerShell na pasta 'openai-server' e rode: .\setup-conda.ps1

$ErrorActionPreference = "Stop"
$EnvName = "llm-openai-server"
$PyVersion = "3.11"

# Inicializa hook da conda no PowerShell
(& conda 'shell.powershell' 'hook') | Out-String | Invoke-Expression

# Cria env se não existir
$exists = conda env list | Select-String "^\s*$EnvName\s"
if (-not $exists) {
  conda create -y -n $EnvName python=$PyVersion
}

# Ativa env
conda activate $EnvName

# Atualiza pip e instala libs via pip (vLLM + HF CLI)
python -m pip install --upgrade pip
python -m pip install vllm "huggingface_hub[cli]"

Write-Host ""
Write-Host "------------------------------------------"
Write-Host "Conda env pronto: $EnvName (python $PyVersion)"
Write-Host "Para ativar depois: conda activate $EnvName"
Write-Host ""
Write-Host "Para rodar o servidor (formato Hugging Face):"
Write-Host "  .\run-server.ps1 -ModelPath 'D:\models\chatgpt-20b-hf' -Offline"
Write-Host ""
Write-Host "ATENÇÃO: vLLM NÃO carrega GGUF. Para .gguf use LM Studio ou Ollama."
Write-Host "------------------------------------------"
