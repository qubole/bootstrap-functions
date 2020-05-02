#!/usr/bin/env bash
#
# @file prometheus/configure-prometheus-ram.sh
# @brief Provides functions to Configure Prometheus memory usage on master node


# @description Ability to specify the memory usage of prometheus daemon on master. Example : 500M
#
# @example
#      function requires one argument to be passed.
#      Argument must specify the ram to be allocated to the prometheus service from master node ram.
#      Input should be an integer. All the values are assumed in MB.
#
#      Example of function calling :-
#      1) configure_prometheus_ram_on_master '600'
#      2) configure_prometheus_ram_on_master 600
#      Both of them are acceptable.
#
#      sed -i "s/PROMETHEUS_RAM/$1/g" /usr/lib/prometheus/config/docker-compose.yml
#

function configure_prometheus_ram_on_master() {

  prometheus_ram=$1
  # Regex to determine whether the input is a number or not.
  regex_number='^[0-9]+$'

  # Add suffix 'M' to the user's input.
  prometheus_ram_with_suffix="${prometheus_ram}M"

  if [[ -n $prometheus_ram ]] && [[ $prometheus_ram =~ $regex_number ]]; then

    # If the user input is non-empty and is matching with the given regex, then we can override the value.
    sed -i "s/PROMETHEUS_RAM/$prometheus_ram_with_suffix/g" /usr/lib/prometheus/config/docker-compose.yml

  fi

}


