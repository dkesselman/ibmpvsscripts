#!/bin/bash

###############################################
# Constants
###############################################
IBMCLOUD_TRACE=true
IBMCLOUD_TRACE=/tmp/ibmcloud_trace.log

error=0;
errmsg='';

apikey="<APIKEY>";
InstanceName="<INSTANCENAME>";
Resource="<CRN Resource ID>"
Region="<REGION>";

source EXPORT_LPAR_functions.inc 

###############################################

# Login #
CLOUDLOGIN

#Recuperando la URL de la consola#
consoleurl=$( ibmcloud pi ins con get  $InstanceName --json|jq .consoleURL|tr -d '"')
echo $consoleurl
#Opening Microsoft Edge Browser (Linux)
microsoft-edge-stable  $consoleurl  2>&1 &
# open -a "Microsoft Edge" --url "$consoleurl"  # For MacOS
echo ""
exit 0
