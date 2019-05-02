#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh

##
# Start Spark History Server
#
function start_history_server() {
   is_master=$(nodeinfo is_master)
    if [[ "$is_master" == "1" ]]; then
        monit start sparkhistoryserver
    else
        return 1
    fi
}

##
# Stop Spark History Server
#
function stop_history_server() {
   is_master=$(nodeinfo is_master)
    if [[ "$is_master" == "1" ]]; then
        monit stop sparkhistoryserver
    else
        return 1
    fi
}

##
# Restart Spark History Server
#
function restart_history_server() {
    stop_history_server && sleep 2 && start_history_server
}
