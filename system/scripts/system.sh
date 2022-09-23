#!/bin/bash

cdOriginalPath(){
    cd "$ORIGINAL_PATH"
}

setOriginalPath(){
    ORIGINAL_PATH=$(pwd)
}