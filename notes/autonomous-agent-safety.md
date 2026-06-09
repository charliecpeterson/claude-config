# Running autonomous agents safely (overnight, least-privilege, small models)

Research notes, 2026-06-04. Scratch document for thinking and for a later
`/deep-planner` session. Not a plan yet — a landscape and a recommended
direction with sources.

## The goal

Run a coding agent — possibly a small/weak local model — for long stretches
(e.g. overnight) without approving every tool call, while staying safe: the
agent does only what the task needs and nothing more (least privilege), and a
compromised or confused agent can't read secrets, trash the host, or exfiltrate
data. This needs to work across the harnesses I actually use or might use:
Claude Code, Codex, OpenCode, Qwen Code.

This document folds in an earlier idea (`newideas.md`, a permissions/hooks/
sandbox layer for the `claude-config` repo). The short version of how this
revises that plan: the original centerpiece — a hand-rolled pre-approval hook
that decomposes compound bash and judges each command — is the weakest part for
the effort, and parts of it are now redundant with native harness features. The
load-bearing work is the sandbox + network boundary, not command vetting.

## Core principle: deterministic boundaries do the real work

The consensus across primary sources (Simon Willison; the DeepMind/IBM/ETH
design-patterns paper, arXiv 2506.08837; NVIDIA's AI Red Team guidance; OWASP)
is one sentence: **architectural boundaries bound the risk; an LLM checking
another LLM is a soft secondary layer, never the load-bearing control.**
Willison puts it bluntly — "you can't solve AI security problems with more AI"
— and is dismissive of guardrail products advertising "blocks 95% of attacks,"
since 95% is a failing grade for a security boundary.

The governing risk model is the **lethal trifecta**: an agent that
simultaneously has (1) access to private data, (2) exposure to untrusted
content, and (3) an exfiltration path is structurally exploitable, regardless
of model alignment. The recommended move is not "detect the bad command" but
**remove one leg**. For an autonomous coding agent the cheapest, most
deterministic leg to cut is the exfiltration path: network egress control.

This matters *more* when the model is weak, not less. A weak model is both a
worse worker and a worse judge, so you can't lean on its judgment — only on the
environment it runs in.

## The recommended stack (strongest first)

1. **Kernel-level sandbox, network off by default.** Seatbelt (macOS),
   bubblewrap + seccomp / Landlock (Linux) at minimum; Firecracker / Kata
   microVMs for genuinely untrusted code. This is the load-bearing layer. It's
   what makes "don't approve every tool" actually safe — the boundary is the
   environment, not per-command clicking.
2. **Egress allowlist enforced at a proxy / network layer that fails *closed*.**
   The single most-recommended concrete control, because it kills leg (3) of
   the trifecta directly and deterministically no matter what command runs.
   Default to no outbound; allowlist specific hosts; restrict DNS (DNS is itself
   an exfil channel).
3. **Deterministic allow/deny command rules** as the primary gate. Fast,
   testable, no model call. Claude Code and others already decompose compound
   commands (`&&`, `|`, `;`, `$()`) and match each sub-command, so a hand-rolled
   decomposer is no longer needed.
4. **Ephemeral, task-scoped credentials**, not inherited host creds; filesystem
   write-isolation to the workspace; and specifically block writes to
   agent-config files (`CLAUDE.md`, `AGENTS.md`, hooks, MCP configs) so
   untrusted input can't reprogram the agent.
5. **LLM judge only as a scaffolded fallback** for the ambiguous residue that
   rules can't classify, with human escalation on high-risk actions. Never the
   boundary.

## Why a pre-hook command verifier is the wrong primary layer

This was the original instinct, and it's worth understanding why it's weak.

**It checks the wrong thing.** The command string isn't where the risk lives.
`curl $URL -d @$FILE` looks fine until the variables resolve at runtime; an
innocent-looking command can do damage in context. A verifier inspecting command
text can't see intent or data flow. Egress control beats command vetting because
most real damage needs an exit path — so you remove the exit path instead of
trying to predict which of infinitely many command spellings is malicious.

**A weak model judging is exactly the failure regime.** Direct evidence, not
intuition: "Reliable Weak-to-Strong Monitoring of LLM Agents" (arXiv 2508.19461)
found a weak monitor *can* watch an agent with good scaffolding (Claude 3.6
Haiku hit AUC > 0.85 hierarchically), but under adversarial pressure — agent
aware it's monitored, using prompt injection or chain-of-thought obfuscation —
naive monitoring **collapses below AUC 0.50, worse than a coin flip**. The
paper's headline: scaffolding matters more than the monitor's model strength.
The "fox guarding the henhouse" worry is correct for the unscaffolded case.

**Documented failure modes of LLM permission hooks in the wild:** high false
positives (blocking safe `git push --force`), a model call on every tool
invocation (cost + latency), and semantic smuggling in both directions.
Practitioners who use one (e.g. Dyad running Claude Code for PR review) use it
strictly as the *last* tier: rule-based hooks first, model judge only for what
rules can't classify.

## Cautionary tale: even the experts get egress wrong

Egress control is the right layer, but string-matching hostnames in application
code is fragile. Claude Code's own network sandbox was bypassed twice:

- **CVE-2025-66479**: setting `allowedDomains: []` (the most restrictive option)
  evaluated as `0 > 0 = false`, silently disabling the proxy. Fail-*open*.
- A **SOCKS5 null-byte injection**: `attacker-host.com\x00.google.com` passed an
  `endsWith(".google.com")` check while the resolver saw the attacker host.
  Defeated wildcard allowlists for ~130 releases over ~5.5 months, exfiltrating
  `~/.aws/` and `~/.config/gh/` tokens over raw SOCKS5, which also bypassed the
  HTTP egress logs.

Lessons: enforce egress at the network layer with proper hostname
canonicalization, fail *closed*, and log at the network boundary, not just the
HTTP layer.

## Cross-harness: the security layer does NOT port

Instructions port (`AGENTS.md`, Skills are genuinely cross-harness). The
**security layer is bespoke per harness — there is no emerging standard for
it.** Defaults differ enough that the same mental model is actively wrong across
them. The portable thing is the *posture* (sandbox, network off, deterministic
allow/deny, scoped creds), which you re-implement per harness.

| Harness | Default sandbox | Network default | Approval modes | Pre-exec hook |
|---|---|---|---|---|
| **Codex CLI** | OS sandbox **on by default** (Seatbelt / bwrap+seccomp) | **Off by default** in `workspace-write` | `untrusted` / `on-request` / `never` / `granular`; `sandbox_mode`: `read-only` / `workspace-write` / `danger-full-access`; `--full-auto`, `--yolo` | No user-facing scriptable pre-exec hook |
| **Claude Code** | bwrap / Seatbelt, historically **off by default** (`/sandbox`, `sandbox.*` settings) | Off when sandbox on + egress configured | `deny`/`ask`/`allow` rules, first-match wins; native compound-command decomposition | `PreToolUse` + `PermissionRequest` hooks (can approve/deny) |
| **Qwen Code** | **Opt-in, off by default** (Seatbelt or Docker/Podman) | Default Seatbelt profile (`permissive-open`) allows network | `plan` / `default` / `auto-edit` / `yolo` | No documented scriptable pre-exec hook |
| **Gemini CLI** | **Opt-in, off by default** (Seatbelt or container); auto-on with `--yolo` | `permissive-open` allows network | `default` / `auto_edit` / `yolo` | No documented scriptable pre-exec hook |
| **OpenCode** | **None at OS level** — permission gate + path-scoping only | No network sandboxing | per-tool `allow`/`ask`/`deny`, last-match wins | `tool.execute.before` plugin hook (but bug #5894: doesn't intercept subagents) |

Practical reading:

- **Codex has the strongest defaults** — sandbox on, network off. You opt *into*
  danger. `--full-auto` keeps you sandboxed; `--yolo` drops both.
- **Qwen / Gemini** are the same model (Qwen forks Gemini). Documented autonomous
  posture is `--yolo` *plus* an explicitly enabled sandbox; yolo without an
  enabled sandbox gives you nothing. Default profile allows network — use
  `permissive-closed` / `restrictive-closed` to cut egress.
- **OpenCode has no real sandbox.** Its "sandbox" is permission rules plus
  path-scoping; anything `allow`ed runs with full user privileges and full
  network. Its `tool.execute.before` hook is the most flexible programmatic
  vetting layer of the four, but the subagent-bypass bug means it can't be the
  sole boundary today.

## Off-the-shelf option: NVIDIA OpenShell

`github.com/NVIDIA/OpenShell`, Apache-2.0, written mostly in Rust. A governance
runtime that runs an unmodified coding agent (Claude Code, Codex, OpenCode,
Gemini CLI) as a restricted child process inside a sandbox and enforces
declarative policy around it. It's close to a turnkey implementation of the
recommended stack above, and the most directly relevant thing to the goal.

**Maturity caveat, up front:** as of 2026-06-04 it's **v0.0.56, self-labeled
alpha / "single-player mode,"** released essentially now, with a fast release
cadence. Not production-ready. Adopting alpha software *as the security boundary*
for unattended overnight runs is exactly the case where "boring and durable"
should win. Read it as a strong direction to prototype and track, not something
to build the repo's safety layer on this month.

Architecture (three parts):

- **Gateway (control plane):** owns durable state and, crucially, **holds the
  provider credentials**. Provisions sandboxes, enforces policy, brokers CLI
  requests.
- **Supervisor (per-sandbox boundary):** launches the agent as a restricted
  child process and enforces filesystem / process / network policy. Connects
  outbound to the gateway.
- **CLI / SDK / TUI:** the user-facing client.

Policy is **declarative YAML across four domains:**

- **Filesystem:** `read_only` / `read_write` path allowlists, enforced via Linux
  **Landlock**. Locked at sandbox creation.
- **Process:** `run_as_user` / `run_as_group`, privilege-escalation and
  dangerous-syscall blocking. Locked at creation.
- **Network: default-deny egress**, allowlisted by **hostname + port with L7
  HTTP method/path filtering** (the proxy terminates TLS to inspect each request;
  `enforce` or `audit` per endpoint). Hot-reloadable on a running sandbox. This
  is exactly the fail-closed, proxy-enforced egress control the research flagged
  as the single most valuable layer.
- **Inference (the inference router / policy proxy):** the agent talks to
  `https://inference.local` and the gateway substitutes the real provider key,
  so **the API key never enters the sandbox**. Directly mitigates credential
  exfiltration, and lets you route to a local model (Ollama, SGLang) instead of
  a frontier API. (This is the "Privacy Router" the blog named; docs call it the
  inference router / policy proxy.)

Compute backends: **Docker, Podman (rootless), MicroVM, Kubernetes.** Rootless is
achievable (rootless Podman, or Docker via group membership); no mandatory root
for the documented paths. MicroVM uses Apple's **Hypervisor.framework on macOS**
and KVM/QEMU on Linux. Nothing in the docs gates it to NVIDIA/DGX hardware,
despite the DGX-targeted tutorials.

Install: `curl -LsSf .../install.sh | sh` or `uv tool install -U openshell`,
then `openshell sandbox create -- claude`. (The `--remote spark --from openclaw`
syntax floating around isn't real: `sandbox create` has no `--remote` flag and
"spark" is the DGX hardware, not an argument. Remote use is `openshell gateway
add https://<endpoint>` to point the local CLI at a gateway running elsewhere.)

**Build-vs-buy read:** the design is a near-perfect match for the recommended
stack (default-deny L7 egress, Landlock filesystem isolation, credential
isolation via the inference router, cross-harness). For a solo maintainer it's
appealing as one maintained boundary under every harness instead of per-harness
config. Counterweights: it's **alpha** (the dominant one), adds a whole runtime +
gateway as a dependency, and the HPC machines can't run it at all (no
Docker/Podman; see topology). Verdict for now: prototype on the 4090 box, track
maturity, don't commit the repo to it until it's past alpha.

## Deployment topology: one policy, multiple backends

The `claude-config` repo started as a bag of skills I copy between machines.
It's outgrowing that into "my portable agent config, with enforcement that
differs per machine." The framing that makes "what goes where" tractable is to
**separate policy from mechanism**:

- **Policy is portable and identical everywhere**: the deny-list of irreversible
  commands, default-network-off posture, least-privilege intent, instructions
  (`CLAUDE.md` / `AGENTS.md`, style/communication/engineering), and skills.
- **The enforcement mechanism is per-machine and cannot be unified**, because my
  four machine classes have genuinely different isolation primitives.

The hard constraint that kills "OpenShell everywhere": **OpenShell will not run
on the HPC clusters.** Its backends are Docker / Podman / MicroVM / Kubernetes.
On Stampede3 and Anvil there's no root and no Docker daemon (the daemon is root,
which is why HPC centers don't grant it), and even rootless Podman is often
restricted; the sanctioned runtime is Apptainer/Singularity. So the "minimal
sandbox for when I don't want full OpenShell" isn't a convenience toggle on HPC,
it's the only option available. That reframes the minimal layer as a *required
second backend for the same policy*, not an optional one.

Machine classes and their boundary mechanism:

| Class | Privileges | Boundary mechanism | Autonomous overnight? |
|---|---|---|---|
| **Mac (M2 Ultra)** | root, Docker | Seatbelt now; later OpenShell (Hypervisor.framework MicroVM) or thin client to the Linux gateway | Maybe (or drive Linux remotely) |
| **Linux + 4090** | root, Docker/Podman | OpenShell (strongest isolation); the natural home for overnight runs | Yes (primary) |
| **HPC (Stampede3, Anvil)** | no root, Apptainer only | tight deny list + scoped creds + the existing unprivileged shared-system/scheduler boundary; optional Apptainer wrapper | Probably not |
| **Quick / general instances** | varies, disposable | the throwaway VM *is* the sandbox; residual concern is egress | Yes, blast radius = the instance |

A simplifying question worth answering before designing for all four equally:
**does overnight-autonomous even apply to HPC and quick instances?** Realistically
the unattended agent lives on the 4090 box (maybe the Mac). On HPC I'm more
likely driving the agent interactively to build and submit jobs, and running an
unattended process on a login node often violates acceptable-use anyway. On a
throwaway instance "autonomous" is fine because the blast radius is the instance.
If that holds, **OpenShell only needs to target two machines**, and the HPC/quick
story collapses to "good instructions + tight deny list + the boundary that
already exists." That's a large simplification; confirm it rather than assuming.

### Macs specifically (near-term)

We're on the Mac now, so the concrete near-term question is what to run here
before OpenShell is mature enough to trust. Three options, soonest-usable first:

1. **Native Claude Code sandbox (Seatbelt) + deny list + egress allowlist.** Ships
   today, maintained by Anthropic, zero new dependencies. The right default for
   the Mac right now: enable `/sandbox`, set a `permissions.deny` baseline, lock
   network to an allowlist. Good enough for bounded auto-approve sessions where
   the Mac is the host.
2. **OpenShell locally via Hypervisor.framework MicroVM.** A real VM boundary on
   the Mac without Docker Desktop, same policy model as the Linux box. Blocked
   only by OpenShell's alpha status; revisit as it matures.
3. **Mac as a thin client to a gateway on the 4090 box** (`openshell gateway add
   https://<linux-box>`). The heavy, network-locked sandbox runs on Linux while
   you drive from the Mac. Best fit for *overnight autonomous* work: the strongest
   isolation (Linux + bwrap/KVM) does the containment, and the Mac needn't stay
   awake.

Near-term recommendation: native Seatbelt on the Mac for day-to-day bounded
auto-approve; push real overnight-autonomous runs to the Linux box (option 3)
once OpenShell is validated there.

### Install architecture (lean target, not to build yet)

A shared base plus thin per-class overlays, not a profile framework:

- `base/` — instructions + skills + the baseline deny-list policy. Installed
  everywhere, unconditionally.
- per-class overlays that add only the boundary config that class can use:
  OpenShell policy for mac / linux-gpu, the Apptainer/native posture for HPC, an
  egress-only note for ephemeral.
- `install.sh` learns one new thing: a `--profile` arg (or a `~/.claude-profile`
  file it reads), symlinks base always, then the matching overlay. ~30 lines on
  top of the current script, keeping the backup-before-replace and idempotent
  behavior.
- Machine-local state (enabled MCP servers, plugins, keys) stays in
  `settings.local.json`, unsynced, exactly as today.

**Do not build the profile system yet.** The architecture above rests on two
unvalidated assumptions: that OpenShell is good enough to adopt on the 4090, and
that it genuinely can't run on the HPC clusters. Both are cheap to test and
expensive to be wrong about after building structure around them. Validate
first, design the split second, because the test results determine how many
backends are actually needed and what the overlays contain.

## What this points to for me

For "small model running overnight, no per-tool babysitting, safe,
least-privilege," the move that lets babysitting stop *safely* is to make the
environment the boundary:

- Run the session **inside a sandbox with network off** (or a tight egress
  allowlist), so auto-approve is bounded by the environment, not per-command
  judgment.
- A deterministic `deny` list for the irreversible stuff; let native
  compound-command decomposition handle chaining.
- **Skip the LLM verifier.** If ever added, it's tier-3 behind the sandbox, and
  over a weak model the data says it's near-useless under adversarial input.
- Two credible paths: (a) configure each harness's native sandbox + egress
  myself (more control, re-done per harness, the `claude-config` repo carries
  the Claude Code + Codex posture); or (b) adopt **OpenShell** as one
  cross-harness boundary under all of them. Worth a real evaluation before
  choosing.

## Open questions for `/deep-planner`

**Validate before planning (these run on the Linux/4090 box, not the Mac where
these notes were written):**

- [ ] Install OpenShell on the 4090 box, run a real session through it, and check
  its actual policy format, granularity, and overhead. Decide if it's good enough
  to adopt.
- [ ] Confirm whether Anvil / Stampede3 offer rootless Podman or only Apptainer
  (determines whether OpenShell is fully out on HPC or partially usable).
- [ ] Confirm whether overnight-autonomous realistically applies beyond the 4090
  box / Mac (if not, OpenShell targets two machines and the design simplifies).

**Then plan:**

- [ ] OpenShell vs. roll-your-own native sandbox config: which fits a solo,
  durable, cross-harness setup better? Evaluate OpenShell hands-on (policy
  format, overhead, maturity, how cleanly it wraps each harness).
- [ ] Which harness is the primary target for overnight autonomous runs? (Codex
  has the best defaults; Claude Code is the daily driver.) Posture differs.
- [ ] Where does the overnight agent run — the RTX 4090 Linux box (bwrap, real
  egress proxy) or the Mac (Seatbelt)? Linux is the stronger isolation story.
- [ ] Egress policy: full network-off, or a fail-closed allowlist (package
  registries, specific APIs)? Who enforces it (harness sandbox vs. OpenShell
  gateway vs. host firewall)?
- [ ] Credential model: how to give the agent task-scoped, short-lived creds
  instead of inheriting `~/.ssh`, `~/.aws`, `gh` tokens.
- [ ] Audit logging at the network boundary (not just HTTP), and where logs live
  (gitignored).
- [ ] What goes in `claude-config`: a synced baseline `permissions.deny` +
  `sandbox.*` for Claude Code, the equivalent Codex `config.toml` posture, and
  (if adopted) OpenShell policy files — kept lean, machine-specific state stays
  in `settings.local.json`.

## Prior art evaluated and set aside

From the original `newideas.md` plan (a hand-rolled permissions/hooks layer in
`claude-config`), superseded by the native + OpenShell direction above but worth
keeping as references:

- **liberzon/claude-hooks** — `smart_approve.py`, AST-decomposes compound bash
  and checks each sub-command. Now redundant: Claude Code decomposes compound
  commands natively.
- **@abdo-el-mobayad/claude-code-fast-permission-hook** (`cf-approve`) — a small-
  model LLM permission verifier, tiered + cached (~$1 per 5,000+ decisions).
  Only relevant as a tier-3 fallback behind a sandbox; rejected as a primary
  control.
- **affaan-m/everything-claude-code** (ECC, MIT) — cross-harness reference kit
  (Claude Code / Codex / Cursor / OpenCode / Gemini / Zed / Copilot). Reference
  only; keep the repo lean, don't bulk-import.

Rejected approaches: buying the ClaudeFast paid kit (its value is exactly the
non-portable, Claude-locked layer); blanket `--dangerously-skip-permissions`
with no boundary (fine *only* inside a tight sandbox); a small LLM verifier as
the primary control for a weak worker (double jeopardy, "fox guarding the
henhouse").

## Sources

Primary / documented:

- Lethal trifecta — https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/
- Prompt-injection design patterns — https://simonwillison.net/2025/Jun/13/prompt-injection-design-patterns/ (arXiv 2506.08837)
- Weak-to-strong monitoring — arXiv 2508.19461
- NVIDIA AI Red Team sandboxing guidance — https://developer.nvidia.com/blog/practical-security-guidance-for-sandboxing-agentic-workflows-and-managing-execution-risk/
- Claude Code permissions/hooks — https://code.claude.com/docs/en/permissions
- Claude Code sandbox bypasses — https://www.securityweek.com/anthropic-silently-patches-claude-code-sandbox-bypass/ ; https://oddguan.com/blog/second-time-same-sandbox-anthropic-claude-code-network-allowlist-bypass-data-exfiltration/
- Codex sandboxing — https://developers.openai.com/codex/concepts/sandboxing ; approvals — https://developers.openai.com/codex/agent-approvals-security
- OpenCode permissions — https://opencode.ai/docs/permissions/ ; plugins — https://opencode.ai/docs/plugins/ ; subagent hook bug — https://github.com/sst/opencode/issues/5894
- Qwen Code sandbox — https://qwenlm.github.io/qwen-code-docs/en/users/features/sandbox/
- Gemini CLI sandbox — https://google-gemini.github.io/gemini-cli/docs/cli/sandbox.html
- NVIDIA OpenShell — https://github.com/NVIDIA/OpenShell ; https://build.nvidia.com/openshell ; https://developer.nvidia.com/blog/run-autonomous-self-evolving-agents-more-safely-with-nvidia-openshell/ ; https://docs.nvidia.com/openshell/latest/index.html

Secondary / opinion (consensus shape, but vendor-adjacent): Cyera, HiddenLayer,
Airia, Firecrawl, Northflank blogs; treat specific claims as opinion unless they
trace to a primary source above.
