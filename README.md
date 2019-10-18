# bootstrap-functions
This repository holds common functions that can be used in qubole node bootstraps

## How to use

Source the required script in your bootstrap script. For example, to mount an EFS volume with the bootstrap, you may do the following:

```
source /usr/lib/qubole/bootstrap-functions/misc/mount_nfs.sh

mount_nfs fs-7abd2444.efs.us-east-1.amazonaws.com:/ /mnt/efs
```

## Available functions
The following functions are available at present
* [configure_awscli](misc/awscli.sh#L11) - Configure AWS CLI
* [install_python_venv](misc/python_venv.sh#L17) - Install and activate a Python virtualenv
* [install_ranger](hive/ranger-client.sh#L13) - Install Apache Ranger client for Hive
* [mount_nfs_volume](misc/mount_nfs.sh#L21) - Mounts an NFS volume on master and worker nodes
* [restart_hs2](hive/hiveserver2.sh#L30) - Restart HiveServer2 JVM - works on both Hadoop2 and HiveServer2 cluster
* [set_timezone](misc/util.sh#L14) - Set the timezone
* [add_to_authorized_keys](misc/util.sh#L38) - Add public key to authorized_keys
* [install_glue_sync](hive/glue-sync.sh#L11) - Installs Hive Glue Catalog Sync Agent
* [start_history_server](spark/util.sh#L8) - Start Spark History Server
* [stop_history_server](spark/util.sh#L20) - Stop Spark History Server
* [restart_history_server](spark/util.sh#L32) - Restart Spark History Server
* [restart_master_services](hadoop/util.sh#L13) - Restart hadoop services on the cluster master
* [restart_worker_services](hadoop/util.sh#L43) - Restart hadoop services on cluster workers
* [use_java8](hadoop/util.sh#L61) - Use Java 8 for hadoop daemons and jobs
* [wait_until_namenode_running](hadoop/util.sh#L82) - Wait until namenode is out of safe mode.

## Contributing
Please raise a pull request for any modifications or additions you would like to make. There may be a delay between when you want to start using a method and when it might be available via Qubole's AMI. To work around this, it is recommended to put a placeholder `source` line in your bootstrap script. For example

```
function mysparkfunction() {
  # ... do some stuff
}

source /usr/lib/qubole/bootstrap-functions/spark/mysparkfunction.sh

mysparkfunction arg1 arg2 ...
```

This way, when the function makes it to the AMI, you will automatically use the copy in the bootstrap-functions library.
