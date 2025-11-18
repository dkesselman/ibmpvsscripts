###############################################
# Constantes
###############################################
IBMCLOUD_TRACE=true
IBMCLOUD_TRACE=/tmp/ibmcloud_trace.log

error=0;
errmsg="";

# IBM Cloud Account
apikey='<API-KEY>';
Resource="<CRN-Resource>";
RESOURCE_GROUP="<Usually Default>";

# SSH information - You must add the $VSINAME entry to your .ssh/config to make it work properly #
SvrAddr=$VSINAME;

# VSI data
InstanceName=$VSINAME;
ImagePrefix="IBM-PVS_"$InstanceName"_";
ImageName=$ImagePrefix$(date -I);
ImgCapList="";

# NewVSI data
BVRep=False
ICCYN=False
IBMiPHA=False
Memory=6
PinPolicy='none'
ProcType='shared'
Procs='0.25'
STGTier='tier3'

# Object Storage
Region="<Region>";
AccessKey="<IBM Cloud Object Storage Access-Key>";
SecretKey="<IBM Cloud Object Storage Secret-Key>";
BucketName="<ICOS Bucket Name>";
InCapDest="cloud-storage";

# eMail
mailaccount='<eMail Account to send messages>'
mailfrom='<Emal FROM>'
receptor='<Recipient>'
mailserver='<SMTP server>'
###############################################

