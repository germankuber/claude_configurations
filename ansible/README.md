# Claude Code Environment — Ansible

Idempotent provisioning of a complete Claude Code setup on **macOS**.

## What it installs

| Role | Installs | Method |
|------|----------|--------|
| `sfw` | Socket Firewall + `pnpm`/`npm`/`yarn` aliases | official install script |
| `claude` | Claude Code CLI | `pnpm add -g @anthropic-ai/claude-code` |
| `python_tools` | `python@3.12`, `uv`, `pipx`, Headroom, spec-kit | Homebrew + pipx + uv |
| `mcp_servers` | MCP servers (user scope) | `claude mcp add` / plugin |

### MCP servers registered (user scope)

- **codebase-memory** — `codebase-memory-mcp` (reinstalled via pnpm)
- **context7** — `@upstash/context7-mcp` (API key via env)
- **filesystem** — `@modelcontextprotocol/server-filesystem` (scoped to `~/Documents/Repositories`)
- **github** — official Claude plugin `github@claude-plugins-official` (HTTP remote)

### Python tools

- **Headroom** (`headroom-ai[all]`) — context compression, registered as MCP via `headroom mcp install`
- **spec-kit** (`specify` CLI) — spec-driven development, via `uv tool install`

## Prerequisites

- macOS with [Homebrew](https://brew.sh)
- `pnpm` available on PATH (`PNPM_HOME` set)

## Usage

```bash
# One-shot: bootstraps Ansible + collections, then runs the playbook
./bootstrap.sh

# Or manually
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbook.yml
```

### Optional: Context7 API key

```bash
export CONTEXT7_API_KEY="your-key"
./bootstrap.sh
```

Without the key, Context7 is registered in limited mode.

## Configuration

All knobs live in [`group_vars/all.yml`](group_vars/all.yml):
filesystem roots, package names, versions, scope, etc.

## Notes

- **Idempotent** — re-running skips already-installed components.
- After the run, restart your shell (or `source ~/.zshrc`) to load the sfw aliases.
- The GitHub MCP plugin connects over HTTP and may require a Claude/GitHub
  re-authentication (`claude` then follow the auth prompt). That is runtime
  auth, not an install step.
- **No secrets are committed.** Keys are read from environment variables.
