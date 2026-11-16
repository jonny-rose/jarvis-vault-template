---
status: active
project: meta
type: index
---
# VAULT INDEX

<!-- For the AI: every [FILL IN] below is filled by interviewing the person, one question at a time, in their own words. Never invent an answer. Delete this comment when no [FILL IN] is left. -->

Read this file at the start of every conversation to understand who I am, how I work, and how this vault is organized.

---

## Vault location

This vault lives at `{{VAULT_PATH}}`. If you use an AI other than Claude Code, point it at this path (in its filesystem connector) and tell it "my vault is here". An AI can't read or maintain a vault it can't find.

**This section is the single source of truth for where the vault lives.** The same path is copied into the boot config (`{{AGENT_PATH}}/CLAUDE.md`) and Claude Code's memory redirect (`MEMORY.md`). If the vault ever moves, update every copy from this section in the same pass.

---

## Who I Am

[FILL IN: name, where you live, what you do for work, and your near-term and long-term goals. A short paragraph each. The agent addresses you as "{{ADDRESS}}".]

## Key People

[FILL IN: the people who come up in your work and life, one line each: "**Name**: who they are to you."]

## How I Work

[FILL IN: how you take notes, where your ideas come from, how you like things formatted.]

- Keep notes clean and readable: no raw transcripts with timestamps. When reformatting, preserve all original meaning but improve flow and structure.
- Avoid over-engineering the vault; keep it lean and intentional.

## Projects (Projects/)

<!-- One entry per project. Format:
**Name** (`Projects/Name`): one sentence on what it is.
- **Status:** Active | Idea | Parked
-->
[FILL IN: your current projects]

<!-- area:career -->
## Career (Career/)

[FILL IN: your job or career track, one entry per area, same format as Projects.]
<!-- /area:career -->
<!-- area:company -->
## Company (Company/)

[FILL IN: your business or company, same format as Projects.]
<!-- /area:company -->
<!-- area:content -->
## Content (Content/)

[FILL IN: your content channels or brands, same format as Projects.]
<!-- /area:content -->
<!-- area:personal -->
## Personal (Personal/)

[FILL IN: life outside work that you want the agent to help with: hobbies, health, learning. Same format as Projects.]
<!-- /area:personal -->

## Vault Structure

Folders are grouped by domain, with no number prefixes (so a folder can be added or removed without renaming the rest). Sorting rule: **Projects** have a finish line; **domains** are ongoing areas of life; **Resources** is reference material; **Archive** is finished work. Create a new domain (e.g. Finance, Fitness, Community) only when it has real content.

```
Inbox                 ← Capture everything, sort later
Daily Notes           ← Dated logs, one file per day, in NN - Month YYYY subfolders
Projects              ← Work with a finish line
<!-- area:career -->
Career                ← Your job and career track
<!-- /area:career -->
<!-- area:company -->
Company               ← Your business
<!-- /area:company -->
<!-- area:content -->
Content               ← What you publish and teach
<!-- /area:content -->
<!-- area:personal -->
Personal              ← Life outside work
<!-- /area:personal -->
Resources             ← Cross-project reference: Ideas/, Research/
Archive               ← Completed projects and old notes
```

## What's Active Right Now

All open work lives in one note: [[Active Priorities]]. Tag each item with its project where it isn't obvious. Check it at the start of every conversation; verify an item's real state before acting on it (a listed item may already be done).

## My Preferences for Working with AI

How the agent talks and behaves lives in `{{AGENT_PATH}}/personality.md`. Only what that file doesn't cover goes here:

- **Recommend for my actual setup, not a generic beginner.** Weight what I already use and own.
- **Pull me back from rabbit holes.** When a tangent shows up, flag it ("that's a tangent from X: pursue or park?").
- **I drive the trust-and-access ramp.** Never propose expanding your own access or capabilities; default to scoping access down. More access comes from me, not from you.
- [FILL IN: anything else, or delete this line]

---

## How My Memory Works (for the AI)

This vault is your memory. It is external and effectively unlimited. Do not try to hold all of it at once. Hold only what the current task needs, and trust that everything else is one search away. To find something, start at this index, follow the folder indexes and wikilinks, or search. Knowing a note exists is as good as holding it, because you can retrieve it in one step.

---

## Vault Rules for AI

These rules apply to any AI that reads or writes to this vault.

### Frontmatter and Wikilinks

Every note MUST have YAML frontmatter. When you create a note, include it. When you edit an existing note that's missing or has incomplete frontmatter, fix it as part of that write. Don't stop to add frontmatter to files you're only reading. Code files are the exception: no frontmatter or wikilinks in code.

Never ask me what the frontmatter values should be. Infer them.

### Note format

Simple, legible, readable. No random emojis. Checkboxes are real Markdown checkboxes (`- [ ]` / `- [x]`). **Append before you create:** default to adding to an existing note rather than spinning up a new one. Create a new note only when nothing existing is a logical home.

```yaml
---
status: active
project: [project-slug]
type: plan
---
```

When creating or editing a note, add `[[wikilinks]]`:

**Always link:** anyone in Key People · named businesses, products, and platforms · any note this one directly references, extends, or depends on.
**Never link:** generic words just because a note shares the name · the same target twice in one note · the note's own title.

### How to Determine Each Field

**status**: default `active`. For existing notes infer from content: in progress / has unchecked items → `active`; all done → `completed`; a future "maybe" → `idea`; was active but gone quiet → `parked`; in the Archive folder → `archived`.

**project**: what the note *serves* (folder is the default, but content wins). Mapping:
- `Projects/<Name>/*` → the project's slug: its name in lowercase-with-dashes (e.g. `Projects/Home Renovation/` → `home-renovation`)
<!-- area:career -->
- `Career/*` → `career`
<!-- /area:career -->
<!-- area:company -->
- `Company/*` → `company`
<!-- /area:company -->
<!-- area:content -->
- `Content/*` → `content`
<!-- /area:content -->
<!-- area:personal -->
- `Personal/*` → `personal`
<!-- /area:personal -->
- `Daily Notes/*` → `personal`
- `Archive/*` → infer from content / original project
- `Resources/*` → `meta`
- `Inbox/*` → infer from content, else `personal`
- Folder indexes and root-level files → `meta`

**type**: what KIND of document it is (not its topic):
- `index`: a folder index / map-of-content note (or this root index)
- `reference`: a static document meant to be looked up later (specs, knowledge bases, templates, voice guides)
- `guide`: step-by-step how-to, runbook, or build instructions (Jobs are guides)
- `plan`: a strategy, phased build, or multi-step project plan (Active Priorities is a plan)
- `log`: a dated session capture or working note (daily notes are logs)

### Valid Field Values

**status:** `active` | `completed` | `parked` | `idea` | `archived`
**project:** one slug per project in Projects/, plus the domain slugs above, `personal` and `meta`. When you create a project, its slug becomes valid.
**type:** `index` | `reference` | `guide` | `plan` | `log`

### Folder Indexes (keep them in sync)

Every folder that holds substantial content (5+ notes, or a distinct area) gets an index note named after the folder: `<Folder Name>.md`, frontmatter `type: index`, listing each note in the folder with a one-line description. The index is a contract: when you create, rename, move, or materially change a note, update its folder's index in the same pass.

**When a new folder is created:** create its `<Folder Name>.md` index at the same time, add an entry to the parent folder's index, and update the **Vault Structure** map in this file in the same pass. A folder the map doesn't show is a folder no future session will look in.
<!-- module:agents -->

### Folders run by their own agent

Some folders hold their own `CLAUDE.md` and are run by a separate agent (a tutor, a coach, a project bot). Keep them on the map, but don't create, rewrite, or restructure their contents or indexes; read them only. Current list:

- [FILL IN: e.g. `Personal/Spanish`: run by my language tutor agent. Or "none yet".]

If such a folder ever moves, its agent's Claude Code memory is keyed to the folder path, so also copy `~/.claude/projects/<old-key>/memory/` to the new key.
<!-- /module:agents -->
<!-- module:jobs -->

### Jobs

A Job is a note that teaches you one recurring task, done my way. It lives in a `Jobs/` folder inside the project it serves, starts from [[Job Template]], and has a **boot chain**: the exact notes to read, in order, before doing the task. When I ask for that task, read the Job and its boot chain first, then work. When a Job's method changes, update the Job, not just the daily note.
<!-- /module:jobs -->

### Renaming and moving notes

- **Moving** a note to another folder is safe: wikilinks resolve by note name, so a folder change doesn't break `[[links]]`. Update both folders' indexes in the same pass.
- **Renaming** a note breaks the `[[links]]` pointing to it unless the rename is done **inside the Obsidian app**, whose "auto-update internal links" setting repairs them. A shell `mv` does not. So do renames in the app; if the AI must rename a file directly, it then has to find and fix every `[[old name]]` reference by hand.

### Checkpoint Persistence

Whenever something changes that a future session would need to know, persist it without being asked: update the relevant note, today's daily note, and (only for a new always-on rule) CLAUDE.md. Then scan the touched folder's index and any cross-referenced notes for drift and fix it in the same pass.

### Archiving

When I say something is done or ask to archive a note: (1) set its frontmatter `status: archived` and save; (2) move it to the Archive folder, same filename; (3) confirm what was archived and where. Always confirm before archiving. Never archive on your own initiative.

### Daily Notes

Daily notes capture what happened across all of my sessions for a day. They live in `Daily Notes/`, in month subfolders named `NN - Month YYYY` (`Daily Notes/06 - June 2026/`), filename `YYYY-MM-DD.md`. Frontmatter `status: active`, `project: personal`, `type: log`.

Start the body with a human-readable date heading (`# Monday, June 8, 2026`), then an **`## Index`** block: one bold-topic line per session with a one-sentence outcome. Then the entry body follows `Daily Notes/Daily Note Template.md`. Create every daily note FROM that template; never hand-roll one.

If today's note already exists from an earlier session, append a new session section (`## Session 2`) and add a line to the Index block; don't overwrite. Timestamp each entry with my local time.

#### Trigger 1: Wrap-Up Signal
Never ask me if I'm done working. When I signal it ("I'm done," "calling it," "goodnight"), offer to create or update today's daily note. Always check the actual current date and time first.

#### Trigger 2: Review Yesterday's Note at Start of Conversation
At the start of every conversation, after reading this index, check yesterday's daily note (or the most recent weekday if today is Monday).
- **If it doesn't exist:** create it from whatever context you have, and say it's reconstructed and may be incomplete. Zero context for that day → assume a day off and skip it. Don't create empty daily notes.
- **If it exists:** read it; if you have context it's missing, append a session section; otherwise leave it alone.

I may use several AIs across several sessions; no single one sees everything, so each contributes what it knows and the daily note fills in over time. Don't make a production of it.

### Living Profile

This file is a living document. When you learn something lasting about me, **propose** the profile update in one line and write it only after I approve. Log approved updates in the daily note under "Profile Updates."

**You can propose updates to:** Key People · How I Think · Personal Interests · Daily Routine. Add a section the first time it gets content.
**You must NOT update:** Who I Am (only I change it) · the project and domain sections · What's Active Right Now (lives in Active Priorities) · My Preferences for Working with AI · Vault Rules for AI.
**Vault Structure is a special case:** never rewrite it on your own initiative, but when a folder is actually created, renamed, or removed, updating the map is part of that change.

A passing mention is not a personality trait. Check for duplicates and contradictions; if new info contradicts an entry, update that entry rather than adding a second. Fewer, higher-quality updates.
