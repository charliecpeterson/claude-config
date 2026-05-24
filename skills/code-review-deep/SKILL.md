---
name: code-review-deep
description: Use this skill for an in-depth, tool-grounded code review — distinct from Claude Code's built-in lightweight `/code-review`. BY DEFAULT it assesses the WHOLE codebase, not one diff — trigger on "deep code review", "thorough review", "review this codebase/repo/project", "is this good code", "is this sustainable", "should I rewrite this", "is this good architecture", "can a new dev work on this", "review for AI slop", "senior-engineer review", "audit this project", or any time the user points the skill at a project without naming a specific change. The whole-codebase pass runs the project's linters / type checkers / formatters / test runner, reads the architecture for flow and AI slop, fans out across the code, walks the macro checklist, and renders a Continue / Refactor / Rebuild verdict across sustainability, new-developer onboarding, and real user interaction. It scopes DOWN to a deep CHANGE REVIEW (tool-grounded, claim-verified, triaged into Block / Request changes / Discuss / Nit / Praise) only when the user names a specific PR, commit, range, or diff. Answers "is this good code?" — for "is this exploitable?", use security-review-deep instead or in addition; for a quick pending-diff pass, the built-in /code-review is lighter.
---

# Code Review

A disciplined, repeatable process for reviewing code the way a good senior engineer would. By default it assesses the **whole codebase** — architecture, sustainability, and whether it should be continued, refactored, or rebuilt. Pointed at a specific change, it does a deep, tool-grounded review of that change instead. Either way it runs the deterministic tools, reads for flow and AI slop, walks a structured checklist, verifies its claims, and hands back a grounded, triaged report. Grounding in tool output and a fixed checklist is what makes it consistent instead of dependent on what the model happens to notice that day.

## When to use this skill

- Assessing a whole project: "is this good?", "is this sustainable?", "should I rewrite this?", "can someone else work on this?", "review this codebase properly"
- Inheriting or returning to a codebase and wanting an honest health verdict
- Reviewing a specific PR, commit, or diff in real depth (scope it by naming the change)
- After finishing a feature, refactor, or bug fix and wanting a real second pass
- When the user suspects AI-generated slop and wants it caught

This is the heavier counterpart to Claude Code's built-in `/code-review`. Use `/code-review` for a quick pending-diff pass; reach for this skill when the user wants a full audit — the default whole-codebase assessment, or a rigorous deep-dive on a named change — and especially when running in an agent that has no built-in review at all.

**Boundary with `security-review-deep`:** that skill asks "is this exploitable?" with an adversarial lens. This one asks "is this good code that should merge?" with a collaborative lens. They overlap on error handling, input validation, dependencies, and concurrency, but answer different questions about the same lines. Example: "this `except` is too broad" is a code-review comment; "this `except` swallows the auth-check failure and fails open" is the security finding. If you spot something security-relevant here, mention it and point to `security-review-deep` for depth — don't try to do both jobs at once.

## What to review: default to the whole codebase

**The default is a complete assessment of the whole codebase**, not a single diff. When the user points this skill at a project without naming a specific change — "review this," "is this any good," bare `/code-review-deep`, or anything in that neighborhood — assess the whole thing: architecture, sustainability, whether a new dev could work on it, how a real user interacts with it, and a Continue / Refactor / Rebuild verdict. The process, the three lenses, the macro checklist, the subagent fan-out, and the verdict format are in **`references/project-review.md`** — read it and follow it. That's the headline capability; the built-in `/code-review` is where a quick pending-diff check belongs.

**Scope down to a change review only when the user names a change** — a PR, commit, range, or "review this diff." Then run the deep change-review process below: bounded to that change, but far more rigorous than the built-in (full project toolchain, cross-file verification, claim-checking, triaged findings). Reviewing one bounded change inside a large mature repo is exactly the case where scoped review beats trying to read the whole thing — that's when to use it.

**A change review can escalate back to the default.** If a scoped review keeps turning up *systemic* rot — a half-finished migration, no tests anywhere, a God object the change just feeds, multiple crash bugs in uncommitted work — the line-by-line findings are symptoms, not the story. Stop stacking nits, say so plainly, and offer the project-level verdict: "These aren't really change-review findings; the project itself has a health problem. Want the full Continue / Refactor / Rebuild assessment?" Then follow `references/project-review.md`. Don't bury "this foundation is unsound" inside a list of Discuss items.

If you genuinely can't tell whether the user wants the whole codebase or one specific change, ask one question before starting.

## The process (change review)

Work in this order. Don't skip to opinions before running the tools and reading the whole change — that's how reviews turn into either "looks good!" or a pile of nitpicks that miss the real problem.

### Step 1 — Scope the change

```bash
# PR review (against the base branch):
git diff origin/main...HEAD --stat
git diff origin/main...HEAD

# Local/uncommitted work:
git diff --stat
git diff

# Last commit:
git diff HEAD~1 HEAD
```

**Named change resolves to nothing?** You're in change review because the user named a scope — but it can come up empty (a clean working tree, a commit that's only file-mode flips, a range with no code changes). Say so plainly rather than reviewing noise. Then either point at the nearest reviewable change (e.g. the last real code commit) and confirm, or — if it turns out the user wanted a health check rather than a specific change — switch to the default whole-codebase assessment in `references/project-review.md`. Remember the skill's default is the whole codebase; you only narrowed to this scope because a change was named, so if that scope is empty, the whole-codebase pass is usually what they actually want.

Capture the list of changed files and classify the change: feature / bug fix / refactor / dependency bump / breaking API change / docs. The classification sets expectations — a refactor that adds behavior is a smell; a feature with no new tests is a smell.

### Step 2 — Run the deterministic tools

Let the tools find what tools are good at finding, so your attention is free for what they can't.

**Prefer the project's own commands** over the skill's defaults. Look for a `Makefile`, `justfile`, or `package.json` scripts named `lint` / `test` / `typecheck` / `format`, and a CI config (`.github/workflows`, `.gitlab-ci.yml`). The project knows its toolchain better than any default. Fall back to the per-language defaults only when nothing is configured:

- **Python** — `ruff check`, `mypy` or `pyright`, `pytest`, `radon cc` (complexity), `vulture` (dead code)
- **JS/TS** — `eslint`, `tsc --noEmit`, `prettier --check`, `vitest`/`jest`, `knip` (dead code/exports)
- **Go** — `gofmt -l`, `go vet`, `staticcheck`, `go test`, `errcheck`
- **Rust** — `cargo fmt --check`, `cargo clippy`, `cargo test`
- **Ruby** — `rubocop`, `rspec`
- **Java** — `spotbugs`, `checkstyle`, `pmd`, the project's test task

If a tool isn't configured in the project, **provision it before giving up** — `uvx ruff check`, a throwaway venv, `npx`, `pytest --cov`. A one-off install is cheap, and "no linter ran" is a weak line in an audit when the tool is one command away. Only after that genuinely fails do you note it unavailable and move on. Don't refuse to review. Capture each tool's output and treat failures as findings, not blockers.

**Run the code where the risk is dynamic — don't assess it by reading alone.** Linters won't catch a broken LLM/agent retry loop, an async ordering bug, or a runtime crash on a path the tests skip. For the riskiest runtime logic — agent/LLM orchestration, background jobs, anything with no test around it — exercise it: mock the model or external call, replay a fixture, or run the one path in a REPL. "Assessed by reading only, no API key" is the most common way a review misses the real bug. If you truly can't run it, say so loudly in the report rather than implying you verified it.

### Step 3 — Read the change as a whole

Before line-level nitpicking, step back. Most reviewers (human and AI) never do this, and it's where the highest-value findings hide.

- What is this change *trying* to do? Restate it in one sentence. If you can't, that's a finding.
- Trace the main path through the new code. Does the control and data flow make sense, or does it wander?
- Does it fit the codebase, or does it look bolted on? Read 2–3 neighboring files. A change that introduces a second config loader, a parallel error-handling style, or a duplicate helper under a new name is fragmenting the codebase even if every line is "correct."
- Is this the smallest change that solves the problem, or is there speculative generality — config options, hooks, abstractions for one caller?
- Would the next person understand it in 30 seconds? If not, the problem is usually structure or naming, not a missing comment.

### Step 4 — Tests-of-the-change analysis

The single highest-leverage step, and where most AI reviews fall down. Don't accept "there are tests" at face value.

- Did the change add tests? Diff the test files alongside the source.
- Do the new tests actually exercise the new code path? Cross-reference function names and imports — a test that imports the module but never calls the changed function proves nothing.
- **Find the most fragile line and check it's covered.** Tests cluster on the happy path; the bugs hide in the clever bit. Pick out the trickiest logic in the change — the special-case guard, the fallback branch, the off-by-one boundary, the bit with a comment explaining why it's subtle — and confirm a test pins it. An untested guard is one refactor away from silently vanishing. This single question surfaces more than the rest of the step combined.
- Did existing tests change? Distinguish "updated expected value because behavior legitimately changed" from "weakened the assertion to make it pass."
- Any trivially-passing tests? `assert True`, no assertions at all, asserting on a mock you just configured, asserting `x == x`.
- Is each happy-path test paired with a negative/error-path test?
- Run coverage when it's available and **cite the actual number — don't estimate** "~80% covered" from eyeballing. `pytest --cov`, `cargo llvm-cov`, `vitest --coverage` scoped to the changed files. A measured figure is a finding; a guessed one is noise.

### Step 5 — Walk the review checklist

For **every changed file**, walk the checklist in `references/review-checklist.md`. For each category, mark ✅ cleared (with a one-line reason), ⚠️ flagged (with `file:line` + explanation), or N/A. Naming what you checked is the point — "looks good" with nothing behind it is the failure mode this step exists to prevent.

The categories, in priority order:

1. **Correctness & logic** — off-by-one, null/None, boundary cases, error paths, async ordering, transaction boundaries, and plain bad logic: conditions that can't be true, inverted checks, dead branches, convoluted control flow that should be flat.
2. **Tests** — covered in depth at Step 4; record the verdict here.
3. **Code flow & coherence** — does it fit the architecture, or fragment it? Duplicate helpers, parallel mechanisms, wrong-file placement.
4. **AI slop & authenticity** — the tells that mean code was generated and not read: `result`/`data`/`output` names where a specific one fits, `x = f(); return x`, `# Increment counter` over `counter += 1`, defensive `if x is not None` the types already guarantee, leftover debug prints, two near-identical helpers, a block that looks nothing like the file around it.
5. **Refactoring & dead code** — duplication, god functions/files, abstractions with one caller, code the change leaves orphaned.
6. **Clarity & naming** — names, function length, comments that explain *why* not *what*, magic numbers.
7. **Error handling** — swallowed exceptions, unhelpful messages, fail-loud vs. fail-quiet, retry logic.
8. **API design** — public surface, backwards compat, deprecation, versioning.
9. **Performance** — N+1 queries, repeated work, allocations in hot paths, blocking I/O on an event loop.
10. **Concurrency** — races, shared mutable state, lock discipline, ordering assumptions.
11. **Resource usage** — leaked handles/connections, unbounded growth, missing cleanup.
12. **Logging & observability** — levels, no secrets/PII in logs, signals for new operations.
13. **Dependencies** — new dep justified, maintained, licensed, not overlapping an existing one.
14. **Configuration & migrations** — new flags documented and validated; migrations reversible with a rollback path.
15. **Documentation** — README/docstrings/changelog updated when behavior changed.

### Step 6 — Triage and output the report

Sort every finding into one bucket, then write the report using `references/report-template.md`. Lead with the verdict, then the worst finding. Length follows findings — a clean change gets a short report.

**The five buckets:**

- **Block** — must fix before merge. Correctness bugs, broken or missing tests for new code, a breaking API change with no deprecation, failing CI.
- **Request changes** — should fix before merge. Clarity that will hurt the next reader, real perf problems, missing error handling, unclear public names.
- **Discuss** — design questions worth a conversation, not blocking.
- **Nit** — style, minor naming, formatting. Take or leave. Label them so the author knows they're optional.
- **Praise** — call out what was done well. Not optional. A review that only ever criticizes burns out the person receiving it, and praising good patterns reinforces them.

## Tone guardrails

These are load-bearing. A code review that ignores them is either useless or insufferable.

- **Don't pile on.** If a function has eight problems, give the top three, then group the rest: "and 5 similar naming issues in this function." A wall of findings gets ignored wholesale.
- **Separate "wrong" from "I'd prefer."** Heuristic: if you're about to write "I would...", it's a preference — make it a Nit or drop it. Reserve Block and Request-changes for things that are actually wrong.
- **Read charitably.** If something looks odd, assume there's a reason and ask, rather than flagging it as a mistake. Surprising code is sometimes load-bearing.
- **Defer style to the project's tools.** Don't hand-flag formatting the linter/formatter owns. If the project has no formatter, that's one finding, not forty.
- **Praise honestly.** Don't manufacture it, but don't skip it when it's earned.

## Failure modes to actively avoid

- **"Looks good to me."** If you haven't run the tools, read the whole change, and checked the tests, you don't know that.
- **The 40-nitpick review.** Triage discipline exists to prevent this. Group and cap.
- **Reviewing the diff blind to the codebase.** A change can be locally clean and globally wrong (duplicates an existing helper, breaks a convention). Step 3 is not optional.
- **Trusting "there are tests."** Step 4 is where you verify they test the actual change.
- **Rewriting the author's code.** Suggested fixes are small inline snippets showing the idea, not "here's your whole function rewritten my way."
- **Confident nonsense about behavior.** If you're unsure whether something is a bug, say so and frame it as a question.

## Lightweight mode

When the user wants something fast (pre-commit, sub-minute):

1. Run only the formatter check, the linter, and the test runner on the diff.
2. Do Step 3 (read as a whole) and Step 4 (tests) — they're cheap and high-value.
3. Walk only categories 1–5 of the checklist.
4. Output a one-screen report: verdict + Block/Request-changes items only.

Tell the user it was the lightweight pass and a full review can follow.

## When the diff is huge

Over ~2000 changed lines, say so up front and offer to either (a) review by directory in batches, or (b) focus first on the files most likely to carry risk — anything matching the change's core logic, plus `*migration*`, `*auth*`, `*payment*`, schema files, and public API surfaces. Don't pretend to have deeply reviewed 5000 lines in one pass.

For a large diff you can also **fan the reading out to subagents** — one per area or risk cluster, each with a clean context returning a bottom line plus `file:line` evidence — and synthesize the findings yourself. The orchestration pattern is the same one project review uses; see the subagent section in `references/project-review.md`. One rule is non-negotiable in either mode: **verify every delegated claim before it enters the report.** Subagents misread line numbers, contradict each other, and invent bugs that aren't there. Re-check each high-severity finding against the actual code, discard the false positives explicitly, and never ship "an agent said X" — if you couldn't verify it, either verify it or cut it.
