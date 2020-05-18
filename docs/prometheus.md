# prometheus/configure-prometheus.sh

Provides functions to configure Prometheus

* [configure_prometheus_ram_on_master()](#configureprometheusramonmaster)


## configure_prometheus_ram_on_master()

Ability to override the memory usage of prometheus daemon on master. Example : 500M

 function requires one argument to be passed.
 Argument must specify the ram to be allocated to the prometheus service from master node ram.
 Input should be an integer. All the values are assumed in MB.

### Example

```bash
   configure_prometheus_ram_on_master 600
```

### Arguments

* **$1** (integer): Prometheus ram to be substituted in MB.

