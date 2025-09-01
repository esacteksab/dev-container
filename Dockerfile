FROM ubuntu:24.04@sha256:7c06e91f61fa88c08cc74f7e1b7c69ae24910d745357e0dfe1d2c0322aaf20f9 AS base

ARG GO_VERSION=1.25.0

ENV DEBIAN_FRONTEND=noninteractive
# Install dependencies, download Go, and set it up in one layer
RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 \
        wget=1.21.4-1ubuntu4.1 && \
    wget -O go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    rm /root/.wget-hsts && \
    mkdir -p /go/src /go/bin && \
    chmod -R 750 /go && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV CGO_ENABLED=0

# Set the working directory
WORKDIR /go

FROM ubuntu:24.04@sha256:7c06e91f61fa88c08cc74f7e1b7c69ae24910d745357e0dfe1d2c0322aaf20f9 AS node

ENV DEBIAN_FRONTEND=noninteractive

ARG NODE_MAJOR_VERSION=22

ADD https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key nodesource-repo.gpg.key

ADD https://get.pnpm.io/install.sh pnpm-install.sh

ENV PNPM_VERSION="10.15.0"

ENV SHELL=/usr/bin/bash

RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 \
        gnupg=2.4.4-2ubuntu17.3 \
        wget=1.21.4-1ubuntu4.1 && \
        gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg nodesource-repo.gpg.key && \
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
        apt-get update && \
        apt-get install nodejs -y --no-install-recommends && \
        chmod +x pnpm-install.sh && ./pnpm-install.sh && rm pnpm-install.sh && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log

FROM ubuntu:24.04@sha256:7c06e91f61fa88c08cc74f7e1b7c69ae24910d745357e0dfe1d2c0322aaf20f9

ENV DEBIAN_FRONTEND=noninteractive

ADD https://cli.github.com/packages/githubcli-archive-keyring.gpg githubcli-archive-keyring.gpg

RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 \
        git=1:2.43.0-1ubuntu7.3 \
        make=4.3-4.1build2 \
        python3-pip=24.0+dfsg-1ubuntu1.2 \
        zsh=5.9-6ubuntu2 && \
    SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history" \
    && mkdir -p /commandhistory \
    && touch /commandhistory/.zsh_history \
    && echo "$SNIPPET" >> "/root/.zshrc" && \
    mkdir -p -m 755 /etc/apt/keyrings \
	&& cat githubcli-archive-keyring.gpg > /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
	&& apt update \
	&& apt install gh -y --no-install-recommends && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip install --no-cache-dir pre-commit==4.3.0 --break-system-packages

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV CGO_ENABLED=0

COPY --from=base /usr/local/go /usr/local/go
COPY --from=node /usr/bin/node /usr/bin/node
COPY --from=node /root/.local/share/pnpm/pnpm /usr/bin/pnpm
COPY zshrc /root/.zshrc

# Set the working directory
WORKDIR /go
