#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh

## 
# Mounts an NFS volume on master and worker nodes
# param1 - path to NFS share
# param2 - mountpoint to use
#
# Instructions for AWS EFS mount:
# 1. After creating the EFS file system, create a security group
# 2. Create an inbound traffic rule for this security group that allows traffic on
# port 2049 (NFS) from this security group as described here:
# https://docs.aws.amazon.com/efs/latest/ug/accessing-fs-create-security-groups.html
# 3. Add this security group as a persistent security group for the cluster from which
# you want to mount the EFS store, as described here:
# http://docs.qubole.com/en/latest/admin-guide/how-to-topics/persistent-security-group.html
#
# TODO: add instructions for Azure file share
# 
function mount_nfs_volume() {
  nfs_export=$1
  mountpoint=$2

  is_master=$(nodeinfo is_master)
  if [[ $is_master == "1" ]]; then
    mount -v -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 "$nfs_export" "$mountpoint"
  else
    mount -v -t nfs4 -o nfsvers=4.1,ro,rsize=1048576,hard,timeo=600,retrans=2 "$nfs_export" "$mountpoint"
  fi
}
