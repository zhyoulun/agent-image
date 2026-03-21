#!/usr/bin/env bash
set -euo pipefail

real_bin="/usr/local/bin/playwright-real"

needs_display() {
  case "${1:-}" in
    open|codegen|cr|ff|wk|show-trace)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

display_socket() {
  local display_num

  display_num="${DISPLAY:-}"
  display_num="${display_num#:}"
  display_num="${display_num%%.*}"

  printf '/tmp/.X11-unix/X%s\n' "${display_num}"
}

has_live_display() {
  [[ -n "${DISPLAY:-}" ]] && [[ -S "$(display_socket)" ]]
}

if [[ ! -x "${real_bin}" ]]; then
  printf 'playwright runtime not found\n' >&2
  exit 1
fi

if needs_display "${1:-}" && ! has_live_display; then
  exec xvfb-run -a --server-args="-screen 0 1920x1080x24 -ac +extension RANDR +render -noreset" "${real_bin}" "$@"
fi

exec "${real_bin}" "$@"
