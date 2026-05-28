# Upgrade checklist: security-review-deep → senior-grade

Living tracker for upgrading this skill + MCP to match what a senior
security engineer would expect in 2026. Items are tagged P0 (blocking
gap), P1 (strong win), P2 (polish). Each one notes the rationale; deeper
justification + sources are in the chat transcript that produced this
list.

Mark items with `[x]` as they land. Add a one-line note when something
deviates from the plan or the scope changes.

---

## A. MCP server: new tools to add

- [x] **P0** `kev_lookup(cve_id)` — query CISA Known Exploited Vulnerabilities
  catalog. KEV membership is the strongest "weaponized in the wild"
  signal and should bump anything to top of triage. Implemented with
  1-hour TTL cache of the full catalog.
- [x] **P0** `epss_score(cve_id)` — FIRST.org EPSS API. Returns 0.0–1.0
  exploitation probability + percentile.
- [x] **P0** `composite_risk(cve_id)` — returns CVSS + EPSS + KEV + a
  single derived 0–100 score and triage bucket. Parallel-fetches the
  three upstreams.
- [x] **P0** `latest_safe_version(ecosystem, name, current_version)` —
  walks every OSV-affected range, returns per-advisory fix versions
  plus a best-effort smallest version that clears all of them.
- [ ] **P1** `package_health(ecosystem, name)` — last release date,
  maintainer count, recent commit activity, archived flag. Senior
  reviewers care about abandoned packages, not just CVE counts.
- [x] **P1** `ghsa_get(ghsa_id)` — GHSA-specific deep lookup via REST
  `/advisories/{ghsa_id}`. Pairs with the now-honest ghsa_search.
- [ ] **P2** `mitre_attack_lookup(technique_id)` — map findings to
  MITRE ATT&CK. Nice for threat modeling, not load-bearing.

## B. MCP server: bugs and rough edges

- [x] **P0** `ghsa_search` rewritten. Now forwards CVE / GHSA ids to the
  REST field filter for exact lookup. Free-text fallback is documented
  as best-effort (GitHub's REST advisory endpoint has no full-text
  field; results are newest-first, so historical advisories like log4j
  won't surface from a string search). Docstring now points callers to
  `check_package` for "find all advisories for package X" queries.
  Follow-up P1: replace free-text path with GraphQL `securityAdvisories`
  for real full-text + pagination.
- [x] **P0** MCP server audit complete. Bandit + semgrep clean.
  Added: CVE-id and GHSA-id regex validators, package-name charset
  validator, ecosystem alias normalization with length cap, keyword
  length cap, dependency-list size cap, 10 MiB response-size circuit
  breaker on every upstream call, OSV-id path-traversal guard.
- [x] **P1** `_summarize_osv` and `_summarize_nvd` now prefer CVSS v4
  then v3.1 then v3.0. v3-only fields are still returned via the v3
  fallback path.
- [x] **P1** KEV catalog cached for 1 hour per process (the catalog is
  ~2 MB and refetching per call was wasteful). Per-request caching of
  OSV / NVD / EPSS responses deferred to a P2 polish; they're already
  cheap enough per call.
- [x] **P1** Every response returns `source` and `fetched_at`. Helpers
  pull provenance from a single `_now()` so it's consistent across
  tools.
- [x] **P2** Already packaged via `[project.scripts]` in pyproject.toml.
  uv sync confirmed. README updated with the install + register
  commands.
- [x] **P1** `check_dependencies_bulk` hydrates concurrently
  (Semaphore(16)) instead of one-at-a-time. Reduces wall time on big
  lockfiles from minutes to seconds.

## C. Scanners to add to the workflow

Per-file-type routing: only invoke a scanner if its language appears
in the diff.

### Language-specific SAST

- [x] **P0** Go: `gosec` + `govulncheck` documented in SKILL.md Step 2
  language-specific block. install.sh prints a manual-install hint
  (needs Go toolchain).
- [x] **P0** Ruby/Rails: `brakeman` documented in Step 2; install.sh
  prints `gem install brakeman` hint.
- [x] **P0** JS/TS: `njsscan` documented and auto-installed via
  `uv tool install`. `eslint-plugin-security` and `retire.js` deferred
  (per-project npm deps rather than skill-wide tools).
- [x] **P0** Shell: `shellcheck` documented in Step 2; install.sh
  installs via brew.
- [x] **P0** Dockerfile: `hadolint` documented in Step 2; install.sh
  installs via brew.
- [x] **P1** Java/Kotlin: `spotbugs` + `find-sec-bugs` documented in
  Step 2 (manual install — requires a JVM build).
- [x] **P1** Rust: `cargo-audit` documented in Step 2; install.sh
  prints `cargo install cargo-audit` hint. `cargo-geiger` deferred.
- [ ] **P1** .NET: `security-code-scan` — not added; uncommon in this
  setup, can add when needed.
- [ ] **P1** PHP: `psalm` with security plugin — not added; uncommon.
- [ ] **P2** C/C++: `flawfinder` + `clang-analyzer` — not added.

### CI / supply chain / IaC

- [x] **P0** `zizmor` for GitHub Actions workflows. Step 2 CI block.
  install.sh installs via `uv tool install zizmor`.
- [x] **P0** `checkov` for IaC. Step 2 CI block. install.sh installs
  via `uv tool install checkov`.
- [x] **P0** `syft` + `grype` for SBOM-based vuln scanning. Step 2
  CI block. install.sh installs via the anchore install script.
- [x] **P1** `trufflehog` alongside `gitleaks`. Both in Step 2
  always-on block. install.sh installs via brew.
- [ ] **P1** `kube-score` + `kubesec` if K8s manifests present —
  deferred. `checkov` covers most K8s misconfiguration checks already.
- [ ] **P2** `CodeQL` on a schedule (nightly). Worth a one-line
  reference but not part of the skill's fast-path.
- [ ] **P2** Note Opengrep (Jan 2025 Semgrep CE fork) — informational
  only; add to a "scanner alternatives" note when needed.

## D. Checklist categories to add

- [x] **P0** Category 20: LLM / AI agent / MCP security added to
  threat-checklist (mirrors OWASP LLM Top 10 2025). Includes direct +
  indirect prompt injection, insecure output handling, excessive
  agency (functionality/permissions/autonomy), system-prompt leakage,
  RAG poisoning, unbounded consumption, plus an MCP-specific subblock
  (input validation, no shell from args, SSRF in fetch tools, auth on
  connect, response-size caps).
- [x] **P0** Web-app gaps filled. Added category 16 (web-app
  cross-cutting: CSRF, CORS, open redirect, security headers, cookie
  flags, cache poisoning, host header injection, clickjacking) and
  category 17 (protocol-specific: GraphQL introspection / depth /
  complexity / batching / error info leak; WebSocket origin + auth +
  size; gRPC; webhook signature + replay).
- [x] **P0** "Negative space" subsection landed as category 21. Covers
  routes missing from auth/rate-limit lists, PII fields missing from
  log scrubber, weakened controls in the deletion side of the diff,
  background jobs with elevated creds, config flags with surprising
  defaults.
- [x] **P1** Authorization-matrix walkthrough landed as category 18,
  with a structured `caller / side_effect / lesser_role_result`
  one-liner per endpoint and explicit IDOR / info-leak / button-hiding
  checks underneath.
- [x] **P1** Business-logic category 19: payment / coupon / refund,
  workflow step skipping, race-on-balance, signed-message replay,
  state-machine bypass, mass assignment.
- [ ] **P1** Multi-tenant data isolation. Covered indirectly in
  category 1 (trust boundaries) and category 18 (auth matrix), but a
  standalone bullet for "every tenant-scoped query carries tenant_id"
  would sharpen it. Deferred — current coverage is adequate.
- [x] **P1** Category 22: AI-generated code red flags. Tell-tale
  shapes + extra checks for input handling, swallowed errors, ad-hoc
  authz, duplicate helpers, happy-path-only tests.
- [ ] **P2** Mobile-specific (only if relevant): cert pinning, deep-link
  validation, exported component permissions.
- [ ] **P2** Cloud IAM checklist (only if IaC present, since checkov
  covers most): wildcard `*` actions, public S3, OIDC trust wildcards,
  KMS key policies.

## E. Process / methodology additions

- [x] **P0** Reachability gate on every dep CVE added to Step 3 of
  SKILL.md. Direct grep, language-specific tool (`govulncheck`,
  `pip-audit --strict`), or explicit "reachable: unknown." Every dep
  finding now must carry a `reachable: yes/no/unknown` tag.
- [x] **P0** KEV + EPSS triage rule baked into Step 5. KEV → Critical
  regardless of CVSS. EPSS >= 0.5 → minimum High. `composite_score`
  from `composite_risk` is the default order within bucket.
- [x] **P0** Run-summary JSON now required at the end of every report
  per Step 6. Format documented in SKILL.md.
- [ ] **P1** Secrets history pass: `trufflehog git file://./ --since-commit=...`
  even when the current diff is clean.
- [ ] **P1** Regression check. Diff against previous review in
  `.security-reviews/` (if exists). Flag new findings as regressions.
- [ ] **P1** Confidence levels on every finding: High (scanner-confirmed),
  Medium (pattern match, manual verification recommended), Low
  (heuristic, may be FP).
- [ ] **P1** Test-coverage check on changed lines. Flag changed
  security-relevant lines with no test coverage.
- [ ] **P2** Custom-rule prompt at end of review: "did you see a pattern
  here that should become a project-specific semgrep rule?" Write to
  `.semgrep/project-rules.yml`.
- [ ] **P2** Time-box per scanner with `timeout 300 ...` and report
  which ones timed out.

## F. Report / output improvements

- [x] **P0** Top-of-report banner: "3 KEV · 7 EPSS≥0.5 · 41 other"
  required in Step 6 of SKILL.md.
- [x] **P0** Every dep CVE gets `reachable: yes/no/unknown` tag
  (enforced in Step 3 + restated in Step 6).
- [ ] **P1** Machine-readable output toggle (SARIF or JSON alongside
  markdown) so CI can parse and the skill composes with other tools.
- [ ] **P1** Patch suggestions as diffs, including for dep bumps
  (`requests: 2.19.1 → 2.32.4 in requirements.txt:14`).
- [ ] **P2** PR-comment mode (post each finding as inline GitHub PR
  review comment via `gh api`).

## G. Repo / packaging hygiene (the skill itself)

- [x] **P0** `security-workflow.zip` deleted. It was a 2026-05-21
  snapshot of older copies of the same files that live at top level
  (SKILL.md, mcp_security_server.py, threat-checklist.md, etc.),
  referenced from nothing.
- [ ] **P1** Pin scanner versions in SKILL.md examples. Pre-commit
  config does this; SKILL.md doesn't. Deferred — versions drift fast
  and the skill's "use what's installed" model is more durable than
  pinning in docs.
- [x] **P1** `install.sh` extended to cover the full Step 2 stack:
  trufflehog, zizmor, checkov, hadolint, shellcheck, njsscan, syft,
  grype installed automatically; gosec / govulncheck / brakeman /
  cargo-audit print manual hints (they need a language toolchain).
  `install.sh --check` reports presence of each, distinguishing
  required (✗) from optional (-).
- [ ] **P2** Integration test: run the skill against a seeded
  vulnerable repo (OWASP juice-shop, DVPWA, etc.) and assert it
  catches the planted vulns. Without this, refactors can silently
  regress detection.

---

## Suggested order of attack

If we stop after five items, take these:

1. **MCP**: add `kev_lookup`, `epss_score`, `latest_safe_version`. Fix
   `ghsa_search`. Audit the MCP server's own input-validation surface.
2. **Workflow**: add `zizmor`, `checkov`, `hadolint`, `trufflehog`.
   Per-language routing for `gosec`/`brakeman`/`shellcheck`.
3. **Process**: reachability gate + KEV/EPSS triage rule.
4. **Checklist**: LLM/MCP category, web-app gaps, negative-space.
5. **Report**: run-summary JSON + reachability tag on dep findings.

Skip on purpose for now: CodeQL (slow, belongs in nightly CI), MITRE
ATT&CK tagging (cosmetic), mobile-specific (most projects don't need
it). They don't move the false-negative needle the way reachability +
KEV/EPSS + zizmor + checkov + the LLM category do.
