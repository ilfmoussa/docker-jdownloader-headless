#FROM ghcr.io/tuxpeople/baseimage-alpine:3.14.3
#FROM balenalib/raspberrypi4-64-debian-openjdk:11
FROM ghcr.io/ilfmoussa/ubuntu-jdk:arm

# set args
ARG BUILD_DATE
ARG VERSION
ARG TARGETARCH
ARG TARGETPLATFORM
ARG NAME

# set env
ENV LD_LIBRARY_PATH=/lib;/lib32;/usr/lib
ENV XDG_DOWNLOAD_DIR=/opt/JDownloader/Downloads
ENV UMASK=''
ENV LC_CTYPE="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LC_COLLATE="C"
ENV LANGUAGE="C.UTF-8"
ENV LC_ALL="C.UTF-8"

# ARG TARGETPLATFORM
# ARG BUILDPLATFORM
# ARG TARGETOS
# ARG TARGETARCH
# ARG TARGETVARIANT
# RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"
# RUN echo "$TARGETPLATFORM consists of $TARGETOS, $TARGETARCH and $TARGETVARIANT"

WORKDIR /opt/JDownloader
VOLUME /opt/JDownloader/Downloads
VOLUME /opt/JDownloader/cfg

# Upgrade and install dependencies

RUN apt-get update && apt-get install -y wget ca-certificates jq && chmod -R 777 /opt/JDownloader*

# archive extraction uses sevenzipjbinding library
# which is compiled against libstdc++
COPY ./ressources/${TARGETARCH}/*.jar /opt/JDownloader/libs/

COPY ./config/default-config.json.dist /etc/JDownloader/settings.json.dist
COPY ./scripts/configure.sh /usr/bin/configure
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD [ "/entrypoint.sh" ]
