ARG ALPINE_VERSION=3.23.3
ARG YQ_VERSION=4.52.5

FROM alpine:${ALPINE_VERSION} AS base

FROM base AS build-base

FROM build-base AS yq

WORKDIR /build/yq/

ARG YQ_VERSION

RUN case "$(uname -m)" in \
        aarch64|arm*) \
            YQ_ARCHITECTURE="arm64" \
        ;; x86_64) \
            YQ_ARCHITECTURE="amd64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${YQ_ARCHITECTURE}.tar.gz" \
    | tar xzOf - "./yq_linux_${YQ_ARCHITECTURE}" > yq \
    && chmod +x yq

FROM base

COPY --link --from=yq /build/yq/yq /usr/bin/

ARG ALPINE_VERSION

RUN NOW_SECONDS_FROM_EPOCH="$(date +%s)" \
    && wget -qO- https://www.alpinelinux.org/releases.json \
    | yq '.release_branches | .[1:] | .[] | "\(.eol_date) \(.rel_branch)"' \
    | sed -E "s|(.*) v(\d+\.\d+$)|\1 \2|" \
    | sort -r \
    | while read -r EOL_DATE VERSION_N; do \
        EOL_SECONDS_FROM_EPOCH="$(date -d ${EOL_DATE} +%s)" \
        && if [ "$EOL_SECONDS_FROM_EPOCH" -lt "$NOW_SECONDS_FROM_EPOCH" ]; then \
            break \
        ; fi \
        && if [ "$VERSION_N" != "${ALPINE_VERSION%.*}" ]; then \
            printf \
                "%s\n%s\n" \
                "https://dl-cdn.alpinelinux.org/alpine/v${VERSION_N}/main" \
                "https://dl-cdn.alpinelinux.org/alpine/v${VERSION_N}/community" \
                >> /etc/apk/repositories \
        ; fi \
    ; done \
    && rm /usr/bin/yq \
    && apk update
