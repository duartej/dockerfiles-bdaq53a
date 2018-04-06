# BDAQ53-EUDAQ integration dockerfile

Creates the environment to develop the BDAQ53 readout
system against the EUDAQ framework. 
This image is based on [duartej/eudaqv1-ubuntu image](dockerfiles-eudaqv1) 
so it is assume that the repository is present locally 
(pointing to ```EDAQDOCKER```) and was installed and configured.

## Installation
1. Clone the docker eudaq repository and configure it
```bash 
$ git clone https://github.com/duartej/dockerfiles-bdaq53a.git
$ cd dockerfiles-bdaq53a
$ source setup.sh ${EDAQDOCKER}
```
The ```setup.sh``` creates the ```docker-compose.yml``` based
in some system information of the requirement dockerfiles-eudaqv1

2. Download the automated build from the dockerhub: 
```bash
$ docker pull duartej/bdaq53
```
or alternativelly you can build an image from the
[Dockerfile](Dockerfile)
```bash
# Using docker
$ docker build github.com/duartej/bdaq53
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
$ docker-compose run --rm devcode
```


