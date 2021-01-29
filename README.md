# ESA SNAP 8 docker images

Docker image of ESA Sentinel Application Platform (SNAP) from http://step.esa.int/main/toolboxes/snap/

The related docker images are created and available for download from here:

https://hub.docker.com/r/mundialis/esa-snap

**Tag**|**Description**|**GitHub branch**|**Base image**|**Size**|**docker pull command**
:-----:|:-----:|:-----:|:-----:|:-----:|:-----:
s1tbx |Only s1tbx toolbox| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)   | Alpine based| 600 MB| `docker pull mundialis/esa-snap:s1tbx`
latest|All SNAP toolboxes| [master](https://github.com/mundialis/esa-snap/)            | Alpine based|1.15 GB| `docker pull mundialis/esa-snap:latest`
ubuntu|All SNAP toolboxes| [ubuntu](https://github.com/mundialis/esa-snap/tree/ubuntu) | Ubuntu based|   2 GB| `docker pull mundialis/esa-snap:ubuntu`

## Background info

This docker image (master branch) is based on Alpine Linux. Furthermore,

* the original installer provided by ESA ships its own oracle java
* Alpine is based on musl libc and busybox. As Oracle JAVA depends on glibc, it
  doesn't work smoothly. With https://github.com/sgerrand/alpine-pkg-glibc this
  can be workarounded to a certain way but in our case not sufficient (conflicting dependencies).
* From SNAP Version 8, oracle java > 8 and openjdk in general will be supported
  officially (https://forum.step.esa.int/t/problems-running-tests-in-intellij/9350/8)

## Where is the Ubuntu based docker image?

Find the Ubuntu based docker image related files in branch `ubuntu` (see [here](https://github.com/mundialis/esa-snap/tree/ubuntu)).

## Dev stuff

Alternatively, a build approch was tried out. Kept here if needed further.
As stable SNAP version 7.0.2 needs maven 3.6.0 (while alpine offers 3.6.3), so SNAP 8 was built for testing.

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
