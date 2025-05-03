# ibmpvsscripts
Scripts for IBM Power Virtual Server

These are simple scripts I use to manage my IBM Power Virtual Server instances, calling IBM CLOUD CLI commands.
Most of them are IBM i instances, but they can work with Linux and AIX with minimum or no change.
The general idea is to usual admin/operator tasks skipping portal login page.

These BASH scripts were created for Linux (also work on WSL2), and can be easily ported to PowerShell.

* console.sh : Open a browser (Microsoft Edge) with LPAR's web-console.
* EXPORT_LPAR.sh: Export instance to IBM Cloud Object Storage.
* EXPORT_CHECK.sh : Shows export status for an instance (LPAR).
* SnapShot_LPAR.sh: Similar to EXPORT_LPAR.sh, but creates a snapshot.
* EXPORT_LPAR_functions.inc : Functions to include in these scripts (global variables)

Requirements:

* jq: To parse and filter json data
* ibmcloud CLI: to make these scripts work
