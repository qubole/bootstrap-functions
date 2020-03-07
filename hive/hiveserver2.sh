#!/usr/bin/env bash
#
# @file hive/hiveserver2.sh
# @brief Provides functions to start/stop/restart HiveServer2

source /usr/lib/qubole/bootstrap-functions/common/utils.sh

# @description Function to check if HiveServer2 is configured
#
# @example
#   if [[ is_hs2_configured ]]; then
#       # do something here
#   fi
#
# @noargs
#
# @exitcode 0 If HiveServer2 is configured
# @exitcode 1 Otherwise
function is_hs2_configured() {
  (is_master_node && is_hs2_enabled) || (is_worker_node && is_hs2_cluster)
}

# @description Function to stop HiveServer2 JVM
# Works on both Hadoop2 and HiveServer2 clusters
#
# @example
#   stop_hs2
#
# @noargs
function stop_hs2() {
  if [[ is_hs2_configured ]]; then
    monit stop hs2
  fi
}

# @description Function to start HiveServer2 JVM
# Works on both Hadoop2 and HiveServer2 clusters
#
# @example
#   start_hs2
#
# @noargs
function start_hs2() {
  if [[ is_hs2_configured ]]; then
    monit start hs2
  fi
}

# @description Function to restart HiveServer2 JVM
# Works on both Hadoop2 and HiveServer2 clusters
#
# @example
#   restart_hs2
#
# @noargs
function restart_hs2() {
  stop_hs2
  sleep 5
  start_hs2
}

