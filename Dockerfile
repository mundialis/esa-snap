FROM mundialis/grass-py3-pdal:stable-alpine

LABEL authors="Carmen Tawalika,Markus Neteler"
LABEL maintainer="tawalika@mundialis.de,neteler@mundialis.de"

ARG SOURCE_GIT_URL=https://github.com
ARG SOURCE_GIT_REMOTE=mundialis
ARG SOURCE_GIT_REPO=esa_snap_docker
# can be "tags" (for tag) or "heads" (for) branch
ARG SOURCE_GIT_TYPE=heads
# can be a tag name or branch name
ARG SOURCE_GIT_REF=master

USER root

ENV BUILD_PACKAGES="\
      maven \
      openjdk8"

ENV PACKAGES="\
      git \
      vim"

WORKDIR /src

# Install minimalistic dependencies and tools
RUN echo "Install minimalistic dependencies and tools";\
    apk update; \
    apk add --no-cache \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
            $PACKAGES; \
    # Add packages just for the GRASS addon install process
    apk add --no-cache \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
            --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
            --virtual .build-deps $BUILD_PACKAGES; \
    #
    echo "Install step done"

ENV LC_ALL "en_US.UTF-8"

# install SNAPPY
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
COPY snap /src/snap
RUN sh /src/snap/install.sh

# Reduce the image size
RUN rm -rf /src/*; \
    # remove build dependencies and any leftover apk cache
    apk del --no-cache --purge .build-deps; \
    rm -rf /var/cache/apk/*; \
    rm -rf /root/.cache

ENTRYPOINT ["/bin/bash"]
#CMD ["/src/start.sh"]

