FROM alpine:latest as build
#
# BUILD:
#   wget https://raw.githubusercontent.com/thbe/docker-sls/master/Dockerfile
#   docker build --rm --no-cache -t thbe/sls .
#
# USAGE:
#   docker run --detach --restart always --name sls --hostname sls.$(hostname -d) -p 10000:10000/udp thbe/sls
#   docker logs --tail 1000 --follow --timestamps sls
#   docker exec -ti sls /bin/sh
#

# Set metadata
LABEL maintainer="Thomas Bendler <code@thbe.org>"
LABEL version="1.0"
LABEL description="Creates an Alpine container serving an SRT Live Server (SLS) instance"

# Set environment
ENV LANG en_US.UTF-8
ENV TERM xterm

# Install build tools
RUN apk update --no-cache &&\
    apk add --no-cache linux-headers alpine-sdk cmake tcl openssl-dev zlib-dev &&\
    apk upgrade --no-cache

# Set workdir and clone GIT repositories for srt and srt-live-server
WORKDIR /srv/build
RUN git clone https://github.com/Haivision/srt.git &&\
    git clone https://github.com/Edward-Wu/srt-live-server.git

# Replace Makefile
COPY build/Makefile /srv/build/srt-live-server/Makefile

# Set workdir and build srt
WORKDIR /srv/build/srt
RUN ./configure --prefix=/srv/sls && make && make install

# Set workdir and build srt-live-server
WORKDIR /srv/build/srt-live-server
RUN make

# Create final Docker image from build image
FROM alpine:latest

# Set library path
ENV LD_LIBRARY_PATH /lib:/usr/lib:/usr/local/lib64

# Install and setup runtime environment
RUN apk update --no-cache &&\
    apk add --no-cache openssl libstdc++ &&\
    apk upgrade --no-cache &&\
    mkdir -p /srv/sls/logs

# Install srt and sls application
COPY --from=build /srv/sls /srv/sls/
COPY --from=build /srv/build/srt-live-server/bin /srv/sls/bin/

# Copy configuration files
COPY root /

# Create volume for log files
VOLUME /srv/sls/logs

# Expose streaming port
EXPOSE 10000/udp

# Set workdir to srt user home directory
WORKDIR /srv/sls/tmp

# Start srt-live-server instance
ENTRYPOINT [ "/srv/sls/bin/sls", "-c", "/srv/sls/etc/sls.conf"]
