# ESA SNAP docker image

Docker image of ESA Sentinel Application Platform (SNAP) from http://step.esa.int/main/toolboxes/snap/

The related docker image created and available for download from here:

https://hub.docker.com/r/mundialis/esa-snap

## Background info

This docker image is based on alpine

* the original installer provided by ESA ships its own oracle java
* alpine is based on musl libc and busybox. As oracle java depends on glibc, it
  doesn't work smoothely. With https://github.com/sgerrand/alpine-pkg-glibc this
  can be workarounded to a certain way but in our case not sufficient (conflicting dependencies).
* Current SNAP Version (8.0.0) is recommended to be run with JAVA 8.
  From Version 8, oracle java > 8 and openjdk in general will be supported officially (https://forum.step.esa.int/t/problems-running-tests-in-intellij/9350/8)


## Dev stuff

Alternatively, a build approch was tried out. Kept here if needed further.
As stable version 8.0.0 needs maven 3.6.0 (while alpine offers 3.6.3), so SNAP 8 was built for testing.

```

FROM alpine:edge

<!-- ARG SNAP_ENGINE_TAG=8.0.0 -->
ENV JAVA_HOME "/usr/lib/jvm/java-1.8-openjdk"

RUN apk add git openjdk8 maven
RUN git clone https://github.com/senbox-org/snap-engine.git /src/snap/snap-engine
WORKDIR /src/snap/snap-engine
<!-- RUN git checkout $SNAP_ENGINE_TAG -->
RUN sed -i 's+<module>snap-classification</module>+<!--<module>snap-classification</module>-->+g' pom.xml
RUN mvn clean install -DskipTests

WORKDIR /src/snap/s1tbx
git clone https://github.com/senbox-org/s1tbx.git /src/snap/s1tbx
cd s1tbx
mvn clean install

WORKDIR /src/snap/snap-enginge
java -cp snap-runtime/target/snap-runtime.jar org.esa.snap.runtime.BundleCreator ../snap.zip "/src/snap/snap-engine" "/src/snap/s1tbx"

```
