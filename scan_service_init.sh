#!/bin/bash

# Some useful functions
# -- Name of the run control   
if [ "X$1" == "Xscans-10" ];
then
    KINTEX=10
    MODIFY_IP=true
elif [ "X$1" == "Xscans-16" ];
then
    KINTEX=16
    MODIFY_IP=false
else
    echo "Initialization script should not be invoked with '$1'" 
    exit -1
fi
# Propagating env. variables
export KINTEX

# Extract DUT id from user
echo "Service initialization ..."
printf "Introduce DUT ID [0,1,2,3]: "
while [ ! ${finished} ]
do 
  read -r DUT
  if [ "X$DUT" != "X0" ] &&
        [ "X$DUT" != "X1" ] &&
        [ "X$DUT" != "X2" ] &&
        [ "X$DUT" != "X3" ]; 
  then
      echo "\[\033[01;31m\]Invalid DUT ID: '${DUT}'\[\033[00m\]"
      finished=false
  else
      finished=true
  fi
done

# Initialize a scan eudaq service
echo "###########################################"
echo "+ IMAGE: duartej/bdaq53"
echo "+ CONTAINER ID: ${HOSTNAME}"
echo "+ MODE: scans-${KINTEX}"
echo "+-- KINTEX PORT IP: 192.168.10.${KINTEX}"
echo "  +- DUT: ${DUT}"
echo "###########################################"


# Rename the command line
_PS1="\[\033[01;32m\][K${KINTEX}-PC${PC}::DUT${DUT}]\[\033[00m\]$ "
echo "PS1=\"${_PS1}\"" >> $HOME/.bashrc

# Substitute IP addresses if needed
if [ ${MODIFY_IP} ]; 
then  
    cd /bdaq53/bdaq53/bdaq53
    for filemod in bdaq53.yaml rbcp.py;
    do 
        sed -i -e 's/192.168.10.16/192.168.10.10/g' ${filemod}
    done 
    sed -i -e 's/10,16/10,10/g' rbcp.py
fi

# Define a quick alias to launch 
# Be sure the dut is propagated
export DUT
alias bdaq53_producer='python scan_eudaq.py tcp://192.168.5.2 -b ${DUT}"'
