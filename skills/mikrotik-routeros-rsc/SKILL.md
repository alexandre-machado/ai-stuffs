---
name: mikrotik-routeros-rsc
description: "Criação, edição e revisão de scripts RouterOS (.rsc) com foco em idempotência, segurança e boas práticas. Use quando for necessário gerar, ajustar ou importar arquivos .rsc para MikroTik: (1) criar novas configurações via script, (2) editar scripts existentes com correções seguras, (3) revisar riscos e políticas de execução, (4) validar com import dry-run e captura de erros."
---

# Skill: RouterOS .rsc

Esta skill orienta a criação, edição e revisão de scripts RouterOS (.rsc) com padrões seguros e idempotentes, além de validação antes da importação.

## Fluxo rápido

1. Defina objetivo e escopo do script.
2. Aplique padrões idempotentes (ver Referências).
3. Valide sintaxe e riscos com o linter (scripts/lint_rsc.py).
4. Teste import com `dry-run` e `on-error`.
5. Importe de forma controlada em produção.

## Práticas essenciais

- Preferir `find where ...` + condicionais antes de `add`/`set`.
- Evitar políticas amplas em `/system script add policy=...`.
- Usar `:onerror` e `:jobname` para robustez e instância única.
- Nunca incluir comandos destrutivos (`system reset-configuration`, etc.).
- Parametrizar e isolar escopos (`:local` vs `:global`).

## Validação e teste

- Lint: `python scripts/lint_rsc.py caminho/do/script.rsc`.
- Import seguro (RouterOS ≥ 7.16.x):
  - `import test.rsc verbose=yes dry-run` para encontrar múltiplos erros sem aplicar mudanças.
  - `do { import test.rsc } on-error={ :put "Failure" }` para capturar erro.
  - `onerror e in={ import test.rsc } do={ :put "Failure - $e" }` para mensagem detalhada.

## Referências (usar conforme necessário)

- Linguagem e sintaxe: ver references/LANGUAGE.md
- .rsc export/import, `dry-run` e `onerror`: ver references/RSC_GUIDE.md
- Boas práticas de segurança e idempotência: ver references/SAFE_PRACTICES.md
- Exemplos comuns e padrões: ver references/EXAMPLES.md
- Regras do linter: ver references/LINTER_RULES.md

## Observações

- Scripts devem ser consistentes com RouterOS v7 (preferencial) e compatíveis com v6 onde possível.
- Utilize `print as-value`, arrays e filtros `where` para consultas robustas.
- Para execução programada, use Scheduler com permissões adequadas.
