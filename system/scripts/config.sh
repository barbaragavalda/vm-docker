#!/bin/bash

setEnvironment(){
    ROOT_PATH="../.."

    # SCRIPTS
    SCRIPTS_PATH="${ROOT_PATH}/system/scripts"

    # STORAGE
    STORAGE_PATH="${ROOT_PATH}/storage"
    STORAGE_CONFIG_PATH="${STORAGE_PATH}/config"
    STORAGE_CONFIG_APACHE_PATH="${STORAGE_CONFIG_PATH}/apache"
    STORAGE_SRC_PATH="${STORAGE_PATH}/src"
    
    # TEMPLATES
    TEMPLATES_PATH="${ROOT_PATH}/templates"
    TEMPLATES_APACHE_PATH="${TEMPLATES_PATH}/apache"
    TEMPLATES_TEST_PATH="${TEMPLATES_PATH}/test"
}