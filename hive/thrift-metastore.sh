#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh

is_master=$(nodeinfo is_master)

##
# Start thrift metastore server
#
function start_thrift_metastore() {
    if [[ "$is_master" == "1" ]]; then
        monit start metastore1_2
    else
        return 1
    fi
}

##
# Stop thrift metastore server
#
function stop_thrift_metastore() {
    if [[ "$is_master" == "1" ]]; then
        monit stop metastore1_2
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
