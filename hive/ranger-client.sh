#!/bin/bash
#
# @file hive/ranger-client.sh
# @brief Provides function to install Apache Ranger client for Hive

source /usr/lib/qubole/bootstrap-functions/common/utils.sh
source /usr/lib/qubole/bootstrap-functions/hive/hiveserver2.sh

# @description Install Apache Ranger client for Hive
#
# Currently supported only on AWS
# Requires HiveServer2
#
# @example
#   install_ranger -h example.host -p 6080 -r examplerepo
#
# @arg -h string Hostname of Ranger admin. Defaults to `localhost`
# @arg -p int Port where Ranger admin is running. Defaults to `6080`
# @arg -r string Name of Ranger repository. Defaults to `hivedev`
# @arg -S string Hostname of Solr admin. Defaults to `""`
# @arg -P int Port where Solr admin is running. Defaults to `6083`

function install_ranger() {
    populate_nodeinfo
    if [[ is_hs2_configured ]]; then
        HOST=localhost
        PORT=6080
        REPOSITORY_NAME=hivedev
        QBOL_HEALTH_CHECK_USER=qbol_user
        SOLR_HOST=""
        SOLR_PORT=6083
        PLUGIN_VER="1.1.0"
        HIVE_VERSION=$(nodeinfo hive_version)
        if [ "${HIVE_VERSION}" = "2.3" ]; then
            PLUGIN_VER="1.2.0"
        elif [ "${HIVE_VERSION}" = "3.1.1" ]; then
            PLUGIN_VER="2.0.0"
        fi

        while getopts ":h:p:r:S:P:" opt; do
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
                S)
                    SOLR_HOST=${OPTARG}
                    ;;
                P)
                    SOLR_PORT=${OPTARG}
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

        S3_PATH=s3://paid-qubole/ranger-${PLUGIN_VER}
        RANGER_PLUGIN=ranger-${PLUGIN_VER}-hive-plugin
        RANGER_PLUGIN_FILE=${S3_PATH}/${RANGER_PLUGIN}.tar.gz

        change_java_version "1.8" "1.8"
        mkdir -p /media/ephemeral0/hive_plugin
        pushd /media/ephemeral0/hive_plugin

        # Fetch and extract Ranger Hive plugin
        /usr/lib/hadoop2/bin/hadoop dfs -get ${RANGER_PLUGIN_FILE}
        tar -xzf ${RANGER_PLUGIN}.tar.gz
        cd ${RANGER_PLUGIN}
        /usr/lib/hadoop2/bin/hadoop dfs -get ${S3_PATH}/hc_user.sh

        chown -R ${USER}:${USER} .
        chmod 755 *.sh *.py

        # Configure install.properties
        sed -i "s#^\(REPOSITORY_NAME=\).*#REPOSITORY_NAME=${REPOSITORY_NAME}#g" install.properties
        sed -i "s#^\(POLICY_MGR_URL=\).*#POLICY_MGR_URL=${URL}#g" install.properties
        sed -i "s#^\(COMPONENT_INSTALL_DIR_NAME=\).*#COMPONENT_INSTALL_DIR_NAME=${HIVE_LIB}#g" install.properties
        sed -i "s#^\(HCOMPONENT_INSTALL_DIR=\).*#HCOMPONENT_INSTALL_DIR=${HIVE_LIB}#g" enable-hive-plugin.sh
        sed -i "s#POLICY_CACHE_FILE_PATH=/etc#POLICY_CACHE_FILE_PATH=/media/ephemeral0/hive_plugin/data#g" enable-hive-plugin.sh

        # Enable Solr Configure install.properties
        if [[ $SOLR_HOST -ne "" ]]; then
            SPOOL_DIR=/media/ephemeral0/logs/ranger/hive/audit/solr
            SOLR_URL=http://${SOLR_HOST}:${SOLR_PORT}/solr/ranger_audits

            sed -i "s#\(XAAUDIT.SOLR.ENABLE=\).*#XAAUDIT.SOLR.ENABLE=true#g" install.properties
            sed -i "s#\(XAAUDIT.SOLR.URL=\).*#XAAUDIT.SOLR.URL=$SOLR_URL#g" install.properties
            sed -i "s#\(XAAUDIT.SOLR.IS_ENABLED=\).*#XAAUDIT.SOLR.IS_ENABLED=true#g" install.properties
            sed -i "s#\(XAAUDIT.SOLR.SOLR_URL=\).*#XAAUDIT.SOLR.SOLR_URL=$SOLR_URL#g" install.properties
            sed -i "s#\(XAAUDIT.SOLR.FILE_SPOOL_DIR=\).*#XAAUDIT.SOLR.FILE_SPOOL_DIR=${SPOOL_DIR}#g" install.properties
        fi

        # Run enable-hive-plugin.sh
        ./enable-hive-plugin.sh
        chmod -R 777 /media/ephemeral0/hive_plugin/data

        # Update Qubole Health check user
        ./hc_user.sh /usr/lib/hive1.2/bin/test-hs2.sh ${QBOL_HEALTH_CHECK_USER}

        # Copy Ranger files in the expected path
        cp -r /usr/lib/hive1.2/lib/ranger-hive-plugin-impl/* /usr/lib/hive1.2/lib/

        # Restart HS2
        echo "Restarting HS2"
        restart_hs2

        popd
        return 0
    else
        echo "Ranger plugin can only be installed on machines where HS2 is configured."
        return 1
    fi
}
