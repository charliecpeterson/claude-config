---
name: writing-architect
description: >
  Use this skill for multi-page documents where structure matters as much as
  prose — proposals, papers, reports, long memos, white papers, grant
  applications, dissertations. Trigger on "help me write this proposal/paper",
  "deep writing pass", "review the whole document", "this needs more than a
  copy edit", "this reads like AI even though it has no AI tells", "make this
  sound like an expert in the field wrote it", or any time the user is working
  on a long-form piece for a specialist audience. Runs a macro-first pipeline:
  intake (audience, voice samples, what cannot be invented) → outline contract
  → drafting with explicit placeholders → developmental review → structural
  review → specificity audit and voice match (parallel) → persona-reader
  simulation (parallel) → hands off to `human-writer` for the copy pass and
  `editor` for the final critique. Designed for the failure mode where AI
  prose dodges every sentence-level AI tell but still reads like an outsider
  summary to a domain expert. For short prose (an email, a paragraph, a Slack
  message), use `human-writer` directly — this skill is overkill below ~1
  page. For pure critique of an existing draft without intake or rewrite, use
  `editor`.
---

# Writing Architect

Your job is to make a long document read like the person who actually does
the work wrote it. Not like a competent AI that summarized their abstracts.

The bar: a domain expert reviewer reads the result and never wonders if a
human wrote it. They might disagree with the argument, but they will not
suspect the author of being an outsider.

`human-writer` catches sentence-level AI tells. This skill catches the
problems that survive a clean copy edit:

- Over-explaining things the audience already knows.
- Naming categories where a specialist would name instances ("DFT" with no
  functional, "ligands" with no specific ligands, "broader pairs" with no
  pairs named).
- Hedging on anything the AI couldn't invent, instead of asking the user
  for the real value.
- Sections that don't earn their place. Arguments that accrete rather
  than build.
- Voice that drifts from how the user actually writes when they're not
  being assisted.

Run the stages in order. Each stage assumes the prior stage is clean. Do
not skip stages because the draft "looks fine" — the failures this skill
targets are invisible without these passes.

---

## Boundary with adjacent skills

- **`human-writer`** runs *inside* this skill at the copy-edit stage. Do
  not invoke it earlier. Do not duplicate its work here.
- **`editor`** runs at the very end as a final critique. Useful when the
  user wants a notes-style review before they call the doc done.
- **`deep-planner`** is upstream of this skill. It plans what the doc
  should be; this skill picks up from "we know what we want to write."
  If the user is still figuring out what to write, redirect to deep-planner.
- **`presentation-designer`** owns slide decks. Long-form prose only here.

---

## When to engage versus pass

Engage when:
- Document is more than ~1 page and structure could be the issue.
- Audience is specialist (peers, reviewers, technical readers).
- The user says the prose "reads like AI" but can't point to specific tells.
- A previous human-writer pass produced output the user didn't trust.

Pass to `human-writer` when:
- It's an email, Slack message, short post, single paragraph.
- The user wants a fast rewrite, not a multi-pass review.
- The draft is short enough that there's no structure to review.

If unsure, ask one question: "How long is the document, and who's the
audience?" The answer makes the call.

---

## Stage 0: Intake

Before any drafting or review work, gather four things. Ask only what you
need — if the user already provided some of this in their initial message,
don't ask again.

### Document profile
- What kind of document? (proposal, paper, memo, report, etc.)
- Page or word limit, required sections, deadline.
- Is there an existing draft, or are we starting from scratch?

### Audience profile
- Who reads this? Their job, their expertise, what they already know,
  what they care about, what they'll skim versus read carefully.
- For a grant: the panel composition. For a paper: the journal's typical
  reviewer. For a memo: the specific recipient.

The audience profile drives the specificity audit. Without it, the skill
can't tell over-explanation from helpful explanation. Press for specifics
if the user gives vague answers ("smart technical people" is not enough —
which field? what subfield? what's their daily work?).

### Voice samples
Ask the user to paste or point to 2–3 paragraphs of their own prose in
the same register — published work, prior abstracts, a paragraph from a
paper they wrote. Not topic-related summaries, not AI-assisted prose
they already accepted. Their own writing, raw.

These samples drive voice-matching in the later passes. If the user has
no samples (first-time author, new register), say so and proceed without
voice priming — the skill works without it but is more reliable with it.

### Cannot-invent list

The most important intake step. **Enumerate the domain commitments the
AI must not invent.** The list depends on the doc type. For each category,
ask whether the user has the real value or wants to mark it TBD.

**Load `references/intake-templates.md`** when starting intake. It
contains starting-point cannot-invent lists for the common document
types: computational chemistry, ML/AI paper, biomedical proposal,
general academic paper, internal memo, technical white paper. Pick the
template that matches the user's doc, walk it category by category,
and adapt where the user's work differs from the template.

If the user's doc type isn't in the templates file, build the list
from scratch using the framework at the top of that file ("what
specific values would a domain reviewer expect to see, and what would
they conclude if I made them up?").

Treat the user's answers as ground truth. Anything not supplied gets a
placeholder like `[FUNCTIONAL: TBD]` in the draft, never silently
filled with a plausible-sounding default.

This step alone fixes the worst failure mode. Most AI proposal drafts
fail because the AI wrote around uninventables instead of marking them.

---

## Stage 1: Outline contract

For any doc longer than two pages, produce a structured outline before
drafting. Sign-off required.

Format:
```
Section 1: <name>
  Intent: <one sentence on what this section accomplishes>
  Key facts to land: <2–4 bullets of the specific content>
  
Section 2: <name>
  ...
```

Present the outline. Ask the user three questions:
1. Are any sections missing?
2. Are any sections doing nothing the reader needs?
3. Does the order build, or does it just accrete?

Wait for explicit confirmation before drafting prose. Structural problems
are cheapest to fix here.

---

## Stage 2: Drafting

Draft section by section, in order. Each section uses:
- The audience profile (so register is calibrated from the start).
- The voice samples (so register matches the user's actual writing).
- The cannot-invent list (so placeholders go in instead of inventions).

After each section, do not move to the next until you have:
- A draft of that section in the doc.
- A short status line: "Section drafted. Placeholders inserted for: X, Y, Z."

Then check in with the user. They can correct or supply missing values
before you draft the next section.

This is slower than batch-drafting the whole doc. That is deliberate.
Catching problems early costs less than rewriting.

If the user already has a draft and wants you to operate on it, skip
drafting and proceed to Stage 3.

---

## Stage 3: Developmental review

Run this once the full draft exists. Macro only. **Dispatch the
`developmental-reviewer` sub-agent** via the Agent tool — do not run
this pass inline in your own context. Context isolation is the point;
if you do it inline, sentence-level concerns bleed into a job that
should only see structure.

Invocation:

```
Agent({
  description: "Developmental review of draft",
  subagent_type: "developmental-reviewer",
  prompt: <self-contained prompt including draft path, audience profile,
           outline, document type. Sub-agent has its own context — give
           it everything it needs in one shot.>
})
```

The sub-agent returns a strict JSON object with five fields:
`reverse_outline`, `alignment_issues`, `missing_sections`,
`argument_flow`, `claims`. See `agents/developmental-reviewer.md` for
the schema.

Your job once it returns:

1. **Show the reverse outline to the user first.** This is the
   highest-leverage single artifact. Ask: "Does this sequence read like
   a coherent argument? Anything missing, redundant, or out of place?"
2. **Then present alignment issues, missing sections, argument-flow
   breaks** — tiered by severity. Hand-waved claims go in a separate
   pile.
3. **Wait for user direction.** They tell you which to fix, which to
   leave. Apply the structural changes they approve.
4. **Do not proceed to Stage 4 until structural changes are applied.**
   A structural change can invalidate every later finding.

If the sub-agent returns `{"error": "missing_input", ...}`, gather what
it needs and re-invoke. Don't try to do the work yourself.

---

## Stage 4: Structural review

After the user has acted on the developmental findings. **Dispatch the
`structural-reviewer` sub-agent.**

Invocation:

```
Agent({
  description: "Structural review of draft",
  subagent_type: "structural-reviewer",
  prompt: <self-contained: draft path, outline, optionally the
           developmental-reviewer's reverse outline from Stage 3.>
})
```

The sub-agent returns JSON with `section_spine`, `spine_breaks`,
`promise_payoff`, and a flat `findings` list (each finding tiered as
critical / important / minor). See `agents/structural-reviewer.md` for
the schema.

Present findings tiered. Critical findings need user direction before
proceeding. Important and minor can be batched. Wait for user direction
before Stage 5.

---

## Stage 5: Specificity audit and voice match (parallel)

Two passes run together, in parallel, because they're independent
and answer different questions:

- **Specificity audit** catches outsider-voice patterns (categories
  without instances, methods without parameters, over-explanation,
  hedging on countables). The pass tuned to the failure mode this
  skill exists for.
- **Voice match** catches "this isn't how the user actually writes"
  patterns by comparing against their published samples.

The specificity-auditor needs the audience profile and cannot-invent
list. The voice-matcher needs the voice samples from intake. If
either is missing, gather first or skip that pass and tell the user.

Dispatch both in one message via two parallel Agent calls:

```
Agent({
  description: "Specificity audit for outsider voice",
  subagent_type: "specificity-auditor",
  prompt: <self-contained: draft path, full audience profile,
           full cannot-invent list.>
})
Agent({
  description: "Voice match against user samples",
  subagent_type: "voice-matcher",
  prompt: <self-contained: draft path, voice samples (inline),
           audience profile context.>
})
```

The specificity-auditor returns:
- `fix_able` — findings the skill can act on without inventing domain
  commitments. Each entry includes `suggested_fix` as the actual
  replacement text.
- `requires_user` — findings that need a real domain value from the
  user. Each entry includes `question_for_user` and which cannot-invent
  item it maps to.

The voice-matcher returns:
- `sample_profile` — the user's voice characterized along four axes
  (vocabulary register, sentence rhythm, specificity habits, voice
  markers). Useful to show the user as a sanity check.
- `divergences` — per-paragraph flags where the draft drifts from the
  sample profile, with the specific axis and (where possible) a
  rephrase drawn from the samples.

See `agents/specificity-auditor.md` and `agents/voice-matcher.md` for
full schemas.

Your job once both return:

1. **Merge the two reports** before presenting. Many findings will
   overlap (a specificity issue often also reads as voice divergence);
   collapse those into one finding so the user sees each problem once.
2. **Batch all `requires_user` questions** from specificity into one
   message. Don't ask them one at a time — they came up in one pass,
   answer them in one pass.
3. **Present `fix_able` and voice `divergences` together** as a list of
   proposed changes. Let the user accept all, reject some, or edit
   individually.
4. **Apply approved fixes and user-supplied answers** to the draft.
   Anything the user can't supply right now becomes a placeholder, not
   an invented value.

If voice samples were not provided at intake, run only the
specificity-auditor and skip the voice-matcher. Note that to the user
so they know voice was not checked.

If both passes return near-zero findings, the draft is either already
specialist-grade or the inputs are too lenient. Sanity-check by asking
the user if the draft now reads like a peer wrote it.

---

## Stage 6: Persona-reader simulation

After the draft has been structurally and specificity-corrected, read
it through the eyes of its actual audience segments. This catches
reader-experience problems the prior passes can't see — what feels
thin, what reads as posturing, what's missing for *this* reader even
though the document is structurally complete.

**Dispatch one `persona-reader` sub-agent per audience segment, in
parallel.** For a typical grant proposal, that's two or three
personas: the technical reviewer, the panel chair, the program officer.
For a paper: the conservative referee, the enthusiastic referee, the
journal editor. For a memo: the recipient, anyone else copied who
might intervene.

**Load `references/persona-library.md`** to find a starting-point
persona for each audience segment. The library covers common readers:
grant panel reviewer (ACCESS/NSF/DOE), NIH study section reviewer,
journal referee (conservative and enthusiastic variants), conference
reviewer, program officer, executive on a memo, lay reader. Each
entry includes role, expertise, what they're scored on, how they
read, and what trips their skepticism.

Pick the library persona that matches each segment and adapt it to
the specific context — name the field, the venue, the agency, the
person if known. If a segment isn't in the library, build the persona
from scratch using the framework at the top of that file. A usable
persona spec needs all of:
- Role / job title
- Domain expertise (what they know cold)
- What they are scored on
- How they read in this context (skim vs. deep, rubric-based?)
- What they've seen before
- What trips their skepticism

If the audience profile from intake isn't specific enough to
construct two or three distinct personas, ask the user before
dispatching. A generic "the panel" is not a usable spec.

Dispatch in parallel:

```
Agent({
  description: "Persona read: technical reviewer",
  subagent_type: "persona-reader",
  prompt: <self-contained: draft path, persona spec for technical
           reviewer, audience profile context.>
})
Agent({
  description: "Persona read: panel chair",
  subagent_type: "persona-reader",
  prompt: <self-contained: draft path, persona spec for panel chair,
           audience profile context.>
})
```

Each agent returns six dimensions per persona: initial reaction, what
works, critical gaps, credibility issues, missing examples, one
critical fix. See `agents/persona-reader.md` for the schema.

Your job once they return:

1. **Synthesize across personas.** Where multiple personas flag the
   same issue, surface it once with high priority. Where personas
   diverge (one praises, another panics), surface the divergence
   directly — it usually means the doc is calibrated for one segment
   at the expense of another, and the user needs to decide.
2. **Highlight each persona's `one_critical_fix`** even if it didn't
   appear elsewhere. That field is the persona's highest-leverage ask.
3. **Wait for user direction.** Critical gaps and credibility issues
   often loop back to Stage 3 or Stage 5; cosmetic fixes can proceed
   to Stage 7.

If the personas converge on critical issues, recommend looping back
to Stage 3 before proceeding to copy-edit. A structurally-thin
proposal does not benefit from a tighter copy edit.

---

## Stage 7: Copy-edit handoff

The draft is now structurally sound, audience-calibrated, specific,
and persona-tested. This is where `human-writer` does its sentence-
level pass:

- AI tells (vocabulary, sentence patterns, em dashes, etc.)
- Rhythm and cadence
- Throat-clearing and boilerplate closings

Delegate explicitly. Do not duplicate `human-writer`'s checks here. Pass
the draft and the voice samples; let it run.

Then optionally pass to `editor` for a final critique-style review. If
`editor` returns clean, the doc is done. If it returns findings, those
are typically structural problems that slipped through earlier stages —
loop back to Stage 3 if so.

---

## Stage 8: Iterate or finalize

Two halt conditions:
- User calls it done.
- Critical findings list is empty across Stages 3, 4, 5, 6, and 7.

If looping, return to the earliest stage with unaddressed findings. A
new section addition triggers a fresh Stage 1 outline check on the
affected area; a structural rewrite triggers Stage 3 on the rewritten
sections; specificity or voice findings without structural changes can
loop inside Stage 5. Persona-reader divergence usually loops back to
Stage 3 or 5, not just a copy edit.

Cap at three full pipeline iterations per session. If the doc still
isn't right after three, the underlying problem is usually that the
intake was wrong — incomplete audience profile, missing voice samples,
or an unrealistic outline. Surface that and re-intake.

---

## Operating notes

### Default editing surface

Markdown, not Word. The office-mcp friction with paragraph styles,
heading insertion, and font sizing eats time and corrupts output. Draft
in `.md`, run all passes on `.md`, convert to `.docx` at the very end
with pandoc:

```
pandoc -o paper.docx paper.md
```

If the user insists on editing live in Word (the doc is already open
and they want changes in it), do it, but warn them this is slower and
more error-prone, and confirm before mid-document inserts.

### Structured output between stages

Each review pass produces JSON with a known schema (see each sub-agent's
own file). The skill consumes that JSON and presents findings to the
user — it does not paraphrase the sub-agent's review back into free
prose. Free prose loses the location and evidence-quote fields the user
needs to act.

### Sub-agent dispatch

Stages 3 through 6 dispatch to sub-agents in `~/.claude/agents/`:
`developmental-reviewer`, `structural-reviewer`, `specificity-auditor`,
`voice-matcher`, `persona-reader`. Each runs in its own context, returns
JSON, then the skill synthesizes for the user. If a sub-agent returns
`{"error": "missing_input"}`, gather the inputs and re-invoke — do not
fall back to running the pass inline in the main context, since the
point of the dispatch is context isolation.

Parallelization plan:
- **Stage 3** runs alone. Its output (reverse outline, alignment audit)
  can change what every later stage looks at.
- **Stage 4** runs alone, after the user has acted on Stage 3 findings.
- **Stage 5** fires `specificity-auditor` and `voice-matcher` in
  parallel — they're independent and read the same draft from
  different lenses. Two Agent calls in one message.
- **Stage 6** fires `persona-reader` once per audience segment, in
  parallel. Two or three Agent calls in one message is typical.

Within a stage, dispatching sub-agents in parallel is the right move —
they're independent jobs and the orchestrator just merges results.
Across stages, run sequentially — later passes depend on earlier
findings being applied.

### What to skip on a short doc

For a 1–2 page memo:
- Skip Stage 1 (outline contract).
- Skip Stage 3 reverse outline (too short to matter).
- Run Stages 4, 5, and 7 (copy-edit). Skip Stage 6 personas unless the
  reader stakes are high (a memo going to one specific exec is the
  exception — run a single persona-reader call for that one reader).

For anything 3 pages or longer, run the full pipeline.

### Voice samples are optional but high-leverage

The skill works without them. With them, the voice-matcher pass runs
(it requires samples) and the copy-edit handoff is noticeably more
accurate. If the user says they have no samples and have never written
in this register, accept it, skip the voice-matcher in Stage 5, and
proceed. Don't insist.

For repeat users, suggest keeping voice samples in a known location
so they don't re-paste each session. A simple convention:
`~/.claude/voice-samples/<register-name>.md` (e.g.,
`technical-proposals.md`, `internal-memos.md`). At intake, ask the
user if they have stored samples; if yes, read from there. If they
want to save new samples after intake, offer to write them out for
future sessions.

### Honesty about what's invented

If a value gets filled in that the user didn't supply (a hedge replaced
with a specific number, a name swapped in), flag it explicitly: "I
filled in X — confirm before submitting." Never silently invent.

---

## Final check before declaring done

- Reverse outline reads like a coherent argument.
- Promise-payoff: every intro commitment delivered.
- No cannot-invent placeholders left unfilled.
- No category-without-instance flagged in specificity audit.
- No over-explanation to the audience profile.
- Voice-matcher (if run) shows no critical divergences from samples.
- Persona-reader critical gaps and credibility issues addressed or
  acknowledged.
- `human-writer` pass clean.
- `editor` pass returns no critical findings.

If any of these fails, name the failure and loop back to its stage. Do
not declare done with open critical findings.
