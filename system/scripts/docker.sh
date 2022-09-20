#!/bin/bash

ORIGINAL_PATH=$(pwd)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RELATIVE_DOCKERFILE_PATH="../../"

command=$1

case $command in
    start)
        cd $RELATIVE_DOCKERFILE_PATH
        sudo docker-compose up --detach --force-recreate --remove-orphans --always-recreate-deps --build
    ;;
    stop)
        cd $RELATIVE_DOCKERFILE_PATH
        sudo docker-compose down
    ;;
    *)
        echo "Command not found";
    ;;
esac
cd "$ORIGINAL_PATH"