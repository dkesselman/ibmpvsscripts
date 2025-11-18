#==================== Functions ==========================#
DB2SUSPEND(){
echo '=================';
echo 'Suspend Db2 for i';
echo '=================';
#  Quiesce the database - Suspend Database disk activity
sshcmdx="PASE_FORK_JOBNAME='EXPORTCAT';export PASE_FORK_JOBNAME;system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*FRCWRT)';system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*SUSPEND) SSPTIMO(120) SSPTIMOACN(*END)'"
ssh $SvrAddr "$sshcmdx" 

}
#=========================================================#
DB2RESUME(){
sshcmdx="PASE_FORK_JOBNAME='EXPORTCAT';export PASE_FORK_JOBNAME;system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*RESUME)'";
ssh $SvrAddr  "$sshcmdx" || { error=1;errmsg="Error resuming Db2";echo $errmsg; }
}
#=========================================================#
CLOUDLOGIN(){
# Login to the account
ibmcloud login --apikey $apikey -r $Region 
ibmcloud pi ws tg "$Resource"
}
#=========================================================#
PVSEXPORTCLEAN(){
echo "Cleaning old captured images";
if [ "$ImgCapList" == "" ]
then
    echo "Nothing to clean"
else
    ImgCaptoDlt=$(echo $ImgCapList|cut -f1 -d" ")
    ibmcloud pi img del $ImgCaptoDlt 
fi
}
#=========================================================#
PVSEXPORTGET(){
echo "Listing old captured images";
ImgCapList=$(ibmcloud pi img ls |grep $ImagePrefix)
echo "========================="
echo $ImgCapList
echo "========================="
}
#=========================================================#
PVSEXPORTCAT(){

# Suspend Db2 Activity #
DB2SUSPEND

echo '==============================='
echo 'Start IBM i instance export job'
echo '==============================='

# List volumes attached to the instance to an auxiliary file
ibmcloud pi ins vol list $InstanceName |cut  -c1-36|grep -v ID>/tmp/pvsinstance_volumenes.lst

    # Chain volume IDs in a variable
    vols='';
    while read line 
        do 
        vols=$vols$line','
    done < /tmp/pvsinstance_volumenes.lst
    # Remove las character ','
    len=${#vols};
    vols=${vols:0:len-1};

# Get old image name
PVSEXPORTGET

# Remove old image capture
PVSEXPORTCLEAN

# Run image export job
ibmcloud pi ins cap cr $InstanceName --destination $InCapDest --name $ImageName --volumes "$vols" --image-path $BucketName --region $Region --access-key $AccessKey --secret-key $SecretKey > /tmp/PVS_capture_job.txt || { error=1;errmsg="Error exportando la instancia";echo $errmsg; }


if [ $error == 0 ]
then
    echo '============================'
    echo 'Wait until image reach consistency point'
    # Wait 3 minutes. In our tests it took less than 2 minutes
    sleep 3m
    if [ $InCapDest == 'cloud-storage' ]
    then
        echo 'Wait until image gets to Active State'
        # Wait for the image creation to end
        ImageGet="ibmcloud pi img get " $ImageName
        while ($ImageGet|grep queued)
        do
            echo '============================'
	        date 
            sleep 30
        done
    fi
fi

echo '============================'
echo 'Resume Db2 activity'
# Release the database from suspend state
DB2RESUME
}
#=========================================================#
EXPORTMAIL(){

# Create email body
echo "Sending email";
cp mail_status.txt mail_status2.txt
echo 'Date: '$dt >> $stsfile
echo "--------------------------------------------------------------------------" >> mail_status2.txt
echo ""                                                                           >> mail_status2.txt

if [ $error == 0 ]
    then
    errmsg = "Capture was Successful"
    echo $errmsg                                                                  >> mail_status2.txt
    echo ""                                                                       >> mail_status2.txt
    echo "File >>"$ImageName"<< in capture process"                              >> mail_status2.txt
    echo "======================================================================" >> mail_status2.txt
    ibmcloud pi job ls   --operation-action vmCapture                                >> mail_status2.txt
    echo "======================================================================" >> mail_status2.txt
else
    if [ "$errmsg" ==  "" ]
    then
        errmsg = "Error during image capture"        
        echo $errmsg                                                              >> mail_status2.txt
    fi
fi

echo ""                                                                           >> mail_status2.txt
echo "--------------------------------------------------------------------------" >> mail_status2.txt

curl --url $mailserver --ssl-reqd --mail-from $mailfrom --mail-rcpt $receptor --user $mailaccount --insecure --upload-file mail_status2.txt || { error=1;errmsg="Error al enviar correo";echo $errmsg; }
}
#=========================================================#
RMVOLDINSTANCE(){
# Delete previous instance with the same name
ibmcloud pi ins delete $NewVSINAME  --delete-data-volumes=True

# Wait for the image creation to end
echo 'Wait until previous VSI is removed'
VSIGet="ibmcloud pi ins ls "
while ($VSIGet|grep  $NewVSINAME)
do
    echo '============================'
    date 
    sleep 30
done
}
#=========================================================#
EXPORTCHECK(){
status=$(ibmcloud pi ins cap show $InstanceName --json|jq .status.state|tr -d '"');
if [ $status == "running" ]
then
	echo ''
    echo '================================================' 
	echo "There is an export job running - Try again later"
	echo '================================================'
	errorcheck=1;
else
	errorcheck=0;
fi
}
#=========================================================#
PVSEXPORT(){

# Db2 Suspend (Quiesce) #
DB2SUSPEND

echo '==============================='
echo 'Start IBM i instance export job'
echo '==============================='

# List volumes attached to the instance to an auxiliary file
ibmcloud pi ins vol list $InstanceName |cut  -c1-36|grep -v ID>/tmp/pvsinstance_volumenes.lst

    # Chain Volume IDs in one variable
    vols='';
    while read line 
    do 
        vols=$vols$line','
    done < /tmp/pvsinstance_volumenes.lst
    # Remove last ','
    len=${#vols};
    vols=${vols:0:len-1};

# Run the export process
ibmcloud pi ins cap cr $InstanceName --destination $InCapDest --name $ImageName --volumes "$vols" --image-path $BucketName --region $Region --access-key $AccessKey --secret-key $SecretKey > /tmp/PVS_capture_job.txt || { error=1;errmsg="Error exportando la instancia";echo $errmsg; }


if [ $error == 0 ]
then
    echo '============================================='
    echo 'Wait 2 minutes to reach the consistency point'
    # Wait 2 minutes
    sleep 2m
fi

echo '============================'
echo 'Resume Db2 activity         '

# Resume and unlock Db2 activity
DB2RESUME
}
#=========================================================#
CLOUDINITON(){

# Start Cloud Init #
sshcmdx="PASE_FORK_JOBNAME='EXPORTCAT';system 'CALL PGM(QSYS/QAENGCHG) PARM((*ENABLECI))' "
ssh $SvrAddr $sshcmdx
}
#=========================================================#
CLOUDINITOFF(){

# Start Cloud Init #
sshcmdx="PASE_FORK_JOBNAME='EXPORTCAT';system 'CALL PGM(QSYS/QAENGCHG) PARM((*DISABLE))'"
ssh $SvrAddr $sshcmdx
}
#=========================================================#
CRTNEWVSI(){
# Create new VSI
ibmcloud pi ins create $NewVSINAME --image $ImageName --subnets "$SubNet $IPAddr" --boot-volume-replication-enabled=$BVRep --IBMiCSS-license=$ICCYN --IBMiPHA-license=$IBMiPHA --memory $Memory --pin-policy $PinPolicy --processor-type $ProcType --processors $Procs --storage-tier $STGTier --sys-type $SysType > /tmp/PVS_NEW_VSI.txt
}
#=========================================================#
GETPREVIMGNAME(){
    PrevImageName=$(cat /tmp/PVS_EXPORT_VSI_imagename.txt)
}