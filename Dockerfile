FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    DISPLAY=:1 \
    VNC_PORT=5901 \
    NOVNC_PORT=6080 \
    VNC_GEOMETRY=1920x1080 \
    VNC_DEPTH=24

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends \
        dbus-x11 \
        ffmpeg \
        libatk-bridge2.0-0t64 \
        libatk1.0-0t64 \
        libatspi2.0-0t64 \
        libcups2t64 \
        libnspr4 \
        libnss3 \
        nodejs \
        novnc \
        libxcomposite1 \
        libxdamage1 \
        python3 \
        python3-pip \
        websockify \
        xfce4 \
        x11vnc \
        xvfb \
    && useradd -ms /bin/bash agent \
    && python3 -m pip install --no-cache-dir --break-system-packages yt-dlp \
    && npm install -g agent-browser \
    && agent-browser install \
    && npm cache clean --force \
    && rm -rf /root/.cache/pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --break-system-packages xiaohongshu-cli \
    && ln -sf /usr/local/bin/xhs /usr/local/bin/xiaohongshu-cli

COPY start-desktop.sh /usr/local/bin/start-desktop.sh

RUN chmod +x /usr/local/bin/start-desktop.sh

EXPOSE 5901 6080

CMD ["/usr/local/bin/start-desktop.sh"]
