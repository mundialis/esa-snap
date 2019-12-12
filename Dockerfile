FROM alpine:edge

LABEL authors="Carmen Tawalika,Markus Neteler"
LABEL maintainer="tawalika@mundialis.de,neteler@mundialis.de"

USER root

ENV BUILD_PACKAGES="\
      gcc \
      git \
      maven \
      musl-dev \
      python3-dev \
      wget \
      "

ENV PACKAGES="\
      openjdk11 \
      python3 \
      vim \
      zip \
      "

RUN echo "Install dependencies and tools";\
    apk update; \
    apk add --no-cache --virtual .build-deps $BUILD_PACKAGES; \
    apk add --no-cache $PACKAGES; \
    echo "Install step done"


ENV LC_ALL "en_US.UTF-8"

# install SNAPPY
ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk"
ENV PATH $PATH:/usr/lib/jvm/java-11-openjdk/bin
COPY snap /src/snap
RUN sh /src/snap/install.sh
