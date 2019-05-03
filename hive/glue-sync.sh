#!/bin/bash

source /usr/lib/hustler/bin/qubole-bash-lib.sh
source /usr/lib/qubole/bootstrap-functions/hive/thrift-metastore.sh

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

        hadoop dfs -get s3://paid-qubole/aws_glue_sync/HiveGlueCatalogSyncAgent-1.0-SNAPSHOT-jar-with-dependencies.jar /usr/lib/hive1.2/lib/

        # Add glue sync configurations to hive-site.xml
        # (Refer : https://github.com/awslabs/aws-glue-catalog-sync-agent-for-hive)
        sed -i "s|</property></configuration>|</property><property><name>hive.metastore.event.listeners</name><value>com.amazonaws.services.glue.catalog.HiveGlueCatalogSyncAgent</value></property></configuration>|g" /usr/lib/hive1.2/conf/hive-site.xml
        sed -i "s|</property></configuration>|</property><property><name>glue.catalog.athena.jdbc.url</name><value>jdbc:awsathena://athena.${aws_region}.amazonaws.com:443</value></property></configuration>|g" /usr/lib/hive1.2/conf/hive-site.xml
        sed -i "s|</property></configuration>|</property><property><name>glue.catalog.athena.s3.staging.dir</name><value>${glue_staging_dir}</value></property></configuration>|g" /usr/lib/hive1.2/conf/hive-site.xml

        # Restart metastore
        monit unmonitor metastore1_2
        export OVERRIDE_HADOOP_JAVA_HOME=/usr/lib/jvm/java-1.8.0_60
        restart_thrift_metastore
        monit monitor metastore1_2

        rm /tmp/jdbc.log
    fi
}
