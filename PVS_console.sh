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

#Retrieve VSI ID
VSI_ID=$(ibmcloud pi ins ls |grep $VSINAME|cut -f1 -d' ')
# Retrieve console URL #
consoleurl=$( ibmcloud pi ins con get  $VSI_ID --json|jq .consoleURL|tr -d '"')
echo $consoleurl
#Open Web Browser - Change for your system
open $consoleurl 
exit 0
