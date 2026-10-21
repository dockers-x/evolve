# Evolve (evolveidle) static site image.
# Upstream has no image and no release tags: build the game bundle from source
# on top of a pinned node image, then serve it with nginx.
#
# The build context is this repository (it holds nginx.conf); the upstream
# checkout is passed as a source tarball through the SOURCE_ARCHIVE build arg.
#
# esbuild ships a `node` shim in node_modules/.bin (its own node wrapper) which
# `npm run` puts on PATH and which breaks the build, so the toolchain is invoked
# directly from node_modules instead of through package.json scripts.

FROM --platform=$BUILDPLATFORM node:22-bookworm-slim AS fetch

ARG SOURCE_ARCHIVE
COPY ${SOURCE_ARCHIVE} /tmp/src.tar.gz
RUN mkdir -p /src && tar -xzf /tmp/src.tar.gz -C /src --strip-components=1 && rm /tmp/src.tar.gz

FROM --platform=$BUILDPLATFORM node:22-bookworm-slim AS builder

COPY --from=fetch /src /src
WORKDIR /src
RUN set -eux; \
    npm install --no-audit --no-fund --omit=optional; \
    /usr/local/bin/node buildEvolve.js; \
    /usr/local/bin/node buildWiki.js; \
    ./node_modules/.bin/lessc src/evolve.less evolve/evolve.css; \
    ./node_modules/.bin/lessc src/wiki/wiki.less wiki/wiki.css; \
    mkdir -p /out; \
    cp -r *.html *.ico LICENSE evolve lib font strings wiki /out/

FROM nginx:1.27-alpine

COPY --from=builder /out /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
