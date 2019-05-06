#!/usr/bin/env bash

function get_running_services() {
  running_svcs=()  
  for s in "$@"; do
    monitored=$(wget -q -O - localhost:2812/_status?format=xml | xmlstarlet sel -t -v "/monit/service[name='$s']/monitor")
    if [[ "$monitored" == "0" ]]; then
      running_svcs=(${running_svcs[@]} "$s")
    fi
  done

  echo "${running_svcs[@]}"
}