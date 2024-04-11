# ESA SNAP 9 docker images

Docker images of ESA Sentinel Application Platform (SNAP) from http://step.esa.int/main/toolboxes/snap/

The related docker images are created and available for download from here:

https://hub.docker.com/r/mundialis/esa-snap

**Tag**|**Description**|**GitHub branch**|   **Base image**   | **Size** |**docker pull command**
:-----:|:-----:|:-----:|:------------------:|:--------:|:-----:
s1tbx |Only s1tbx toolbox| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)  | Alpine 3.18 based  |  1.4 GB  | `docker pull mundialis/esa-snap:s1tbx`
latest|Only s1tbx toolbox| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)  | Alpine 3.18 based  |  1.4 GB  | `docker pull mundialis/esa-snap:latest`
ubuntu|All SNAP toolboxes| [ubuntu](https://github.com/mundialis/esa-snap/tree/ubuntu)| Ubuntu 18.04 based |   2 GB   | `docker pull mundialis/esa-snap:ubuntu`


## Installation

Pull the Alpine Linux based image (only SNAP Sentinel-1 toolbox):

```
docker pull mundialis/esa-snap:latest
```

## Tutorial

We recommend the following tutorial:

http://step.esa.int/docs/tutorials/SNAP_CommandLine_Tutorial.pdf

### Usage examples

#### SNAP Graphical User Interface - GUI

Using the GUI, among other functionality the GraphBuilder is available.

Start of GUI, with volume mapping of current directory (`pwd`; may be set to a
different directory) to `/data/` within docker:

```
docker run -it --rm --volume="$(pwd)/:/data" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --env DISPLAY=$DISPLAY --device="/dev/dri/card0:/dev/dri/card0" \
    mundialis/esa-snap:latest \
    /usr/local/snap/bin/snap
```

### SNAP Graph Processing Tool - command line
Using the SNAP Graph Processing Tool (GPT):

```
# show help of gpt tool
docker run -it --rm mundialis/esa-snap:latest /usr/local/snap/bin/gpt -h
```

One can pass the required processing settings in an XML-encoded graph file which is passing this
graph as parameter to the gpt tool:

```
docker run -it --rm mundialis/esa-snap:latest /usr/local/snap/bin/gpt <GraphFile.xml> [options] [<source-file-1> <source-file-2> ...]
```

For further `gpt` usage please refer to the official documentation.

## Background info

This docker image is based on Alpine Linux and **only contains the s1tbx toolbox**. Furthermore,

* the original installer provided by ESA ships its own oracle java
* Alpine is based on musl libc and busybox. As Oracle JAVA depends on glibc, it
  doesn't work smoothly. With https://github.com/sgerrand/alpine-pkg-glibc this
  can be workarounded to a certain way but in our case not sufficient (conflicting dependencies).
* From SNAP Version 8, oracle java > 8 and openjdk in general will be supported
  officially (https://forum.step.esa.int/t/problems-running-tests-in-intellij/9350/8)

## Where is the Ubuntu based docker image?

Find the Ubuntu based docker image related files in branch `ubuntu` (see [here](https://github.com/mundialis/esa-snap/tree/ubuntu)).
See there for related instructions.

## Alpine dev stuff

Alternatively, a build approach was tried out. Kept here if needed further.
As the stable SNAP version 7.0.2 needs maven 3.6.0 (while alpine offers 3.6.3), so SNAP 8 was built for testing.

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
