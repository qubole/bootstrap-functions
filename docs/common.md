# common/utils.sh

Provides common utility functions

## Overview

Function to populate nodeinfo

Please call this method at start of node bootstrap

## Index

* [populate_nodeinfo()](#populatenodeinfo)
* [is_hadoop2_cluster()](#ishadoop2cluster)
* [is_hs2_enabled()](#ishs2enabled)
* [is_hs2_cluster()](#ishs2cluster)
* [is_master_node()](#ismasternode)
* [is_worker_node()](#isworkernode)

### populate_nodeinfo()

Function to populate nodeinfo

Please call this method at start of node bootstrap

#### Example

```bash
populate_nodeinfo
```

_Function has no arguments._

### is_hadoop2_cluster()

Function to check if the node belongs to a Hadoop2 cluster

#### Example

```bash
if is_hadoop2_cluster; then
    # do something here
fi
```

_Function has no arguments._

#### Exit codes

* **0**: If the cluster runs hadoop2
* **1**: Otherwise

### is_hs2_enabled()

Function to check if a HiveServer2 is configured to run on a master node

#### Example

```bash
if is_hs2_enabled; then
    # do something here
fi
```

_Function has no arguments._

#### Exit codes

* **0**: When HiveServer2 is configured on a master node
* **1**: Otherwise

### is_hs2_cluster()

Function to check if a node belongs to a HiveServer2 cluster

#### Example

```bash
if is_hs2_cluster; then
    # do something here
fi
```

_Function has no arguments._

#### Exit codes

* **0**: When node belongs to a HiveServer2 cluster
* **1**: Otherwise

### is_master_node()

Function to check if a node is a cluster master node

#### Example

```bash
if is_master_node; then
    # do something here
fi
```

_Function has no arguments._

#### Exit codes

* **0**: When node is a cluster master node
* **1**: Otherwise

### is_worker_node()

Function to check if a node is a cluster worker node

#### Example

```bash
if is_worker_node; then
    # do something here
fi
```

_Function has no arguments._

#### Exit codes

* **0**: When node is a cluster worker node
* **1**: Otherwise

