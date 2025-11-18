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
  echo "./PVS_EXPORT_VSI.sh <VSI Name>"
  echo ""
  echo "########################################################################################"
  # Exiting program
  exit 1
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
fi

# Save last Boot Image name to a temporary file
echo $ImageName > /tmp/PVS_EXPORT_VSI_imagename.txt
#=========================================================#