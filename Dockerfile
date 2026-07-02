# syntax=docker/dockerfile:1

# ── Builder ────────────────────────────────────────────────────────────────
ARG CADDY_VERSION
FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

ARG CADDY_VERSION
ARG CADDY_DNS_CLOUDFLARE_VERSION

RUN xcaddy build v${CADDY_VERSION} \
    --with github.com/caddy-dns/cloudflare@${CADDY_DNS_CLOUDFLARE_VERSION} \
    --output /usr/bin/caddy

# ── Runtime ────────────────────────────────────────────────────────────────
ARG CADDY_VERSION
FROM caddy:${CADDY_VERSION}-alpine

ARG CADDY_VERSION

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Assert the Cloudflare DNS module is present
RUN caddy list-modules | grep -qF dns.providers.cloudflare

# Ensure no certificates, config, or credentials exist in the image
RUN test ! -d /etc/caddy/certs   || test -z "$(ls -A /etc/caddy/certs   2>/dev/null)" \
    && test ! -f /etc/caddy/Caddyfile || true
