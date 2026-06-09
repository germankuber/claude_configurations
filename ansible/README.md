# Claude Code Environment — Ansible

Idempotent provisioning of a complete Claude Code setup on **macOS**.

## What it installs

| Role | Installs | Method |
|------|----------|--------|
| `sfw` | Socket Firewall + `pnpm`/`npm`/`yarn` aliases | official install script |
| `claude` | Claude Code CLI | `pnpm add -g @anthropic-ai/claude-code` |
| `python_tools` | `python@3.12`, `uv`, `pipx`, Headroom, spec-kit | Homebrew + pipx + uv |
| `mcp_servers` | MCP servers (user scope) | `claude mcp add` / plugin |
| `claude_local` | `claude-local` launcher script + zsh alias | file + blockinfile |

### MCP servers registered (user scope)

- **codebase-memory** — UI variant binary in `~/.local/bin` (official installer
  `install.sh --ui`); registered with `--ui=true` so the 3D graph runs at
  **http://localhost:9749** whenever Claude is connected. The pnpm package is the
  standard (no-UI) variant, so it is NOT used here.
- **context7** — `@upstash/context7-mcp` (API key via env)
- **filesystem** — `@modelcontextprotocol/server-filesystem` (scoped to `~/Documents/Repositories`)
- **ccusage** — `@ccusage/mcp` (Claude Code token usage / cost analytics)
- **github** — official Claude plugin `github@claude-plugins-official` (HTTP remote)

### claude-local launcher

`scripts/claude-local` — interactive launcher that runs Claude Code with
per-project or global MCP data dirs (CBM + Headroom), optional Headroom
wrapping, and an optional `--dangerously-skip-permissions` toggle. The
`claude_local` role makes it executable and adds a `claude-local` zsh alias.

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
