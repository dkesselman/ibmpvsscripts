#==================== Functions ==========================#
DB2SUSPEND(){
echo '=================';
echo 'Suspend Db2 for i';
echo '=================';
#  Quiesce the database - Suspend Database disk activity
# Warning: QUIESCING *SYSBAS ASP can cause services to stop working. With iASP this works with no issues #
ssh $UserID@$SvrAddr  "system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*FRCWRT)';system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*SUSPEND) SSPTIMO(120)'"

}
#=========================================================#
DB2RESUME(){
ssh $UserID@$SvrAddr  "system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*RESUME)'" || { error=1;errmsg="Error reactiva    ndo la base de datos";echo $errmsg; }
}
#=========================================================#
CLOUDLOGIN(){
# Login to the account
ibmcloud login --apikey $apikey -r $Region -g "$RESOURCE_GROUP"
ibmcloud target -r "$Region" -g "$RESOURCE_GROUP"
ibmcloud pi ws tg "$Resource"
}
#=========================================================#
PVSEXPORT(){

# Suspend databas activity #
DB2SUSPEND

echo '==============================='
echo 'Start IBM i instance export job'
echo '==============================='

# List volumes attached to the instance to an auxiliary file
ibmcloud pi ins vol list $InstanceName |cut  -c1-36|grep -v ID>/tmp/pvsinstance_volumes.lst

    # Chain all volume names in one single string
    vols='';
    while read line 
        do 
        vols=$vols$line','
    done < /tmp/pvsinstance_volumes.lst
    # Remove last ',' character
    len=${#vols};
    vols=${vols:0:len-1};

# Capture/Export job starts
ibmcloud pi ins cap cr $InstanceName --destination $InCapDest --name $ImageName --volumes "$vols" --image-path $BucketName --region $Region --access-key $AccessKey --secret-key $SecretKey > /tmp/capture_job.txt || { error=1;errmsg="Error exporting VSI";echo $errmsg; }


if (($error == 0))
then
    echo '============================'
    echo 'Wait 5 minutes'
    sleep 5m
fi

echo '============================'
echo 'Resume database activity'
# Resume database activity
DB2RESUME
}
#=========================================================#
EXPORTMAIL(){

# Create email content
echo "Sending email";
cp mail_status.txt mail_status2.txt
echo 'Date: '$dt >> $stsfile
echo "--------------------------------------------------------------------------" >> mail_status2.txt
echo ""                                                                           >> mail_status2.txt

if (($error == 0))
    then
    errmsg = "Export: Successful"
    echo $errmsg                                                                  >> mail_status2.txt
    echo ""                                                                       >> mail_status2.txt
    echo "File >>"$ImageName"<< running capture process"                          >> mail_status2.txt
    echo "======================================================================" >> mail_status2.txt
    ibmcloud pi job ls   --operation-action vmCapture                                >> mail_status2.txt
    echo "======================================================================" >> mail_status2.txt
else
    if [[ "$errmsg" ==  "" ]]
    then
        errmsg = "Error during capture procedure"        
        echo $errmsg                                                              >> mail_status2.txt
    fi
fi

echo ""                                                                           >> mail_status2.txt
echo "--------------------------------------------------------------------------" >> mail_status2.txt

curl --url $mailserver --ssl-reqd --mail-from $mailfrom --mail-rcpt $receptor --user $mailaccount --insecure --upload-file mail_status2.txt || { error=1;errmsg="Error sending email";echo $errmsg; }
}
#=========================================================#
EXPORTCHECK(){

status=$(ibmcloud pi ins cap show $InstanceName --json|jq .status.state|tr -d '"') >/dev/null;
if [ "$status" == "running" ]
then
	echo ''
    echo '============================================' 
	echo "Previous capture job running - Retry later      "
	echo '============================================'
	errorcheck=1;
else
	errorcheck=0;
	echo ''
        echo '============================================'
        echo "Ready to run Export job - Continue          "
        echo '============================================'
fi
}
