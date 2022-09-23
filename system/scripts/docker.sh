#!/bin/bash

source config.sh
source system.sh

setOriginalPath
setEnvironment

function start(){
    cd $ROOT_PATH
    sudo docker-compose up --detach --force-recreate --remove-orphans --always-recreate-deps --build
    cdOriginalPath
}

function stop(){
    cd $ROOT_PATH
    sudo docker-compose down
    cdOriginalPath
}

command=$1
case $command in
    restart)
        stop
        start
    ;;
    start)
        start
    ;;
    stop)
        stop
    ;;
    *)
        echo "Command not found";
    ;;
esac