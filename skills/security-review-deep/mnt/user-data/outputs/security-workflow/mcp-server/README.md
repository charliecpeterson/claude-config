# Security Advisories MCP Server

A Model Context Protocol server that gives any MCP-aware LLM (Claude Code,
Claude Desktop, custom agents) live access to vulnerability data from:

- **OSV.dev** — Google's aggregator across PyPI, npm, crates.io, Go, Maven, NuGet, RubyGems, Packagist, GHSA, and more
- **NVD** — canonical CVE database
- **GitHub GHSA** — curated advisories with patched-version ranges

## Why this exists

Static scanners (Semgrep, Trivy, OSV-Scanner) tell you *what* is vulnerable. An LLM with these tools can tell you:

- whether a finding is actually exploitable in your code path,
- what the fix is and the safe version to upgrade to,
- whether a CVE that just dropped affects you,
- and how to prioritize a backlog of findings.

The smaller the model, the more it benefits from grounded, real-time data — it stops guessing about advisory IDs and version ranges.

## Tools exposed

| Tool | Purpose |
|---|---|
| `check_package` | Is `name@version` in ecosystem X vulnerable? |
| `check_dependencies_bulk` | Same, batched for whole lockfiles |
| `lookup_cve` | Full NVD record for a CVE ID |
| `recent_critical_cves` | "What HIGH/CRITICAL CVEs dropped in the last N days?" optional keyword filter |
| `ghsa_search` | Search GitHub Security Advisories |

## Install

```bash
cd mcp-server
pip install -e .
# or: uv pip install -e .
```

## Wire into Claude Code

```bash
claude mcp add security-advisories -- python /absolute/path/to/mcp_security_server.py
```

## Wire into Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or equivalent:

```json
{
  "mcpServers": {
    "security-advisories": {
      "command": "python",
      "args": ["/absolute/path/to/mcp_security_server.py"],
      "env": {
        "GITHUB_TOKEN": "ghp_...",
        "NVD_API_KEY": "..."
      }
    }
  }
}
```

Env vars are optional but recommended — they lift rate limits substantially.

## Test it

After wiring up, ask Claude:

> Is `requests==2.19.1` vulnerable?
>
> Look up CVE-2024-3094.
>
> What HIGH/CRITICAL CVEs related to nginx were published in the last 30 days?

The model will call the tools and return grounded answers with sources.
