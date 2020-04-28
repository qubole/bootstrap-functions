#!/usr/bin/env bash
#
# @file prometheus/configure-prometheus-ram.sh
# @brief Provides functions to Configure Prometheus memory usage on master node


# @description Ability to specify the memory usage of prometheus daemon on master. Example : 500M
#
# @example
#      function requires one argument to be passed.
#      Argument must specify the ram to be allocated to the prometheus service from master node ram.
#
#      Suffixes :-
#      1) Add 'M' at the end to denote Megabyte.
#      2) Add 'G' at the end to denote Gigabyte
#
#      Example of function calling :-
#      1) configure_prometheus_ram_on_master '600M'
#      2) configure_prometheus_ram_on_master 600M
#      Both of them are acceptable.
#
#      sed -i "s/PROMETHEUS_RAM/$1/g" /usr/lib/prometheus/config/docker-compose.yml
#
#
function configure_prometheus_ram_on_master() {
  sed -i "s/PROMETHEUS_RAM/$1/g" /usr/lib/prometheus/config/docker-compose.yml
}


