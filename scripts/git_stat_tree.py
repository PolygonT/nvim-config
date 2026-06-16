#!/usr/bin/env python3
"""Render `git show --numstat --format=` (stdin) as a colored file tree.

Each input line is `<added>\t<removed>\t<path>` (counts are `-` for binary).
Output is an ANSI-colored tree with per-file +added/-removed counts; single
child directory chains are collapsed (e.g. `lua/plugins/`).
"""
import sys

DIR = "\033[38;2;127;187;179m"   # directory: teal #7fbbb3
ADD = "\033[32m"                 # +added: green
DEL = "\033[31m"                 # -removed: red
TREE = "\033[38;5;240m"          # branch glyphs: dim grey
R = "\033[0m"


def build(lines):
    root = {}
    for line in lines:
        line = line.rstrip("\n")
        if not line or "\t" not in line:
            continue
        added, removed, path = line.split("\t", 2)
        parts = path.split("/")
        node = root
        for seg in parts[:-1]:
            node = node.setdefault("dirs", {}).setdefault(seg, {})
        node.setdefault("files", {})[parts[-1]] = (added, removed)
    return root


def counts(added, removed):
    if added == "-" or removed == "-":
        return "bin"
    return "%s+%s%s %s-%s%s" % (ADD, added, R, DEL, removed, R)


def render(node, prefix=""):
    dirs = sorted(node.get("dirs", {}).items())
    files = sorted(node.get("files", {}).items())
    items = [("d", k, v) for k, v in dirs] + [("f", k, v) for k, v in files]
    for i, (kind, name, val) in enumerate(items):
        last = i == len(items) - 1
        branch = "└── " if last else "├── "
        child_prefix = prefix + ("    " if last else "│   ")
        if kind == "d":
            label, sub = name, val
            # collapse single-child directory chains into one line
            while "dirs" in sub and len(sub["dirs"]) == 1 and "files" not in sub:
                only = next(iter(sub["dirs"]))
                label += "/" + only
                sub = sub["dirs"][only]
            print("%s%s%s%s%s%s/%s" % (TREE, prefix, branch, R, DIR, label, R))
            render(sub, child_prefix)
        else:
            added, removed = val
            print("%s%s%s%s%s%s  %s" % (TREE, prefix, branch, R, name, R,
                                        counts(added, removed)))


def main():
    root = build(sys.stdin)
    render(root)


if __name__ == "__main__":
    main()
