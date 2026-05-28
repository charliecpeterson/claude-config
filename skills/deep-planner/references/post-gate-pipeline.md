# Post-gate pipeline: Phases 6-9

Reference for the `deep-planner` skill. **Load this only after the
user has passed the gate at the end of Phase 5.** Sessions that stop
at requirements never need this file in context, and that's the
common case. Don't pre-load it.

The four phases below pick up from the gate and produce the
architecture-and-roadmap artifact:

- **Phase 6**: Research (parallel scouts).
- **Phase 7**: Production-readiness audit.
- **Phase 8**: Architecture draft.
- **Phase 9**: Staged roadmap.

After Phase 9, return to `SKILL.md` for the final write to
`PROJECT_PLAN.md` and the end-of-session handoff.

---

## Phase 6: Research (parallel scouts)

Dispatch sub-agents in parallel to ground the project in real
current evidence, not training-data defaults. Run them in one
message via parallel Agent calls.

The three scouts:

- **`stack-scout`** — what stacks people actually use for this kind
  of project right now, with citations. Returns ranked candidates
  and an explicit "avoid" list.
- **`library-scout`** — for each capability the project needs
  (auth, payments, search, queue, etc.), the maintained
  build-or-buy options. Dispatch one library-scout per capability
  if the project needs several distinct capabilities.
- **`competitor-scout`** — prior art in the same problem space:
  direct competitors, adjacent solutions, differentiation
  opportunities, with citations.

Invocation (parallel, single message, multiple Agent calls):

```
Agent({
  description: "Stack research for project",
  subagent_type: "stack-scout",
  prompt: <self-contained: project_description, domain, target_users,
           constraints, archetype (primary), secondary_archetypes
           (if any) — verbatim from confirmed decisions and Phase 0.>
})
Agent({
  description: "Library research for {capability}",
  subagent_type: "library-scout",
  prompt: <self-contained: capability, language_or_platform,
           constraints, scale_expectation, archetype.>
})
Agent({
  description: "Prior-art research for project",
  subagent_type: "competitor-scout",
  prompt: <self-contained: project_description, target_users,
           value_proposition, archetype, secondary_archetypes.>
})
```

The `archetype` argument routes each scout to the right source
surfaces (e.g., Scholar / arXiv for data/ML and research archetypes,
not just GitHub / HN). See each scout's `agents/*.md` for the
routing.

If the project needs more than one capability researched (e.g., auth
*and* payments *and* search), dispatch one library-scout per
capability, all in parallel with the other scouts.

Each scout returns JSON. See the respective `agents/*.md` files for
schemas.

Your job once they return:

1. **Surface "avoid" findings and `open_questions` first.** These
   are the parts the user must resolve before any architecture
   decision is locked.
2. **Present the candidates plainly.** Don't pick a winner. Show
   the shortlists with the citations.
3. **Ask the user which candidates they want carried forward.** A
   single concrete choice per category (stack, each library) before
   moving to Phase 7.
4. **If a scout returns `{"error": "missing_input", ...}`**, gather
   what it needs and re-invoke. Do not work around it.

Do not proceed to Phase 7 until the user has named the stack and
library choices that will be assumed downstream.

---

## Phase 7: Production-readiness audit

After research, before architecture. Dispatch the
`readiness-auditor` sub-agent.

Invocation:

```
Agent({
  description: "Production-readiness audit",
  subagent_type: "readiness-auditor",
  prompt: <self-contained: project_plan (Phase 5 output) +
           research_findings (Phase 6 outputs, condensed) +
           archetype (primary, declared in Phase 0) +
           secondary_archetypes (if any).>
})
```

The auditor picks the matching checklist from its archetype
variants and applies it. If secondary archetypes were declared, it
unions in their categories too.

The auditor returns JSON with a status per checklist category and
a `headline_gaps` ranking. See `agents/readiness-auditor.md` for
the schema.

Your job once it returns:

1. **Show `headline_gaps` first.** These are the must-resolve
   items.
2. **Walk through each gap with the user.** For each: state the
   decision the auditor identified, offer 2-3 options where you
   can, get an answer. Treat each like a Phase 3 decision: confirm
   explicitly before moving on.
3. **`not_applicable` categories** should be visible to the user
   once, briefly, so they can object if the auditor marked
   something NA that they actually care about.
4. **Append resolved decisions to the confirmed-decisions list.**

Do not proceed to Phase 8 until every `gap` and `partial` from the
checklist has either been resolved or explicitly deferred (with a
note on what triggers revisiting).

---

## Phase 8: Architecture draft

After requirements, research, and readiness gaps are settled.
Dispatch the `architecture-drafter` sub-agent.

Invocation:

```
Agent({
  description: "Draft project architecture",
  subagent_type: "architecture-drafter",
  prompt: <self-contained: project_plan, stack_findings,
           library_findings (all of them), competitor_findings,
           readiness_audit, archetype, secondary_archetypes.>
})
```

The drafter returns Markdown (not JSON) with sections for
components, data model, deployment shape, trust boundaries,
external interfaces, assumptions, and open architectural questions.
See `agents/architecture-drafter.md` for the structure.

Your job once it returns:

1. **Show the architecture draft to the user.**
2. **Highlight the `**Assumption:**` markers and the open
   architectural questions section.** These are the most likely
   points of disagreement.
3. **Walk through any assumption the user wants to change.** Each
   one becomes a new confirmed decision; update accordingly.
4. **If the user changes a decision that invalidates a downstream
   choice** (e.g., switches from monolith to services), re-dispatch
   the drafter with the new inputs. Do not patch the architecture
   inline.

Do not proceed to Phase 9 until the architecture is one the user
can read aloud and agree with.

---

## Phase 9: Staged roadmap

After architecture is settled. The roadmap is the bridge between
"agreed architecture" and "engineer can start building."

You produce this directly in the conductor context, no sub-agent
needed. Use the following structure:

- **Phase 1: Ship the smallest end-to-end version.** Identify the
  thinnest slice through the architecture that proves the core
  value. List what's IN and what's deliberately deferred. Should
  be buildable in a defined timeframe (the user states the
  timeframe).
- **Phase 2: Production hardening.** From `readiness-auditor`'s
  headline gaps, the items that must be true before real users
  arrive. Backups, observability, rate limiting, the boring stuff.
- **Phase 3: Scale and breadth.** Features deferred from Phase 1,
  scale work, secondary capabilities.

For each phase:

- What lands at the end of this phase (concrete, testable).
- What's explicitly out of scope for this phase.
- Dependencies on prior phases.
- Rough effort framing (days / weeks / months, whatever the user
  is thinking in).

Show the roadmap to the user. Confirm:

1. Phase 1 is genuinely the smallest end-to-end version, not a
   half-system that proves nothing.
2. Phase 2 actually covers the readiness gaps from Phase 7.
3. Phase 3 isn't doing the work of Phase 1 in disguise.

Once confirmed, return to `SKILL.md` and update `PROJECT_PLAN.md`
with the Research Summary, Production-Readiness Audit,
Architecture, and Roadmap sections per the template.
