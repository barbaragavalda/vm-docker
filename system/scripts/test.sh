#!/bin/bash

source config.sh
source system.sh

setOriginalPath
setEnvironment

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

command=$1
case $command in
    build-example)
        cp -R $TEST_PATH/* $SRC_PATH
        echo "Test examples created, you may open your browser to check them under localhost"
    ;;
    *)
        echo "Command not found";
    ;;
esac

cdOriginalPath