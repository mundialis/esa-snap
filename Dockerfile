FROM alpine:edge

LABEL authors="Carmen Tawalika,Markus Neteler"
LABEL maintainer="tawalika@mundialis.de,neteler@mundialis.de"

USER root

ENV BUILD_PACKAGES="\
      gawk \
      gcc \
      git \
      maven \
      musl-dev \
      python3-dev \
      wget \
      "

ENV PACKAGES="\
      fontconfig \
      openjdk8 \
      python3 \
      vim \
      ttf-dejavu \
      zip \
      "

RUN echo "Install dependencies and tools";\
    apk update; \
    apk add --no-cache --virtual .build-deps $BUILD_PACKAGES; \
    apk add --no-cache $PACKAGES; \
    echo "Install step done"

ENV LC_ALL "en_US.UTF-8"
# SNAP wants the current folder '.' included in LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"

# install SNAPPY
ENV JAVA_HOME "/usr/lib/jvm/java-1.8-openjdk"
# SNAP wants the current folder '.' included in LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"

COPY snap /src/snap
RUN sh /src/snap/install.sh
