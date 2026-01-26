# Boas Práticas: Segurança e Idempotência

Fontes principais:
- Manual Scripting (Jan 2026): https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting
- Scripting Tips & Tricks: https://help.mikrotik.com/docs/spaces/ROS/pages/283574370/Scripting+Tips+and+Tricks

## Idempotência
- Antes de `add`/`set`, verifique com `find where ...` e condicional `:if`.
- Use `print as-value` e arrays para comparar estados.
- Evite depender de `numbers`; selecione por `name`, `address`, `comment`, etc.

## Permissões
- Scripts herdam permissões do usuário/scheduler a depender da execução.
- `use-script-permissions` só funciona quando permissões do script são suficientes.
- Não conceda políticas desnecessárias em `/system script add policy=...`.

## Robustez
- `:onerror` para capturar falhas; combine com `:retry` para retentativas controladas.
- Limite instâncias múltiplas com `:jobname`.
- Evite `:delay` em loops sem limites; use `Scheduler` para tarefas periódicas.

## Segurança
- Não automatizar comandos destrutivos (`system reset-configuration`, formatação, wipe).
- Evitar exfiltração acidental (`/export hide-sensitive=no` em ambientes sensíveis).
- Trate segredos com cuidado; não registrar senhas em `:log`.
- Validar entradas antes de `fetch` e similares.

## Estilo
- Parametrizar com `:local` no topo; somar `:global` apenas quando necessário.
- Comentários curtos e objetivos; sem blocos longos.
- Usar `where` e expressões claras; alinhamento consistente.
