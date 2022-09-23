#!/bin/sh

HOSTS_FILE='/etc/hosts'

source config.sh
source system.sh

setOriginalPath
setEnvironment

command=$1
hostName=$2
hostNameAlias=${hostName/./-}
hostString="127.0.0.1 $hostName"

case $command in
    create)
        echo $command $hostName as $hostNameAlias
        mkdir -p $STORAGE_SRC_PATH/$hostNameAlias
        cp $TEMPLATES_APACHE_PATH/new-vhost.conf $STORAGE_CONFIG_APACHE_PATH/$hostNameAlias.conf
        sed -i '' "s/{HOST_NAME}/${hostName}/g" "$STORAGE_CONFIG_APACHE_PATH/$hostNameAlias.conf"
        sed -i '' "s/{HOST_NAME_ALIAS}/${hostNameAlias}/g" "$STORAGE_CONFIG_APACHE_PATH/$hostNameAlias.conf"
        
        cp $TEMPLATES_TEST_PATH/new-host-index.html $STORAGE_SRC_PATH/$hostNameAlias/index.html
        sed -i '' "s/{HOST_NAME}/${hostName}/g" "$STORAGE_SRC_PATH/$hostNameAlias/index.html"

        echo "$hostString" | sudo tee -a "$HOSTS_FILE"
        sh $SCRIPTS_PATH/ssh.sh add-rsa-id
    ;;
    delete)
        echo $command $hostName as $hostNameAlias
        rm $STORAGE_CONFIG_APACHE_PATH/$hostNameAlias.conf
        rm -rf $STORAGE_SRC_PATH/$hostNameAlias
        sudo sed -i '' "/$hostString/d" "$HOSTS_FILE"

    ;;
    *)
        echo "Command not found";
    ;;
esac

sh $SCRIPTS_PATH/docker.sh restart

cdOriginalPath

