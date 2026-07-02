# syntax=docker/dockerfile:1

# ── Builder ────────────────────────────────────────────────────────────────
ARG CADDY_VERSION=2.10.2
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

# Assert the Cloudflare DNS module is present.
RUN caddy list-modules | grep -qFx dns.providers.cloudflare
