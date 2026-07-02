# caddy-cloudflare

Custom Caddy image with the
[`caddy-dns/cloudflare`](https://github.com/caddy-dns/cloudflare) module baked
in, published to GitHub Container Registry.

## Image

```
ghcr.io/yaver-dev/caddy-cloudflare
```

### Tags

| Tag | Meaning |
|---|---|
| `2.10.2-cf0.2.1-r1` | Caddy 2.10.2 + cloudflare module v0.2.1, revision 1 |
| `<git-sha>` | Immutable commit-SHA tag for pinning in production |

No `latest` tag is published. Pin to an exact version tag (or digest) in
production.

## Usage

### Docker Compose (pull only)

```yaml
services:
  caddy:
    image: ghcr.io/yaver-dev/caddy-cloudflare:2.10.2-cf0.2.1-r1
    # No build section — pull the prebuilt image.
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
    environment:
      CLOUDFLARE_API_TOKEN: ${CLOUDFLARE_API_TOKEN}
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: caddy
spec:
  template:
    spec:
      containers:
        - name: caddy
          image: ghcr.io/yaver-dev/caddy-cloudflare:2.10.2-cf0.2.1-r1
          ports:
            - containerPort: 80
            - containerPort: 443
          env:
            - name: CLOUDFLARE_API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: cloudflare-api-token
                  key: token
```

### Production pinning

After the first publish, pin by digest:

```yaml
image: ghcr.io/yaver-dev/caddy-cloudflare:2.10.2-cf0.2.1-r1@sha256:...
```

## Runtime secrets

The Cloudflare API token is a **runtime-only** concern. Supply it via:

* Docker Compose `environment` / `env_file`
* Kubernetes `Secret`
* Any other runtime secret mechanism

The image itself contains **no** certificates, Caddy configuration, or
Cloudflare credentials.

## Package visibility

The GHCR package must be set to **Public** after the first publication so
consumers can pull without a registry login. This is a one-time manual step
in the GitHub package settings UI.

## Certificate lifecycle & token validity

Caddy certificate lifecycle and Cloudflare token validity are runtime
concerns, intentionally outside the scope of this image pipeline. This
repository only provides the base image with the DNS module compiled in.

## Local build

```bash
source versions.env
docker buildx build --platform linux/amd64 --load \
  --build-arg CADDY_VERSION="${CADDY_VERSION}" \
  --build-arg CADDY_DNS_CLOUDFLARE_VERSION="${CADDY_DNS_CLOUDFLARE_VERSION}" \
  -t caddy-cloudflare:local \
  .
```

Then verify the module:

```bash
docker run --rm caddy-cloudflare:local caddy list-modules | grep dns.providers.cloudflare
```
