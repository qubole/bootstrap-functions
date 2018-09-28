# bootstrap-functions
This repository holds common functions that can be used in qubole node bootstraps

## How to use

Source the required script in your bootstrap script. For example, to mount an EFS volume with the bootstrap, you may do the following:

```
source /usr/lib/qubole/bootstrap-functions/misc/mount_nfs.sh

mount_nfs fs-7abd2444.efs.us-east-1.amazonaws.com:/ /mnt/efs
```

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
