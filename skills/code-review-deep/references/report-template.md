# Report Template

Use this structure. Drop sections that don't apply. Lead with the verdict, then the worst finding. Length follows findings — a clean change gets a short report.

---

## Code Review — `<PR title or commit-sha>`

**Scope:** `<files changed>` (`+N -M` lines across `<n>` files)
**Change type:** feature / bug fix / refactor / dep bump / breaking change / docs
**Tools run:** ruff ✓, mypy ✓, pytest ✓ (12 passed) — or note what was skipped and why
**Verdict:** ⛔ Block / 🔧 Request changes / 💬 Discuss / ✅ Looks good to merge

**Summary:** 1–3 sentences. What the change does, and the headline judgment. If there's one thing the author should read, it's this.

---

## ⛔ Block

> Must fix before merge. If none, write "None."

### 1. `<short descriptive title>`
**File:** `path/to/file.py:42`
**Category:** Correctness / Missing test / Breaking change / etc.

**What's wrong:**
> 2–4 sentences in plain language. Show the relevant snippet.

**Why it matters:**
> The concrete consequence — wrong result for input X, crash on empty list, silent data loss.

**Suggested fix:**
```python
# Before
if items: process(items[0])

# After — handle the empty case the caller can hit
if not items:
    return None
process(items[0])
```

---

## 🔧 Request changes

> Should fix before merge. Same structure, condensed.

### 1. `<title>` — `path/to/file.ts:88`
> What and why, 2–3 sentences. Inline snippet only if it clarifies.

---

## 💬 Discuss

> Design questions worth a conversation, not blocking. One short paragraph each.

- `service/orders.py` — the new retry wrapper duplicates the one in `http/client.py`. Worth consolidating, or is the duplication deliberate?

---

## 🎨 Nit

> Optional. Style, minor naming, formatting. One line each. Group similar ones.

- `utils.py:14` — `data` → something specific like `parsed_rows`
- `utils.py:30–48` — 4 more generic variable names in this function; rename together

---

## ✅ Praise

> Not optional. Call out what was done well — it reinforces good patterns and keeps the review honest.

- The migration in `0042_orders.py` is reversible and the backfill is idempotent. Nicely done.
- Good negative tests in `test_orders.py` — the empty-cart and over-limit cases are both covered.

---

## Checklist summary

> Quick coverage map so the author knows what was actually checked. One line per category — ✅ / ⚠️ / N/A.

| Category | Status | Note |
|---|---|---|
| Correctness & logic | ⚠️ | see Block #1 |
| Tests | ✅ | new paths covered, negative cases present |
| Code flow & coherence | ⚠️ | retry duplication, see Discuss |
| AI slop | 🎨 | generic names in `utils.py` |
| Refactoring & dead code | ✅ | — |
| ... | | |

---

## What was NOT reviewed

> Be honest about coverage.

- Did not run the integration suite (needs a live DB)
- Did not assess security depth — run `security-review-deep` if this touches a trust boundary
- The generated `*.pb.go` files (out of scope)

---

## Suggested next steps

> Maximum 3 bullets. Concrete, in priority order.

1. Fix the empty-list crash in `orders.py:42` before merge.
2. Add a test for the over-limit path.
3. Decide on the retry-wrapper duplication (consolidate or document why not).
