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
#
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
#
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
#
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

# @file hive/hiveserver2.sh
# @brief Provides function to start sending hs2 metrics to port 12155 for release<60.
#
# @description Function to start sending hs2 metrics to the port 12155.
#
#  This function will replace the /usr/lib/hive1.2/bin/hive file to allow
#  bind jmx exporter to the port 12155 and start receiving the hs2 metrics.
#
# Works on hs2 clusters

# @example
#    send_hs2_metrics
#
# @noargs
function send_hs2_metrics() {

  # if cluster is hs2 configured, then only jmx exporter will be bind.
  if [[ is_hs2_configured ]]; then

    # call populate_nodeinfo to collect information about the S3 bucket location.
    populate_nodeinfo

    # collect S3 default location in defloc.
    defloc=$(nodeinfo s3_default_location)

    # Collect the file from S3 bucket at the given location and copy that to the specified location.
    /usr/lib/hadoop2/bin/hadoop dfs -get -f $defloc/hive /usr/lib/hive1.2/bin/hive

    # Change file permissions.
    chmod 755 /usr/lib/hive1.2/bin/hive

    # restart hs2 to reflect the changes.
    restart_hs2

  fi
}