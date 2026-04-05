FROM ubuntu:24.04@sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c AS python

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        python3-pip && \
        pip install --user pre-commit==4.5.1 --break-system-packages

FROM ubuntu:24.04@sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c AS gh

RUN set -eux && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget && \
    mkdir -p -m 755 /etc/apt/keyrings \
    && wget -nv -O /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt update \
    && apt install gh -y --no-install-recommends && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log

FROM ubuntu:24.04@sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c AS go

# Set the working directory
WORKDIR /go

ARG GO_VERSION=1.26.1

ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV CGO_ENABLED=0

RUN set -eux && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget && \
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

FROM ubuntu:24.04@sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c AS node

ENV DEBIAN_FRONTEND=noninteractive

ARG NODE_MAJOR_VERSION=22

ENV PNPM_VERSION="10.32.1"

ARG PNPM_VERSION=10.32.1

ENV SHELL=/usr/bin/bash

RUN set -eux && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        wget && \
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
        apt-get update && \
        apt-get install nodejs -y --no-install-recommends && \
        curl -fsSL https://get.pnpm.io/install.sh | env PNPM_VERSION=${PNPM_VERSION} sh - && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log

FROM ubuntu:24.04@sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c

# Set the working directory
WORKDIR /go

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        direnv \
        git \
        libatomic1 \
        make \
        openssh-client \
        python3 \
        python3-pip \
        vim \
        zsh && \
    git config --system core.editor vim && \
    git config --system pager.diff 'vim -R -c "set ft=diff" -' && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions && \
    SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history" \
    && mkdir -p /commandhistory \
    && touch /commandhistory/.zsh_history \
    && echo "$SNIPPET" >> "/root/.zshrc" && \
    curl -fsSL https://mise.run | env MISE_INSTALL_PATH=/usr/bin/mise sh && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log && \
    ln -s /usr/bin/python3 /usr/bin/python

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:/root/.local/bin:$PATH
ENV CGO_ENABLED=0

COPY --link --from=gh /usr/bin/gh /usr/bin/gh
COPY --link --from=go /usr/local/go /usr/local/go
COPY --link --from=node /usr/bin/node /usr/bin/node
COPY --link --from=node /root/.local/share/pnpm/pnpm /usr/bin/pnpm
COPY --link --from=python /root/.local /root/.local
COPY --from=ghcr.io/astral-sh/uv:0.10.10 /uv /uvx /bin/

COPY zshrc /root/.zshrc
COPY vimrc /root/.vimrc
COPY .prettier* .
COPY .editorconfig .
COPY .typos.toml .
COPY package.json .
COPY pnpm-lock.yaml .
