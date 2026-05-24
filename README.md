# claude-config

Personal Claude Code configuration: global instructions, coding style,
communication preferences, engineering judgment, and skills. One repo, cloned
to every machine, symlinked into `~/.claude/` by `install.sh`.

## Layout

```
.
├── CLAUDE.md           Global instructions (imports the three files below)
├── style.md            Coding style and conduct
├── communication.md    Chat tone and format
├── engineering.md      Engineering judgment: pushback, build-vs-buy, anti-over-engineering
├── skills/             One folder per skill (each contains SKILL.md + optional references/)
├── install.sh          Symlinks files into ~/.claude/
└── .gitignore
```

`settings.json` is intentionally not synced — it can hold machine-specific
state (enabled plugins, MCP servers). Per-machine overrides go in
`~/.claude/settings.local.json`, which Claude Code reads automatically.

## Install on a new machine

```bash
git clone <repo-url> ~/projects/claude-config
cd ~/projects/claude-config
./install.sh
```

The script:
- Symlinks `~/.claude/CLAUDE.md` → `~/projects/claude-config/CLAUDE.md` (and the
  same for `style.md`, `communication.md`, `engineering.md`).
- Symlinks each skill folder under `~/.claude/skills/<name>` → the matching
  folder in this repo.
- Backs up any existing real file at the target path to
  `~/.claude/<name>.backup-YYYYMMDD-HHMMSS` before replacing it.
- Skips files that are already correctly symlinked, so the script is safe
  to re-run.

Restart Claude Code after the first install so it picks up the new skills.

## Editing

Edit files directly in this repo. The symlinks mean changes take effect
immediately in `~/.claude/`. Commit and push when you're happy; on other
machines, `git pull` and the changes propagate.

## Skills

| Skill | Purpose |
|---|---|
| `bug-hunter` | Disciplined debugging — root cause, not symptom |
| `code-review-deep` | Tool-grounded review — whole-codebase assessment by default (Continue/Refactor/Rebuild), or a deep scoped change review when you name a PR/commit (distinct from built-in `/code-review`) |
| `deep-planner` | Exhaustive one-question-at-a-time planning sessions |
| `dyslexia-friendly` | Formats all output for dyslexic-friendly reading |
| `editor` | Critique-only feedback on drafts (no rewriting) |
| `human-writer` | Generate or rewrite prose, always non-AI-sounding |
| `presentation-designer` | Slide content and narrative for decks |
| `security-review-deep` | Scanner-grounded security audit (distinct from built-in `/security-review`) |
| `session-handoff` | Cross-agent handoff document |
| `diffusion-skills/skills/*` | Prompting skills for image and video models (Flux, Qwen, Z-Image, Wan, LTX, Illustrious) |

The diffusion-skills folder is a container — each prompt-skill inside it
installs as a top-level skill in `~/.claude/skills/` (e.g., `prompt-flux`
becomes its own skill).
