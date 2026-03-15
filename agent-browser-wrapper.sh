#!/usr/bin/env bash
set -euo pipefail

real_bin="/usr/bin/agent-browser"
default_browser="/usr/local/bin/chromium"

for arg in "$@"; do
  if [[ "${arg}" == "--executable-path" || "${arg}" == --executable-path=* ]]; then
    exec "${real_bin}" "$@"
  fi
done

exec "${real_bin}" --executable-path "${default_browser}" "$@"
