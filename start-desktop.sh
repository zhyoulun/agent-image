#!/usr/bin/env bash
set -euo pipefail

DESKTOP_USER="${DESKTOP_USER:-agent}"
DESKTOP_HOME="/home/${DESKTOP_USER}"
DISPLAY="${DISPLAY:-:1}"
VNC_PORT="${VNC_PORT:-5901}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
VNC_DEPTH="${VNC_DEPTH:-24}"
XDG_RUNTIME_DIR="/tmp/runtime-${DESKTOP_USER}"

mkdir -p /tmp/.X11-unix /var/log/desktop "${DESKTOP_HOME}/.vnc" "${XDG_RUNTIME_DIR}"
chmod 1777 /tmp/.X11-unix
chmod 700 "${XDG_RUNTIME_DIR}"
chown -R "${DESKTOP_USER}:${DESKTOP_USER}" "${DESKTOP_HOME}" "${XDG_RUNTIME_DIR}"

VNC_AUTH_ARGS=(-nopw)
if [[ -n "${VNC_PASSWORD:-}" ]]; then
  runuser -u "${DESKTOP_USER}" -- x11vnc -storepasswd "${VNC_PASSWORD}" "${DESKTOP_HOME}/.vnc/passwd" >/dev/null
  VNC_AUTH_ARGS=(-rfbauth "${DESKTOP_HOME}/.vnc/passwd")
fi

cleanup() {
  pkill -TERM -P $$ >/dev/null 2>&1 || true
}
trap cleanup EXIT

Xvfb "${DISPLAY}" -screen 0 "${VNC_GEOMETRY}x${VNC_DEPTH}" -ac +extension RANDR +render -noreset \
  >/var/log/desktop/xvfb.log 2>&1 &

sleep 1

runuser -u "${DESKTOP_USER}" -- bash -lc "
  export DISPLAY='${DISPLAY}'
  export XDG_RUNTIME_DIR='${XDG_RUNTIME_DIR}'
  dbus-launch --exit-with-session startxfce4
" >/var/log/desktop/xfce.log 2>&1 &

x11vnc -display "${DISPLAY}" -forever -shared -rfbport "${VNC_PORT}" "${VNC_AUTH_ARGS[@]}" \
  >/var/log/desktop/x11vnc.log 2>&1 &

websockify --web=/usr/share/novnc/ "${NOVNC_PORT}" "localhost:${VNC_PORT}" \
  >/var/log/desktop/novnc.log 2>&1 &

cat <<EOF
Desktop is starting.
noVNC: http://localhost:${NOVNC_PORT}/vnc.html
VNC: localhost:${VNC_PORT}
EOF

wait -n
