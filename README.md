# SLS on Docker

[![Build Status](https://img.shields.io/docker/automated/thbe/sls.svg)](https://hub.docker.com/r/thbe/sls/builds/) [![GitHub Stars](https://img.shields.io/github/stars/thbe/docker-sls.svg)](https://github.com/thbe/docker-sls/stargazers) [![Docker Stars](https://img.shields.io/docker/stars/thbe/sls.svg)](https://hub.docker.com/r/thbe/sls) [![Docker Pulls](https://img.shields.io/docker/pulls/thbe/sls.svg)](https://hub.docker.com/r/thbe/sls)

This Docker image could be used to run an SRT Live Server (SLS) instance. The Docker image is based on the official [Alpine Linux](https://hub.docker.com/r/_/alpine/).

#### Table of Contents

- [Install Docker](https://github.com/thbe/docker-sls#install-docker)
- [Download](https://github.com/thbe/docker-sls#download)
- [How to use this image](https://github.com/thbe/docker-sls#how-to-use-this-image)
- [Next steps](https://github.com/thbe/docker-sls#next-steps)
- [Update Docker image](https://github.com/thbe/docker-sls#update-docker-image)
- [Advanced usage](https://github.com/thbe/docker-sls#advanced-usage)
- [Technical details](https://github.com/thbe/docker-sls#technical-details)
- [Development](https://github.com/thbe/docker-sls#development)

## Install Docker

To use this image you have to [install Docker](https://docs.docker.com/engine/installation/) first.

## Download

You can get the trusted build from the [Docker Hub registry](https://hub.docker.com/r/thbe/sls/):

```
docker pull thbe/sls
```

Alternatively, you may build the Docker image from the
[source code](https://github.com/thbe/docker-sls#build-from-source-code) on GitHub.

## How to use this image

### Start the sls instance

The instance can be started as follow:

```
docker run --detach --restart always --name sls --hostname sls.$(hostname -d) -p 9710:9710/udp thbe/sls
```

### Check server status

You can use the standard Docker commands to examine the status of the sls instance:

```
docker logs --tail 1000 --follow --timestamps sls
```

### Use server

Example Sending of SRT in OBS:
* In the setup menu under "Stream", select "Custom..."  leave the Key field blank.
* Put the following url to send to your docker container: `srt://your.server.ip:9710?streamid=publish/stream/yourstreamname`

Example of Receiving of SRT in OBS:
* Add a Media Source
* Put the following url to receive: `srt://your.server.ip:9710?streamid=stream/live/yourstreamname`

### Example usage

You can find the blog article [virtual come together](https://thbe.org/posts/2020/11/29/Virtual_come_together.html) on my website that shows a real life usage example of SLS.

## Next steps

The next release of this Docker image should have a persistent sls configuration outside of the docker image.

## Update Docker image

Simply download the trusted build from the [Docker Hub registry](https://hub.docker.com/r/thbe/sls/):

```
docker pull thbe/sls
```

## Advanced usage

### Build from source code

You can build the image also from source. To do this you have to clone the
[docker-sls](https://github.com/thbe/docker-sls) repository from GitHub:

```
git clone https://github.com/thbe/docker-sls.git
cd docker-sls
docker build --rm --no-cache -t thbe/sls .
```

### Bash shell inside container

If you need a shell inside the container you can run the following command:

```
docker exec -ti sls /bin/sh
```

## Technical details

- Alpine base image
- srt and sls source code from official Github repository

## Development

If you like to add functions or improve this Docker image, feel free to fork the repository and send me a merge request with the modification.
