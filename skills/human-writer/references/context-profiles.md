# Context Profiles — Tolerance Matrix

Different formats tolerate different patterns. The main `SKILL.md` covers the
rules that always apply. This file is the full per-context tolerance matrix
plus auto-detection cues. Open it when the user specifies a context (or you
need to infer one) and you're unsure how strict to be.

---

## Profiles

- **`linkedin`** — Short-form social. Punchy fragments and visual formatting
  carry weight.
- **`blog`** — Default. Standard long-form prose. All rules at full strength.
- **`technical-blog`** — Long-form with code, architecture, APIs. Technical
  terms get a pass.
- **`investor-email`** — High-trust audience. Tighten everything; promotional
  language is the biggest risk.
- **`docs`** — Documentation, READMEs, guides. Clarity over voice.
- **`casual`** — Slack messages, internal notes, quick replies. Only catch
  the worst offenders.

---

## Tolerance matrix

Rules not listed apply at full strength across all profiles.

| Rule | linkedin | blog | technical-blog | investor-email | docs | casual |
|------|----------|------|----------------|----------------|------|--------|
| Em dashes | relaxed (2/post OK) | strict | strict | strict | relaxed | skip |
| Bold overuse | relaxed (bold hooks OK) | strict | strict | strict | relaxed | skip |
| Emoji in headers | relaxed (1–2 end-of-line OK) | strict | strict | strict | skip | skip |
| Excessive bullets | skip (lists work on LinkedIn) | strict | relaxed (technical lists OK) | strict | skip (lists are docs) | skip |
| Hedging | strict | strict | relaxed ("may" is accurate in technical) | strict | relaxed | skip |
| Word table (full list) | strict | strict | **partial** (see below) | strict | relaxed | P0 only |
| Promotional language | relaxed (some sell is expected) | strict | strict | **extra strict** | strict | skip |
| Significance inflation | strict | strict | strict | **extra strict** | relaxed | skip |
| Copula avoidance | skip | strict | relaxed | strict | skip | skip |
| Uniform paragraph length | skip (short-form) | strict | strict | strict | relaxed | skip |
| Numbered-list inflation | relaxed | strict | relaxed | strict | skip | skip |
| Rhetorical questions | relaxed (1 as hook OK) | strict | strict | strict | strict | skip |
| Transition phrases | skip (short-form) | strict | strict | strict | relaxed | skip |
| Generic conclusions | skip | strict | strict | **extra strict** | skip | skip |

**Technical-blog word exceptions:** These have legitimate technical meaning
and should not be flagged in technical context: `robust`, `comprehensive`,
`seamless`, `ecosystem`, `leverage` (when discussing actual platform leverage
or APIs), `facilitate`, `underpin`, `streamline`. Still flag: `delve`,
`tapestry`, `beacon`, `embark`, `testament to`, `game-changer`, `harness`.

**"Extra strict"** means: flag even borderline instances. In an investor
email, a single "thriving ecosystem" can undermine the whole message.

**"Skip"** means: don't audit this category for this profile. The rule
doesn't apply or isn't worth the edit.

---

## Auto-detection cues

When no context is specified, infer from these signals:

| Signal | Inferred context |
|--------|-----------------|
| Under 300 words + hashtags or mentions | `linkedin` |
| Code blocks, API references, or technical architecture | `technical-blog` |
| Salutation ("Hi [name]", "Dear") + investor/fundraising language | `investor-email` |
| Step-by-step instructions, parameter docs, README structure | `docs` |
| No strong signals | `blog` (safest default — all rules apply) |

If auto-detection feels wrong, say which profile you picked and why. The
user can override.
