# claude_configurations

Reproducible **Claude Code** environment for macOS, provisioned with Ansible.

One command sets up the CLI, the MCP servers, the supporting tooling, and a
custom launcher — so a fresh machine ends up identical to this one.

## What it sets up

| Component | What | How |
|-----------|------|-----|
| **Claude Code** | The CLI itself | official installer (`~/.local/bin/claude`) |
| **sfw** | Socket Firewall + `pnpm`/`yarn` shell aliases | install script |
| **Python tooling** | `python@3.12`, `uv`, `pipx`, Headroom, spec-kit | Homebrew / pipx / uv |
| **Docker** | Docker CLI + Compose (daemon check) | Homebrew |
| **Agent Monitor** | Real-time Claude Code dashboard (`:4820`) | Docker + session hooks |
| **MCP servers** | codebase-memory, context7, filesystem, ccusage, headroom, github | `claude mcp add` / plugin |
| **claude-local** | Interactive launcher script + zsh alias | file + zsh alias |

### MCP servers (user scope)

- **codebase-memory** — code knowledge graph (UI variant, 3D graph at
  `localhost:9749`). Use it for structural questions ("who calls X", dependency
  /impact analysis); it shines on large repos.
- **context7** — up-to-date library docs (API key via `CONTEXT7_API_KEY`).
- **filesystem** — scoped to `~/Documents/Repositories`.
- **ccusage** — Claude Code token usage / cost analytics.
- **headroom** — context compression proxy.
- **github** — official Claude plugin (HTTP remote; auth-gated).

## Quick start

```bash
cd ansible
export CONTEXT7_API_KEY="your-key"   # optional
./bootstrap.sh                        # installs Ansible + collections, runs the playbook
```

The playbook is **idempotent** — re-running it only changes what drifted.
See [`ansible/README.md`](ansible/README.md) for per-role detail and options.

## claude-local

`scripts/claude-local` — interactive launcher (aliased as `claude-local`) that
starts Claude Code with:

- **Per-project or global MCP data** (`~/.claude-mcp-data/<project>` or `_global`)
  for codebase-memory (CBM) and Headroom.
- **Optional Headroom wrapping** (`--memory --code-graph --no-serena`).
- **Optional** `--dangerously-skip-permissions`.
- A **per-session graph-UI port** (picks the next free port from 9749 so multiple
  Claude instances each get their own 3D graph) and a colored banner showing the
  **Graph UI** and **Agent Monitor** URLs.

```
🎯 Scope:        LOCAL (my-project)
🧠 CBM data:     ~/.claude-mcp-data/my-project/cbm
🌐 Graph UI:     http://localhost:9749   (codebase-memory)
📊 Agent Monitor: http://localhost:4820  (dashboard)
🪄 Headroom:     ON (wrap)
```

## Layout

```
claude_configurations/
├── ansible/
│   ├── bootstrap.sh        # install Ansible + run the playbook
│   ├── playbook.yml        # orchestrates the roles
│   ├── group_vars/all.yml  # all knobs (paths, packages, versions, ports)
│   ├── requirements.yml    # community.general collection
│   └── roles/              # sfw · claude · python_tools · mcp_servers
│       │                   #   · docker · agent_monitor · claude_local
│       └── ...
└── scripts/
    └── claude-local        # the launcher
```

## Notes

- **macOS only** (the playbook asserts Darwin).
- **Prerequisites:** Homebrew, and `pnpm` on `PATH` (`PNPM_HOME` set).
- **No secrets are committed** — keys are read from environment variables.
- After provisioning, open a **new terminal** (or `exec zsh`) to load the aliases.
- The GitHub MCP connects over HTTP and may need a one-time auth (`claude` then
  follow the prompt) — that's runtime auth, not an install step.
