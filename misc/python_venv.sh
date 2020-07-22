#!/bin/bash -x
#
# @file misc/python_venv.sh
# @brief Provides function to install Python virtualenv

# @description Install and activate a Python virtualenv
#
# This function activates the new virtualenv, so install
# any libraries you want after calling this with "pip install"
#
# Alternatively you can also use a requirements file. For example
# to use a requirements file stored in S3 or Azure Blob Store, run
#
#    /usr/lib/hadoop2/bin/hadoop dfs -get {s3|wasb}://path/to/requirements/file /tmp/requirements.txt
#    pip install -r /tmp/requirements.txt
#
# @example
#   install_python_env 3.6 /path/to/virtualenv/py36
#
# @arg $1 float Version of Python to use. Defaults to 3.6
# @arg $2 string Location to create virtualenv in. Defaults to /usr/lib/virtualenv/py36
#
# @exitcode 0 Python virtualenv was created and activated
# @exitcode 1 Python executable for virtualenv couldn't be found or installed
function install_python_venv() {
  version=${1:-36}
  location=${2:-/usr/lib/virtualenv/py36}

  if [[ ! -x /usr/bin/python${version} ]]; then
      echo "No executable /usr/bin/python${version} found. Attempting to install.."
      yum_python_package=${version//.}
      yum install -y "python${yum_python_package}"
      if [[ $? -ne 0 ]]; then
          echo "Failed to install python${version}.."
	  return 1
      fi
  fi

  mkdir -p $location

  virtualenv -p "/usr/bin/python${version}" $location
  hadoop_use_venv "$location"

  source ${location}/bin/activate
}

function hadoop_use_venv() {
  location="$1"
  echo "VIRTUAL_ENV_DISABLE_PROMPT=1 source ${location}/bin/activate ${location}" >> /usr/lib/hadoop2/etc/hadoop/hadoop-env.sh
}
