# IBM Power Systems Virtual Server scripts

These are simple scripts I use to manage my IBM Power Virtual Server instances, calling IBM CLOUD CLI commands.
Most of them are IBM i instances, but they can work with Linux and AIX with minimum or no change.
The general idea is to usual admin/operator tasks skipping portal login page.

These BASH scripts were created for Linux and MacOS (also work on WSL2), and can be easily ported to PowerShell.

* PVS_console.sh : Open a browser with LPAR's web-console.
* PVS_EXPORT_VSI.sh: Export instance to IBM Cloud Object Storage.
* PVS_CLONE_VSI.sh : Export instance as Boot Image, wait for Active status an create a new VSI with this image.
* PVS_CRTfrmEXP.sh: Create a new VSI from latest export. 
* PVS_functions.sh : Functions to include in these scripts (global variables)
* PVS_const.sh : These are the constants and variables include file to make things work.

Requirements:

* jq: To parse and filter json data
* ibmcloud CLI: to make these scripts work
* ibmcloud pi plugin
* Run on MacOS or Linux (these are BASH scripts)
