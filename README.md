# ESA SNAP 9 docker images

Docker images of ESA Sentinel Application Platform (SNAP) from http://step.esa.int/main/toolboxes/snap/

The related docker images are created and available for download from here:

https://hub.docker.com/r/mundialis/esa-snap

**Tag**|**Description**|**GitHub branch**|**Base image**|**Size**|**docker pull command**
:-----:|:-----:|:-----:|:-----:|:-----:|:-----:
s1tbx |Only s1tbx toolbox| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)  | Alpine 3.15 based | 600 MB| `docker pull mundialis/esa-snap:s1tbx`
latest|Only s1tbx toolbox| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)  | Alpine 3.15 based | 600 MB| `docker pull mundialis/esa-snap:latest`
ubuntu|All SNAP toolboxes| [ubuntu](https://github.com/mundialis/esa-snap/tree/ubuntu)| Ubuntu 18.04 based|   2 GB| `docker pull mundialis/esa-snap:ubuntu`


## Installation

Pull the Ubuntu Linux based image (all SNAP toolboxes included):

```
docker pull mundialis/esa-snap:ubuntu
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
    mundialis/esa-snap:ubuntu \
    /usr/local/snap/bin/snap
```

### SNAP Graph Processing Tool - command line

Using the SNAP Graph Processing Tool (GPT):

```
# show help of gpt tool
docker run -it --rm mundialis/esa-snap:ubuntu /usr/local/snap/bin/gpt -h
```

One can pass the required processing settings in an XML-encoded graph file which is passing this
graph as parameter to the gpt tool:

```
docker run -it --rm mundialis/esa-snap:ubuntu /usr/local/snap/bin/gpt <GraphFile.xml> [options] [<source-file-1> <source-file-2> ...]
```

For further `gpt` usage please refer to the official documentation.

## Background info

This docker image is based on Ubuntu (`ubuntu` branch). 


## Where is the Alpine based docker image?

Find the Alpine based docker image related files in branch `s1tbx` (see [here](https://github.com/mundialis/esa-snap/tree/s1tbx)).
See there for related instructions.


