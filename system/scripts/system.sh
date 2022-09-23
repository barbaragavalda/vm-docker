#!/bin/bash

cdOriginalPath(){
    cd "$ORIGINAL_PATH"
}

getRsaIdPath(){
    echo ~/.ssh/id_rsa.pub
}

setOriginalPath(){
    ORIGINAL_PATH=$(pwd)
}