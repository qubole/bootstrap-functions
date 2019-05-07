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
* [mount_nfs_volume](misc/mount_nfs.sh#L21) - Mounts an NFS volume on master and worker nodes
* [restart_master_services](hadoop/util.sh#L13) - Restart hadoop services on the cluster master
* [restart_worker_services](hadoop/util.sh#L43) - Restart hadoop services on cluster workers
* [use_java8](hadoop/util.sh#L61) - Use Java 8 for hadoop daemons and jobs
* [install_python_venv](misc/python_venv.sh#L17) - Install and activate a Python virtualenv

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
