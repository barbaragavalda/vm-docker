#!/bin/bash

source config.sh
source system.sh

setOriginalPath
setEnvironment

function addRsaId(){
    if [ ! -f $STORAGE_RSAID_PATH ]
    then
        cp $(getRsaIdPath) $STORAGE_RSAID_PATH
        chmod 0600 $STORAGE_RSAID_PATH
    else
        echo "rsa-id already exists"
    fi
}
function removeRsaId(){
    if [ -f $STORAGE_RSAID_PATH ]
    then
        rm $STORAGE_RSAID_PATH
    else
        echo "rsa-id does not exist"
    fi
}

command=$1
case $command in
    add-rsa-id)
        addRsaId
    ;;
    remove-rsa-id)
        removeRsaId
    ;;
    *)
        echo "Command not found";
    ;;
esac