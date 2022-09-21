#!/bin/bash

setEnvironment(){
    ROOT_PATH="../.."

    # STORAGE
    STORAGE_PATH="${ROOT_PATH}/storage"
    STORAGE_SRC_PATH="${STORAGE_PATH}/src"
    
    # TEMPLATES
    TEMPLATES_PATH="${ROOT_PATH}/templates"
    TEMPLATES_APACHE_PATH="${TEMPLATES_PATH}/apache"
    TEMPLATES_TEST_PATH="${TEMPLATES_PATH}/test"
}

setOriginalPath(){
    ORIGINAL_PATH=$(pwd)
}