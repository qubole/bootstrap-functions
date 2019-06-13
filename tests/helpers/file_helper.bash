#!/bin/bash

function assert_file_exists() {
    local file=$1
    if [[ ! -f ${file} ]]; then
        return 1
    fi
}

function assert_file_contains() {
    local pattern=$1
    local file=$2
    if ! grep -qs ${pattern} ${file}; then
        return 1
    fi
}

function assert_file_mode() {
    local file=$1
    local mode=$2
    file_mode=$(stat -c "%a" ${file})
    if [[ ! ${file_mode} == ${mode} ]]; then
        return 1
    fi
}

function assert_dir_exists() {
    local directory=$1
    if [[ ! -d ${directory} ]]; then
        return 1
    fi
}

function assert_file_is_symlink() {
    local file=$1
    if [[ ! -L ${file} ]]; then
        return 1
    fi
}

function assert_symlinked_to() {
    local sym=$1
    local file=$2
    symlast=$(readlink -f ${sym})
    if [[ ! ${symlast} == ${file} ]]; then
        return 1
    fi
}

function assert_multiple_files_exist() {
    loc=$1;
    shift;
    arr=("$@");
    for f in ${arr[@]};
    do
        if [[ ! -e ${loc}/${f} ]]; then
            return 1
        fi
    done
}