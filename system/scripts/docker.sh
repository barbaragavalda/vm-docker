#!/bin/bash

source config.sh
source system.sh

setOriginalPath
setEnvironment

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

command=$1
case $command in
    start)
        cd $ROOT_PATH
        sudo docker-compose up --detach --force-recreate --remove-orphans --always-recreate-deps --build
    ;;
    stop)
        sudo docker-compose down
    ;;
    *)
        echo "Command not found";
    ;;
esac
cdOriginalPath