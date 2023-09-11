#FROM ghcr.io/tuxpeople/baseimage-alpine:3.14.3
#FROM balenalib/raspberrypi4-64-debian-openjdk:11
FROM balenalib/raspberrypi4-64-ubuntu

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
# hadolint ignore=DL3018,DL3019
RUN ["cross-build-start"]
RUN echo "deb http://archive.raspberrypi.org/debian/ jessie main ui staging" > /etc/apt/sources.list.d/raspi.list
RUN rm -f /usr/bin/entry.sh
RUN wget -qO - https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add -

RUN { \
        echo '#!/bin/bash'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home && \
    chmod +x /usr/local/bin/docker-java-home

RUN apt-key adv --recv-key --keyserver keyserver.ubuntu.com C2518248EEA14886 && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list.d/raspi.list

RUN set -x && \
    apt-get update && \
    apt-cache madison oracle-java8-installer && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    apt-get install -y oracle-java8-installer oracle-java8-set-default && \
    rm -rf /var/lib/apt/lists/* && \
    [ "$JAVA_HOME" = "$(docker-java-home)" ]

RUN [ "cross-build-end" ]

RUN apt-get update && apt-get install -y wget ca-certificates jq && wget -q -O /opt/JDownloader/JDownloader.jar --user-agent="Github Docker Image Build (https://github.com/tuxpeople)" "http://installer.jdownloader.org/JDownloader.jar" && chmod +x /opt/JDownloader/JDownloader.jar && chmod -R 777 /opt/JDownloader*

# archive extraction uses sevenzipjbinding library
# which is compiled against libstdc++
COPY ./ressources/${TARGETARCH}/*.jar /opt/JDownloader/libs/
#COPY ./root/ /
COPY ./config/default-config.json.dist /etc/JDownloader/settings.json.dist
COPY ./scripts/configure.sh /usr/bin/configure

EXPOSE 3129
CMD ["java","-Dsun.jnu.encoding=UTF-8", "-Dfile.encoding=UTF-8","-Djava.awt.headless=true","-jar","/opt/JDownloader/JDownloader.jar","-norestart"]
