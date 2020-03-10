#!/bin/bash

source /usr/lib/qubole/bootstrap-functions/common/utils.sh

if [[ $(nodeinfo_feature hive.use_thrift_metastore1_2) == "true" ]]; then
    metastore_service=metastore1_2
else
    metastore_service=metastore
fi

##
# Start thrift metastore server
#
function start_thrift_metastore() {
    if is_master_node; then
        monit start ${metastore_service}
    else
        return 1
    fi
}

##
# Stop thrift metastore server
#
function stop_thrift_metastore() {
    if is_master_node; then
        monit stop ${metastore_service}
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
