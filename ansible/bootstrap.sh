#!/usr/bin/env bash
# Bootstrap Ansible and run the Claude Code provisioning playbook (macOS).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Checking Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh first." >&2
  exit 1
fi

echo "==> Ensuring Ansible is installed..."
if ! command -v ansible-playbook >/dev/null 2>&1; then
  brew install ansible
fi

echo "==> Installing required Ansible collections..."
ansible-galaxy collection install -r requirements.yml

echo "==> Running playbook..."
ansible-playbook playbook.yml "$@"

echo "==> Done. Restart your shell to load sfw aliases."
