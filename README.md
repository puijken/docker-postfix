# docker-postfix

A small Postfix relay in an Alpine container. Applications on your network hand their mail to
it on port 25, and it forwards everything through one upstream SMTP server (for example
Gmail), authenticating with SASL. Nothing is delivered locally.

Originally derived from
[juanluisbaptiste/docker-postfix](https://github.com/juanluisbaptiste/docker-postfix) (GPL-3.0),
and now maintained separately. The main differences:

- **Relay access is strict.** `SMTP_NETWORKS` is the *only* range allowed to relay. Upstream
  always adds `10.0.0.0/8`, `172.16.0.0/12` and `192.168.0.0/16` on top, so anything on any
  private network can send mail through it.
- **Queue retries are tightened**, and a stuck message triggers an early "still trying" notice
  (see below).
- TLS uses `smtp_tls_security_level` instead of the deprecated `smtp_use_tls`.
- `TZ` works (the image includes `tzdata`).

## Quick start

```yaml
services:
  postfix:
    image: ghcr.io/puijken/docker-postfix:latest
    container_name: postfix
    restart: always
    expose:
      - "25"
    env_file:
      - .env   # SMTP_USERNAME / SMTP_PASSWORD belong here, not in the compose file
    environment:
      - SMTP_SERVER=smtp.gmail.com
      - SERVER_HOSTNAME=relay.example.com
      - SMTP_NETWORKS=192.168.10.0/24
      - TZ=Europe/Amsterdam
```

Then point your applications at the container on port 25, without authentication or TLS.

## Configuration

### Required

| Variable | Meaning |
|---|---|
| `SMTP_SERVER` | Upstream SMTP server to relay through, e.g. `smtp.gmail.com`. |
| `SERVER_HOSTNAME` | This relay's own hostname (`myhostname`). The last two labels become `mydomain`, which is also used as `myorigin`. |
| `SMTP_NETWORKS` | Comma-separated IPv4 subnets allowed to relay, e.g. `192.168.10.0/24,10.0.5.7/32`. This is the **only** access control. The container refuses to start without it, rather than falling back to anything broader. Entries that aren't `a.b.c.d/nn` are logged and ignored. |

### Upstream connection

| Variable | Default | Meaning |
|---|---|---|
| `SMTP_PORT` | `587` | Upstream port. `587` uses STARTTLS when offered. `465` switches to implicit TLS and requires encryption. |
| `SMTP_USERNAME` | — | SASL username. If set, `SMTP_PASSWORD` is required. |
| `SMTP_PASSWORD` | — | SASL password (for Gmail, an app password). |
| `SMTP_USERNAME_FILE`, `SMTP_PASSWORD_FILE` | — | Read the username or password from a file instead, e.g. a Docker secret. |

### Message handling

| Variable | Default | Meaning |
|---|---|---|
| `OVERWRITE_FROM` | — | Rewrite the `From:` header of every outgoing message to this value. |
| `SMTP_HEADER_TAG` | — | Add a `RelayTag:` header with this value, to recognise relayed mail. |
| `ALWAYS_ADD_MISSING_HEADERS` | `no` | Let Postfix add missing `From:`, `To:`, `Date:` or `Message-ID:` headers. |
| `DESTINATION` | `localhost` | Postfix `mydestination`. |

### Queue retry timing

Tightened from Postfix's stock defaults, which are tuned for outages measured in hours rather
than a home relay's typical short network blip.

| Variable | Default | Meaning |
|---|---|---|
| `MINIMAL_BACKOFF_TIME` | `300s` | Shortest gap between delivery attempts for a deferred message. |
| `MAXIMAL_BACKOFF_TIME` | `900s` | Longest gap between attempts (Postfix's own default is `4000s`, about 67 minutes). A recovered network is noticed within 15 minutes at worst. |
| `QUEUE_RUN_DELAY` | `300s` | How often the queue manager scans for messages due for a retry. |

### Delivery delay notice

| Variable | Default | Meaning |
|---|---|---|
| `DELAY_WARNING_TIME` | `1h` | How long a message can sit in the deferred queue before Postfix emails the original sender a one-time "still trying" notice. |

Without this, a failing message gives no signal at all until the final bounce after
`maximal_queue_lifetime` (5 days by default). The notice does not stop delivery from being
retried. Whether it reaches anyone useful depends on the sending application setting a real
envelope-from address.

### Other

| Variable | Default | Meaning |
|---|---|---|
| `TZ` | UTC | Timezone for the logs, e.g. `Europe/Amsterdam`. |
| `DEBUG` | — | `yes` traces the startup script (`set -x`). |

Logs go to the container's stdout (`docker logs postfix`).

## Image and CI

Published as `ghcr.io/puijken/docker-postfix:latest`. GitHub Actions builds and pushes it on a
push to `master`, on manual dispatch, and monthly to pick up base-image security rebuilds.
Dependabot keeps the base image and actions current. Pull requests are build-checked before
merging.

## License

GPL-3.0, inherited from the original project. See [LICENSE](LICENSE).
