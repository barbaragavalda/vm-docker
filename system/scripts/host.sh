#!/bin/sh

source config.sh
source system.sh

setOriginalPath
setEnvironment

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

command=$1
hostname=$2

case $command in
    create)
        echo $1 $2
        mkdir -p $STORAGE_SRC_PATH/$2
        cp $TEMPLATES_APACHE_PATH 
        # 2) crear la config de apache
        # 3) crear base de dades?
    ;;
    delete)
        echo $1 $2
        rm -rf $STORAGE_SRC_PATH/$2
    ;;
    *)
        echo "Command not found";
    ;;
esac

cdOriginalPath