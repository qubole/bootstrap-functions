#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh

##
# Start thrift metastore server
#
function start_thrift_metastore() {
    is_master=$(nodeinfo is_master)
    if [[ "$is_master" == "1" ]]; then
        /usr/lib/hive1.2/bin/thrift-metastore server start
    fi
}

##
# Stop thrift metastore server
#
function stop_thrift_metastore() {
    is_master=$(nodeinfo is_master)
    if [[ "$is_master" == "1" ]]; then
        /usr/lib/hive1.2/bin/thrift-metastore server stop
    fi
}

##
# Restart thrift metastore server
#
function restart_thrift_metastore() {
   stop_thrift_metastore && sleep 2 && start_thrift_metastore
}
