#!/usr/bin/env python3
import re
import sys
from pathlib import Path

RULES = [
    (re.compile(r"(^|/)system\s+reset-configuration", re.IGNORECASE), "Destructive command forbidden: system reset-configuration"),
    (re.compile(r"((^|/)tool\s+\w*format)|((^|/)disk\s+format)", re.IGNORECASE), "Potentially destructive command: format"),
    (re.compile(r"(^|/)import\b", re.IGNORECASE), "Avoid 'import' inside script: execute at root menu"),
    (re.compile(r"(^|/)system\s+script\s+add.*policy=([^\n]*)", re.IGNORECASE), "Possibly excessive policy in /system script add"),
    (re.compile(r"(^|/)ip\s+firewall\s+filter\s+add\b", re.IGNORECASE), "'add' without idempotent guard (firewall filter)"),
    (re.compile(r"(^|/)ip\s+address\s+add\b", re.IGNORECASE), "'add' without idempotent guard (ip address)"),
    (re.compile(r"(^|/)interface\s+list\s+member\s+add\b", re.IGNORECASE), "'add' without idempotent guard (interface list member)"),
    (re.compile(r"\bset\s+\d+\b|\bremove\s+\d+\b"), "Use of fixed IDs in set/remove; prefer 'find'"),
    (re.compile(r":delay\b", re.IGNORECASE), "Use of :delay; avoid loops with delay without limits"),
    (re.compile(r"\blog\s+(info|warning|error).*\b(password|secret|token)\b", re.IGNORECASE), "Possible credential exposure in :log"),
]

SCOPED_GLOBAL = re.compile(r"\{[^}]*:global\s+", re.IGNORECASE | re.DOTALL)

HEADER = "Lint .rsc – heuristic check (RouterOS)"


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
    # local scope containing :global
    for m in SCOPED_GLOBAL.finditer(text):
        # get approximate line number
        start = text[:m.start()].count('\n') + 1
        warnings.append((start, "Use of :global inside local scope; verify external re-reference", "{ ... :global ... }"))
    return warnings


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/lint_rsc.py path/to/script.rsc")
        sys.exit(2)
    path = Path(sys.argv[1])
    if not path.exists():
        print(f"File not found: {path}")
        sys.exit(1)
    text = path.read_text(encoding='utf-8', errors='ignore')
    warnings = lint_text(text)
    print(HEADER)
    if not warnings:
        print("No warnings found.")
        return
    for ln, msg, snippet in warnings:
        print(f"L{ln}: {msg}\n    > {snippet}")


if __name__ == '__main__':
    main()
