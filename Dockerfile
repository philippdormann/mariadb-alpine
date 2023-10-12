FROM alpine:3.18

ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.description="A tiny MariaDB container" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.revision="$BUILD_REF" \
  org.opencontainers.image.source="https://github.com/philippdormann/mariadb-alpine" \
  org.opencontainers.image.title="philippdormann/mariadb-alpine" \
  org.opencontainers.image.url="https://github.com/philippdormann/mariadb-alpine" \
  org.opencontainers.image.vendor="Philipp Dormann" \
  org.opencontainers.image.version="$BUILD_VERSION"

RUN \
  apk add --no-cache mariadb=10.11.5-r0

# The ones installed by MariaDB was removed in the clean step above due to its large footprint
# my_print_defaults should cover 95% of cases since it doesn't properly do recursion
COPY sh/resolveip.sh /usr/bin/resolveip
COPY sh/my_print_defaults.sh /usr/bin/my_print_defaults
COPY sh/run.sh /run.sh
# switch to non-root user
USER mysql
# Used in run.sh as a default config
COPY my.cnf /tmp/my.cnf

# This is not super helpful; mysqld might be running but not accepting connections.
# Since we have no clients, we can't really connect to it and check.
#
# Below is in my opinion better than no health check.
HEALTHCHECK --start-period=5s CMD pgrep mariadbd

VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/run.sh"]
EXPOSE 3306
