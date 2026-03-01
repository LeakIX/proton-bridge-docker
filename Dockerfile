# syntax=docker/dockerfile:1
#
# Proton Mail Bridge - headless (no GUI / no X11)
#
# Build from official source with `make build-nogui`.
# At runtime, uses pass + gpg as the keychain backend.
#
# First run (interactive login):
#   docker compose run --rm proton-bridge --cli
#   > login
#   > info
#   > exit
#
# Then start normally:
#   docker compose up -d proton-bridge

ARG GO_VERSION=1.24
FROM golang:${GO_VERSION}-trixie AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git=1:2.47.3-0+deb13u1 \
    make=4.4.1-2 \
    gcc=4:14.2.0-1 \
    pkg-config=1.8.1-4 \
    libcbor-dev \
    libfido2-dev \
    libsecret-1-dev=0.21.7-1 \
    && rm -rf /var/lib/apt/lists/*

ARG BRIDGE_VERSION=v3.22.0
RUN git clone --depth 1 --branch "${BRIDGE_VERSION}" \
    https://github.com/ProtonMail/proton-bridge.git /src

WORKDIR /src
RUN make build-nogui

# -----------------------------------------------------------
FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates=20250419 \
    pass=1.7.4-7 \
    gnupg=2.4.7-21+deb13u1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/bridge /usr/local/bin/proton-bridge

RUN useradd -m -s /bin/bash proton

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER proton
WORKDIR /home/proton

# Bridge config, GPG keys, and pass store
VOLUME ["/home/proton/.config", "/home/proton/.gnupg", \
        "/home/proton/.password-store"]

# IMAP and SMTP
EXPOSE 1143 1025

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--noninteractive"]
