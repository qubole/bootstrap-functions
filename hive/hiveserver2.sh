#!/usr/bin/env bash

source /usr/lib/qubole/bootstrap-functions/common/utils.sh

#--------------------------------------------------------------------------------
# Methods to stop/start/restart HiveServer2
#--------------------------------------------------------------------------------

is_hs2_configured() {
  [[ (is_master_node && is_hs2_enabled) || (is_worker_node && is_hs2_cluster) ]]
}

# Stop HiveServer2 JVM - works on both Hadoop2 and HiveServer2 cluster
stop_hs2() {
  if [[ is_hs2_configured ]]; then
    sudo monit stop hs2
  fi
}

# Start HiveServer2 JVM - works on both Hadoop2 and HiveServer2 cluster
start_hs2() {
  if [[ is_hs2_configured ]]; then
    sudo monit start hs2
  fi
}

# Restart HiveServer2 JVM - works on both Hadoop2 and HiveServer2 cluster
restart_hs2() {
  stop_hs2
  sleep 5
  start_hs2
}

