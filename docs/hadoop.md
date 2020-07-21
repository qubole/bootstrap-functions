# hadoop/util.sh

Provides Hadoop2 utility functions

## Overview

Function to restart hadoop services on the cluster master

This may be used if you're using a different version
of Java, for example

## Index

* [restart_master_services()](#restartmasterservices)
* [restart_worker_services()](#restartworkerservices)
* [restart_hadoop_services()](#restarthadoopservices)
* [use_java8()](#usejava8)
* [wait_until_namenode_running()](#waituntilnamenoderunning)

### restart_master_services()

Function to restart hadoop services on the cluster master

This may be used if you're using a different version
of Java, for example

#### Example

```bash
restart_master_services
```

_Function has no arguments._

### restart_worker_services()

Function to restart hadoop services on the cluster workers

This only restarts the datanode service since the
nodemanager is started after the bootstrap is run

#### Example

```bash
restart_worker_services
```

_Function has no arguments._

### restart_hadoop_services()

Generic function to restart hadoop services

#### Example

```bash
restart_hadoop_services
```

_Function has no arguments._

### use_java8()

Use Java 8 for hadoop daemons and jobs

By default, the hadoop daemons and jobs on Qubole
clusters run on Java 7. Use this function if you would like
to use Java 8. This is only required if your cluster:
1. is in AWS, and
2. is running Hive or Spark < 2.2

#### Example

```bash
use_java8
```

_Function has no arguments._

### wait_until_namenode_running()

Wait until namenode is out of safe mode

#### Example

```bash
wait_until_namenode_running 25 5
```

#### Arguments

* **$1** (int): Number of attempts function will make to get namenode out of safemode. Defaults to 50
* **$2** (int): Number of seconds each attempt will sleep for, waiting for namenode to come out of sleep mode. Defaults to 5

