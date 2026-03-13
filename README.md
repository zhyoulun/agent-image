# agent-image

这个仓库会在代码 `push` 到 GitHub 的 `main` 分支后，以及每天定时任务触发时，自动构建 Docker 镜像并推送到 Docker Hub。

镜像基于带 XFCE 桌面的 `ubuntu:24.04`，默认包含：

- `curl`
- `ffmpeg`
- `python3`
- `yt-dlp`
- `agent-browser`
- `xiaohongshu-cli` (`xhs`)
- Chromium browser runtime for `agent-browser`
- System `chromium` / `chromium-browser` command and desktop launcher
- XFCE desktop
- VNC / noVNC remote desktop access

## 使用方式

### 1. 配置 GitHub Secrets

在仓库 `Settings -> Secrets and variables -> Actions` 中新增：

- `DOCKERHUB_USERNAME`：填写 `fabulerg`
- `DOCKERHUB_TOKEN`：你的 Docker Hub Access Token

### 2. Docker Hub 镜像地址

工作流固定推送到：

```text
fabulerg/agent-image
```

### 3. 标签规则

每次构建会推送两个标签：

- `latest`
- UTC 日期标签，例如 `2026-03-13`

同时会发布多架构镜像清单，当前支持：

- `linux/amd64`
- `linux/arm64`

说明：Docker 里通常说的 `x86_64` 就是 `amd64`。

### 4. 触发发布

提交代码并推送到 `main`：

```bash
git add .
git commit -m "Add Docker publish workflow"
git push origin main
```

GitHub Actions 会自动：

1. 检出代码
2. 登录 Docker Hub
3. 构建镜像
4. 推送到 Docker Hub

另外，GitHub Actions 还会在每天 `00:10 UTC` 自动构建一次，用来刷新基础镜像和系统包更新。

## 本地构建

```bash
docker build -t agent-image:local .
```

## 启动桌面

```bash
docker run --rm -it -p 6080:6080 -p 5901:5901 agent-image:local
```

启动后可以通过下面两种方式访问桌面：

- 浏览器访问 `http://localhost:6080/vnc.html`
- VNC 客户端连接 `localhost:5901`

如果你想加 VNC 密码，可以传入环境变量：

```bash
docker run --rm -it \
  -e VNC_PASSWORD=your-password \
  -p 6080:6080 \
  -p 5901:5901 \
  agent-image:local
```

## 本地验证

```bash
docker run --rm agent-image:local curl --version
docker run --rm agent-image:local ffmpeg -version
docker run --rm agent-image:local python3 --version
docker run --rm agent-image:local yt-dlp --version
docker run --rm agent-image:local agent-browser --version
docker run --rm agent-image:local xhs --help
docker run --rm agent-image:local chromium --version
docker run --rm agent-image:local xiaohongshu-cli --help
```
