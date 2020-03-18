#!/bin/bash
#
# @file spark/util.sh
# @brief Provides functions to start/stop/restart Spark History Server

source /usr/lib/hustler/bin/qubole-bash-lib.sh

# @description Function to start Spark History Server
#
# @example
#   start_history_server
#
# @noargs
#
# @exitcode 0 When Spark History Server is started
# @exitcode 1 Otherwise
function start_history_server() {
   is_master=$(nodeinfo is_master)
    if [[ "$is_master" == "1" ]]; then
        monit start sparkhistoryserver
    else
        return 1
    fi
}

# @description Function to stop Spark History Server
#
# @example
#   stop_history_server
#
# @noargs
#
# @exitcode 0 When Spark History Server is stopped
# @exitcode 1 Otherwise
function stop_history_server() {
   is_master=$(nodeinfo is_master)
    if [[ "$is_master" == "1" ]]; then
        monit stop sparkhistoryserver
    else
        return 1
    fi
}

# @description Function to restart Spark History Server
#
# @example
#   restart_history_server
#
# @noargs
function restart_history_server() {
    stop_history_server && sleep 2 && start_history_server
}
