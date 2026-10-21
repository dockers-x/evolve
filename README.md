# evolve (Docker image)

Docker image for [Evolve](https://github.com/pmotschmann/Evolve) — 一款网页进化类放置游戏（Evolve Idle）。

上游**没有预构建镜像**，也没有发布 tag，因此本仓库直接从源码构建并推送：

- `ghcr.io/dockers-x/evolve:latest`
- `ghcr.io/dockers-x/evolve:v{package.json 版本}`（例如 `v1.4.10`）

## 构建方式

- 多阶段：`node:22-bookworm-slim` 执行 `npm ci && npm run build`（esbuild + less + csso，生成 `evolve/main.js`、`wiki/wiki.js` 和压缩后的 CSS）→ `nginx:1.27-alpine` 托管静态站点
- 静态站点，无后端、无数据库；存档保存在浏览器 localStorage 中

## 运行

```bash
docker run -d --name evolve -p 8080:80 ghcr.io/dockers-x/evolve:latest
```

访问 `http://<服务器IP>:8080/`。

## 自动更新

`.github/workflows/build.yml` 每天检查上游 `master` 的最新提交：

- 读取上游 `package.json` 的版本号作为镜像 tag；
- 用 `src-<commit>` tag 记录已构建的提交，相同提交不会重复构建；
- 推送 `linux/amd64` 与 `linux/arm64` 两个平台。

## 许可

MPL-2.0（上游）
