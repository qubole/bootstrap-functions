#!/bin/bash -x

#
# Install python virtualenv in NFS mount. If it fails
# fall back to local
#
# Installing python libraries in an NFS mount has the following advantages over
# installing them locally on each node:
# 1. It allows for faster cluster startup and upscaling since the libraries only
# need to be installed once. This is especially pertinent with libraries that have
# compiled components, like numpy, scipy, etc.
# 2. One can install new libraries or upgrading existing ones at runtime, and the
# changes would be immediately available to all the cluster's nodes
#

source /usr/lib/hustler/bin/qubole-bash-lib.sh
source /usr/lib/qubole/bootstrap-functions/misc/mount_nfs.sh
source /usr/lib/qubole/bootstrap-functions/misc/python_venv.sh

mount_nfs_volume "fs-7abdefa3.efs.us-east-1.amazonaws.com:/" /mnt/efs

if [[ $? == 0 ]]; then
  is_master=$(nodeinfo is_master)
  cluster_id=$(nodeinfo cluster_id)
  # Use the cluster id so we can install different virtualenvs for 
  # different clusters
  install_location="/mnt/efs/${cluster_id}/py36"

  # symlink to same path as local install so we can
  # use in zeppelin
  symlink=/usr/lib/virtualenv/py36
  
  if [[ "$is_master" != "1" ]]; then
    ln -s "$install_location" "$symlink"
    hadoop_use_venv "$install_location"
    # Install only from master. On worker nodes we just
    # need the change to use the new virtualenv
    exit 0
  fi
  install_python_venv "36" "$install_location"
  ln -s "$install_location" "$symlink"
else 
  install_python_venv
fi
