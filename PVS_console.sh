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
  echo "./PVS_console.sh <VSI Name>"
  echo ""
  echo "########################################################################################"
  # Exiting program
  exit 1
fi

###############################################
source PVS_const.sh 
source PVS_functions.sh 

# Login #
CLOUDLOGIN

# Retrieve console URL #
consoleurl=$( ibmcloud pi ins con get  $VSINAME --json|jq .consoleURL|tr -d '"')
echo $consoleurl
#Open Web Browser - Change for your system
open $consoleurl 
echo ""
exit 0
