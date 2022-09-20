#!/bin/bash

cdOriginalPath(){
    cd "$ORIGINAL_PATH"
}

setOriginalPwd(){
    ORIGINAL_PATH=$(pwd)
}