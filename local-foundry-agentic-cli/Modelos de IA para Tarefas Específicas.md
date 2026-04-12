# 📊 Relatório Técnico: Modelos de IA para Execução via NPU

Este documento classifica e detalha as melhores aplicações para os modelos detectados via **OpenVINO Execution Provider** no hardware NPU (Neural Processing Unit).

---

## 🛠️ Melhores CLIs para Terminal
Para rodar esses modelos localmente via linha de comando, as opções mais eficientes no momento são:

1.  **Foundry CLI (O que você já possui):** A melhor ponte direta para o ecossistema OpenVINO, permitindo gerenciar os EPs (Execution Providers) de forma granular.
2.  **Ollama (Builds OpenVINO):** A CLI mais popular para uso casual. Procure pelas versões compatíveis com OpenVINO para descarregar o processamento na NPU em vez da CPU/GPU.
3.  **LM Studio (CLI - `lms`):** Oferece um servidor local robusto que permite integrar os modelos a outras ferramentas de desenvolvimento.

---

## ⚠️ Esclarecimento sobre Tarefas Multimodais
Os modelos listados (Phi, Mistral, DeepSeek, Qwen) são exclusivamente **LLMs (Large Language Models)**. 

* **Edição de Fotos/GIFs:** Estes modelos **não** possuem capacidade nativa para processar imagens. 
* **O que eles fazem:** Eles escrevem o **código** (Python/OpenCV/JS) que você pode usar para editar imagens, mas não "enxergam" os arquivos diretamente.
* **Recomendação:** Para edição de imagem via NPU, utilize o **Stable Diffusion** com aceleração OpenVINO.

---

## 📋 Classificação por Tarefas e Especialidade

| Modelo | Tamanho (GB) | Tarefa Principal | Especialidade Técnica |
| :--- | :--- | :--- | :--- |
| **Qwen 2.5 Coder 7B** | 4.73 GB | Programação | **Melhor para JavaScript**, Python e refatoração de código complexo. |
| **DeepSeek-R1 7B** | 4.17 GB | Raciocínio | Lógica matemática, pensamento estruturado e planejamento de sistemas. |
| **Mistral 7B v0.2** | 3.60 GB | Chat Geral | Redação criativa, resumos de texto e conversação natural. |
| **Phi-4 Mini Reasoning**| 2.15 GB | Lógica | Tomada de decisão e resolução de enigmas lógicos complexos. |
| **Phi-3 Mini 4k** | 2.13 GB | Chat/Leve | Assistente de tarefas rápidas com baixo consumo de energia. |
| **Qwen 2.5 1.5B** | 0.86 GB | Ultra Leve | Tarefas simples de classificação de texto em tempo real. |
| **Qwen 2.5 Coder 0.5B**| 0.32 GB | Autocomplete | Sugestões de linhas de código em tempo real (estilo Copilot). |

---

## 💡 Recomendações Específicas

### 1. Codificação (JavaScript/Web)
* **Escolha:** `qwen2.5-coder-7b`.
* **Por que:** É o modelo mais robusto da lista para entender sintaxe moderna, frameworks (React/Vue) e lógica assíncrona.
* **Alternativa Leve:** `qwen2.5-coder-1.5b` para quando você precisa de velocidade máxima e economia de bateria na NPU.

### 2. Raciocínio e Lógica (Deep Reasoning)
* **Escolha:** `deepseek-r1-7b` ou `phi-4-mini-reasoning`.
* **Por que:** O DeepSeek-R1 utiliza uma técnica de "Chain of Thought" (Cadeia de Pensamento), ideal para debugar erros de lógica difíceis ou planejar arquiteturas de software.

### 3. Uso Geral e Chat
* **Escolha:** `mistral-7b-v0.2`.
* **Por que:** Possui o melhor equilíbrio linguístico para gerar e-mails, artigos e explicações didáticas.

---

## ⚙️ Notas de Hardware (NPU)
* **Modelos de 7B (~4GB):** Requerem que sua NPU tenha acesso a uma quantidade razoável de memória RAM compartilhada. Podem apresentar lentidão se o sistema estiver sobrecarregado.
* **Modelos < 1GB:** São ideais para rodar em segundo plano sem impactar a performance do seu computador, perfeitos para extensões de IDE ou pequenos bots de automação.

---
*Relatório gerado com base nos modelos registrados: NvTensorRT, OpenVINO e CUDA Execution Providers.*