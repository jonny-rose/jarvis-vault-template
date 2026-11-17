# Troubleshooting

Written for your agent to read and act on. Each entry: the symptom, the cause, the fix.

## The agent doesn't greet me, or doesn't know who I am
**Cause:** Claude Code was started in the wrong folder. It only loads `CLAUDE.md` from the folder you start it in (and the folders above it).
**Fix:** `cd` into the agent folder, then run `claude`. To check, ask the agent "which CLAUDE.md did you load?"

## The agent forgot something we decided
**Cause:** it was never written down in its proper home, or it was written only in a daily note.
**Fix:** find the decision in the daily notes and put it where it belongs: the project's note, Active Priorities, VAULT-INDEX.md, or CLAUDE.md if it must hold in every session. Daily notes are a log, not the documentation.

## Claude Code's memory and the vault disagree
**Cause:** Claude Code's own memory file isn't pointing at the vault (it was created before setup, or the agent folder moved).
**Fix:** the file is `~/.claude/projects/<key>/memory/MEMORY.md`, where `<key>` is the agent folder's full path with every non-letter, non-digit character turned into `-` (`/Users/sam/jarvis/agent` → `-Users-sam-jarvis-agent`). Move anything useful in it into the vault, then replace its contents with the redirect in `agent/MEMORY.md` from this repo, filling in both paths.

## I moved the vault or the agent folder
**Fix:** update the path everywhere it's written: the "Vault location" section of VAULT-INDEX.md, the top of CLAUDE.md, the git-commit rule in CLAUDE.md (if backups are on), and MEMORY.md. If the agent folder moved, its Claude Code memory folder key changes too: copy the old `memory/` folder to the new key.

## Links broke after a rename
**Cause:** the note was renamed outside Obsidian (in the terminal or by the agent).
**Fix:** search the vault for `[[old name]]` and replace each one with `[[new name]]`. To prevent it, rename inside Obsidian with **Settings → Files and links → Automatically update internal links** on (the template turns it on).

## New daily notes land in the wrong folder or don't use the template
**Fix:** check `.obsidian/daily-notes.json` in the vault: folder `Daily Notes`, format `MM - MMMM YYYY/YYYY-MM-DD`, template `Daily Notes/Daily Note Template`. The agent follows the same rule from CLAUDE.md.

## A folder shows up in Obsidian but the agent never looks in it
**Cause:** it isn't on the map.
**Fix:** give the folder an index note named after it, list it in the parent folder's index, and add it to the Vault Structure map in VAULT-INDEX.md.

## `install.sh` says it skipped files
That's the safety rule working: it never overwrites. If you want the template version of a skipped file, rename yours first (e.g. `CLAUDE.old.md`), run the installer again, then merge the two by hand or ask the agent to.

## I want to add a life area or extra after setup
Re-running `install.sh` adds a new area's folder and index, but it won't edit your existing CLAUDE.md or VAULT-INDEX.md. Ask your agent to copy the matching block from this repo's `agent/CLAUDE.md` or `vault/VAULT-INDEX.md` (between the `<!-- module:… -->` or `<!-- area:… -->` markers) into your files.

## A migration stopped halfway
**Fix:** open `Inbox/Migration log.md` in the new vault: it has the approved folder mapping and which folders are done. Carry on from the first folder not ticked off. Copying uses `--ignore-existing`, so re-copying a folder that's half done is safe. When finished, run `python3 tools/vault-check.py <new> --compare <old>`.

## After a migration, a link opens the wrong note
**Cause:** two notes share a name, and Obsidian resolves `[[Name]]` by name alone.
**Fix:** `python3 tools/vault-check.py <vault>` lists every name used twice. Rename one copy (inside Obsidian, so its links update) or make the link a path, `[[Folder/Name]]`.

## git push fails
**Cause:** usually no remote, or no permission to push to it.
**Fix:** `git -C <vault> remote -v` shows the remote. If it's missing, create a **private** repo on your git host, then `git -C <vault> remote add origin <url>` and `git -C <vault> push -u origin HEAD`. Never make a vault repo public: it is your memory.
