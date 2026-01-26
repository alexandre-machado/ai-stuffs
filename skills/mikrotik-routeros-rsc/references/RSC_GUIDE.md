# Arquivos .rsc – Export, Import e Validação

Baseado no manual RouterOS (Scripting, Jan 2026):
https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting

## Export
- `export [file=<nome>]` em qualquer menu exporta config do nível atual e submenus.
- Sem `file`, imprime no console; com `file`, grava `.rsc` em `/files`.
- Use `print as-value` para obter arrays e montar scripts dinâmicos.

## Import (raiz)
- `import <arquivo.rsc>` importa comandos gerados por `export` ou escritos à mão.
- RouterOS ≥ 7.16.x:
  - Captura de erro: `do { import test.rsc } on-error={ :put "Failure" }`.
  - Mensagem detalhada: `onerror e in={ import test.rsc } do={ :put "Failure - $e" }`.
  - `verbose=yes dry-run` encontra múltiplos erros sem alterar configuração:
    - `import test.rsc verbose=yes dry-run`.
- Em produção, sempre executar primeiro em ambiente de teste e com `dry-run`.

## Diretrizes de autoria
- Scripts devem ser idempotentes: antes de `add`/`set`, verificar existência com `find where ...`.
- Evitar hardcodes de `numbers` (IDs internos); preferir `find` por chaves/nome.
- Organizar por menus, evitar mistura de `:` global e `/path` sem necessidade.
- Comentar brevemente linhas críticas; evitar comentários extensos.
- Usar `:onerror` e `:jobname` quando aplicável.

## Riscos comuns a evitar
- Comandos destrutivos: `system reset-configuration`, formatação, remoção em massa.
- Políticas excessivas em `/system script add policy=...`.
- `import` dentro de scripts (use no terminal raiz, não dentro de `source`).
- `set`/`remove` com IDs fixos; use `find`.
- Loops com `:delay` sem limites; usar `:retry` com `max` e `delay` apropriados.

## Padrões recomendados
- Firewall: criar regras apenas se não existirem (filtrar por `chain`, `action`, `comment`).
- Endereços IP: adicionar somente se `address`/`interface` não existir.
- Scheduler/Scripts: definir `policy` mínima necessária; testar permissões (`use-script-permissions`).
- DHCP, Routes, Bridges: sempre validar antes de modificar.
