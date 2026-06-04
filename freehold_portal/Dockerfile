ARG BUILD_FROM
FROM ${BUILD_FROM}

# Node runtime (Alpine base from the HA add-on image).
RUN apk add --no-cache nodejs

# Pre-bundled, dependency-free server (see addon/README.md — run `pnpm bundle`
# in apps/portal before building/deploying this add-on).
COPY rootfs /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
