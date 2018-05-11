# BDAQ53-EUDAQ integration dockerfile

Creates the environment to develop the BDAQ53 readout
system against the EUDAQ framework. 
This image is based on [duartej/eudaqv1-ubuntu image](dockerfiles-eudaqv1:eutelescope) 
so it is assume that the repository is present locally 
(pointing to ```EDAQDOCKER```) and was installed and configured.
This eudaqv1 image contains all needed dependencies to compile
against EUTelescope as well.

## Installation
1. Clone the docker eudaq repository and configure it
```bash 
$ git clone https://github.com/duartej/dockerfiles-bdaq53a.git
$ cd dockerfiles-bdaq53a
$ source setup.sh ${EDAQDOCKER}
```
The ```setup.sh``` creates the ```docker-compose.yml``` and 
```docker-compose.override.yml``` based in some system information
of the requirement dockerfiles-eudaqv1. If there is no 
[bdaq53](https://gitlab.cern.ch/silab/bdaq53) local repository in
the system at ```$HOME/repos/bdaq53```, it clones in there.

2. Download the automated build from the dockerhub: 
```bash
$ docker pull duartej/bdaq53:eutelescope
```
or alternativelly you can build an image from the
[Dockerfile](Dockerfile)
```bash
# Using docker
$ docker build github.com/duartej/bdaq53:eutelescope
# Using docker-compose
$ docker-compose build bdaq53
```

## Usage
Note that any container created with this image will 
assume that the EUDAQ source code is in the host computer
at ```$HOME/repos/eudaq``` binded to the container path
```/eudaq/eudaq```. 

As any service defined in the ```docker-compose.yml``` uses 
the external network created by the  ```eudaqv1-ubuntu``` image, 
the proper way to run any service (expect building the image) is 
creating first the usual EUDAQ services, at least run control 
and a data-collector (for the plugin convertor, the online monitor as well).

```bash
# Start the minimum services usefuls at eudaqv1-ubuntu image context
$ cd $EDAQDOCKER
$ docker-compose run --rm dataCollector 
# Open a new terminal (or add -d to the previous command)
$ docker-compose run --rm onlineMon
# Come back to the bdaq53 docker image folder (BDAQ53DOCKER)
$ cd $BDAQ53DOCKER
# Start the service setting up the development environment
$ docker-compose run --rm devcode-bdaq53
# In order to run an image of the container not using docker-compose,
# for instance, to create a new devcode-bdaq53 
$ docker run -it --rm -v /tmp/.X11-unix:/tmp/.X11-unix --mount type=bind,source=${HOME}/repos/eudaq,target=/eudaq/eudaq --mount type=bind,source=${HOME}/bdaq53,target=/bdaq53/bdaq53 -e DISPLAY=unix${DISPLAY} --network=dockerfileseudaqv1_static_network --ip=172.20.128.34 duartej/bdaq53
```


### Production
The production mode does not uses the local host machine 
[bdaq53](https://gitlab.cern.ch/silab/bdaq53) repository but the downloaded
inside the image (probably a pre-defined release). The service should be
run with
```bash
$ docker-compose -f docker-compose.yml run --rm devcode
```


