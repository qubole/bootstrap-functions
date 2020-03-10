#!/usr/bin/env bash
#
# @file common/utils.sh
# @brief Provides common utility functions

# @description Function to populate nodeinfo
# Please call this method at start of node bootstrap
#
# @example
#   populate_nodeinfo
#
# @noargs
populate_nodeinfo() {
  source /usr/lib/hustler/bin/qubole-bash-lib.sh
}

# @description Function to check if the node belongs to a Hadoop2 cluster
#
# @example
#   if is_hadoop2_cluster; then
#       # do something here
#   fi
#
# @noargs
#
# @exitcode 0 If the cluster runs hadoop2
# @exitcode 1 Otherwise
is_hadoop2_cluster() {
   [[ `nodeinfo use_hadoop2` = "1" ]]
}


# @description Function to check if a HiveServer2 is configured to run on a master node
#
# @example
#   if is_hs2_enabled; then
#       # do something here
#   fi
#
# @noargs
#
# @exitcode 0 When HiveServer2 is configured on a master node
# @exitcode 1 Otherwise
is_hs2_enabled() {
  is_hadoop2_cluster && [[ `nodeinfo hive_use_hs2` = "1" ]]
}

# @description Function to check if a node belongs to a HiveServer2 cluster
#
# @example
#   if is_hs2_cluster; then
#       # do something here
#   fi
#
# @noargs
#
# @exitcode 0 When node belongs to a HiveServer2 cluster
# @exitcode 1 Otherwise
is_hs2_cluster() {
  is_hadoop2_cluster && [[ `nodeinfo is_hs2_cluster` = "1" ]]
}

# @description Function to check if a node is a cluster master node
#
# @example
#   if is_master_node; then
#       # do something here
#   fi
#
# @noargs
#
# @exitcode 0 When node is a cluster master node
# @exitcode 1 Otherwise
is_master_node() {
   [[ `nodeinfo is_master` = "1" ]]
}

# @description Function to check if a node is a cluster worker node
#
# @example
#   if is_worker_node; then
#       # do something here
#   fi
#
# @noargs
#
# @exitcode 0 When node is a cluster worker node
# @exitcode 1 Otherwise
is_worker_node() {
   ! is_master_node
}

populate_nodeinfo
