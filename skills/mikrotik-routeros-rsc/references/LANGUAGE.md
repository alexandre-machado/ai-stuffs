# RouterOS Scripting – Linguagem e Sintaxe

Referência concisa baseada no manual oficial (atualizado Jan 2026):
https://help.mikrotik.com/docs/spaces/ROS/pages/47579229/Scripting

## Conceitos
- Linha lógica termina em `;` ou `NEWLINE`; dentro de `()`, `[]`, `{}` não precisa `;`.
- Comentário: começa com `#` até fim da linha; não há multi-linha.
- Junção de linhas com `\` seguindo regras (não continua comentário/token exceto string).
- Escopos: global (raiz) e local `{}`; evite `:global` dentro de escopos locais sem re-referência externa.
- Palavras-chave: `and`, `or`, `in`. Delimitadores: `() [] {} : ; $ /`.

## Tipos
- `num`, `bool`, `str`, `ip`, `ip-prefix`, `ip6`, `ip6-prefix`, `id`, `time`, `array`, `nil`.
- Conversões: `:tonum`, `:tostr`, `:toarray`, `:toip`, `:toid`, `:totime`, etc.

## Operadores
- Aritméticos: `+ - * / %`. Use parênteses para evitar ambiguidade com IP.
- Relacionais: `< > = <= >= !=`. Negação por `expr=false` ou `!` lógico.
- Lógicos: `! && || and or in`.
- Bitwise (IP/IPv6): `~ | ^ & << >>` (sem shift p/ IPv6).
- Concatenação: `.` para strings, `,` para arrays. Interpolação com `$var`, `$()`, `$[]`.
- Outros: `[]` substituição de comando, `()` agrupamento, `$` substituição, `~` regex POSIX.

## Variáveis
- `:global` e `:local` obrigam declaração antes do uso.
- Evite nomes reservados (propriedades embutidas de menus). Preferir nomes customizados.
- Case-sensitive; nomes inválidos devem ser entre aspas.

## Comandos globais úteis
- `:onerror e in={ ... } do={ ... }` captura erros; `:retry` para retentativa.
- `:jobname` para limitar execução a instância única.
- `:serialize`/`:deserialize` para JSON/DSV; `file-name` para gerar arquivo.
- `:time`, `:timestamp`, `:rndnum`, `:rndstr` utilitários.

## Comandos de menu
- `add`, `remove`, `enable`, `disable`, `set`, `get`, `print`, `find`, `export`, `edit`.
- `print` parâmetros: `as-value`, `where`, `count-only`, `file`, `follow`, `interval`, etc.
- `import` (raiz): desde 7.16.x suporta `onerror` e `verbose=yes dry-run`.

## Estruturas de controle
- Loops: `:for`, `:foreach`, `:do { ... } while=()` e `:while do={}`.
- Condicional: `:if (cond) do={...} else={...}`.

## Funções
- Não há funções nativas; use `:global myFunc do={...}` ou `:parse` para definir e invocar; `:return` para retorno.

## Arrays
- Chaves não alfanuméricas devem ser entre aspas; `:foreach k,v in={...}` para iterar.

