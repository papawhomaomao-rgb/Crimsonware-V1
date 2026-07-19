#!/usr/bin/env python3
"""
Crimsonware static checks — catch the crash class that keeps biting after forks.

  1. Syntax     every .lua parses under the real Luau grammar.        (hard fail)
  2. Libraries  every `vape.Libraries.X` used is registered somewhere. (hard fail)
  3. Modules    every `vape.Modules.X` used resolves to a real module
                (that game file's modules + the universal ones).       (hard fail)

The bugs this would have caught before they shipped:
  - vape.Libraries.calculatePosition  (Killaura dealt no damage, loop died)
  - vape.Libraries.string             (Whisper/Owl Aura crashed on fire)
  - vape.Modules['Silent Aura']       (Auto Shoot crashed on fire)

References that are intentionally optional (guarded with `and`) go in
OPTIONAL_MODULE_REFS so they don't fail the build.

Run locally:  python3 tools/luau_check.py
Deps:         pip install tree-sitter tree_sitter_luau
"""
import glob
import sys

try:
    import tree_sitter_luau
    from tree_sitter import Language, Parser
except ImportError:
    sys.exit("missing deps — run: pip install tree-sitter tree_sitter_luau")

LANG = Language(tree_sitter_luau.language())
PARSER = Parser(LANG)

# vape.Modules refs that are deliberately optional (nil-guarded in code because
# the module may not exist in a given build). Keep this list short and honest.
OPTIONAL_MODULE_REFS = {"Silent Aura"}


def walk(node, cb):
    cb(node)
    for c in node.children:
        walk(c, cb)


def strval(node):
    if node is not None and node.type == "string":
        return node.text.decode().strip("'\"[]")
    return None


def index_object(node):
    """Text of the thing being indexed, e.g. `vape.Modules` in `vape.Modules.Fly`."""
    return node.children[0].text.decode() if node.children else ""


def dot_property(node):
    """Trailing identifier of a dot_index_expression, e.g. `Fly`."""
    return node.children[-1].text.decode()


def bracket_key(node):
    """String key of a bracket_index_expression, e.g. `Silent Aura`; None if not a literal."""
    for c in node.children:
        if c.type == "string":
            return strval(c)
    return None


def main():
    files = sorted(glob.glob("**/*.lua", recursive=True))
    if not files:
        sys.exit("no .lua files found — run from the repo root")

    trees = {f: PARSER.parse(open(f, "rb").read()) for f in files}
    failures = []

    # ---- 1. syntax ------------------------------------------------------
    for f, t in trees.items():
        if t.root_node.has_error:
            loc = [None]

            def find(n):
                if loc[0]:
                    return
                if n.type == "ERROR" or n.is_missing:
                    loc[0] = n.start_point[0] + 1
                else:
                    for c in n.children:
                        find(c)

            find(t.root_node)
            failures.append(f"[syntax]  {f}:{loc[0]}  does not parse")

    # ---- gather library registrations + every `Name = '...'` -----------
    lib_registered = set()
    name_fields = {}  # file -> set of Name string literals (superset of module names)

    for f, t in trees.items():
        names = set()

        def cb(n):
            if n.type == "assignment_statement":
                varlist = next((c for c in n.children if c.type == "variable_list"), None)
                exprlist = next((c for c in n.children if c.type == "expression_list"), None)
                if varlist:
                    for v in varlist.children:
                        if v.type != "dot_index_expression":
                            continue
                        if index_object(v).endswith(".Libraries"):        # X.Libraries.Y = ...
                            lib_registered.add(dot_property(v))
                        elif dot_property(v) == "Libraries" and exprlist:  # X.Libraries = {..}
                            for e in exprlist.children:
                                if e.type == "table_constructor":
                                    for fld in e.children:
                                        if fld.type == "field" and fld.children and fld.children[0].type == "identifier":
                                            lib_registered.add(fld.children[0].text.decode())
            if n.type == "field" and len(n.children) >= 2 and \
               n.children[0].type == "identifier" and n.children[0].text.decode() == "Name":
                s = strval(n.children[-1])
                if s:
                    names.add(s)

        walk(t.root_node, cb)
        name_fields[f] = names

    universal_names = name_fields.get("games/universal.lua", set())

    # ---- 2. Libraries: used but never registered ------------------------
    lib_used = {}  # name -> "file:line"
    for f, t in trees.items():
        def cb(n, f=f):
            if n.type == "dot_index_expression" and index_object(n).endswith(".Libraries"):
                lib_used.setdefault(dot_property(n), f"{f}:{n.start_point[0]+1}")
        walk(t.root_node, cb)

    for key, where in sorted(lib_used.items()):
        if key not in lib_registered:
            failures.append(f"[library] {where}  vape.Libraries.{key} is never registered")

    # ---- 3. Modules: `vape.Modules.X` that resolves to no module --------
    for f, t in trees.items():
        if not f.startswith("games/") or f == "games/universal.lua":
            continue
        known = name_fields.get(f, set()) | universal_names
        found = []

        def cb(n, found=found):
            if index_object(n) != "vape.Modules":
                return
            if n.type == "dot_index_expression":
                found.append((dot_property(n), n.start_point[0] + 1))
            elif n.type == "bracket_index_expression":
                k = bracket_key(n)
                if k is not None:
                    found.append((k, n.start_point[0] + 1))

        walk(t.root_node, cb)
        for key, line in found:
            if key in known or key in OPTIONAL_MODULE_REFS:
                continue
            failures.append(f"[module]  {f}:{line}  vape.Modules['{key}'] resolves to no module")

    # ---- report ---------------------------------------------------------
    print(f"checked {len(files)} lua files  ·  libs registered {len(lib_registered)} / referenced {len(lib_used)}")
    if failures:
        print(f"\n{len(failures)} problem(s):\n")
        for msg in failures:
            print("  " + msg)
        sys.exit(1)
    print("all checks passed ✓")


if __name__ == "__main__":
    main()
