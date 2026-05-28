# writing-architect: design plan

A planning doc for a multi-scale writing-and-editing system. Captures what
we want, why, what already exists, and the concrete pieces to build. Not a
skill yet — when SKILL.md ships next to this file, the design rationale stays
here for future edits.

Working names considered: `writing-architect`, `doc-writer`, `deep-writer`,
`co-writer`. Going with `writing-architect` for the orchestrator role; the
sub-agents have their own names.

## 1. The problem we're solving

The trigger case: an ACCESS Accelerate proposal drafted by the existing
`human-writer` skill. The prose dodged all the obvious AI tells (no
`leverage`, no `robust`, no em dashes, no "let's dive in" openers) but
still read like an outsider's summary, not like the PI who actually does
the work. Specific failure modes that survived the human-writer pass:

- **Over-explaining to a peer audience.** "Ac-225, an alpha-emitting
  radionuclide used in targeted alpha therapy for cancer" — the reviewer
  panel already knows this. Defining it to them is the tell.
- **Categories instead of instances.** "DFT in NWChem" with no functional.
  "CASSCF/CASPT2" with no active space. "Four-component DIRAC" with no
  Hamiltonian. "Broader REE/actinide pairs" with no specific pairs.
- **Generic descriptors where a specialist commits.** "Chemically similar
  lanthanum" instead of language about trivalent ionic radii or 5f/4f.
  "Replace expensive ab initio steps" instead of naming the step.
- **Hedging on anything the AI couldn't invent**, without surfacing the
  unknown to the user. The AI asked for resource numbers because it knew
  not to make those up. It didn't know that functional, basis, active
  space, and system names were equally uninventable, so it wrote around
  them. The hedging is invisible to sentence-level AI-tell checks.

Underneath: AI writing tools (including the user's current `human-writer`)
operate at sentence scale. They catch sentence-shaped failures. They miss
**document-shape failures** — disjointed flow, repeated points, sections
doing nothing, hedge-coated technical claims, mismatched audience register
across paragraphs.

What we want instead: a tool that edits top-down the way human editors do
— developmental edit first, copy edit last — and that explicitly handles
the things sentence-level review can't see.

## 2. Design principles

Drawn from prior art (see Section 9 for sources):

1. **Macro first, micro last.** Developmental → structural → line → copy.
   A developmental cut invalidates structural work; structural rewrites
   invalidate copy work. Doing them in reverse order wastes tokens and
   user attention. Enforced ordering, not parallel review.
2. **Each pass in its own context.** A reviewer that sees prior
   sentence-level critique gets pulled toward micro analysis. Isolation
   is a feature, not just a cost-saver.
3. **Evidence-backed critique.** Every finding quotes the passage it
   refers to (the "Iron Laws" pattern). Stops vague AI feedback. Makes
   findings reviewable and actionable.
4. **Structured output between passes.** Each sub-agent emits JSON or
   strict markdown the orchestrator can route without re-understanding.
   Necessary for local-LLM workers; useful even with Claude as worker.
5. **Surface what the AI cannot invent.** Don't write around missing
   domain commitments. Enumerate them, ask the user, mark them in the
   draft. Extends beyond resource numbers to every specialist parameter.
6. **Voice priming from the user's own published prose.** 2–3 paragraphs
   of the user's actual writing, used to calibrate register, vocabulary,
   technical specificity, sentence rhythm. Not just topic priming.
7. **Audience profiling with shared-knowledge assumption.** The skill
   asks who is reading and what they already know. Used to suppress
   over-explanation and lift the technical register.
8. **Iterative refine with a halt condition.** Generate → critique →
   refine, loop until the persona-reader's blind-spot list goes empty
   (or user calls it). Self-Refine-style, but bounded.

## 3. Architecture

A skill orchestrates; sub-agents do the focused passes.

```
~/.claude/skills/writing-architect/SKILL.md     (orchestrator)
~/.claude/agents/developmental-reviewer.md      (sub-agent)
~/.claude/agents/structural-reviewer.md         (sub-agent)
~/.claude/agents/specificity-auditor.md         (sub-agent)
~/.claude/agents/persona-reader.md              (sub-agent, parameterized)
~/.claude/agents/voice-matcher.md               (sub-agent)
```

**Why this split.** The skill stays in the main conversation so the
user-facing dialogue (intake, sign-off, decisions) keeps full context.
Sub-agents have their own clean contexts so each pass can do its narrow
job without bias from prior passes. Where passes are independent
(personas, specificity vs. structural), they run in parallel via separate
Agent calls.

`human-writer` and `editor` stay as the **copy-edit layer**. The architect
delegates to them at the end rather than replacing them. Existing skills
keep working alone for short prose; the architect is the path for anything
multi-page where structure matters.

## 4. Component specs

Each component below is sized for a single, focused job with structured I/O.

### 4.1 `writing-architect` skill (orchestrator)

Responsibilities:
- Intake (Section 5, Stage 0).
- Outline contract with user before drafting.
- Section-by-section drafting (or coordinating an existing draft through review).
- Dispatch sub-agents in the macro-first order.
- Synthesize findings into a tiered report (Critical / Important / Minor).
- Present findings to user; user decides which to address.
- Loop or finalize.

Inputs: target doc type, target file, audience profile, voice samples,
"cannot-invent" list, optional page/word limits.

Triggers: `/writing-architect`, or natural phrases like "deep writing
pass", "help me write this proposal/paper", "review the whole document",
"this needs more than a copy edit."

### 4.2 `developmental-reviewer` sub-agent

Job: macro-level structural review. **Forbidden** from sentence-level or
wording feedback.

Techniques:
- Reverse outline: one sentence per paragraph, in order. Returned as a
  list the orchestrator can show the user directly.
- Thesis-section alignment: does each section advance the thesis or fill
  page count?
- Missing-section detection: required-by-template sections, plus
  reviewer-expected sections that aren't in the template.
- Argument-build check: do sections accrete or genuinely build?
- Claim inventory: every assertion in the doc, tagged supported /
  hand-waved / domain-assumed.

Output schema (JSON):
```
{
  reverse_outline: [{paragraph_index, summary, section}],
  alignment_issues: [{section, problem, evidence}],
  missing_sections: [{name, why_needed}],
  argument_flow: {build_quality, breaks: [...]},
  claims: [{claim, status, location}]
}
```

### 4.3 `structural-reviewer` sub-agent

Job: section and paragraph flow. Runs after developmental.

Techniques:
- Section-summary sequence: one sentence per section. Read as a
  sequence. Flag where the spine breaks.
- Transition check: does each section/paragraph land cleanly after the
  previous one?
- Pacing: where does the reader bog down? Where is too much covered
  too fast?
- Promise-payoff: every commitment in the intro mapped to its delivery
  later.
- Redundancy: same point made twice in different words.

Output schema (JSON): findings list with `{type, location, evidence_quote, suggestion}`.

### 4.4 `specificity-auditor` sub-agent

The pass that would have caught the proposal's actual failure. New
contribution; I didn't find this in prior art.

Job: find every place the prose uses a category where a specialist
would name an instance, or names a method without the parameters that
make it meaningful.

Techniques:
- Method-without-parameters: every named technique flagged if missing
  the parameters that define it (DFT without functional, CASPT2 without
  active space, four-component without Hamiltonian variant, basis set
  not specified).
- Category-instead-of-instance: every plural-class noun ("ligands",
  "systems", "models", "datasets") flagged if no specific instance is
  named within N sentences.
- Over-explanation to peers: definitions of terms a domain-expert
  audience would already know, given the audience profile.
- Hedging language: "approximately", "various", "several", "a range of"
  flagged when followed by no specific count or example.

This pass depends on the **audience profile** to distinguish good
specificity from over-jargon. For a lay audience the same prose would be
fine; for the ACCESS panel it reads as outsider.

Output: findings list, each with the flagged phrase, the audience
expectation it violates, and a suggested concrete substitute or a
request to the user ("what functional did you actually use?").

### 4.5 `persona-reader` sub-agent (parameterized)

Job: read the draft as a specific persona. Parameterized by persona
spec from intake.

The orchestrator can fire several in parallel — one per audience
segment. For a grant proposal: the technical reviewer, the panel chair,
the program officer.

Output dimensions (per Superpath's pattern, lightly adapted):
- Initial reaction (first 30 seconds of skimming)
- What works
- Critical gaps
- Credibility issues / where did the writer lose me
- Missing examples or evidence
- One critical fix

### 4.6 `voice-matcher` sub-agent

Job: given user's own samples + the draft, flag every paragraph whose
register diverges. Catches the "this isn't how the PI writes" feel.

Comparison axes:
- Vocabulary register (technical density, hedging frequency)
- Sentence rhythm (length distribution, complex/simple ratio)
- Specificity habits (how often the user names instances vs. categories)
- Voice markers (contractions? first person plural? declarative? etc.)

Output: per-paragraph divergence flags with the specific axis and a
suggested rephrase pattern drawn from the samples.

### 4.7 Existing skills as the copy-edit layer

`human-writer` runs last, after the structural and specificity passes
have done their work. Its job stays the same: sentence-level AI-tell
scrub. `editor` runs as a final critique pass to catch anything the
specialized agents missed.

## 5. Workflow

### Stage 0: intake (interactive, in main conversation)

- What is this document? (proposal, paper, memo, blog post, etc.)
- Who is the reader? Specifically: job, expertise level, what they
  already know, what they care about.
- Page or word limit, required sections, deadline.
- Voice samples: paste or point to 2–3 paragraphs of your own published
  prose in this register. (For Charlie's case: a paragraph from the JRNC
  paper, a paragraph from a prior abstract.)
- Cannot-invent list: enumerate the domain commitments the user must
  supply rather than have invented. For a chemistry proposal:
  functional, basis set, active space, Hamiltonian variant, specific
  systems studied, software-specific modules, real compute numbers from
  prior runs. The skill prompts category-by-category; user fills in
  what's true and marks the rest as "to fill later."

### Stage 1: outline contract

For docs longer than one page, the architect proposes a structured
outline (sections, intent of each, key facts to land per section). User
signs off before any prose gets written. This catches structure problems
when they cost nothing.

### Stage 2: drafting

Section by section. Each section's draft includes explicit placeholders
for any cannot-invent item not yet supplied: `[FUNCTIONAL: TBD]` etc.
No paragraph leaves drafting without either real content or a marked
placeholder.

### Stage 3: developmental review (sub-agent)

Reverse outline + alignment + missing-section + claim inventory.
Returned to the orchestrator, presented to the user, structural changes
made before any wording work.

### Stage 4: structural review (sub-agent)

Flow, transitions, pacing, promise-payoff, redundancy. Same loop:
present, decide, fix.

### Stage 5: specificity + voice (sub-agents, parallel)

`specificity-auditor` and `voice-matcher` run in parallel — they're
independent. Findings merged. User decides which to fix; many will be
"answer this question" prompts back to the user (what functional? what
basis?).

### Stage 6: persona-reader (sub-agents, parallel)

One persona per audience segment. The orchestrator synthesizes
across personas into a single tiered list.

### Stage 7: copy-edit

Delegate to `human-writer`, then `editor`. The doc should be
structurally sound and specificity-corrected before it reaches this
layer.

### Stage 8: iterate or finalize

Loop back to Stage 3 if the user wants another round (or if any pass
flagged something not yet addressed). Halt condition: persona-reader's
critical-gap list is empty, or user calls it.

## 6. Local-LLM considerations (~70B class)

The architecture is **more** valuable on a local 70B than on a frontier
model, because each pass is a small focused task and a 70B's reliable
context is far smaller than its nominal max.

Practical rules for local-LLM operation:

- **Orchestrator stays on Claude.** The skill itself, the user dialogue,
  the synthesis across findings — these need solid instruction-following
  and long-context reliability. A local 70B as orchestrator falls apart
  after a few hand-offs.
- **Sub-agents are where local 70B works.** Each sub-agent is a narrow
  task with structured output. Qwen 2.5 72B Instruct, Llama 3.3 70B
  Instruct, Mistral Large class all handle this.
- **Per-section, not per-document.** Each pass processes one section at
  a time. Keeps every sub-task inside the 70B's reliable window.
- **Strict structured output.** JSON schema enforced. Don't ask the 70B
  for "a thoughtful review"; ask for the JSON object defined in the
  component spec. The orchestrator routes; the 70B doesn't have to be
  subtle.
- **Voice-matcher is the riskiest pass on a 70B.** Style imitation works
  well but the model's taste may diverge from Claude's on what counts as
  voice divergence. Expect this pass to need empirical tuning per
  model.
- **Transport.** Either an MCP bridge to a local Ollama / LM Studio /
  vLLM endpoint, or the orchestrator emits prompts and the user runs
  them locally. The MCP path is smoother but adds setup.

Open question: should the local-LLM path be a per-sub-agent setting (so
the user can route some passes to Claude and some to local), or
all-or-nothing? Probably per-sub-agent, configurable in intake.

## 7. Integration with existing skills

- `human-writer` — delegated to as the copy-edit layer (Stage 7).
  Survives unchanged. Add a note to its SKILL.md saying when to defer
  to `writing-architect` (anything multi-page where structure could be
  the issue).
- `editor` — runs after `human-writer` in Stage 7 as the final
  critique. Unchanged.
- `deep-planner` — adjacent but different. Deep-planner is for upstream
  *what should the doc be*; writing-architect picks up from there for
  *how does the doc actually read*. They compose if the user wants the
  full pipeline.
- `presentation-designer` — slides are different enough that this skill
  doesn't apply directly. Possible future: a `presentation-architect`
  that borrows the macro-first idea for decks.

## 8. Build checklist

Order matters: ship something usable end-to-end at each milestone, then
add depth. Don't build all six sub-agents before the first user session.

### Milestone 1: minimum viable architect (sequential, Claude-only)

- [x] Write `skills/writing-architect/SKILL.md` covering intake, outline
      contract, dispatch, synthesis. Conversational, no sub-agents yet.
- [x] Inline the developmental-review prompt in the skill — full pass
      runs in the main agent's context for v1.
- [x] Inline the structural-review prompt the same way.
- [x] Inline the specificity-audit prompt (the new contribution; brought
      forward from Milestone 3 so v1 actually addresses the failure case
      that motivated the skill).
- [x] Hand off to existing `human-writer` for the copy pass and `editor`
      for the final critique.
- [ ] Test on a fresh draft (not the ACCESS proposal — pick something
      new so we don't bias the test).

### Milestone 2: extract sub-agents

- [x] Move developmental-review prompt into
      `agents/developmental-reviewer.md` with a tight system prompt and
      structured JSON output schema. Symlinked to `~/.claude/agents/`
      via `install.sh`.
- [x] Same for `structural-reviewer.md`.
- [x] Same for `specificity-auditor.md` (brought forward in M1, now a
      proper sub-agent).
- [x] Update `install.sh` to create `~/.claude/agents/` and symlink
      every `.md` file from `agents/`. `--check` mode verifies agents
      are linked.
- [x] Update `SKILL.md` Stages 3, 4, 5 to dispatch via the Agent tool
      instead of running inline.
- [ ] Confirm context isolation actually helps (compare findings
      quality vs. Milestone 1 inline). Requires a test run.

### Milestone 3: the high-value additions

- [x] Build `specificity-auditor` agent. Brought forward into M1 inline
      and extracted in M2 as a proper sub-agent.
- [x] Build `voice-matcher` agent in `agents/voice-matcher.md`. Four
      comparison axes (vocabulary register, sentence rhythm, specificity
      habits, voice markers). Requires user prose samples; errors out
      cleanly if absent.
- [x] Build `persona-reader` agent in `agents/persona-reader.md`.
      Parameterized — invoking skill provides a persona spec per call.
      Returns six-dimension structured impression. Designed to fire in
      parallel for documents with multiple audience segments.
- [x] Wire both into `SKILL.md`: voice-matcher in parallel with
      specificity-auditor at Stage 5; persona-reader as a new Stage 6
      before copy-edit. Renumbered downstream stages.

### Milestone 4: iteration and halt

- [x] Loop logic in the orchestrator: re-run flagged passes after user
      edits. Documented in `SKILL.md` Stage 8.
- [x] Halt condition: empty critical-gap list across Stages 3–7, or
      explicit user halt. Documented.
- [x] Budget: cap at three full pipeline iterations per session.
      Documented in Stage 8. After three, the skill re-intakes rather
      than looping further.

M4 turned out to be documentation-only — the skill's loop is driven
by Claude reading SKILL.md instructions on each turn, so there's no
separate orchestrator code that needs hardening.

### Milestone 5: local-LLM support

- [ ] Add per-sub-agent backend setting in intake (Claude vs. local).
- [ ] Document the local-LLM transport options (MCP bridge,
      emit-and-run).
- [ ] Validate at least one sub-agent (probably specificity-auditor —
      narrowest task) running on a local 70B.

### Milestone 6: refinement

- [x] Cannot-invent templates per doc type in
      `references/intake-templates.md`. Covers computational chemistry,
      ML/AI paper, biomedical proposal, general academic paper,
      internal memo, technical white paper. Each template includes
      framework guidance for adapting to doc types not on the list.
- [x] Persona library in `references/persona-library.md`. Covers
      ACCESS/NSF/DOE panel reviewer, NIH study section, journal
      referee (conservative + enthusiastic), conference reviewer,
      program officer, executive scanning a memo, lay reader. Each
      entry has the five-field spec (role, expertise, scored on, how
      they read, seen before) plus skepticism triggers.
- [x] Voice-sample storage convention documented in `SKILL.md`
      operating notes: `~/.claude/voice-samples/<register>.md`. Skill
      checks for stored samples at intake and offers to save new ones.
- [x] Wire references into `SKILL.md` so the skill loads them at the
      right stages.

## 9. Validation plan

How do we know the system works.

### Smoke test

Re-run on a *different* document (not paper.docx, since prior knowledge
of its problems biases the test) where we know the failure mode. Pick
something existing that reads as outsider-voice. Run the full pipeline.
The specificity-auditor's findings should match what a domain expert
would catch on a careful read.

### Regression test

Re-run on a known-good piece of the user's prose (e.g., a paragraph from
the JRNC paper). The specificity-auditor and voice-matcher should
produce minimal findings on the user's own polished writing. If they
flag the user's own paper as outsider-voice, the prompts are wrong.

### A-vs-B comparison

For a fresh draft, run two pipelines:
1. Current path: `human-writer` only.
2. New path: full architect.

Diff the outputs. The architect output should be measurably more
specific, less hedged, and structurally tighter on the same source
material.

### User judgment

Charlie reads both. If the new path still feels like an undergrad wrote
it, the prompts need more work. If it reads like the PI, ship.

## 10. Open questions

- **Default scope.** Is the architect always *full pipeline* or does it
  scope to what the doc needs? A one-page memo probably skips
  developmental review. Need a "doc complexity" assessment in intake.
- **Voice priming budget.** How much sample prose is enough? 2–3
  paragraphs is the working hypothesis. Could be more for highly
  specialized registers.
- **Persona library.** Build a curated set of persona specs (grant
  reviewer, paper referee, journal editor, conference reviewer, exec
  audience, etc.) or have the user write each one from scratch?
  Probably both: library defaults that the user can override.
- **Cost / latency.** The full pipeline could be ~10–20 sub-agent
  invocations on a long doc. Make sure intake makes this clear; offer a
  "fast path" that skips persona-reader and voice-matcher for
  short-deadline situations.
- **Editor-skill overlap.** `editor` already does critique. The
  specificity-auditor and structural-reviewer overlap with parts of it.
  Decide: deprecate `editor`, narrow its scope, or keep both with
  documented differences. Easiest answer: keep `editor` for short prose
  critique (a paragraph, an email), use architect for documents.
- **MCP for live document editing.** The office-mcp friction in the
  source case made the editing surface itself a problem. The architect
  doesn't have to use Word as its editing surface — drafting in
  Markdown and converting via pandoc at the end avoids most of that.
  Worth deciding default editing surface as part of intake.

## 11. Prior art relied on

- **Plug-and-Play Dramaturge** (arXiv 2510.05188) — top-down
  Global → Scene → Hierarchical Coordinated Revision. The macro-first
  argument and the divide-and-conquer rationale come from here.
- **Self-Refine** (arXiv 2303.17651) — generate → critique → refine
  loop. The iteration backbone.
- **academic-writing-agents** (github andrehuang/academic-writing-agents)
  — multi-agent specialization, review-then-act, prioritized findings.
- **Writing Editor mcpmarket skill** — Document / Paragraph / Sentence /
  Word four-level pattern.
- **Writing Reviewer mcpmarket skill** — the "Iron Laws" pattern of
  evidence-quoted critique.
- **Superpath synthetic feedback** — persona-reader simulation
  dimensions.
- **UWEX / Northwestern reverse outlining** — the reverse-outline
  technique as the cheapest structural diagnostic.
- **Canonical publishing editing pipeline** — developmental → line →
  copy → proof ordering, and the rationale that each stage invalidates
  later-stage work if reordered.
