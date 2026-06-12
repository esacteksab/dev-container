# hadolint global ignore=DL3008
FROM ubuntu:24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc AS python

ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux \
    && echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker \
    && echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        python3-pip

FROM ubuntu:24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc AS gh

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

FROM ubuntu:24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc AS node

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

ARG NODE_VERSION=22.22.3

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

FROM ubuntu:24.10@sha256:cdf755952ed117f6126ff4e65810bf93767d4c38f5c7185b50ec1f1078b464cc

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG USERNAME=devcontainer
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG ZSH_AUTOSUGGESTIONS_SHA=85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
ARG NPM_VERSION=11.14.1

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
COPY --from=ghcr.io/zizmorcore/zizmor:1.24.1@sha256:128ebbe369a95f9d4427737e794537256095b55f779a247aebc960dc4ea1f7b3 /usr/bin/zizmor /usr/local/bin/zizmor
COPY --link --from=golang:1.26.3@sha256:313faae491b410a35402c05d35e7518ae99103d957308e940e1ae2cfa0aac29b /usr/local/go /usr/local/go
COPY --link --from=node /usr/bin/node /usr/bin/node
COPY --link --from=node /usr/local/lib/nodejs /usr/local/lib/nodejs
COPY --from=ghcr.io/astral-sh/uv:0.11.7@sha256:240fb85ab0f263ef12f492d8476aa3a2e4e1e333f7d67fbdd923d00a506a516a /uv /uvx /bin/
COPY --from=ghcr.io/aquasecurity/trivy@sha256:be1190afcb28352bfddc4ddeb71470835d16462af68d310f9f4bca710961a41e /usr/local/bin/trivy /usr/bin/trivy
COPY --from=ghcr.io/hadolint/hadolint@sha256:27086352fd5e1907ea2b934eb1023f217c5ae087992eb59fde121dce9c9ff21e /bin/hadolint /bin/

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
    && npm install --global --prefix /usr/local corepack@0.35.0 \
    && corepack enable pnpm \
    && corepack prepare pnpm@10.33.0 --activate

COPY zshrc /home/${USERNAME}/.zshrc
COPY vimrc /home/${USERNAME}/.vimrc
COPY .prettier* .
COPY .editorconfig .
COPY .typos.toml .
COPY package.json .
COPY pnpm-lock.yaml .

RUN chown "${USER_UID}:${USER_GID}" "/home/${USERNAME}/.zshrc" "/home/${USERNAME}/.vimrc"
