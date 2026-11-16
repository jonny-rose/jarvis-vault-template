#!/bin/bash
# jarvis-vault-template installer: builds an AI memory vault and the agent
# folder that boots from it. Derived from ai-memory-vault by Jared Rhodenizer.
# Licensed CC BY-SA 4.0 (see LICENSE).
#
# Safe by design: it never overwrites or deletes a file. Anything that
# already exists is skipped and reported, so running it twice is harmless.
#
# Usage (every flag is optional; missing answers are asked, or defaulted with --yes):
#   ./install.sh [--name Jarvis] [--address sir] [--persona jarvis|custom]
#                [--agent ~/jarvis/agent] [--vault ~/jarvis/brain]
#                [--areas career,company,content,personal | none]
#                [--rules standard|strict] [--git none|local|push]
#                [--modules jobs,agents,connectors | none] [--yes]

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
NAME="" ADDRESS="" PERSONA="" AGENT="" VAULT="" AREAS="" RULES="" GITMODE="" MODULES="" YES=0

die() { echo "error: $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --address) ADDRESS="${2:-}"; shift 2 ;;
    --persona) PERSONA="${2:-}"; shift 2 ;;
    --agent) AGENT="${2:-}"; shift 2 ;;
    --vault) VAULT="${2:-}"; shift 2 ;;
    --areas) AREAS="${2:-}"; shift 2 ;;
    --rules) RULES="${2:-}"; shift 2 ;;
    --git) GITMODE="${2:-}"; shift 2 ;;
    --modules) MODULES="${2:-}"; shift 2 ;;
    --yes|-y) YES=1; shift ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
done

# Ask a question on the terminal, or take the default when --yes / no terminal.
ask() { # prompt default -> echoes answer
  local answer=""
  if [ "$YES" -eq 0 ] && [ -r /dev/tty ]; then
    read -r -p "$1 [$2]: " answer < /dev/tty || true
  fi
  echo "${answer:-$2}"
}

[ -n "$PERSONA" ] || PERSONA="$(ask "Persona: 'jarvis' (ready-made) or 'custom' (your own)" jarvis)"
case "$PERSONA" in jarvis|custom) ;; *) die "--persona must be jarvis or custom" ;; esac
if [ "$PERSONA" = jarvis ]; then
  [ -n "$NAME" ] || NAME="$(ask "Agent name" Jarvis)"
  [ -n "$ADDRESS" ] || ADDRESS="$(ask "How should it address you" sir)"
else
  [ -n "$NAME" ] || NAME="$(ask "Agent name" Friday)"
  [ -n "$ADDRESS" ] || ADDRESS="$(ask "How should it address you (your first name works)" boss)"
fi
SLUG="$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9\n' '-')"
[ -n "$AGENT" ] || AGENT="$(ask "Agent folder (where you run Claude Code)" "~/$SLUG/agent")"
[ -n "$VAULT" ] || VAULT="$(ask "Vault folder (your notes, opened in Obsidian)" "~/$SLUG/brain")"
[ -n "$AREAS" ] || AREAS="$(ask "Life areas, comma-separated, or 'none' (career,company,content,personal)" "career,personal")"
[ -n "$RULES" ] || RULES="$(ask "Rule set: 'standard' or 'strict'" standard)"
[ -n "$GITMODE" ] || GITMODE="$(ask "Vault backup with git: 'none', 'local' or 'push'" local)"
[ -n "$MODULES" ] || MODULES="$(ask "Extras, comma-separated, or 'none' (jobs,agents,connectors)" jobs)"

case "$RULES" in standard|strict) ;; *) die "--rules must be standard or strict" ;; esac
case "$GITMODE" in none|local|push) ;; *) die "--git must be none, local or push" ;; esac

# Expand ~ and make paths absolute.
abspath() { local p="${1/#\~/$HOME}"; case "$p" in /*) ;; *) p="$PWD/$p" ;; esac; echo "${p%/}"; }
AGENT="$(abspath "$AGENT")"
VAULT="$(abspath "$VAULT")"
[ "$AGENT" != "$VAULT" ] || die "the agent folder and the vault must be different folders"
case "$VAULT/" in "$AGENT"/*) die "keep the vault outside the agent folder (siblings work well)" ;; esac
case "$AGENT/" in "$VAULT"/*) die "keep the agent folder outside the vault (siblings work well)" ;; esac

# Which marked blocks to keep: " strict jobs career git-local ... "
KEEP=" "
[ "$RULES" = strict ] && KEEP="$KEEP strict "
[ "$GITMODE" != none ] && KEEP="$KEEP git-$GITMODE "
for a in ${AREAS//,/ }; do
  case "$a" in none) ;; career|company|content|personal) KEEP="$KEEP $a " ;; *) die "unknown area: $a" ;; esac
done
for m in ${MODULES//,/ }; do
  case "$m" in none) ;; jobs|agents|connectors) KEEP="$KEEP $m " ;; *) die "unknown extra: $m" ;; esac
done
has() { case "$KEEP" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

CREATED=() SKIPPED=()

# Copy one file: drop unselected <!-- module:x --> / <!-- area:x --> blocks,
# strip the markers of selected ones, fill the {{PLACEHOLDERS}}. Never overwrites.
render() { # src dest
  local src="$1" dest="$2"
  if [ -e "$dest" ]; then SKIPPED+=("$dest"); return; fi
  mkdir -p "$(dirname "$dest")"
  KEEP="$KEEP" V_NAME="$NAME" V_ADDRESS="$ADDRESS" V_AGENT="$AGENT" V_VAULT="$VAULT" awk '
    function lit(s, from, to,   out, i) {
      out = ""
      while ((i = index(s, from)) > 0) { out = out substr(s, 1, i - 1) to; s = substr(s, i + length(from)) }
      return out s
    }
    BEGIN { keep = ENVIRON["KEEP"]; skip = "" }
    {
      if (match($0, /^<!-- \/(module|area):[a-z-]+ -->$/)) {
        n = $0; sub(/^<!-- \/(module|area):/, "", n); sub(/ -->$/, "", n)
        if (skip == n) skip = ""
        next
      }
      if (skip != "") next
      if (match($0, /^<!-- (module|area):[a-z-]+ -->$/)) {
        n = $0; sub(/^<!-- (module|area):/, "", n); sub(/ -->$/, "", n)
        if (index(keep, " " n " ") == 0) skip = n
        next
      }
      line = $0
      line = lit(line, "{{AGENT_NAME}}", ENVIRON["V_NAME"])
      line = lit(line, "{{ADDRESS}}", ENVIRON["V_ADDRESS"])
      line = lit(line, "{{AGENT_PATH}}", ENVIRON["V_AGENT"])
      line = lit(line, "{{VAULT_PATH}}", ENVIRON["V_VAULT"])
      print line
    }' "$src" > "$dest"
  CREATED+=("$dest")
}

echo
echo "Building $NAME"
echo "  agent folder: $AGENT"
echo "  vault:        $VAULT"
echo

# The vault: core folders always, life areas only when chosen.
SRC="$HERE/vault"
while IFS= read -r -d '' f; do
  rel="${f#"$SRC"/}"
  top="${rel%%/*}"
  case "$top" in
    Career|Company|Content|Personal) has "$(echo "$top" | tr '[:upper:]' '[:lower:]')" || continue ;;
  esac
  [ "$rel" = "Resources/Job Template.md" ] && ! has jobs && continue
  render "$f" "$VAULT/$rel"
done < <(find "$SRC" -type f ! -name .DS_Store -print0)

# The agent folder: boot config, personality.
render "$HERE/agent/CLAUDE.md" "$AGENT/CLAUDE.md"
render "$HERE/agent/personality-$PERSONA.md" "$AGENT/personality.md"

# Claude Code's own memory, redirected into the vault. Its folder is named after
# the agent folder's path with every non-alphanumeric character turned into "-".
KEY="$(printf '%s' "$AGENT" | sed 's/[^A-Za-z0-9]/-/g')"
MEMDIR="$HOME/.claude/projects/$KEY/memory"
MEMORY_NOTE=""
if [ -e "$MEMDIR/MEMORY.md" ] && grep -q "There is no separate memory layer here" "$MEMDIR/MEMORY.md"; then
  MEMORY_NOTE="Claude Code's memory already points at the vault."
elif [ -e "$MEMDIR/MEMORY.md" ]; then
  MEMORY_NOTE="Claude Code already has memory for this folder ($MEMDIR). It was left alone: move what's in it into the vault first, then replace MEMORY.md with the redirect in agent/MEMORY.md (the setup wizard does this with you)."
else
  render "$HERE/agent/MEMORY.md" "$MEMDIR/MEMORY.md"
fi

# Git backup for the vault.
GIT_NOTE=""
if [ "$GITMODE" != none ]; then
  command -v git >/dev/null || die "git is not installed; install it or rerun with --git none"
  if [ ! -d "$VAULT/.git" ]; then
    git -C "$VAULT" init -q
    git -C "$VAULT" add -A
    # Use the person's own git identity; fall back to a local one only if they have none.
    IDENT=()
    git -C "$VAULT" config user.email >/dev/null 2>&1 || IDENT=(-c "user.name=$NAME" -c "user.email=vault@localhost")
    git -C "$VAULT" ${IDENT[@]+"${IDENT[@]}"} commit -qm "Initial vault" \
      && GIT_NOTE="The vault is a git repo with a first commit." \
      || GIT_NOTE="git init done, but the first commit failed; run 'git commit' in the vault."
  else
    GIT_NOTE="The vault was already a git repo; left as it was."
  fi
  if [ "$GITMODE" = push ] && ! git -C "$VAULT" remote get-url origin >/dev/null 2>&1; then
    GIT_NOTE="$GIT_NOTE Push needs a remote: create a PRIVATE repo, then run: git -C \"$VAULT\" remote add origin <its-url> && git -C \"$VAULT\" push -u origin HEAD"
  fi
fi

echo "Created ${#CREATED[@]} files."
if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "Skipped ${#SKIPPED[@]} that already existed (nothing was overwritten):"
  for s in "${SKIPPED[@]}"; do echo "  - $s"; done
fi
[ -n "$MEMORY_NOTE" ] && echo && echo "$MEMORY_NOTE"
[ -n "$GIT_NOTE" ] && echo && echo "$GIT_NOTE"
LEFT="$(grep -rl '\[FILL IN' "$VAULT" "$AGENT" 2>/dev/null | wc -l | tr -d ' ')"
cat <<EOF

Next:
  1. Open the vault in Obsidian: "Open folder as vault" -> $VAULT
  2. Start your agent:  cd "$AGENT" && claude
  3. Say: "Interview me and fill in every [FILL IN] in my vault and personality."
     (Files with [FILL IN] spots left: $LEFT.)
EOF
