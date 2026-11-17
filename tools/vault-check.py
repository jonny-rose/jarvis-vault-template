#!/usr/bin/env python3
"""vault-check: a read-only health report for a Markdown / Obsidian vault.

Used to survey a vault before adopting or migrating it, and to verify a
migration afterwards. It never changes a file.

    python3 tools/vault-check.py <vault>                  survey one vault
    python3 tools/vault-check.py <new-vault> --compare <old-vault>
                                                         also check the migration: every note
                                                         and attachment of the old vault is in
                                                         the new one (matched by file name), and
                                                         no link that worked before is broken now

Reports: notes and attachments per top-level folder, notes without
frontmatter, note names used more than once (ambiguous [[links]]), links to
notes that don't exist, and top-level folders without an index note.
Exit code 1 only when --compare finds a missing file or a newly broken link.

Part of jarvis-vault-template. Licensed CC BY-SA 4.0 (see LICENSE).
"""
import argparse
import os
import re
import sys
from collections import Counter, defaultdict

SKIP_DIRS = {".git", ".obsidian", ".trash", "node_modules"}
JUNK = {".DS_Store", "Thumbs.db", "desktop.ini", "Desktop.ini"}
LINK = re.compile(r"!?\[\[([^\]\|#\^]*)(?:[#\^][^\]\|]*)?(?:\|[^\]]*)?\]\]")
FENCE = re.compile(r"```.*?```", re.S)
INLINE = re.compile(r"`[^`\n]*`")


def walk(root):
    """Yield (relative path, absolute path) for every real file in the vault."""
    for d, dirs, files in os.walk(root):
        dirs[:] = sorted(x for x in dirs if x not in SKIP_DIRS and not x.startswith("."))
        for f in sorted(files):
            if f in JUNK or f.startswith("."):
                continue
            full = os.path.join(d, f)
            yield os.path.relpath(full, root), full


def read(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.read()


def survey(root):
    notes, attachments = [], []
    for rel, full in walk(root):
        (notes if rel.lower().endswith(".md") else attachments).append((rel, full))
    return notes, attachments


def stem(rel):
    return os.path.splitext(os.path.basename(rel))[0].lower()


def top(rel):
    return rel.split(os.sep)[0] if os.sep in rel else "(vault root)"


def broken_links(notes, attachments):
    """Links whose target exists nowhere in the vault, as (note path, target).

    Obsidian resolves [[Name]] by file name anywhere in the vault, and
    [[Folder/Name]] by path suffix. Links inside code are not links. Template
    notes hold placeholder links on purpose, so they're skipped.
    """
    stems = {stem(r) for r, _ in notes}
    files = {os.path.basename(r).lower() for r, _ in attachments}
    paths = {os.path.splitext(r)[0].lower().replace(os.sep, "/") for r, _ in notes}
    paths |= {r.lower().replace(os.sep, "/") for r, _ in attachments}
    broken = []
    for rel, full in notes:
        if "template" in os.path.basename(rel).lower():
            continue
        text = INLINE.sub("", FENCE.sub("", read(full)))
        for target in LINK.findall(text):
            t = target.strip().lower().replace("\\", "/")
            if not t:
                continue  # [[#heading]]: a link inside the same note
            if t.endswith(".md"):
                t = t[:-3]
            base = t.rsplit("/", 1)[-1]
            if base in stems or base in files or any(p == t or p.endswith("/" + t) for p in paths):
                continue
            broken.append((rel, target.strip()))
    return broken


def show(items, limit, fmt):
    for item in items[:limit]:
        print(fmt(item))
    if len(items) > limit:
        print(f"  ... and {len(items) - limit} more")


def report(root):
    notes, attachments = survey(root)
    print(f"Vault: {root}")
    print(f"  {len(notes)} notes, {len(attachments)} attachments\n")

    per = defaultdict(lambda: [0, 0])
    for rel, _ in notes:
        per[top(rel)][0] += 1
    for rel, _ in attachments:
        per[top(rel)][1] += 1
    print("Top-level folders (notes / attachments):")
    for name in sorted(per):
        print(f"  {name}: {per[name][0]} / {per[name][1]}")

    counts = Counter(stem(r) for r, _ in notes)
    dupes = sorted(s for s, n in counts.items() if n > 1)
    if dupes:
        print(f"\nNote names used more than once ({len(dupes)}): [[links]] to them are ambiguous")
        show(dupes, 25, lambda s: f"  {s}: " + " | ".join(r for r, _ in notes if stem(r) == s))

    no_fm = [r for r, f in notes if not read(f).startswith("---")]
    if no_fm:
        print(f"\nNotes without frontmatter: {len(no_fm)}")
        show(no_fm, 15, lambda r: f"  {r}")

    broken = broken_links(notes, attachments)
    if broken:
        print(f"\nLinks to notes that don't exist: {len(broken)}")
        print("  (Often deliberate: Obsidian lets you link a name before its note exists.)")
        show(broken, 25, lambda b: f"  {b[0]} -> [[{b[1]}]]")

    missing_index = sorted(
        name for name in per
        if name != "(vault root)" and per[name][0]
        and not os.path.exists(os.path.join(root, name, name + ".md"))
    )
    if missing_index:
        print("\nTop-level folders without an index note (<Folder>/<Folder>.md):")
        show(missing_index, 50, lambda n: f"  {n}")

    if not (dupes or no_fm or broken or missing_index):
        print("\nNo issues found.")
    return notes, attachments, broken


def compare(old_root, new_notes, new_atts, new_broken):
    old_notes, old_atts = survey(old_root)
    print(f"\nMigration check against {old_root}:")
    print(f"  old: {len(old_notes)} notes, {len(old_atts)} attachments")
    print(f"  new: {len(new_notes)} notes, {len(new_atts)} attachments")
    problems = 0

    have = Counter(os.path.basename(r).lower() for r, _ in new_notes + new_atts)
    need = Counter(os.path.basename(r).lower() for r, _ in old_notes + old_atts)
    short = sorted(n for n in need if have[n] < need[n])
    if short:
        problems = 1
        print(f"  Missing from the new vault ({len(short)} file names):")
        def line(n):
            where = " | ".join(r for r, _ in old_notes + old_atts if os.path.basename(r).lower() == n)
            return f"    {n}: {need[n]} in old, {have[n]} in new  ({where})"
        show(short, 40, line)
    else:
        print("  Every note and attachment from the old vault is in the new one.")

    # A link is "newly broken" if the same note had the same link working in the old vault.
    was_broken = Counter((os.path.basename(r).lower(), t.lower()) for r, t in broken_links(old_notes, old_atts))
    now_broken = Counter((os.path.basename(r).lower(), t.lower()) for r, t in new_broken)
    newly = [(r, t) for r, t in new_broken if now_broken[(os.path.basename(r).lower(), t.lower())]
             > was_broken[(os.path.basename(r).lower(), t.lower())]]
    if newly:
        problems = 1
        print(f"  Links that worked in the old vault and are broken now ({len(newly)}):")
        show(newly, 40, lambda b: f"    {b[0]} -> [[{b[1]}]]")
    else:
        print("  No link that worked in the old vault is broken in the new one.")
    return problems


def main():
    ap = argparse.ArgumentParser(description="Read-only health report for a Markdown vault.")
    ap.add_argument("vault")
    ap.add_argument("--compare", metavar="OLD_VAULT", help="verify a migration from OLD_VAULT into VAULT")
    a = ap.parse_args()
    for p in [a.vault] + ([a.compare] if a.compare else []):
        if not os.path.isdir(p):
            sys.exit(f"error: {p} is not a folder")
    notes, atts, broken = report(os.path.abspath(a.vault))
    problems = compare(os.path.abspath(a.compare), notes, atts, broken) if a.compare else 0
    sys.exit(problems)


if __name__ == "__main__":
    main()
