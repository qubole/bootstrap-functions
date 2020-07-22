# prometheus/configure-prometheus.sh

Provides functions to configure Prometheus

## Overview

Ability to override the memory usage of prometheus daemon on master. Example : 500M

function requires one argument to be passed.
Argument must specify the ram to be allocated to the prometheus service from master node ram.
Input should be an integer. All the values are assumed in MB.



