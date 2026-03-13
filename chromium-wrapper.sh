#!/usr/bin/env bash
set -euo pipefail

find_chromium() {
  local candidate

  for candidate in \
    /ms-playwright/chromium-*/chrome-linux/chrome \
    /ms-playwright/chromium-*/chrome-linux64/chrome \
    /ms-playwright/chromium-*/chrome-linux-arm64/chrome
  do
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

chromium_bin="$(find_chromium || true)"
if [[ -z "${chromium_bin}" ]]; then
  printf 'chromium runtime not found under /ms-playwright\n' >&2
  exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
  exec "${chromium_bin}" --no-sandbox "$@"
fi

exec "${chromium_bin}" "$@"
