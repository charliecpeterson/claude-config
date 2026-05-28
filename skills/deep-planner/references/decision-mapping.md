# Decision-mapping: Phases 1-5

Reference for the `deep-planner` skill. **Load this only when the
eject check after Phase 0 determines that decision-tree mapping is
warranted.** Sessions where the eject check fires (focused-tasks
situation) never need this file. Don't pre-load it.

The five phases below pick up from the eject check and run the
core decision-mapping discipline:

- **Phase 1**: Understand the problem.
- **Phase 2**: Map the decision tree (pulls in the archetype's
  "secretly upstream" checklist).
- **Phase 3**: Resolve decisions, one branch at a time.
- **Phase 4**: Surface hidden decisions.
- **Phase 5**: Final confirmation.

After Phase 5 closes, return to `SKILL.md` for **The Gate**, which
decides whether to proceed into the post-gate pipeline (Phases
6-9, in `references/post-gate-pipeline.md`).

The core principles in `SKILL.md` apply throughout: assume nothing,
one question at a time (with the analysis-first relaxation if that
mode is active), resolve dependencies first, build the decision
tree explicitly, surface decisions the user hasn't mentioned, never
decide for the user, devil's advocate when warranted, prioritize
sustainability over speed.

---

## Phase 1: Understand the Problem

Explore the problem space before touching solutions.

Questions in this phase cover:

- Who has this problem?
- How do they experience it today?
- What does failure look like?
- What constraints exist (budget, time, team, tech, legal)?
- What does success look like, and how will we know?

Do not discuss solutions yet.

In analysis-first mode (declared at Phase 0), much of Phase 1 may
already be covered by the bounded codebase orientation. Don't
re-ask what the code or the user has already told you. Move to
Phase 2 when the problem is clearly understood from either source.

---

## Phase 2: Map the Decision Tree

List all the major decision points this project requires.

**Pull in the archetype's "secretly upstream" checklist** from
`references/archetypes.md` (load it if it isn't already in
context), using the primary archetype and any secondary archetypes
the user named in Phase 0. These are decisions that usually get
missed in casual planning and force rework when discovered late.
Add them to the map even if the user hasn't mentioned them. Each
item becomes either:

- a decision to resolve in Phase 3,
- an Open Question in `PROJECT_PLAN.md` if it can't be resolved
  yet, or
- a Deferred Register entry if it's explicitly out of v1 scope.

Group all decisions by dependency. Identify which decisions block
others.

Share this map with the user so they can see the full shape of
what needs to be resolved. Ask them if anything is missing. The
archetype-upstream items in particular benefit from the user
saying "we don't need that" or "yes we should think about that
now" rather than the conductor guessing.

---

## Phase 3: Resolve Decisions — One Branch at a Time

Work through the decision tree systematically.

For each decision:

1. State the decision clearly: "We need to decide: X"
2. Explain why it matters and what it affects downstream.
3. Offer options if you have them (with pros and cons).
4. Ask the user what they want.
5. If their answer is vague, ask a clarifying follow-up.
6. Once clear, confirm explicitly: "So we're going with X,
   confirmed?"
7. Only then mark it as resolved and move to the next.

Never jump ahead. Never assume a previous answer settles a new
question.

Append each confirmed decision to the Decision Log in
`PROJECT_PLAN.md` as it lands (date, choice, reasoning,
alternatives considered, revisit-if condition).

---

## Phase 4: Surface Hidden Decisions

After working through the obvious decisions, actively probe for
hidden ones.

Use prompts like:

- "We haven't talked about [X] yet, have you thought about how
  you want to handle that?"
- "One thing that often gets overlooked here is [Y], do you have
  a view on that?"
- "What happens if [Z]? Have we accounted for that?"

Keep going until you genuinely cannot find another unresolved
question.

Items that surface here become Phase 3 decisions (if resolvable
now), Open Questions, or Deferred Register entries. Update
`PROJECT_PLAN.md` accordingly.

---

## Phase 5: Final Confirmation

Before producing any output (plan, spec, design, etc.):

1. Show a complete summary of all confirmed decisions.
2. Show any deferred decisions and what triggers them.
3. Ask: "Does this reflect everything we've discussed? Anything
   missing or wrong?"
4. Wait for explicit confirmation before proceeding.

After explicit confirmation, return to `SKILL.md` for **The
Gate**, which decides with the user whether to stop here with the
requirements doc or continue into the post-gate pipeline.
