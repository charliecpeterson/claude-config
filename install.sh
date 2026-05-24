#!/usr/bin/env bash
# Symlink this repo's Claude Code config files into ~/.claude/ so the same
# CLAUDE.md, style.md, communication.md, and skills are active wherever the
# repo is cloned. Existing files (not already symlinks pointing into this
# repo) are backed up to ~/.claude/<name>.backup-YYYYMMDD-HHMMSS first.
#
# Re-runnable. Skips files that are already correctly symlinked.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/skills"

link_file() {
  local src="$1" dest="$2"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      echo "  ok       $dest -> $src"
      return
    fi
    echo "  relink   $dest (was: $current)"
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    local backup="${dest}.backup-${STAMP}"
    echo "  backup   $dest -> $backup"
    mv "$dest" "$backup"
  else
    echo "  new      $dest"
  fi

  ln -s "$src" "$dest"
}

echo "Installing from: $REPO_DIR"
echo "Target:          $CLAUDE_DIR"
echo

echo "Global config files:"
for name in CLAUDE.md style.md communication.md; do
  if [[ -f "$REPO_DIR/$name" ]]; then
    link_file "$REPO_DIR/$name" "$CLAUDE_DIR/$name"
  fi
done

echo
echo "Skills:"
for skill_dir in "$REPO_DIR/skills"/*/; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"

  # Only treat as a skill if it contains a SKILL.md (skips containers like diffusion-skills/)
  if [[ -f "$skill_dir/SKILL.md" ]]; then
    link_file "${skill_dir%/}" "$CLAUDE_DIR/skills/$skill_name"
  fi
done

# Diffusion skills live one level deeper: skills/diffusion-skills/skills/<name>/
if [[ -d "$REPO_DIR/skills/diffusion-skills/skills" ]]; then
  echo
  echo "Diffusion skills:"
  for skill_dir in "$REPO_DIR/skills/diffusion-skills/skills"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    if [[ -f "$skill_dir/SKILL.md" ]]; then
      link_file "${skill_dir%/}" "$CLAUDE_DIR/skills/$skill_name"
    fi
  done
fi

echo
echo "Done. Restart Claude Code if it was running, so it picks up the new skills."
