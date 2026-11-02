# ESA SNAP 14 docker images

Docker images of ESA Sentinel Application Platform (SNAP) from http://step.esa.int/main/toolboxes/snap/

The related docker images are created and available for download from here:

https://hub.docker.com/r/mundialis/esa-snap

**Tag**|**Description**|**GitHub branch**|   **Base image**   | **Size** |**docker pull command**
:-----:|:-----:|:-----:|:------------------:|:--------:|:-----:
s1tbx |Microwave toolbox + SNAPHU| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)  | Alpine 3.24 based  |  build-dependent  | `docker pull mundialis/esa-snap:s1tbx`
latest|Microwave toolbox + SNAPHU| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)  | Alpine 3.24 based  |  build-dependent  | `docker pull mundialis/esa-snap:latest`
ubuntu|All SNAP toolboxes| [ubuntu](https://github.com/mundialis/esa-snap/tree/ubuntu)| Ubuntu 18.04 based |   2 GB   | `docker pull mundialis/esa-snap:ubuntu`


## Installation

Pull the Alpine Linux based image (SNAP 14 Microwave Toolbox and SNAPHU):

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

This docker image is based on Alpine Linux and contains the **Microwave Toolbox** (including Sentinel-1 support) and **SNAPHU 2.0.7**. It uses Alpine 3.24 and the system OpenJDK 21. The bundled installer JVM is removed.
The Python interface esa_snappy and Python dependencies are not installed.
Available SNAP 14 module updates are applied during the image build (tested with 14.0.2).
The Linux installer and native library setup target x86_64.
The system Fortran runtime and explicit library search paths fix Alpine
compatibility issues in SNAP's bundled native libraries.

## SNAPHU and GPT

SNAPHU 2.0.7 is compiled for Alpine and installed as `/usr/local/bin/snaphu`.
The official SNAPHU Unwrapping plugin is installed and configured to use this binary.
No interactive bundle installation is required. The adapter configuration also fixes
headless variable resolution, exposes `outputFolder` to GPT, and allows repeated
runs in the same output folder.

```sh
docker build -t esa-snap:14 .
docker run --rm esa-snap:14 gpt -h
docker run --rm esa-snap:14 snaphu -h
docker run --rm esa-snap:14 gpt SnaphuExport -h
docker run --rm esa-snap:14 gpt Snaphu-unwrapping -h
docker run --rm esa-snap:14 gpt SnaphuImport -h
```

`snaphu -h` prints the help text and returns exit code 1 (upstream behaviour).

Use these operators in GPT XML graphs for export, unwrapping and import.
Export must finish writing the SNAPHU files before unwrapping starts; import
must run after unwrapping finishes. Run the stages as separate GPT graph calls
so that the required files exist before the next stage reads them. Keep the
exported phase, coherence, configuration and unwrapped files in a mounted directory.
For the unwrapping graph, read the exported phase `.hdr` file and set
`outputFolder` to the export directory and `targetProductFile` to the unwrapped
phase `.hdr` file. For example:

```xml
<graph id="unwrap">
  <version>1.0</version>
  <node id="read">
    <operator>Read</operator>
    <parameters><file>${phaseHeader}</file></parameters>
  </node>
  <node id="unwrap">
    <operator>Snaphu-unwrapping</operator>
    <sources><sourceProduct refid="read"/></sources>
    <parameters>
      <outputFolder>${exportFolder}</outputFolder>
      <targetProductFile>${unwrappedHeader}</targetProductFile>
    </parameters>
  </node>
</graph>
```

Pass these graph parameters with `-PphaseHeader=... -PexportFolder=... -PunwrappedHeader=...`.
Use absolute container paths in a mounted directory. Import the unwrapped `.hdr`
together with the original wrapped SNAP product using `SnaphuImport` to retain
geocoding and metadata. Run unwrapping sequentially within a container: the
upstream adapter uses `/root` as its temporary working directory.

For a stack with multiple interferograms, process matching phase/coherence pairs.
`BatchSnaphuUnwrapOp` is also provided by the Microwave Toolbox; its
`snaphuInstallLocation` can point to `/usr/local/bin/snaphu`.

Validation with a Sentinel-1 stack: Subset, BandSelect, BandMaths,
SnaphuExport → Snaphu-unwrapping → SnaphuImport, repeated unwrapping,
and a NetCDF4-CF write/read roundtrip passed. CLI and GPT unwrapping produced
identical pixels; import preserved elevation and geocoding.
An additional NetCDF4-BEAM roundtrip with the stack's extensive metadata failed
in SNAP's Java HDF5 reader. Use the tested BEAM-DIMAP or NetCDF4-CF formats
for this workflow.

Official documentation: [SNAP download](https://step.esa.int/main/download/snap-download/),
[SNAPHU plugin](https://step.esa.int/main/snap-supported-plugins/snaphu/),
[SNAPHU software](https://web.stanford.edu/group/radar/softwareandlinks/sw/snaphu/).

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
