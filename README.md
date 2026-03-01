# Proton Bridge Docker

Headless Proton Mail Bridge built from source, packaged as a Docker image.
Uses `pass` + `gpg` as the keychain backend (no GUI, no X11 required).

Image is rebuilt weekly and published to
`ghcr.io/leakix/proton-bridge-docker`.

## Quick Start

Pull the image:

```bash
docker pull ghcr.io/leakix/proton-bridge-docker:latest
```

### First Run (Interactive Login)

You must log in interactively once to authenticate with Proton:

```bash
docker run -it --rm \
    -v proton-config:/home/proton/.config \
    -v proton-gnupg:/home/proton/.gnupg \
    -v proton-pass:/home/proton/.password-store \
    ghcr.io/leakix/proton-bridge-docker --cli
```

Inside the CLI:

```
> login
> info
> exit
```

The `info` command shows the local IMAP/SMTP credentials you will need
to configure your mail client or agent.

### Normal Operation

```bash
docker run -d \
    --name proton-bridge \
    -v proton-config:/home/proton/.config \
    -v proton-gnupg:/home/proton/.gnupg \
    -v proton-pass:/home/proton/.password-store \
    -p 1143:1143 \
    -p 1025:1025 \
    ghcr.io/leakix/proton-bridge-docker
```

### Docker Compose

```yaml
services:
  proton-bridge:
    image: ghcr.io/leakix/proton-bridge-docker:latest
    restart: unless-stopped
    ports:
      - "1143:1143"
      - "1025:1025"
    volumes:
      - proton-config:/home/proton/.config
      - proton-gnupg:/home/proton/.gnupg
      - proton-pass:/home/proton/.password-store

volumes:
  proton-config:
  proton-gnupg:
  proton-pass:
```

## Ports

| Port | Protocol |
| ---- | -------- |
| 1143 | IMAP     |
| 1025 | SMTP     |

## Volumes

| Path                          | Purpose              |
| ----------------------------- | -------------------- |
| `/home/proton/.config`        | Bridge configuration |
| `/home/proton/.gnupg`         | GPG keys             |
| `/home/proton/.password-store`| Pass credential store|

## Build Args

| Arg              | Default   | Description                   |
| ---------------- | --------- | ----------------------------- |
| `GO_VERSION`     | `1.24`    | Go version for build stage    |
| `BRIDGE_VERSION` | `v3.22.0` | Proton Bridge release tag     |

## Building Locally

```bash
docker build -t proton-bridge .
```

To build a specific Bridge version:

```bash
docker build --build-arg BRIDGE_VERSION=v3.22.0 -t proton-bridge .
```

## How It Works

The entrypoint script automatically initializes a GPG key and `pass`
store on first run. This provides the keychain backend that Bridge
requires, without needing `gnome-keyring` or any graphical session.

## License

The Dockerfile and entrypoint script in this repository are provided
as-is. Proton Mail Bridge is licensed under the
[GNU GPL v3](https://github.com/ProtonMail/proton-bridge/blob/master/LICENSE).
