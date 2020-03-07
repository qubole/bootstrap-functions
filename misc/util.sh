#!/bin/bash
#
# @file misc/util.sh
# @brief Provides miscellaneous utility functions

# @description Set the timezone
#
# This function sets the timezone on the cluster node.
# The timezone to set is a mandatory parameter and must be present in /usr/share/zoneinfo
# Eg: "US/Mountain", "America/Los_Angeles" etc.
#
# After setting the timezone, it is advised to restart engine daemons on the master and worker nodes
#
# @example
#   set_timezone "America/Los_Angeles"
#
# @arg $1 string Timezone to set
function set_timezone() {
    timezone=$1

    if [[ $# -eq 0 ]]; then
        echo "Usage: set_timezone <new_timezone>"
    else
        timezone_path="/usr/share/zoneinfo/${timezone}"
        if [[ -f ${timezone_path} ]]; then
            mv -f /etc/localtime /etc/localtime.old
            ln -sf ${timezone_path} /etc/localtime
            echo "Updated timezone to ${timezone}."
        else
            echo "Invalid timezone ${timezone} provided."
        fi
    fi
}

# @description Add a public key to authorized_keys
#
# @example
#   add_to_authorized_keys "ssh-rsa xyzxyzxyzxyz...xyzxyz user@example.com" ec2-user
#
# @arg $1 string Public key to add to authorized_keys file
# @arg $2 string User for which the public key is added. Defaults to `ec2-user`
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
