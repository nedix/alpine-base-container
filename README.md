# [alpine-base-container][project]

## Getting started

```dockerfile
ARG ALPINE_VERSION=3.24.1

FROM ghcr.io/nedix/alpine-base-container:${ALPINE_VERSION}

RUN apk update
```

[project]: https://github.com/nedix/alpine-base-container
