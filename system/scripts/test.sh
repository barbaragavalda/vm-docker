#!/bin/bash

ORIGINAL_PATH=$(pwd)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ROOT_PATH="../.."
SRC_PATH="${ROOT_PATH}/storage/src"
TEST_PATH="${ROOT_PATH}/templates/test"

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
cd "$ORIGINAL_PATH"