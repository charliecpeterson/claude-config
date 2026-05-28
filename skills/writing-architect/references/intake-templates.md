# Intake templates: cannot-invent categories by document type

The cannot-invent list is the most important intake step. It enumerates
the domain commitments the AI must not silently fill in. The templates
below are starting points for common document types — they save the
intake from being a blank page. Adapt each to the specific work.

## How to build a cannot-invent list

For each document type, ask: "What specific values would a domain
reviewer expect to see, and what would they conclude if I made them
up?" Anything where the answer is "they'd lose trust in the author" is
on the list.

A useful cannot-invent item has three parts:
- **Category**: what kind of value it is (functional, dataset, cohort).
- **Why uninventable**: what a reviewer concludes if the value is
  wrong, vague, or generic.
- **Default behavior when missing**: usually a placeholder
  (`[FUNCTIONAL: TBD]`) so the user can fill in later.

The skill should walk these category-by-category at intake, asking
the user for each one. Anything the user can't supply right now
becomes a placeholder in the draft.

---

## Template: Computational/quantum chemistry proposal

For grants like ACCESS, NERSC, INCITE, or generic NSF/DOE submissions
where the panel includes computational chemists.

- **DFT functional(s)** — e.g., B3LYP, ωB97X-D, PBE0. "DFT" alone
  signals the author hasn't decided.
- **Basis set(s)** — e.g., def2-TZVP, aug-cc-pVTZ, cc-pwCV5Z.
- **Active space** for multireference methods — e.g., CAS(8,8),
  CAS(14,12). "CASSCF" without the active space is incomplete.
- **Hamiltonian variant** for relativistic work — DC, DCB, X2C-MMF,
  exact-2c. "Four-component DIRAC" alone is ambiguous.
- **Pseudopotential or all-electron** choice for heavy elements.
- **Specific molecular systems** — named ligands, named element pairs,
  specific complexes. Not "REE/actinide pairs" with no pairs.
- **Software modules** — e.g., NWChem's TCE, Molpro's MRCC. "We will
  use NWChem" is generic.
- **Real compute numbers** — cores, wallclock, memory per job from
  prior runs. Estimates dressed as benchmarks are a red flag.
- **Storage estimates** — TB of project space, TB of scratch per job.
- **Spin states and electronic configurations** explicitly studied.

---

## Template: Machine-learning / AI paper or proposal

For papers, workshop submissions, or grants where the panel includes
ML researchers.

- **Architecture details** — layer count, hidden dim, head count,
  positional encoding variant. "Transformer-based" is not a method.
- **Dataset names and splits** — exact splits (random / scaffold /
  temporal / by-X), seed handling, deduplication policy.
- **Hyperparameters that drive results** — learning rate, batch size,
  warmup, weight decay, dropout, training tokens.
- **Specific baselines** — named prior methods compared against, not
  "we compare against standard baselines."
- **Compute budget actually used** — GPU type, hours, total
  parameter-updates. Hand-waved compute is a giveaway.
- **Evaluation metrics chosen** — exact metric definition (exact
  match, BLEU variant, ROUGE variant, win-rate against what).
- **Ablations performed** — specific factors swept.
- **Failure modes observed** — what the model gets wrong. The absence
  of this section is a credibility issue on its own.
- **Reproducibility artifacts** — code release plan, checkpoint
  release plan, eval harness.

---

## Template: Biomedical / preclinical proposal

For NIH R01/R21, similar grants, where the panel includes biologists,
clinicians, or biostatisticians.

- **Specific assays** — named, with relevant cell lines or animal
  models. Not "we will use standard assays."
- **Cell lines or animal models** — specific strains, vendor, age,
  sex distribution if relevant.
- **Cohort sizes** — power analysis behind each cohort.
- **Specific biomarkers or endpoints** — named measurements with
  measurement protocol.
- **Dose ranges or treatment regimens** — for any intervention work.
- **Statistical methods** — named tests, correction for multiple
  comparisons, handling of confounders.
- **Prior preliminary data** — actual numbers from prior pilot work,
  not "preliminary data suggests."
- **Regulatory / IRB / IACUC status** — approved, pending, planned.
- **Specific collaborators** — for assays you don't run in-house.

---

## Template: General academic paper (conference or journal)

For peer-reviewed work in any field; defaults that apply when domain-
specific intake doesn't fit cleanly.

- **Specific claims under contribution** — what's new, stated as
  enumerated contributions.
- **Specific prior work being extended or challenged** — named papers,
  not "prior work has shown."
- **Specific experimental setup** — instruments, samples, parameters
  used.
- **Specific data sources** — provenance of any external data.
- **Specific limitations** — named, not gestured at. The "limitations"
  section is a credibility lever.
- **Specific reproducibility plan** — what's released, where, under
  what license.

---

## Template: Internal business memo / proposal

For a memo going to specific people inside an organization. Less
formal than a paper or grant, but the cannot-invent list still
matters — invented numbers in an internal doc destroy trust faster
than in a grant.

- **Real numbers from real systems** — current revenue, cost, head
  count, latency, error rate. Not "approximately several percent."
- **Specific people and roles** — by name, not "the team" or "leadership."
- **Specific timelines** — concrete dates, not "next quarter."
- **Specific decisions being asked for** — what the reader is being
  asked to approve, fund, or change.
- **Specific tradeoffs being made** — what's being given up, named.
- **Specific risks** — named scenarios, not "risks include various
  factors."

---

## Template: Technical white paper / external-facing report

For documents that go to external readers (customers, partners, the
public). Specificity here is about credibility with people who can't
easily verify your claims.

- **Specific products, systems, or platforms** named.
- **Specific benchmark numbers** with the benchmark named, the
  hardware named, the methodology disclosed.
- **Specific case studies** — named customers (with permission) or
  anonymized with enough detail to be useful.
- **Specific versions** of any software referenced.
- **Specific competitors or alternatives** when comparing.
- **Specific authors and dates** on any cited prior work.

---

## Adapting the template

If the user's document type isn't in this file:

1. Ask the user what kind of document this is and who reviews work
   like it.
2. From that, derive the kind of values a reviewer expects (methods,
   parameters, named systems, numbers, sources).
3. Read existing examples of the document type if the user can point
   to any — that's the fastest way to learn what specificity matters.
4. Build a short cannot-invent list (5–10 items is usually enough)
   tailored to the type.

The templates above are starting points, not exhaustive checklists.
Drop categories that don't apply. Add categories specific to the
work. The cannot-invent list should fit on one screen — if it's
longer than that, you're trying to enumerate everything in the
document instead of just the things the AI must not invent.
