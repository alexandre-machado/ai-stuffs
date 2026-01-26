# Regras do Linter (.rsc)

O linter aplica verificações estáticas básicas de segurança e idempotência.

## Regras
- Proibir comandos destrutivos: `system reset-configuration`, formatação, wipe.
- Alertar `import` dentro de script (deve ser usado no terminal raiz).
- Alertar políticas excessivas em `/system script add policy=...` (preferir mínimo necessário).
- Alertar `add` sem guarda (`find where ...` + `:if`), para menus comuns (IP/Firewall/etc.).
- Alertar `set`/`remove` referindo `numbers` (IDs fixos) ao invés de `find`.
- Alertar uso de `:delay` em loops sem limites.
- Alertar `:global` dentro de escopos locais sem re-referência externa.
- Alertar `log` com termos como `password`, `secret`, `token`.

## Limitações
- Análise é por linha; não compreende todo fluxo nem estado do roteador.
- Regras são heurísticas; exigem revisão humana.

## Uso
- `python scripts/lint_rsc.py caminho/do/script.rsc`
- Saída: avisos com número de linha e regra.
