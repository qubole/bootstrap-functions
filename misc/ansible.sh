#!/bin/bash

##
# Installs ansible via pip
# param1 - Ansible version to install. Optional, defaults to 2.7.0
#
function install_ansible() {
    version=${1:-2.7.0}

    pip install ansible==${version}
    echo "Installed ansible==${version}"
}

##
# Run ansible-playbook on the node
# param1 - Playbook to run
# param2 - Path to inventory file or comma separated list of hosts
# param3 - Extra variables
#
function run_ansible_playbook() {
    playbook=$1
    inventory=$2
    extra_vars=$3

    if [[ $# -eq 0 ]]; then
        echo "Usage: run_ansible_playbook <playbook> [inventory] [extra_vars]"
    else
        comm="ansible-playbook -c local"
        if [[ ! -z ${inventory} ]]; then
            comm="${comm} -i ${inventory}"
        fi
        if [[ ! -z ${extra_vars} ]]; then
            comm="${comm} -e ${extra_vars}"
        fi
        ${comm}
        echo "Executed ansible-playbook ${playbook}"
    fi
}
