FROM alpine:3.24 as base

# SNAP 14 requires Java 21; use Alpine's system JVM.
RUN apk add openjdk21


FROM base as build

LABEL authors="Carmen Tawalika,Markus Neteler, Guido Riembauer"
LABEL maintainer="tawalika@mundialis.de,neteler@mundialis.de, riembauer@mundialis.de"

USER root

# Python/snappy is no longer needed; make builds the SNAPHU executable.
ENV BUILD_PACKAGES="\
      gawk \
      gcc \
      gcompat \
      git \
      maven \
      musl-dev \
      make \
      wget \
      "

ENV PACKAGES="\
      fontconfig \
      gcompat \
      libgfortran \
      openjdk21 \
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
ENV LD_LIBRARY_PATH ".:/usr/lib/jvm/java-21-openjdk/lib/server/:$LD_LIBRARY_PATH"

# Install SNAP 14 with the Microwave Toolbox, without esa_snappy.
ENV JAVA_HOME "/usr/lib/jvm/java-21-openjdk"

COPY snap /src/snap
RUN sh /src/snap/install.sh


FROM base as snap

# Keep the system JVM and native compatibility libraries in the runtime image.
RUN apk add openjdk21 gcompat ttf-dejavu
ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
COPY --from=build /usr/local/bin/snaphu /usr/local/bin/snaphu
COPY --from=build /root/.snap /root/.snap
COPY --from=build /usr/local/snap /usr/local/snap
# update SNAP from Web, requires font
RUN /usr/local/snap/bin/snap --nosplash --nogui --modules --update-all

# Fix native library compatibility and the official SNAPHU adapter for headless GPT.
COPY snap/snap-runtime.sh /src/snap/snap-runtime.sh
RUN sh /src/snap/snap-runtime.sh

# add gpt to PATH
ENV PATH="${PATH}:/usr/local/snap/bin"
# Test GPT operators; SNAPHU reports successful help output with exit code 1.
RUN gpt -h && gpt SnaphuExport -h && gpt Snaphu-unwrapping -h && gpt SnaphuImport -h && (snaphu -h || test "$?" -eq 1)
