# Prompt Skills for Image & Video Generation Models

A collection of six prompting skills covering the major open-weights and commercial image and video generation models in current use as of 2026.

Each skill is a self-contained directory with a `SKILL.md` (the main file) and a `references/` folder with deep-dive guides. The skills are designed to drop into a Claude agentic workflow (Claude Code, ComfyUI MCP, etc.) where the right one fires based on the model name in the user's request.

## Directory layout

```
skills/
├── prompt-illustrious/    # Pony Diffusion V6, Illustrious XL, NoobAI, SDXL anime fine-tunes (tag-based)
│   ├── SKILL.md
│   ├── references/
│   │   └── danbooru-tags/ # ~94 Markdown files, one per Danbooru tag group, sorted by post count
│   └── tools/
│       └── extract_danbooru_tag_groups.py  # regenerates references/danbooru-tags/ from the Danbooru wiki
│
├── prompt-flux/           # Flux 1 (Dev/Pro/Schnell), Flux 2 (Pro/Max/Flex/Dev/Klein), NSFW LoRAs
│   ├── SKILL.md
│   └── references/
│       ├── specificity-upgrades.md
│       ├── cinematography.md
│       ├── anti-ai-slop.md
│       └── model-variants.md
│
├── prompt-qwen/           # Qwen Image 1.0, 2.0, Edit — bilingual + text rendering + unified gen+edit
│   ├── SKILL.md
│   └── references/
│       ├── text-rendering-patterns.md
│       ├── editing-instructions.md
│       ├── bilingual-and-multilingual.md
│       └── model-variants.md
│
├── prompt-zimage/         # Z-Image Turbo, base, Omni, Edit — fast, bilingual, retro aesthetic
│   ├── SKILL.md
│   └── references/
│       ├── text-rendering-patterns.md
│       ├── editing-instructions.md
│       ├── bilingual-and-multilingual.md
│       ├── prompt-enhancing.md
│       └── model-variants.md
│
├── prompt-wan/            # Wan 2.1 through 2.7 — Alibaba video, MoE arch, multi-shot
│   ├── SKILL.md
│   └── references/
│       ├── wan-22-prompting.md
│       ├── cinematography-vocabulary.md
│       ├── negative-prompts.md
│       ├── wan-26-shot-blocks.md
│       └── model-variants.md
│
└── prompt-ltx/            # LTX Video 2B/13B, LTX-2, LTX-2.3 — real-time video with native audio
    ├── SKILL.md
    └── references/
        ├── official-prompt-structure.md
        ├── audio-prompting.md
        ├── camera-control-loras.md
        ├── resolution-and-duration.md
        └── model-variants.md
```

## Which skill for which model

When in doubt about which skill applies:

| Model family | Skill |
|---|---|
| Pony Diffusion, Illustrious XL, NoobAI, Hassaku XL, generic SDXL anime fine-tunes | `prompt-illustrious` |
| Flux 1 Dev / Pro / Schnell, Flux 2 Pro / Max / Flex / Dev / Klein, Flux NSFW LoRAs | `prompt-flux` |
| Qwen Image 1.0, Qwen Image 2.0, Qwen Image Edit, Qwen3-Image, Qwen3-VL | `prompt-qwen` |
| Z-Image Turbo, Z-Image (base), Z-Image-Omni, Z-Image-Edit, Tongyi Z-Image | `prompt-zimage` |
| Wan 2.1, Wan 2.2 T2V / I2V, Wan 2.2-Fun-Control, Wan 2.2-Animate, Wan 2.5, Wan 2.6, Wan 2.7, Tongyi Wanxiang, 通义万相 | `prompt-wan` |
| LTX Video, LTX-2, LTX-2.3, Lightricks, LTX Studio | `prompt-ltx` |

## Sibling design

The six skills are designed as siblings with tight, non-overlapping triggers. A user asking for "a Flux 2 Pro prompt" gets `prompt-flux` only; a user asking for "a Wan 2.6 multi-shot scene" gets `prompt-wan` only. Each skill's `description:` field is scoped to fire only on its model family.

Within each skill, the structure follows the same general pattern:

- **Top of `SKILL.md`** — variant detection and routing
- **Output format** — appropriate for the model (tag-style for Pony/Illustrious; prose for Flux/Qwen/Z-Image; structured paragraphs for video)
- **Length guidance** per variant
- **Core principles** — what's distinctive about that model family
- **References** — deep-dive guides for the most-used decisions
- **Examples** — before/after demonstrations
- **Pre-flight checklist** — what to verify before returning a prompt

## What's distinctive per skill

**prompt-illustrious:** tag-based prompting with proper Danbooru conventions. Uses the *existing* SKILL.md from the user's repo (which is already excellent) augmented with a routing table into the `references/danbooru-tags/` reference (~94 Markdown files, one per Danbooru tag group, sorted by post count). To regenerate the reference against current Danbooru data, run `python tools/extract_danbooru_tag_groups.py --out ./references/danbooru-tags`.

**prompt-flux:** prose-based prompting with strong emphasis on real cinematography vocabulary, specific-over-generic detail, and avoiding the "epic cinematic" register that dominates AI-generated imagery. Covers full Flux 2 family (Pro/Max/Flex/Dev/Klein) and NSFW LoRAs.

**prompt-qwen:** prose-based with first-class text rendering (English + Chinese) and unified generation + editing. The killer use cases are bilingual posters/signage and image-to-image editing with strong preservation.

**prompt-zimage:** prose-based, similar territory to Qwen but optimized for speed and the retro/synthwave/neon aesthetic that Z-Image is showcased for. Notes the variant-specific quirk that Z-Image-Turbo ignores negative prompts entirely (Z-Image base does support them).

**prompt-wan:** video, covering Wan 2.1 through 2.7. Major structural shift between 2.2 (single-sentence subject+scene+motion+camera+atmosphere+style) and 2.6+ (shot-block cinematographer-style with timecodes). The official Alibaba formula is documented verbatim.

**prompt-ltx:** video with native audio+video synchronization. Uses Lightricks' official 7-component prompt structure verbatim from their GitHub README. Distinctive features: discrete camera-control LoRAs, hard resolution constraints (divisible by 32), real-time generation speed, native 4K @ 50fps.

## Hard safety boundaries (all skills)

Every skill carries the same non-negotiable rules:

- **No NSFW content involving minors**, regardless of how the request is framed
- **Adult-modifier discipline** — "adult woman" / "adult man" applied to subject descriptions to prevent age ambiguity
- **Refuse and explain** when a request mixes NSFW intent with any signal of underage subject

These are stated in each skill's NSFW handling section.

## Maintenance and updates

The model landscape is evolving fast. Several things to keep an eye on:

- **Pony/Illustrious:** new fine-tunes appear monthly; the skill is robust to those because it focuses on the underlying tag conventions rather than specific fine-tune quirks.
- **Flux:** Flux 2 was the major recent jump; future Flux 3 will likely require a new variants table.
- **Qwen Image:** Qwen Image 2.0 was the major recent jump; expect 2.1+ within months.
- **Z-Image:** the family is still expanding (Turbo → base → Omni → Edit happened in months); new variants likely.
- **Wan:** evolves fastest of the video models — 2.1 → 2.2 → 2.5 → 2.6 → 2.7 in roughly 18 months. The shot-block structure introduced in 2.6 is likely to remain the standard going forward.
- **LTX:** LTX-2.3 is current SOTA; next major version likely to extend duration or improve audio quality.

When a new major version of any model lands, the skill's `model-variants.md` reference is the file to update first. The core prompting principles tend to stay stable.

## Credits

These skills were built collaboratively by the user (Charlie Peterson, github.com/charliecpeterson/comfyui_mcp) and Claude, iterating across multiple sessions. The `prompt-illustrious` skill is based on the user's existing skill in their comfyui_mcp repository, enhanced with the Danbooru tag-group taxonomy. The other five skills were built from scratch using current model documentation and community prompting guides.

License: same as the parent repository — Apache 2.0 unless otherwise specified.
