# ESA SNAP 9 docker image

Ubuntu based docker image of ESA Sentinel Application Platform (SNAP) from http://step.esa.int/main/toolboxes/snap/

The related docker images are created and available for download from here:

https://hub.docker.com/r/mundialis/esa-snap

**Tag**|**Description**|**GitHub branch**|**Base image**|**Size**|**docker pull command**
:-----:|:-----:|:-----:|:-----:|:-----:|:-----:
s1tbx |Only s1tbx toolbox| [s1tbx](https://github.com/mundialis/esa-snap/tree/s1tbx)   | Alpine based| 600 MB| `docker pull mundialis/esa-snap:s1tbx`
latest|All SNAP toolboxes| [master](https://github.com/mundialis/esa-snap/)            | Alpine based|1.15 GB| `docker pull mundialis/esa-snap:latest`
ubuntu|All SNAP toolboxes| [ubuntu](https://github.com/mundialis/esa-snap/tree/ubuntu) | Ubuntu based|   2 GB| `docker pull mundialis/esa-snap:ubuntu`


## Installation

Pull the Ubuntu Linux based image (all SNAP toolboxes included):

```
docker pull mundialis/esa-snap:ubuntu
```

## Background info

This docker image is based on Ubuntu (`ubuntu` branch). 

Note: the Alpine based docker image is located in the `master` branch.
