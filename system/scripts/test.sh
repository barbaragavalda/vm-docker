#!/bin/bash

EXAMPLE_URL="example.local"

source config.sh
source system.sh

setOriginalPath
setEnvironment

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

command=$1
case $command in
    create-example)
        sh $SCRIPT_DIR/host.sh create $EXAMPLE_URL
        echo "Test examples created, you may open your browser to check them under ${EXAMPLE_URL}"
    ;;
    delete-example)
        sh $SCRIPT_DIR/host.sh delete $EXAMPLE_URL
        echo "Test examples created, you may open your browser to check them under ${EXAMPLE_URL}"
    ;;
    *)
        echo "Command not found";
    ;;
esac

cdOriginalPath