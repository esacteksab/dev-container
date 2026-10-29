# hadolint global ignore=DL3008
FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852 AS python

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux \
    && echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker \
    && echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        python3-pip

FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852 AS gh

RUN set -eux \
    && echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker \
    && echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
    && mkdir -p /etc/apt/keyrings \
    && chmod 755 /etc/apt/keyrings \
    && wget -nv -O /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && mkdir -p /etc/apt/sources.list.d \
    && chmod 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/apt/* \
    && rm -rf /var/log/dpkg.log

FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852 AS node

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

ARG NODE_VERSION=22.23.4

ENV SHELL=/usr/bin/bash

RUN set -eux \
    && echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker \
    && echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xz-utils \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" -o /tmp/SHASUMS256.txt \
    && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -o /tmp/node.tar.xz \
    && node_sha256="$(grep " node-v${NODE_VERSION}-linux-x64.tar.xz$" /tmp/SHASUMS256.txt | awk '{print $1}')" \
    && echo "${node_sha256}  /tmp/node.tar.xz" | sha256sum -c - \
    && mkdir -p /usr/local/lib/nodejs \
    && tar -xJf /tmp/node.tar.xz -C /usr/local/lib/nodejs \
    && ln -sfn "/usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/node" /usr/bin/node \
    && ln -sfn "/usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/npm" /usr/bin/npm \
    && ln -sfn "/usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/npx" /usr/bin/npx \
    && ln -sfn "/usr/local/lib/nodejs/node-v${NODE_VERSION}-linux-x64/bin/corepack" /usr/bin/corepack \
    && rm -f /tmp/node.tar.xz /tmp/SHASUMS256.txt \
    && apt-get clean && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/apt/* \
    && rm -rf /var/log/dpkg.log

FROM ubuntu:24.04@sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3064
ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG ZSH_AUTOSUGGESTIONS_SHA=85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
ARG NPM_VERSION=12.2.1

# Set the working directory
WORKDIR /go

ENV DEBIAN_FRONTEND=noninteractive

COPY requirements.txt /tmp/requirements.txt

RUN set -eux \
    && echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker \
    && echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        direnv \
        git \
        libatomic1 \
        jq \
        make \
        openssh-client \
        python3 \
        python3-pip \
        python3-venv \
        vim \
        zsh \
    && if ! getent group "${USER_GID}" > /dev/null 2>&1; then groupadd --gid "${USER_GID}" "${USERNAME}"; fi \
    && if id -u "${USERNAME}" > /dev/null 2>&1; then \
        :; \
    elif getent passwd "${USER_UID}" > /dev/null 2>&1; then \
        existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1)"; \
        usermod --login "${USERNAME}" "${existing_user}"; \
        usermod --home "/home/${USERNAME}" --move-home --shell /usr/bin/zsh "${USERNAME}"; \
    else \
        useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /usr/bin/zsh "${USERNAME}"; \
    fi \
    && mkdir -p /go/bin /go/pkg /go/src \
    && chown -R "${USER_UID}:${USER_GID}" /go \
    && install -d -m 0755 -o "${USER_UID}" -g "${USER_GID}" "/home/${USERNAME}/.zsh" \
    && git init "/home/${USERNAME}/.zsh/zsh-autosuggestions" \
    && git -C "/home/${USERNAME}/.zsh/zsh-autosuggestions" remote add origin https://github.com/zsh-users/zsh-autosuggestions.git \
    && git -C "/home/${USERNAME}/.zsh/zsh-autosuggestions" fetch --depth 1 origin "${ZSH_AUTOSUGGESTIONS_SHA}" \
    && git -C "/home/${USERNAME}/.zsh/zsh-autosuggestions" checkout --detach FETCH_HEAD \
    && chown -R "${USER_UID}:${USER_GID}" "/home/${USERNAME}/.zsh" \
    && SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history" \
    && mkdir -p /commandhistory \
    && touch /commandhistory/.zsh_history \
    && chown -R "${USER_UID}:${USER_GID}" /commandhistory \
    && echo "$SNIPPET" >> "/home/${USERNAME}/.zshrc" \
    && python3 -m pip install --no-cache-dir -r /tmp/requirements.txt --break-system-packages \
    && curl -fsSL https://mise.run | env MISE_INSTALL_PATH=/usr/bin/mise sh \
    && apt-get clean && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/log/apt/* \
    && rm -rf /var/log/dpkg.log \
    && ln -s /usr/bin/python3 /usr/bin/python

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:/home/${USERNAME}/.local/bin:$PATH
ENV CGO_ENABLED=0

COPY --link --from=gh /usr/bin/gh /usr/bin/gh
COPY --from=ghcr.io/zizmorcore/zizmor:1.31.1@sha256:42d409dbb851d4c5d35a058cf042b828bea1e3f2884378c526eb0974780e18d9 /usr/bin/zizmor /usr/local/bin/zizmor
COPY --link --from=golang:1.26.10@sha256:670bb5aa5349ae03b8516764718486f4f16399134bdc9acd0c46a23f043ab05c /usr/local/go /usr/local/go
COPY --link --from=node /usr/bin/node /usr/bin/node
COPY --link --from=node /usr/local/lib/nodejs /usr/local/lib/nodejs
COPY --from=ghcr.io/astral-sh/uv:0.13.6@sha256:af22a52f5eafef3d78e551599d405c02df61919d18028f0cea8eda93bc9986d0 /uv /uvx /bin/
COPY --from=ghcr.io/aquasecurity/trivy:0.76.1@sha256:790fd66d1697395d8693d1acaa1ea702406a20f109b6fc7bac8db623eca6c06c /usr/local/bin/trivy /usr/bin/trivy
COPY --from=ghcr.io/hadolint/hadolint:v2.15.1@sha256:32dac94127fd60b7b7e3fbfc65e1383b9b5e25c9bfd7b8536de7a539fe68a12d /bin/hadolint /bin/

RUN set -eux \
    && mkdir -p /usr/local/lib/node_modules \
    && curl -fsSL "https://registry.npmjs.org/npm/${NPM_VERSION}" -o /tmp/npm-version.json \
    && npm_sha1="$(jq -r '.dist.shasum' /tmp/npm-version.json)" \
    && curl -fsSL "https://registry.npmjs.org/npm/-/npm-${NPM_VERSION}.tgz" -o /tmp/npm.tgz \
    && echo "${npm_sha1}  /tmp/npm.tgz" | sha1sum -c - \
    && tar -xzf /tmp/npm.tgz -C /usr/local/lib/node_modules \
    && mv /usr/local/lib/node_modules/package /usr/local/lib/node_modules/npm \
    && rm -f /tmp/npm.tgz /tmp/npm-version.json \
    && ln -sfn ../local/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm \
    && ln -sfn ../local/lib/node_modules/npm/bin/npx-cli.js /usr/bin/npx \
    && npm install --global --prefix /usr/local corepack@0.36.0 \
    && corepack enable pnpm \
    && corepack prepare pnpm@12.16.1 --activate

COPY zshrc /home/${USERNAME}/.zshrc
COPY vimrc /home/${USERNAME}/.vimrc
COPY .prettier* .
COPY .editorconfig .
COPY .typos.toml .
COPY package.json .
COPY pnpm-lock.yaml .

RUN chown "${USER_UID}:${USER_GID}" "/home/${USERNAME}/.zshrc" "/home/${USERNAME}/.vimrc"
