# Project archetypes

Reference for the `deep-planner` skill. Load this at Phase 0 to
present the archetype choices, and again at Phase 2 to pull the
matching "secretly upstream" checklist into the decision map.

Five archetypes cover the common project shapes. They have
different upstream concerns, different readiness questions, and
different prior-art surfaces.

## The five archetypes

- **product/service** — a running service (web app, SaaS, internal
  tool, API). Concerns: auth, billing, hosting, observability,
  on-call, scale.
- **data/ML** — a model plus a pipeline, possibly with a serving
  layer. Concerns: data coverage and bias, baseline to beat,
  evaluation protocol, applicability domain, train/serve skew,
  dataset versioning, experiment tracking.
- **research artifact** — output is a paper, a benchmark, or a
  reproducible result others will cite. Concerns: prior-art
  coverage, statistical rigor, reproducibility for reviewers, code
  and data release plan.
- **library/CLI** — released for others to consume (PyPI, npm,
  Homebrew, container). Concerns: API stability promise, version
  compatibility, deprecation policy, distribution, documentation.
- **pipeline** — data infrastructure, ETL, batch jobs, stream
  processing. Concerns: idempotency, schema evolution, backfill,
  partial-failure semantics, data quality, lag.

Hybrids are common. A scientific ML project is often data/ML +
research artifact + (eventually) product/service. The user names
the **primary** archetype; the conductor asks whether to apply
concerns from secondary archetypes too. When secondary archetypes
are declared, union in their upstream checklists below.

## Per-archetype "secretly upstream" concerns

These are decisions that usually get missed in casual planning,
discovered too late, and force rework. Each archetype carries its
own list. The conductor pulls the matching list into Phase 2
(decision-tree mapping) so these land in the map *before* Phase 3
resolves anything. Items without a clear position become either
Open Questions or Deferred Register entries; they do not silently
default.

### product/service

- Tenant model (single tenant vs multi-tenant).
- Identity model (anonymous, account, SSO, OAuth, sector-specific).
- Pricing or business model (if applicable).
- Hosting boundary (where it runs, who owns the infrastructure).
- Compliance scope (GDPR / HIPAA / PCI / sector-specific).

### data/ML

- Selection bias and label coverage. What's in the training data
  is a function of what's been measured, observed, or annotated,
  rarely a representative sample.
- True negatives. Many domains have no recorded negatives; the
  task may need reframing as ranking rather than classification.
- Baseline to beat. The paper has no claim without one. Specify
  the baseline before the model.
- Evaluation split strategy. Split by chemistry / patient /
  document / scaffold / time, NOT by row. Random splits leak.
- Applicability domain. When asked about a region of input space
  with no training data, does the model say "I don't know" rather
  than guess confidently?
- Reproducibility (seed, environment lockfile, dataset version,
  deterministic preprocessing).
- Data licensing — can the data be redistributed, fine-tuned on,
  shipped with the model, used commercially?
- Experiment tracking — how runs are compared, what gets logged.
- Dataset versioning — v1 vs v2 of the data is what.
- Model versioning and registry.
- Train/serve skew — inference features match training features.

### research artifact

- Prior-art coverage — what's been published, where the new work
  positions itself.
- Baseline to beat — explicit comparison; what makes the new work
  a claimed improvement.
- Statistical methodology — power, significance, multiple
  comparisons, confidence intervals.
- Reproducibility kit for reviewers — code, data, environment,
  expected outputs sufficient to rerun the headline result.
- Code and data release — license, hosting, DOI or permanent
  identifier.
- Negative results disclosure — what didn't work, honestly.
- Ethical / regulatory review (IRB, animal use, dual-use, data
  subject consent), where applicable.
- Long-term archive — where the artifact lives in 5 years.

### library/CLI

- API stability promise — SemVer policy, what counts as a
  breaking change.
- Supported runtime / language versions and drop policy.
- Deprecation strategy — how users learn something is going away.
- Distribution channels — PyPI, npm, Homebrew, container, source.
- Documentation contract — quickstart, reference, examples.
- License — chosen, applied uniformly.
- Maintainership and response policy (especially for solo
  maintainers).

### pipeline

- Idempotency — can the same input be processed twice without
  doubling the output?
- Schema evolution — what happens when input shapes change.
- Backfill story — how do you rerun history when logic changes?
- Partial-failure semantics — what happens when 1% of records
  fail; isolation vs propagation.
- Data quality gates — what's checked before downstream consumers
  see the data.
- Lag and freshness — how stale is acceptable; how it's measured.
- Lineage — for any output, can the inputs and code version be
  recovered?
