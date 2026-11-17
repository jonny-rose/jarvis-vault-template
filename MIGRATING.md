# Already have a vault?

You have three options. The guided setup (`claude "set me up"`) does all of this with you and is the easiest way. This page is the same process as a checklist, for anyone who'd rather do it by hand or wants to know what the agent will do.

First, take stock. This is read-only and changes nothing:

```bash
python3 tools/vault-check.py ~/path/to/your-vault
```

It lists your folders and how many notes and attachments each holds. It also flags notes that share a name, notes without frontmatter, links to notes that don't exist, and folders without an index.

| | **Adopt** | **Migrate** | **Start fresh** |
|---|---|---|---|
| Your folders | stay exactly as they are | copied into this template's structure | stay where they are, unused |
| Your notes | untouched | copied, never moved; frontmatter added | untouched |
| Time | minutes | about an hour per few hundred notes, with the agent doing the work | minutes |
| Pick it when | you like your structure, the vault is large, or you're unsure | your structure stopped working, or you want the full system from day one | you want a clean break |

Not sure? **Adopt.** It changes nothing of yours, and you can still migrate later.

---

## Adopt: keep your structure

1. Install pointing at your vault:
   ```bash
   ./install.sh --adopt --vault ~/path/to/your-vault
   ```
   This adds `VAULT-INDEX.md`, `Active Priorities.md`, `Daily Notes/Daily Note Template.md` (plus `Job Template.md` if you choose Jobs) and the agent folder. It doesn't add any of the template's folders, and it doesn't touch your notes or your Obsidian settings.
2. Rewrite the **Vault Structure** map in `VAULT-INDEX.md` to list your own top-level folders, and the `project` mapping under "How to Determine Each Field" to match them.
3. Already keep daily notes? Move `Daily Note Template.md` into your daily folder, remove the `Daily Notes.md` index the installer added, and change the daily-notes path and format in `CLAUDE.md` and `VAULT-INDEX.md` to yours.
4. Give each top-level folder an index note, `<Folder>/<Folder>.md`, listing what's in it.
5. Leave frontmatter alone. The agent adds it to each note the first time it edits that note.
6. In Obsidian, turn on **Settings → Files and links → Automatically update internal links**.
7. Fill in every `[FILL IN]` in `VAULT-INDEX.md`, or have your agent interview you for it.

## Migrate: move into the template's structure

The golden rule: **copy, never move.** Your old vault stays untouched until you decide what to do with it.

1. **Back up.** If the old vault isn't in git, zip it first.
2. **Install a new vault** in a new folder (not inside the old one): `./install.sh --vault ~/path/to/new-vault`
3. **Map your folders.** Write down where each of your top-level folders goes:
   - projects with a finish line → `Projects/<Name>/`
   - ongoing areas → `Career/`, `Company/`, `Content/`, `Personal/`
   - reference and ideas → `Resources/`
   - finished work → `Archive/`
   - loose captures → `Inbox/`
   - daily notes → `Daily Notes/NN - Month YYYY/`
   - attachments → `Resources/Attachments/`

   Keep the table in `Inbox/Migration log.md` and tick folders off as you go.
4. **Rename duplicates first.** For each note name that `vault-check` listed twice, rename one copy and update the links that pointed at it. Obsidian resolves `[[links]]` by name, so two notes with one name can quietly link to the wrong one.
5. **Copy one folder at a time**, keeping file names:
   ```bash
   rsync -a --ignore-existing ~/old-vault/"03 - Ideas"/ ~/new-vault/Resources/Ideas/
   ```
   Don't copy `.obsidian`, `.git` or `.trash`. If you use community plugins, copy `.obsidian/plugins/` and `community-plugins.json` only.
6. **After each folder:** add frontmatter (`status`, `project`, `type`; keep any fields a note already has), create the folder's index note, and update the Vault Structure map if the folder is new.
7. **Verify:**
   ```bash
   python3 tools/vault-check.py ~/new-vault --compare ~/old-vault
   ```
   It checks that every note and attachment arrived (matched by file name) and that no link that worked before is broken now. Notes you renamed in step 4 show up as missing; everything else listed needs fixing.
8. **Switch over.** Open the new vault in Obsidian and fill in `VAULT-INDEX.md`. Move the migration log to `Archive/`. Keep the old vault until you're confident, then delete it yourself.

## Already using Claude Code with its own memory?

Claude Code keeps a memory file per working folder, at `~/.claude/projects/<key>/memory/MEMORY.md`. Before the installer points that at your vault, move what's in it into the vault (profile facts into `VAULT-INDEX.md`, open work into Active Priorities, the rest into the notes they belong to). The installer leaves an existing memory alone and tells you; the guided setup walks you through it.
