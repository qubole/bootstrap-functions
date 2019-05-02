#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh

is_master=$(nodeinfo is_master)
use_hadoop2=$(nodeinfo use_hadoop2)
use_thrift_metastore1_2=$(nodeinfo use_thrift_metastore1_2)
hive_version=$(nodeinfo hive_version)

if [[ $is_master == "1" ]]; then
    thrift_metastore_bin_path=/usr/lib/hive13/bin
    if [[ $use_hadoop2 == "1" ]]; then
        thrift_metastore_bin_path=/usr/lib/hive2/bin
        if [[ $use_thrift_metastore1_2 == "true" ]]; then
            thrift_metastore_bin_path=/usr/lib/hive1.2/bin
        fi
    fi
    if [[ "$hive_version" == "3.1.1" ]]; then
        thrift_metastore_bin_path=/usr/lib/hive1.2/bin
    fi
fi


##
# Start thrift metastore server
#
function start_thrift_metastore() {
    if [[ "$is_master" == "1" ]]; then
        ${thrift_metastore_bin_path}/thrift-metastore server start
    else
        return 1
    fi
}

##
# Stop thrift metastore server
#
function stop_thrift_metastore() {
    if [[ "$is_master" == "1" ]]; then
        ${thrift_metastore_bin_path}/thrift-metastore server stop
    else
        return 1
    fi
}

##
# Restart thrift metastore server
#
function restart_thrift_metastore() {
   stop_thrift_metastore && sleep 2 && start_thrift_metastore
}
