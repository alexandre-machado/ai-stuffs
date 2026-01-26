#!/usr/bin/env python3
import re
import sys
from pathlib import Path

RULES = [
    (re.compile(r"(^|/)system\s+reset-configuration", re.IGNORECASE), "Comando destrutivo proibido: system reset-configuration"),
    (re.compile(r"((^|/)tool\s+\w*format)|((^|/)disk\s+format)", re.IGNORECASE), "Comando potencialmente destrutivo: format"),
    (re.compile(r"(^|/)import\b", re.IGNORECASE), "Evite 'import' dentro do script: execute no menu raiz"),
    (re.compile(r"(^|/)system\s+script\s+add.*policy=([^\n]*)", re.IGNORECASE), "Política possivelmente excessiva em /system script add"),
    (re.compile(r"(^|/)ip\s+firewall\s+filter\s+add\b", re.IGNORECASE), "'add' sem guarda idempotente (firewall filter)"),
    (re.compile(r"(^|/)ip\s+address\s+add\b", re.IGNORECASE), "'add' sem guarda idempotente (ip address)"),
    (re.compile(r"(^|/)interface\s+list\s+member\s+add\b", re.IGNORECASE), "'add' sem guarda idempotente (interface list member)"),
    (re.compile(r"\bset\s+\d+\b|\bremove\s+\d+\b"), "Uso de IDs fixos em set/remove; prefira 'find'"),
    (re.compile(r":delay\b", re.IGNORECASE), "Uso de :delay; evite loops com delay sem limites"),
    (re.compile(r"\blog\s+(info|warning|error).*\b(password|secret|token)\b", re.IGNORECASE), "Possível exposição de segredo em :log"),
]

SCOPED_GLOBAL = re.compile(r"\{[^}]*:global\s+", re.IGNORECASE | re.DOTALL)

HEADER = "Lint .rsc – verificação heurística (RouterOS)"


def lint_text(text: str):
    warnings = []
    lines = text.splitlines()
    for i, line in enumerate(lines, start=1):
        l = line.strip()
        if not l or l.startswith('#'):
            continue
        for rx, msg in RULES:
            if rx.search(l):
                warnings.append((i, msg, l))
    # escopo local contendo :global
    for m in SCOPED_GLOBAL.finditer(text):
        # obter número de linha aproximado
        start = text[:m.start()].count('\n') + 1
        warnings.append((start, "Uso de :global dentro de escopo local; verifique re-referência externa", "{ ... :global ... }"))
    return warnings


def main():
    if len(sys.argv) < 2:
        print("Uso: python scripts/lint_rsc.py caminho/do/script.rsc")
        sys.exit(2)
    path = Path(sys.argv[1])
    if not path.exists():
        print(f"Arquivo não encontrado: {path}")
        sys.exit(1)
    text = path.read_text(encoding='utf-8', errors='ignore')
    warnings = lint_text(text)
    print(HEADER)
    if not warnings:
        print("Nenhum aviso encontrado.")
        return
    for ln, msg, snippet in warnings:
        print(f"L{ln}: {msg}\n    > {snippet}")


if __name__ == '__main__':
    main()
