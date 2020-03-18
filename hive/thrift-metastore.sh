#!/bin/bash
#
# @file hive/thrift-metastore.sh
# @brief Provides functions to start/stop/restart thrift metastore server

source /usr/lib/qubole/bootstrap-functions/common/utils.sh

if [[ $(nodeinfo_feature hive.use_thrift_metastore1_2) == "true" ]]; then
    metastore_service=metastore1_2
else
    metastore_service=metastore
fi

# @description Function to start thrift metastore server
#
# @example
#   start_thrift_metastore
#
# @noargs
function start_thrift_metastore() {
    if is_master_node; then
        monit start ${metastore_service}
    else
        return 1
    fi
}

# @description Function to stop thrift metastore server
#
# @example
#   stop_thrift_metastore
#
# @noargs
function stop_thrift_metastore() {
    if is_master_node; then
        monit stop ${metastore_service}
    else
        return 1
    fi
}

# @description Function to restart thrift metastore server
#
# @example
#   restart_thrift_metastore
#
# @noargs
function restart_thrift_metastore() {
   stop_thrift_metastore && sleep 2 && start_thrift_metastore
}
