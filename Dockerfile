FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    NODE_PATH=/usr/lib/node_modules \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NOVNC_PORT=6080 \
    VNC_GEOMETRY=1920x1080 \
    VNC_DEPTH=24 \
    CHROMIUM_CDP_PORT=9222

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends \
        dbus-x11 \
        ffmpeg \
        git \
        libatk-bridge2.0-0t64 \
        libatk1.0-0t64 \
        libatspi2.0-0t64 \
        libcups2t64 \
        libnspr4 \
        libnss3 \
        libopenh264-7 \
        nodejs \
        novnc \
        libxcomposite1 \
        libxdamage1 \
        python3 \
        python3-pip \
        vim \
        websockify \
        xfce4 \
        xauth \
        x11vnc \
        xvfb \
    && useradd -ms /bin/bash agent \
    && python3 -m pip install --no-cache-dir --break-system-packages yt-dlp \
    && npm install -g agent-browser crawlee playwright \
    && playwright_bin="$(readlink -f "$(command -v playwright)")" \
    && ln -sf "${playwright_bin}" /usr/local/bin/playwright-real \
    && npm cache clean --force \
    && rm -rf /root/.cache/pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --break-system-packages xiaohongshu-cli \
    && playwright install chromium \
    && ln -sf /usr/local/bin/xhs /usr/local/bin/xiaohongshu-cli

COPY agent-browser-wrapper.sh /usr/local/bin/agent-browser
COPY chromium-wrapper.sh /usr/local/bin/chromium
COPY playwright-wrapper.sh /usr/local/bin/playwright
COPY chromium.desktop /usr/share/applications/chromium.desktop
COPY start-desktop.sh /usr/local/bin/start-desktop.sh

RUN ln -sf /usr/local/bin/chromium /usr/local/bin/chromium-browser \
    && ln -sf /usr/local/bin/chromium /usr/bin/chromium \
    && ln -sf /usr/local/bin/chromium /usr/bin/chromium-browser \
    && chmod +x /usr/local/bin/agent-browser /usr/local/bin/chromium /usr/local/bin/playwright /usr/local/bin/start-desktop.sh

EXPOSE 5901 6080

CMD ["/usr/local/bin/start-desktop.sh"]
