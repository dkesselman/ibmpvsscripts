###############################################
# Constantes
###############################################
IBMCLOUD_TRACE=true
IBMCLOUD_TRACE=/tmp/ibmcloud_trace.log

error=0;
errmsg="";

# IBM Cloud account
apikey="<APIKEY>";
Resource="<Resource ID>"; # CRN
ResourceGroup='<RESOURCE_GROUP>'; # Usually "Default"

# Instance ID
ImageName='IBMiPVS_'$InstanceName'_'$(date -I);

# Object Storage
Region="<REGION_NAME>";
AccessKey="<ICOS AccessKey>";
SecretKey="<ICOS SecretKey>";
BucketName="norte-power-bkp";
InCapDest="cloud-storage";

# Email
mailaccount='<MailAccount>'
mailfrom='<From_Mail>'
receptor='<TO_Mail>'
mailserver='smtps://<MailServer_Address>:Port'
dt=$(date -R);
###############################################

