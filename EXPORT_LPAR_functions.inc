#==================== Functions ==========================#
DB2SUSPEND(){
echo '=================';
echo 'Suspend Db2 for i';
echo '=================';
#  Quiesce the database - Suspend Database disk activity
ssh $UserID@$SvrAddr  "system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*FRCWRT)';system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*SUSPEND) SSPTIMO(120)'"

}
#=========================================================#
DB2RESUME(){
ssh $UserID@$SvrAddr  "system 'CHGASPACT ASPDEV(*SYSBAS) OPTION(*RESUME)'" || { error=1;errmsg="Error reactiva    ndo la base de datos";echo $errmsg; }
}
#=========================================================#
CLOUDLOGIN(){
# Login to the account
echo 'Login process start'
ibmcloud login --apikey $apikey -r $Region -g "$RESOURCE_GROUP" > /dev/null
error=$?
if (($error == 0))
then
	ibmcloud target -r "$Region" -g "$RESOURCE_GROUP" > /dev/null
	ibmcloud pi ws tg "$Resource" > /dev/null
else
	echo 'Error during login process'
	exit 1
fi
}
#=========================================================#
PVSEXPORT(){

# Suspend databas activity #
DB2SUSPEND

echo '==============================='
echo 'Start IBM i instance export job'
echo '==============================='

# List volumes attached to the instance to an auxiliary file
ibmcloud pi ins vol list $InstanceName |cut  -c1-36|grep -v ID>/tmp/pvsinstance_volumenes.lst

    # Concateno los ID de los volúmenes en una variable
    vols='';
    while read line 
        do 
        vols=$vols$line','
    done < /tmp/pvsinstance_volumenes.lst
    # Quito la última ','
    vols=${vols:0:-1}

#Ejecuto la exportación
ibmcloud pi ins cap cr $InstanceName --destination $InCapDest --name $ImageName --volumes "$vols" --image-path $BucketName --region $Region --access-key $AccessKey --secret-key $SecretKey > /tmp/xiku_capture_job.txt || { error=1;errmsg="Error exportando la instancia";echo $errmsg; }


if (($error == 0))
then
    echo '============================'
    echo 'Espero 5 minutos a que termine la captura'
    #Espero 5 minutos (En las pruebas terminò en menos de 1 minuto)
    sleep 5m
fi

echo '============================'
echo 'Reanudo actividad en base de datos'
# Libero la actividad en disco de la base de datos
DB2RESUME
}
#=========================================================#
EXPORTMAIL(){

# Preparo envio de mail
echo "Enviando Correo";
cp mail_status.txt mail_status2.txt
echo 'Date: '$dt >> $stsfile
echo "--------------------------------------------------------------------------" >> mail_status2.txt
echo ""                                                                           >> mail_status2.txt

if (($error == 0))
    then
    errmsg = "Captura Exitosa"
    echo $errmsg                                                                  >> mail_status2.txt
    echo ""                                                                       >> mail_status2.txt
    echo "Archivo >>"$ImageName"<< en proceso de captura"                         >> mail_status2.txt
    echo "======================================================================" >> mail_status2.txt
    ibmcloud pi job ls   --operation-action vmCapture                                >> mail_status2.txt
    echo "======================================================================" >> mail_status2.txt
else
    if [[ "$errmsg" ==  "" ]]
    then
        errmsg = "Error durante la captura"        
        echo $errmsg                                                              >> mail_status2.txt
    fi
fi

echo ""                                                                           >> mail_status2.txt
echo "--------------------------------------------------------------------------" >> mail_status2.txt

curl --url $mailserver --ssl-reqd --mail-from $mailfrom --mail-rcpt $receptor --user $mailaccount --insecure --upload-file mail_status2.txt || { error=1;errmsg="Error al enviar correo";echo $errmsg; }
}
#=========================================================#
EXPORTCHECK(){

status=$(ibmcloud pi ins cap show $InstanceName --json|jq .status.state|tr -d '"') >/dev/null;
if [ "$status" == "running" ]
then
	echo ''
        echo '============================================' 
	echo "Export en ejecución - Intente más tarde"
	echo '============================================'
	errorcheck=1;
else
	errorcheck=0;
	echo ''
        echo '============================================'
        echo "Listo para ejecutar Export - Continuamos    "
        echo '============================================'
fi
}
