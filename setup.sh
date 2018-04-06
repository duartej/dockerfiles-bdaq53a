#!/bin/bash

# BDAQ53a readout system for RD53A chip, 
# integration into the EUDAQ framework
#
# Run it the first time with the local
# installation of https://github.com/duartej/dockerfiles-eudaqv1
# 
# jorge.duarte.campderros@cern.ch (CERN/IFCA)
#
function print_usage
{
    echo
    echo "Usage:"
    echo "source setup.sh <path_to_docker-eudaq>"
    echo
}

# 0. Check the folder introduced by the user
if [ "X" == "X$1" ];
then 
    echo "Needed the path to the local installation of"
    echo "https://github.com/duartej/dockerfiles-eudaqv1"
    echo "This image cannot be used without the eudaqv1 image"
    print_usage
    exit -1
elif [ -f $1/initialize_service.sh ];
then
    if [ ! -f $1/.setupdone ];
    then
        echo "This image cannot be used without the eudaqv1 image setup"
        echo "Do previously in the '$1' directory:" 
        echo "$ /setup"
        print_usage
        exit -2
    fi
else
    echo "Needed the path to the local installation of"
    echo "https://github.com/duartej/dockerfiles-eudaqv1"
    echo "The introduced path is not the repository or is malformed"
    echo "Read path: '$1'"
    print_usage
    exit -3
fi

# 1. Check it is running as regular user
if [ "${EUID}" -eq 0 ];
then
    echo "Do not run this as root"
    exit -2
fi

# 2. Check if the setup was run:
if [ -e ".setupdone" ];
then
    echo "DO NOT DOING ANYTHING, THE SETUP WAS ALREADY DONE:"
    echo "=================================================="
    cat .setupdone
    exit -3
fi


# 3. Extract some info of the EUDAQ container (assuming python installed!)
EFOLDER=$(basename $1|sed 's/-//g')
PARSEFILE=$1/docker-compose.override.yml
# -- get the path where it was installed the EUDAQ source code
EUDAQCODE=$(python -c "with open('${PARSEFILE}') \
    as f: l=f.readlines(); print filter(lambda x: \
    x.find('source') != -1,l)[0].replace('source:','').strip()")
# --get the name of the create network
NETWORKNAME=${EFOLDER}_$(python -c "with open('${PARSEFILE}') \
    as f: l=f.readlines(); line=filter(lambda (i,x): \
    i and x.find('network') != -1,enumerate(l))[0][0]+1; \
    print l[line].replace(':','').strip()")

DOCKERDIR=${PWD}

## -- XXX Not by the moment
### 4. Download the code: 
##CODEDIR=${HOME}/repos/bdaq53
##mkdir -p ${CODEDIR} && cd ${CODEDIR}/.. ;
##if [ "X$(command -v git)" == "X" ];
##then
##    echo "You will need to install git (https://git-scm.com/)"
##    exit -1;
##fi
##
##echo "Cloning BDAQ53 into : $(pwd)"
##git clone  https://gitlab.cern.ch/silab/bdaq53.git bdaq53
##
##if [ "$?" -eq 128 ];
##then
##    echo "Repository already available at '${CODEDIR}'"
##    echo "Remove it if you want to re-clone it"
##else
##    echo "Switch to eudaq branch"
##    git checkout eudaq
##fi

# 3. Fill the place-holders of the .templ-docker-compose.yml 
cd ${DOCKERDIR}
# -- copying relevant files
for dc in .templ-docker-compose.yml;
do
    finalf=$(echo ${dc}|sed "s/.templ-//g")
    cp $dc $finalf
    sed -i "s#@CODEDIR#${EUDAQCODE}#g" $finalf
    sed -i "s#@NETWORKNAME#${NETWORKNAME}#g" $finalf
done

# 4. Create a .setupdone file with some info about the
#    setup
cat << EOF > .setupdone
BDAQ53A integration docker image and services
---------------------------------------------
Last setup performed at $(date)
eudaqv1-ubuntu CONTEX DIR: $(realpath $1)
EUDAQ LOCAL SOURCE CODE  : ${EUDAQCODE}
NETWORK                  : ${NETWORKNAME}
EOF
cat .setupdone

