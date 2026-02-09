```pwsh
# Step 1: Create the Anaconda environment (Python 3.10 used as an example)
conda create --name py310 python=3.10
# Step 2: Activate the Anaconda environment
conda activate py310
# Step 3: Update the Anaconda environment to the latest version
conda update --all
# Step 4: Download and install the package
conda install -c conda-forge openvino=2025.2.0

conda install ocl-icd-system

# conda install cmake c-compiler cxx-compiler make
# No Windows → não precisa make
conda install cmake c-compiler cxx-compiler
conda env config vars set LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# To reactivate your Conda environment, execute the following command:
conda activate py310


# let's go prepare some model
python -m pip install --upgrade pip
python -m pip install openvino-genai optimum-intel openvino-tokenizers[transformers] optimum-cli
huggingface-cli login   # se for preciso


```


## Setup (Opção 1: Conda - Recomendado para evitar builds em Windows)

1. Instale Miniconda (se ainda não tiver):

```powershell
winget install -e --id Anaconda.Miniconda3
```

2. No diretório `basic-npu-chat`, crie o ambiente a partir do `environment.yml`:

```powershell
conda env create -f environment.yml
```

3. Ative o ambiente:

```powershell
conda activate npu-chat
```

4. Verifique versões:

```powershell
python -V
pip list | Select-String onnx
```

5. Atualizar (se necessário) os pacotes depois:

```powershell
conda activate npu-chat
pip install -U nncf onnx optimum-intel openvino openvino-tokenizers openvino-genai
```

### Recriar / Resetar ambiente Conda

```powershell
conda deactivate
conda env remove -n npu-chat
conda env create -f environment.yml
conda activate npu-chat
```

---

## Setup (Opção 2: Virtualenv puro / venv)

Se preferir não usar Conda:

```powershell
python -m venv npu-env
./npu-env/Scripts/Activate.ps1
pip install --upgrade pip
pip install nncf==2.14.1 onnx==1.17.0 optimum-intel==1.22.0
pip install openvino==2025.3 openvino-tokenizers==2025.3 openvino-genai==2025.3
```

Para resetar:

```powershell
deactivate
Remove-Item -Recurse -Force .\npu-env
python -m venv npu-env
./npu-env/Scripts/Activate.ps1
pip install -r requirements.txt
```

---

## Arquivo requirements.txt (opcional)

Se quiser gerar localmente:

```powershell
@'
nncf==2.14.1
onnx==1.17.0
optimum-intel==1.22.0
openvino==2025.3
openvino-tokenizers==2025.3
openvino-genai==2025.3
'@ | Out-File requirements.txt -Encoding UTF8
```

Instalar via:

```powershell
pip install -r requirements.txt
```

---

## Notas

* Usar Python 3.12 evita builds de alguns pacotes (ex.: onnx) que podem exigir CMake e MSVC no Python 3.13.
* Se aparecer erro de execução ao ativar script: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
* Para atualizar o ambiente Conda após editar `environment.yml`: `conda env update -f environment.yml --prune`.

---

## Troubleshooting rápido

| Problema | Causa provável | Ação |
|----------|----------------|------|
| CMAKE_C_COMPILER not set | Tentativa de build sem toolchain | Use Python 3.12 / Conda ou instale Build Tools |
| onnx compila do zero | Sem wheel para sua versão de Python | Trocar para 3.12 ou outra versão onnx |
| Script não ativa | Política de execução | Set-ExecutionPolicy RemoteSigned |
| Pacote não encontrado | Ambiente errado ativo | `conda info --envs` / `where python` |

---

## Atualizar environment.yml

Edite `environment.yml` e rode:

```powershell
conda env update -f environment.yml --prune
```

---

## Verificação final

```powershell
python -c "import onnx, openvino; print('OK', onnx.__version__)"
```

---

## Original (referência rápida)

```powershell
python -m venv npu-env
npu-env\Scripts\activate
pip install  nncf==2.14.1 onnx==1.17.0 optimum-intel==1.22.0
pip install openvino==2025.3 openvino-tokenizers==2025.3 openvino-genai==2025.3
```