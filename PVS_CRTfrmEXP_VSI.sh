#!/bin/bash

###############################################
# Parameters
###############################################
if [[ -n "$1" ]]; then
  NewVSINAME=$1
else
  echo "########################################################################################"
  echo ""
  echo "PowerVS New VSI name must be provided as a parameter"
  echo ""
  echo "USAGE:"
  echo "./PVS_CRTfrmEXP_VSI.sh <New VSI Name> [<SubNet>] [<IP Address>] [<System Type>]"
  echo ""
  echo "########################################################################################"
  # Exiting program
  exit 1
fi

if [[ -n "$2" ]]; then
  SubNet==$2
else
  SubNet='subnet1'
fi

if [[ -n "$3" ]]; then
  IPAddr==$3
else
  IPAddr='192.168.1.123'
fi

if [[ -n "$4" ]]; then
  SysType==$4
else
  SysType='s1022'
fi

###############################################
# Constants
###############################################
source PVS_const.sh
source PVS_functions.sh
InCapDest="image-catalog";

dt=$(date -R);
errorcheck=0;
###############################################


#=========================================================#

# Login #
CLOUDLOGIN

# Check if export is already running #
EXPORTCHECK

if [ $errorcheck == 0 ]
then
    # Clean old VSI with the same name
    RMVOLDINSTANCE
    # Get previously saved image name
    GETPREVIMGNAME
    ImageName=$PrevImageName
 	  # Create new VSI
    CRTNEWVSI
fi
