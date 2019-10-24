#FROM neteler/docker-alpine-grass-gis
FROM mundialis/grass-py3-pdal

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

# Install dependencies and tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    build-essential \
    python3 \
    vim \
    wget \
    zip \
    && apt-get autoremove -y \
    && apt-get clean -y

ENV LC_ALL "en_US.UTF-8"

# install SNAPPY
RUN apt-get install default-jdk maven -y
ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64"
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
COPY snap /src/snap
RUN sh /src/snap/install.sh
RUN update-alternatives --remove python /usr/bin/python3


# Reduce the image size
RUN apt-get autoremove -y
RUN apt-get clean -y

ENTRYPOINT ["/bin/bash"]
#CMD ["/src/start.sh"]

