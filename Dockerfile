FROM alpine:3.12 as base

ARG OPENJDK_VERSION=8.232.09-r0
ARG OPENJDK_PKGS_URL=https://github.com/mmacata/alpine-openjdk8/releases/download/$OPENJDK_VERSION

RUN apk add curl
RUN curl -L $OPENJDK_PKGS_URL/openjdk8-$OPENJDK_VERSION.apk > openjdk8-$OPENJDK_VERSION.apk
RUN curl -L $OPENJDK_PKGS_URL/openjdk8-jre-$OPENJDK_VERSION.apk > openjdk8-jre-$OPENJDK_VERSION.apk
RUN curl -L $OPENJDK_PKGS_URL/openjdk8-jre-base-$OPENJDK_VERSION.apk > openjdk8-jre-base-$OPENJDK_VERSION.apk
RUN curl -L $OPENJDK_PKGS_URL/openjdk8-jre-lib-$OPENJDK_VERSION.apk > openjdk8-jre-lib-$OPENJDK_VERSION.apk

RUN apk add --allow-untrusted \
    openjdk8-jre-lib-$OPENJDK_VERSION.apk \
    openjdk8-$OPENJDK_VERSION.apk \
    openjdk8-jre-base-$OPENJDK_VERSION.apk \
    openjdk8-jre-$OPENJDK_VERSION.apk


FROM base as build

LABEL authors="Carmen Tawalika,Markus Neteler"
LABEL maintainer="tawalika@mundialis.de,neteler@mundialis.de"

USER root

ENV BUILD_PACKAGES="\
      gawk \
      gcc \
      gcompat \
      git \
      maven \
      musl-dev \
      python3-dev \
      wget \
      "

ENV PACKAGES="\
      fontconfig \
      gcompat \
      libgfortran libgfortran5 \
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

COPY snap /src/snap
RUN sh /src/snap/install.sh


FROM base as snappy

RUN apk add python3 ttf-dejavu
ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"
ENV JAVA_HOME "/usr/lib/jvm/java-1.8-openjdk"
COPY --from=build /root/.snap /root/.snap
COPY --from=build /usr/local/snap /usr/local/snap
COPY --from=build /src/snap /root/snap
RUN (cd /root/.snap/snap-python/snappy && python3 setup.py install)
# update SNAP from Web, requires font
RUN sh /root/snap/update.sh
RUN /usr/bin/python3 -c 'from snappy import ProductIO'
RUN /usr/bin/python3 /root/.snap/about.py
