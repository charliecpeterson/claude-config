# PROJECT_PLAN.md template

Reference for the `deep-planner` skill. Load this when creating
`PROJECT_PLAN.md` at Phase 0 and whenever you need to confirm the
structure during incremental updates.

The file is a **living document** at the project root, created at
Phase 0 and updated incrementally as each phase completes. Sections
marked **(always)** appear from Phase 0 onward, even if empty.
Sections marked **(if Phase X ran)** appear once that phase has run.
If the user stops at the gate after Phase 5, the file still has
stubs for the unbuilt sections so a future re-run knows what's
pending.

The conductor writes via `Write` (initial creation at Phase 0) and
`Edit` (incremental updates afterward). Every write updates the
"Last updated" and "Current phase" lines at the top.

## Template

```markdown
# Project Plan: [Name]

> Living document. Updated incrementally by the deep-planner skill.
> Last updated: YYYY-MM-DD
> Current phase: Phase 0 / Phase 1 / ... / planning complete

## Goal                                                    (always)
One sentence describing what "done" looks like.

## Archetype                                               (always)
- **Primary**: product/service | data/ML | research artifact |
  library/CLI | pipeline
- **Secondary** (if any): list, with a one-line note on which
  concerns are pulled in from each.
- **Expertise calibration**: one or two lines on where the user
  leads (domain) and where the conductor pushes (probing).

## Scope                                                   (always)
### In scope
- Specific items.
### Out of scope
- Specific items. Out-of-scope items the user wants tracked for
  later go in the Deferred Register, not here.

## Decision Log                                            (always)
Every confirmed decision, with reasoning, alternatives considered,
and (where applicable) the condition that would trigger revisiting.
Each entry:

- **[YYYY-MM-DD] Decision title**
  - **Choice**: what was decided.
  - **Why**: the reasoning.
  - **Alternatives considered**: what else was on the table and why
    it was rejected.
  - **Revisit if**: condition under which this should be reopened
    (if any).

This section grows over the life of the project. Old entries don't
get deleted; superseded entries get a note linking forward.

## Deferred Register                                       (always)
Items explicitly deferred. Things the user wants to write down "so
we don't forget," even if not actionable now. Each entry:

| Item | Why deferred | Trigger to revisit |
|------|--------------|--------------------|
| Auto-scaling | Premature for current traffic | DAU > 1k |

## Open Questions                                          (always)
Things still unresolved. Each entry names what needs answering and
who or what could resolve it.

## Research Summary                                        (if Phase 6 ran)
- **Stack**: chosen stack, one-line reason, citation URL.
- **Libraries / services**: for each capability researched, the
  chosen option with one-line reason and citation URL.
- **Prior art note**: brief differentiation observation from
  competitor research.
- **Things to avoid**: anything the scouts flagged in their `avoid`
  lists that the user wants on record.

## Production-Readiness Audit                              (if Phase 7 ran)
### Addressed
Categories where the plan covers the concern. One line per category
naming what addresses it.
### Deferred
Categories deferred to the Deferred Register. List them here with a
pointer; the actual entry lives in the register.
### Not applicable
Categories that genuinely don't apply, with a one-line reason each.

## Architecture                                            (if Phase 8 ran)
The `architecture-drafter` markdown output, inserted verbatim:
components, data model, deployment shape, trust boundaries, external
interfaces, assumptions, open architectural questions.

## Roadmap                                                 (if Phase 9 ran)
### Phase 1: ship smallest end-to-end version
- [ ] Specific, testable task.
- [ ] Another task.
**Out of scope for this phase**: items intentionally deferred to
Phase 2 or 3.
**Effort**: rough framing.

### Phase 2: production hardening
- [ ] Tasks drawn from readiness-audit headline gaps.
**Out of scope for this phase**:
**Effort**:

### Phase 3: scale and breadth
- [ ] Deferred features and scale work.
**Out of scope for this phase**:
**Effort**:

## Dependencies & Risks                                    (always)
External dependencies, sensitive decisions, things that could
derail the project.
```

## Update protocol

- **Phase 0 (creation)**: stub all sections. Fill in Goal, Archetype
  (primary + secondaries + expertise calibration), Scope.
- **Phase 3 and later decision confirmations**: append entries to
  the Decision Log.
- **Phase 4 / Phase 5**: update Open Questions and Deferred Register
  as items surface.
- **Phase 6**: write the Research Summary.
- **Phase 7**: write the Production-Readiness Audit, including
  items moved to the Deferred Register.
- **Phase 8**: write the Architecture section verbatim from the
  drafter.
- **Phase 9**: write the Roadmap with `- [ ]` checkboxes.

Every write updates the "Last updated" date and the "Current phase"
line at the top.
