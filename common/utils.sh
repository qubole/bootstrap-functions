#!/usr/bin/env bash

#--------------------------------------------------------------------------------
# Utility methods
#--------------------------------------------------------------------------------

# Please call this method at start of node bootstrap
populate_nodeinfo() {
  source /usr/lib/hustler/bin/qubole-bash-lib.sh
}

# Returns 0 when run on a Hadoop2 cluster node.
# Returns 1 otherwise
is_hadoop2_cluster() {
   [[ `nodeinfo use_hadoop2` = "1" ]]
}


# Returns 0 when HiveServer2 is configured to run on the cluster master.
# Returns 1 otherwise
is_hs2_enabled() {
  is_hadoop2_cluster && [[ `nodeinfo hive_use_hs2` = "1" ]]
}

# Returns 0 when run on a HiveServer2 cluster node.
# Returns 1 otherwise
is_hs2_cluster() {
  is_hadoop2_cluster && [[ `nodeinfo is_hs2_cluster` = "1" ]]
}

# Returns 0 when run on a cluster master node.
# Returns 1 otherwise
is_master_node() {
   [[ `nodeinfo is_master` = "1" ]]
}

# Returns 0 when run on a cluster worker node.
# Returns 1 otherwise
is_worker_node() {
   ! is_master_node
}

function get_running_services() {
  local running_svcs=()  
  for s in "$@"; do
    monitored=$(wget -q -O - localhost:2812/_status?format=xml | xmlstarlet sel -t -v "/monit/service[name='${s}']/monitor")
    if [[ "$monitored" == "1" ]]; then
      # Order of services is retained when returning
      running_svcs=(${running_svcs[@]} "$s")
    fi
  done

  echo "${running_svcs[@]}"
}
