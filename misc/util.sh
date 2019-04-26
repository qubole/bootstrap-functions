#!/bin/bash

##
# Miscellaneous utility functions

##
# Set the timezone
# param1 - Timezone to set. Defaults to "UTC"
#          Eg: "US/Mountain", "America/Los_Angeles" etc.
#
# This function sets the timezone on the cluster node.
# After setting the timezone, it is advised to restart engine daemons on the master and worker nodes
#
function set_timezone() {
    timezone=${1:-UTC}

    mv /etc/localtime /etc/localtime.old
    ln -sf /usr/share/timezone/${} /etc/localtime
    echo "Updated timezone to ${timezone}."
}

##
# Add public key to authorized_keys
# param1 - Public key to add to authorized_keys file. This parameter is mandatory.
#          Eg: "ssh-rsa xyzxyzxyzxyz...xyzxyz user@example.com"
# param2 - User for which the public key is added. Defaults to "ec2-user".
#          Eg: "ec2-user", "root" etc.
#
function add_to_authorized_keys() {
    public_key=$1
    username=${2:-ec2-user}

    if [[ $# -eq 0 ]]; then
        echo "Usage: add_to_authorized_keys \"<public_key>\" [username]"
    else
        if [[ ${username} == "root" ]]; then
            auth_keys_file=/root/.ssh/authorized_keys
        else
            auth_keys_file=/home/${username}/.ssh/authorized_keys
        fi
        if [[ -f ${auth_keys_file} ]]; then
            echo "${public_key}" >> ${auth_keys_file}
            echo "Added key to ${auth_keys_file}"
        else
            echo "${auth_keys_file} doesn't exist"
        fi
    fi
}
