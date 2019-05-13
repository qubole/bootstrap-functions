#!/bin/bash

source /usr/lib/qubole/bootstrap-functions/common/utils.sh
source /usr/lib/qubole/bootstrap-functions/hive/hiveserver2.sh

##
# Install Apache Ranger client for Hive
# Parameters:
# -h: Ranger admin host. Defaults to `localhost`
# -p: Ranger admin port. Defaults to `6080`
# -r: Ranger repository name. Defaults to `hivedev`
#
function install_ranger() {
    populate_nodeinfo
    if [[ is_hs2_configured ]]; then
        HOST=localhost
        PORT=6080
        REPOSITORY_NAME=hivedev
        QBOL_HEALTH_CHECK_USER=qbol_user

        while getopts ":h:p:r:q:" opt; do
            case ${opt} in
                h)
                    HOST=${OPTARG}
                    ;;
                p)
                    PORT=${OPTARG}
                    ;;
                r)
                    REPOSITORY_NAME=${OPTARG}
                    ;;
                \?)
                    echo "Invalid option: -${OPTARG}" >&2
                    return 1
                    ;;
                :)
                    echo "Option -${OPTARG} requires an argument." >&2
                    return 1
                    ;;
            esac
        done

        URL=http://${HOST}:${PORT}
        HIVE_LIB=/usr/lib/hive1.2
        change_java_version "1.8" "1.8"
        mkdir -p /media/ephemeral0/hive_plugin
        pushd /media/ephemeral0/hive_plugin

        # Fetch and extract Ranger Hive plugin
        /usr/lib/hadoop2/bin/hadoop dfs -get s3://paid-qubole/ranger-1.1.0/ranger-1.1.0-hive-plugin.tar.gz
        tar xf ranger-1.1.0-hive-plugin.tar.gz
        cd ranger-1.1.0-hive-plugin
        /usr/lib/hadoop2/bin/hadoop dfs -get s3://paid-qubole/ranger-1.1.0/scripts/hc_user.sh
        chown -R ${USER}:${USER} .
        chmod 755 *.sh *.py

        # Configure install.properties
        sed -i "s#^\(REPOSITORY_NAME=\).*#REPOSITORY_NAME=${REPOSITORY_NAME}#g" install.properties
        sed -i "s#^\(POLICY_MGR_URL=\).*#POLICY_MGR_URL=${URL}#g" install.properties
        sed -i "s#^\(COMPONENT_INSTALL_DIR_NAME=\).*#COMPONENT_INSTALL_DIR_NAME=${HIVE_LIB}#g" install.properties

        # Configure and run enable-hive-plugin.sh
        sed -i "s#^\(HCOMPONENT_INSTALL_DIR=\).*#HCOMPONENT_INSTALL_DIR=${HIVE_LIB}#g" enable-hive-plugin.sh
        ./enable-hive-plugin.sh

        # Update Qubole Health check user
        ./hc_user.sh /usr/lib/hive1.2/bin/test-hs2.sh ${QBOL_HEALTH_CHECK_USER}

        # Copy Ranger files in the expected path
        cp -r /usr/lib/hive1.2/lib/ranger-hive-plugin-impl/* /usr/lib/hive1.2/lib/

        # Restart HS2
        restart_hs2

        popd
        return 0
    else
        echo "Ranger plugin can only be installed on machines where HS2 is configured."
        return 1
    fi
}
