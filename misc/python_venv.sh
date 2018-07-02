#!/bin/bash -x

function install_python_venv() {
  version=${$1:-36}
  location=${$2:-/usr/lib/virtualenv/py36}

  yum install -y "python${version}"
  mkdir -p $location

  virtualenv -p "/usr/bin/python${version}" $location
  hadoop_use_venv "$location"
}

function hadoop_use_venv() {
  location="$1"
  echo "VIRTUAL_ENV_DISABLE_PROMPT=1 source ${location}/bin/activate ${location}" >> /usr/lib/hadoop2/etc/hadoop/hadoop-env.sh
}
