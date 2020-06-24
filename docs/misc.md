# misc/util.sh

Provides miscellaneous utility functions

* [set_timezone()](#settimezone)
* [add_to_authorized_keys()](#addtoauthorizedkeys)


## set_timezone()

Set the timezone

This function sets the timezone on the cluster node.
The timezone to set is a mandatory parameter and must be present in /usr/share/zoneinfo
Eg: "US/Mountain", "America/Los_Angeles" etc.

After setting the timezone, it is advised to restart engine daemons on the master and worker nodes

### Example

```bash
set_timezone "America/Los_Angeles"
```

### Arguments

* **$1** (string): Timezone to set

## add_to_authorized_keys()

Add a public key to authorized_keys

### Example

```bash
add_to_authorized_keys "ssh-rsa xyzxyzxyzxyz...xyzxyz user@example.com" ec2-user
```

### Arguments

* **$1** (string): Public key to add to authorized_keys file
* **$2** (string): User for which the public key is added. Defaults to `ec2-user`

# misc/python_venv.sh

Provides function to install Python virtualenv

* [install_python_venv()](#installpythonvenv)


## install_python_venv()

Install and activate a Python virtualenv

This function activates the new virtualenv, so install
any libraries you want after calling this with "pip install"

Alternatively you can also use a requirements file. For example
to use a requirements file stored in S3 or Azure Blob Store, run

   /usr/lib/hadoop2/bin/hadoop dfs -get {s3|wasb}://path/to/requirements/file /tmp/requirements.txt
   pip install -r /tmp/requirements.txt

### Example

```bash
install_python_env 3.6 /path/to/virtualenv/py36
```

### Arguments

* **$1** (float): Version of Python to use. Defaults to 3.6
* **$2** (string): Location to create virtualenv in. Defaults to /usr/lib/virtualenv/py36

### Exit codes

* **0**: Python virtualenv was created and activated
* **1**: Python executable for virtualenv couldn't be found or installed

# misc/mount_nfs.sh

Provides function to mount a NFS volume

* [mount_nfs_volume()](#mountnfsvolume)


## mount_nfs_volume()

Mounts an NFS volume on master and worker nodes

Instructions for AWS EFS mount:
1. After creating the EFS file system, create a security group
2. Create an inbound traffic rule for this security group that allows traffic on
port 2049 (NFS) from this security group as described here:
https://docs.aws.amazon.com/efs/latest/ug/accessing-fs-create-security-groups.html
3. Add this security group as a persistent security group for the cluster from which
you want to mount the EFS store, as described here:
http://docs.qubole.com/en/latest/admin-guide/how-to-topics/persistent-security-group.html

TODO: add instructions for Azure file share

### Example

```bash
mount_nfs_volume "example.nfs.share:/" /mnt/efs
```

### Arguments

* **$1** (string): Path to NFS share
* **$2** (string): Mount point to use

# misc/awscli.sh

Provides function to configure AWS CLI

* [configure_awscli()](#configureawscli)


## configure_awscli()

Configure AWS CLI

A credentials file containing the AWS Access Key and the AWS Secret Key
separated by a space, comma, tab or newline must be provided

### Example

```bash
configure_awscli -p exampleprofile -r us-east-1 -c /path/to/credentials/file
```

### Arguments

* -p string Name of the profile. Defaults to `default`
* -r string AWS region. Defaults to `us-east-1`
* -c string Path to credentials file

### Exit codes

* **0**: AWS CLI is configured
* **1**: AWS CLI or credentials file not found

