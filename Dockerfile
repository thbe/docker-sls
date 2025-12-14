# syntax=docker/dockerfile:1
#
# BUILD:
#   wget https://raw.githubusercontent.com/thbe/docker-sls/master/Dockerfile
#   docker build --rm --no-cache -t thbe/sls .
#
# USAGE:
#   docker run --detach --restart always --name sls --hostname sls.$(hostname -d) -p 9710:9710/udp thbe/sls
#   docker logs --tail 1000 --follow --timestamps sls
#   docker exec -ti sls /bin/sh
#

# Pin Alpine version for reproducible builds
ARG ALPINE_VERSION=3.19

#############################################
# Build stage
#############################################
FROM alpine:${ALPINE_VERSION} AS build

# Install build tools (combined into single layer)
RUN apk add --no-cache \
        alpine-sdk \
        cmake \
        linux-headers \
        openssl-dev \
        zlib-dev

# Set workdir and clone GIT repositories
WORKDIR /srv/build
RUN git clone --depth 1 https://github.com/Haivision/srt.git && \
    git clone --depth 1 https://github.com/Edward-Wu/srt-live-server.git

# Copy Makefile first (changes less frequently)
COPY build/Makefile /srv/build/srt-live-server/Makefile

# Build SRT library
WORKDIR /srv/build/srt
RUN ./configure --prefix=/srv/sls && \
    make -j"$(nproc)" && \
    make install

# Build SRT Live Server
WORKDIR /srv/build/srt-live-server
RUN make -j"$(nproc)"

# Strip debug symbols to reduce binary size
RUN strip /srv/sls/bin/* /srv/build/srt-live-server/bin/* 2>/dev/null || true

#############################################
# Runtime stage
#############################################
FROM alpine:${ALPINE_VERSION}

# Set metadata using OCI standard labels
LABEL org.opencontainers.image.title="SRT Live Server"
LABEL org.opencontainers.image.description="Alpine container serving an SRT Live Server (SLS) instance"
LABEL org.opencontainers.image.authors="Thomas Bendler <code@thbe.org>"
LABEL org.opencontainers.image.version="1.2"
LABEL org.opencontainers.image.source="https://github.com/thbe/docker-sls"

# Set environment variables
ENV LANG=C.UTF-8 \
    TERM=xterm \
    LD_LIBRARY_PATH=/lib:/usr/lib:/srv/sls/lib64

# Create non-root user for security
RUN addgroup -g 1000 sls && \
    adduser -D -u 1000 -G sls -h /srv/sls -s /sbin/nologin sls

# Install runtime dependencies and create directories in single layer
RUN apk add --no-cache \
        libstdc++ \
        openssl && \
    mkdir -p /srv/sls/logs /srv/sls/tmp && \
    chown -R sls:sls /srv/sls

# Copy built artifacts from build stage
COPY --from=build --chown=sls:sls /srv/sls /srv/sls/
COPY --from=build --chown=sls:sls /srv/build/srt-live-server/bin /srv/sls/bin/

# Copy configuration files
COPY --chown=sls:sls root /

# Set executable permission
RUN chmod 755 /srv/run.sh

# Create volume for log files
VOLUME /srv/sls/logs

# Expose streaming port
EXPOSE 9710/udp

# Health check to verify server is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD pgrep -x sls > /dev/null || exit 1

# Switch to non-root user
USER sls

# Set workdir
WORKDIR /srv/sls/tmp

# Start SLS instance
CMD ["/srv/run.sh"]
