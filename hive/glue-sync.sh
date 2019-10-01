#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh
source /usr/lib/qubole/bootstrap-functions/hive/hiveserver2.sh

##
# Installs Hive Glue Catalog Sync Agent
# param1 - Region for AWS Athena. Defaults to us-east-1
# Requires Hive 2.x
#
function install_glue_sync() {
    aws_region=${1:-us-east-1}

    is_master=$(nodeinfo is_master)
    hive_version=$(nodeinfo hive_version)
    if [[ ${is_master} == "1" && ${hive_version} == 2* ]]; then
        glue_staging_dir=$(nodeinfo s3_default_location)
        glue_staging_dir="${glue_staging_dir}/query_result"

        /usr/lib/hadoop2/bin/hadoop dfs -get s3://paid-qubole/aws_glue_sync/HiveGlueCatalogSyncAgent-1.1-SNAPSHOT.jar /usr/lib/hive1.2/lib/

        # Add glue sync configurations to hive-site.xml
        # (Refer : https://github.com/awslabs/aws-glue-catalog-sync-agent-for-hive)
        cp /usr/lib/hive1.2/conf/hive-site.xml /usr/lib/hive1.2/conf/hive-site.xml.bak
        xmlstarlet ed --inplace --omit-decl -s '//configuration' -t elem -n "property" -v "" \
            -s '//configuration/property[last()]' -t elem -n "name" -v "hive.metastore.event.listeners" \
            -s '//configuration/property[last()]' -t elem -n "value" -v "com.amazonaws.services.glue.catalog.HiveGlueCatalogSyncAgent" /usr/lib/hive1.2/conf/hive-site.xml

        xmlstarlet ed --inplace --omit-decl -s '//configuration' -t elem -n "property" -v "" \
            -s '//configuration/property[last()]' -t elem -n "name" -v "glue.catalog.athena.jdbc.url" \
            -s '//configuration/property[last()]' -t elem -n "value" -v "jdbc:awsathena://athena.${aws_region}.amazonaws.com:443" /usr/lib/hive1.2/conf/hive-site.xml

        xmlstarlet ed --inplace --omit-decl -s '//configuration' -t elem -n "property" -v "" \
            -s '//configuration/property[last()]' -t elem -n "name" -v "glue.catalog.athena.s3.staging.dir" \
            -s '//configuration/property[last()]' -t elem -n "value" -v "${glue_staging_dir}" /usr/lib/hive1.2/conf/hive-site.xml

        # Restart metastore
        touch /media/ephemeral0/logs/others/hive_glue_jdbc.log
        chmod 777 /media/ephemeral0/logs/others/hive_glue_jdbc.log
        monit unmonitor metastore1_2
        export OVERRIDE_HADOOP_JAVA_HOME=/usr/lib/jvm/java-1.8.0
        /usr/lib/hive1.2/bin/thrift-metastore server stop && sleep 5 && /usr/lib/hive1.2/bin/thrift-metastore server start
        monit monitor metastore1_2
       
        if is_hs2_configured; then
            /usr/lib/hive1.2/bin/hiveserver2-admin stop && sleep 5 && /bin/bash /usr/lib/hive1.2/usr-bin/startHS2.sh
        fi
    fi
}

