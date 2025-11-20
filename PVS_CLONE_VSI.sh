#!/bin/bash

###############################################
# Parameters
###############################################
if [[ -n "$1" ]]; then
  VSINAME=$1
else
  echo "########################################################################################"
  echo ""
  echo "PowerVS VSI name must be provided as a parameter"
  echo ""
  echo "USAGE:"
  echo "./PVS_CLONE_VSI.sh <VSI Name> [<New VSI Name>] [<SubNet>] [<IP Address>] [<System Type>]"
  echo ""
  echo "########################################################################################"
  # Exiting program
  exit 1
fi

if [[ -n "$2" ]]; then
  NewVSINAME=$2
else
  NewVSINAME=$1'_2'
fi

if [[ -n "$3" ]]; then
  SubNet=$3
else
  SubNet='subnet1'
fi

if [[ -n "$4" ]]; then
  IPAddr=$4
else
  IPAddr='192.168.1.123'
fi

if [[ -n "$5" ]]; then
  SysType=$5
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
  # Start Cloud Init #
  CLOUDINITON
 
	# Export to Image Catalog starts  #
	PVSEXPORTCAT

	if [ $error == 0 ]
    	then
    		echo '============================================'
    		echo 'Exporting VSI to the Boot Image catalog     '
    		echo '============================================'
	else
    		echo '============================================'
    		echo 'Error during VSI export procedure           '
    		echo ''
    		echo $errmsg
    		echo '============================================'
	fi
	# Stop Cloud Init #
	CLOUDINITOFF

	# Create new VSI
	ibmcloud pi ins create $NewVSINAME --image $ImageName --subnets "$SubNet $IPAddr" --boot-volume-replication-enabled=$BVRep --IBMiCSS-license=$ICCYN --IBMiPHA-license=$IBMiPHA --memory $Memory --pin-policy $PinPolicy --processor-type $ProcType --processors $Procs --storage-tier $STGTier --sys-type $SysType > /tmp/PVS_CLONE_VSI.txt
fi
